output "elb_dns_name" {
  value = aws_elb.indexer_elb.dns_name
}

output "splunk_cluster_master_public_ip" {
  value = [aws_instance.splunk_cluster_master.*.public_ip]
}

output "splunk_search_head_deployer_public_ip" {
  value = [aws_instance.splunk_search_head_deployer.*.public_ip]
}