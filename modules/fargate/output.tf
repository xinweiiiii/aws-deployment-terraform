output "ALB" {
    value = "${aws_alb.application_load_balancer.arn}"
}

output "ALB_DNS" {
    value = "${aws_alb.application_load_balancer.dns_name}"
}
