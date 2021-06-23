#
# Search Heads - Launch Config
#

locals {
  sh_vars = {
    splunk_password = var.splunk_password
  }
}

resource "aws_launch_configuration" "sh" {
  name_prefix                 = "search_head-"
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = var.aws_key_pair_name
  security_groups             = [aws_security_group.ssh.id, aws_security_group.splunk.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/indexers_user_data.sh.tpl", local.sh_vars)

  lifecycle {
    create_before_destroy = true
  }
}
#
# Load Balancer
#
resource "aws_security_group" "elb_sh" {
  name        = "elb_sh"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id = aws_vpc.splunk_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP through ELB Security Group"
  }
}

resource "aws_elb" "sh_elb" {
  name = "sh-elb"
  security_groups = [
    aws_security_group.elb_sh.id
  ]
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  cross_zone_load_balancing   = true

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 10 #4
    timeout = 60 #3
    interval = 300 #30
    target = "HTTP:8000/"
  }

  listener {
    lb_port = 8000
    lb_protocol = "http"
    instance_port = "8000"
    instance_protocol = "http"
  }

}
#
# Search Heads - Auto Scaling Group
#
resource "aws_autoscaling_group" "sh" {
  name = "${aws_launch_configuration.sh.name}-asg"

  min_size             = 3
  desired_capacity     = 3
  max_size             = 3
  
  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.sh_elb.id
  ]

  launch_configuration = aws_launch_configuration.sh.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier  = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "splunk_search_heads"
    propagate_at_launch = true
  }
}