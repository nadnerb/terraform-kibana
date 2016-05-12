output "launch_configuration" {
  value = "${aws_autoscaling_group.kibana.launch_configuration}"
}
