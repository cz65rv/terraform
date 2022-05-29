################## Load balancer resource block #######################

resource "aws_elb" "rackspace-elb" {
  name                      = "rackspace-elb"
  subnets                   = aws_subnet.pub-subnet.*.id
  security_groups           = [aws_security_group.elb-sg.id]
  cross_zone_load_balancing = true
  
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}

################ Launch configuration for ASG ####################

resource "aws_launch_configuration" "rackspace-host-lc" {
  name_prefix                 = "${var.asg-name}-"
  image_id                    = data.aws_ami.latest-ubuntu1.id
  instance_type               = var.machine-type
  key_name                    = var.ssh-key
  security_groups             = [aws_security_group.pvt-sg.id]
  user_data                   = "${file("webserver.sh")}"
  associate_public_ip_address = false
    
  lifecycle {
    create_before_destroy = true
  }
}

############### Auto scaing group resource block ######################

resource "aws_autoscaling_group" "asg" {
  name                 = "${aws_launch_configuration.rackspace-host-lc.name}-asg"
  min_size             = var.min-size
  desired_capacity     = var.desire-size
  max_size             = var.max-size
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.rackspace-elb.id]
  launch_configuration = aws_launch_configuration.rackspace-host-lc.name
  vpc_zone_identifier  = aws_subnet.pvt-subnet.*.id
  
  metrics_granularity  = "1Minute"
  
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.asg-name}-demo"
    propagate_at_launch = true
    }
}

############### AMI Data Source to pull latest Ubuntu AMI ##################
data "aws_ami" "latest-ubuntu1" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}