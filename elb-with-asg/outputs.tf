output "loadbalancer_url" {
  value = aws_elb.rackspace-elb.dns_name
}
