### MANDATORY ###
variable "role_tag" {
  description = "Role of the ec2 instance, defaults to <SERVICE>"
  default = "SERVICE"
}

variable "environment_tag" {
  description = "Role of the ec2 instance, defaults to <DEV>"
  default = "DEV"
}

variable "costcenter_tag" {
  description = "Role of the ec2 instance, defaults to <DEV>"
  default = "DEV"
}

# group our resources
variable "stream_tag" {
  default = "default"
}

variable "environment" {
  default = "default"
}

variable "name" {
  default = "kibana"
}

###################################################################
# AWS configuration below
###################################################################
variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "kibana"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "ap-southeast-2"
}

variable "availability_zones" {
  description = "AWS region to launch servers."
  default = "ap-southeast-2a,ap-southeast-2b"
}

variable "security_group_name" {
  description = "Name of security group to use in AWS."
  default = "kibana"
}

###################################################################
# Vpc configuration below
###################################################################

### MANDATORY ###
variable "vpc_id" {
  description = "VPC id"
}

variable "internal_cidr_blocks"{
  default = "0.0.0.0/0"
}

###################################################################
# Subnet configuration below
###################################################################

### MANDATORY ###
variable "subnets" {
  description = "subnets to deploy into"
}

###################################################################
# Kibana configuration below
###################################################################

variable "kibana_version" {
  description = "Kibana version"
  default = "4.5"
}

### MANDATORY ###
variable "ami" {
}

variable "instance_type" {
  description = "Kibana instance type."
  default = "t2.micro"
}

# total number of nodes
variable "instances" {
  description = "total instances"
  default = "1"
}

# the ability to add additional existing security groups. In our case
# we have consul running as agents on the box
variable "additional_security_groups" {
  default = ""
}

###################################################################
# Consul configuration below
###################################################################
variable "consul_version" {
  default = "0.6.4"
}

variable "dns_server" {
}

variable "consul_dc" {
  default = "dev"
}

variable "atlas" {
  default = "example/atlas"
}

variable "atlas_token" {
}
