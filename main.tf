//provider "aws" {
//  region = "ap-northeast-1"
//  profile = "3ri"
//}
//
//variable "bucket-name" {
//  default = "panda.3ri"
//}
//variable "acl" {
//  default = "public-read"
//}
//
//data "aws_ami" "ubuntu" {
//  most_recent = true
//  owners = ["099720109477"]
//
//  filter {
//    name   = "name"
//    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
//  }
//}
//
//
//resource "aws_s3_bucket" "bucket" {
//  bucket = "${var.bucket-name}"
//  acl = "${var.acl}"
//}
//
//
//
//resource "aws_instance" "instance" {
//  ami = "${data.aws_ami.ubuntu.image_id}"
//  instance_type = "t2.micro"
//}
//
//output "bucket_arn" {
//  value = "${aws_s3_bucket.bucket.arn}"
//}
//
//output "ec2_public_ip" {
//  value = "${aws_instance.instance.public_ip}"
//}
