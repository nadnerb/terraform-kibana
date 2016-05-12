provider "aws" {
  region = "${var.aws_region}"
}

##############################################################################
# Kibana
##############################################################################

resource "aws_security_group" "kibana" {
  name = "${var.security_group_name}-kibana"
  description = "Kibana ports with ssh"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.internal_cidr_blocks)}"]
  }

  ingress {
    from_port = 5601
    to_port = 5601
    protocol = "tcp"
    cidr_blocks = ["${split(",", var.internal_cidr_blocks)}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "kibana"
    stream = "${var.stream_tag}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "template_file" "user_data" {
  template = "${file("${path.root}/templates/user-data.tpl")}"

  vars {
    kibana_version          = "${var.kibana_version}"
    dns_server              = "${var.dns_server}"
    consul_dc               = "${var.consul_dc}"
    atlas                   = "${var.atlas}"
    atlas_token             = "${var.atlas_token}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "kibana" {
  name_prefix = "kibana-"
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups = ["${split(",", replace(concat(aws_security_group.kibana.id, ",", var.additional_security_groups), "/,\\s?$/", ""))}"]
  associate_public_ip_address = false
  ebs_optimized = false
  key_name = "${var.key_name}"
  user_data = "${template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kibana" {
  availability_zones = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier = ["${split(",", var.subnets)}"]
  max_size = "${var.instances}"
  min_size = "${var.instances}"
  desired_capacity = "${var.instances}"
  default_cooldown = 30
  force_delete = true
  launch_configuration = "${aws_launch_configuration.kibana.id}"

  tag {
    key = "Name"
    value = "${format("kibana-%s", var.environment)}"
    propagate_at_launch = true
  }
  tag {
    key = "Stream"
    value = "${var.stream_tag}"
    propagate_at_launch = true
  }
  tag {
    key = "ServerRole"
    value = "Monitoring"
    propagate_at_launch = true
  }
  tag {
    key = "Cost Center"
    value = "${var.costcenter_tag}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.environment_tag}"
    propagate_at_launch = true
  }
  tag {
    key = "consul"
    value = "agent"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

