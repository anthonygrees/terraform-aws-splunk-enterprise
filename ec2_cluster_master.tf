########
#
# Cluster Master
#
########
resource "aws_instance" "splunk_cluster_master" {
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "t3.medium"
  key_name                = var.aws_key_pair_name
  availability_zone       = "${var.aws_region}${var.aws_availability_zone_a}"
  vpc_security_group_ids  = [aws_security_group.ssh.id, aws_security_group.splunk.id]
  subnet_id               = aws_subnet.public_a.id

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags = {
    Name          = "splunk-cluster-master"
  }

  connection {
    user        = "ubuntu"
    private_key = file(var.aws_key_pair_file)
    #host        = self.public_ip
    host        = coalesce(self.public_ip, self.private_ip)
    agent       = true
    type        = "ssh"
  }

  provisioner "file" {
    content     = templatefile("${path.module}/templates/linux_node_user_data.sh.tpl", { splunk_password = var.splunk_password })
    destination = "/tmp/linux_node_user_data.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/linux_node_user_data.sh"
    ]
  }

}