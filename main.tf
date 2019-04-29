# Backend Initialization using command line

terraform {
 backend "s3" {
   key = "loadbalancers.tfstate"
 }
}

locals {

}

# Initializing the provider

# Following properties need to be set for this to work
# export AWS_ACCESS_KEY_ID="anaccesskey"
# export AWS_SECRET_ACCESS_KEY="asecretkey"
# export AWS_DEFAULT_REGION="us-west-2"
# terraform plan
provider "aws" {}


data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    key = "network.tfstate"
    bucket = "${var.backend_s3_bucket_name}"
  }
}

# Creating the AMI Admin Target group
resource "aws_alb_target_group" "ecs-ami-if-admin" {
  name     = "ecs-ami-if-admin"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.network.vpc_id}"
  target_type = "ip"
  tags = "${var.default_aws_tags}"
}

# resource "aws_alb_target_group" "ecs-ami-if-icm" {
#   name     = "ecs-ami-if-admin"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = "${data.terraform_remote_state.network.vpc_id}"
#   target_type = "ip"
# }

# resource "aws_alb_target_group" "ecs-ami-if-notifications" {
#   name     = "ecs-ami-if-admin"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = "${data.terraform_remote_state.network.vpc_id}"
#   target_type = "ip"
# }

# Creating the AMI Loadbalancer
resource "aws_alb" "ami-if" {
  name            = "alb-ami-if"
  subnets         = ["${data.terraform_remote_state.network.private_subnets}"]
  security_groups = ["${data.terraform_remote_state.network.default_security_group_id}","${data.terraform_remote_state.network.web_security_group_id}"]
  tags = "${var.default_aws_tags}"
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.ami-if.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-ami-if-admin.id}"
    type             = "forward"
  }
  tags = "${var.default_aws_tags}"
}
