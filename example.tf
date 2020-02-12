provider "aws" {
  region = "ap-northeast-1"
  access_key = ""
  secret_key = ""
}


variable "instance-type" {
  default = "t2.micro"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

variable "key-name" {
  default = "panda"
}



resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    enable_classiclink = "false"
    instance_tenancy = "default"

    tags = {
        Name = "demo-vpc"
    }
}


resource "aws_subnet" "subnet-public-1" {
    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "ap-northeast-1a"
    tags = {
        Name = "subnet-public-1"
    }
}

//resource "aws_subnet" "subnet-public-2" {
//  cidr_block = "10.0.2.0/24"
//  vpc_id = "${aws_vpc.vpc.id}"
//  map_public_ip_on_launch = "true" //it makes this a public subnet
//    availability_zone = "ap-northeast-1c"
//    tags = {
//        Name = "subnet-public-2"
//    }
//}
//
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags = {
        Name = "igw"
    }
}

resource "aws_route_table" "public-route" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags = {
        Name = "public-crt"
    }
}

//resource "aws_route_table_association" "crta-public-subnet-2" {
//  route_table_id = "${aws_route_table.public-route.id}"
//  subnet_id = "${aws_subnet.subnet-public-2.id}"
//}
//
resource "aws_route_table_association" "crta-public-subnet-1"{
    subnet_id = "${aws_subnet.subnet-public-1.id}"
    route_table_id = "${aws_route_table.public-route.id}"
}

resource "aws_security_group" "ssh" {
    vpc_id = "${aws_vpc.vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh !
        // Do not do it in the production.
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "ssh-allowed"
    }
  ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

}
//
resource "aws_instance" "ec2" {
  ami = "ami-011facbea5ec0363b"
  instance_type = "${var.instance-type}"
  key_name = "${var.key-name}"
  tags = {
    "Name" = "demo-${count.index}"
  }
  security_groups = ["${aws_security_group.ssh.id}"]
  subnet_id = "${aws_subnet.subnet-public-1.id}"
  count = 2


}
////resource "aws_instance" "ec2-1" {
////  ami = "${var.ami}"
////  instance_type = "${var.instance-type}"
////  key_name = "${var.key-name}"
////  tags = {
////    "Name" = "demo1"
////  }
////  security_groups = ["${aws_security_group.ssh.id}"]
////  subnet_id = "${aws_subnet.subnet-public-1.id}"
////
////
////}
////resource "aws_instance" "ec2-2" {
////  ami = "${var.ami}"
////  instance_type = "${var.instance-type}"
////  key_name = "${var.key-name}"
////  tags = {
////    "Name" = "demo2"
////  }
////  security_groups = ["${aws_security_group.ssh.id}"]
////  subnet_id = "${aws_subnet.subnet-public-1.id}"
////
////
////}
//
////resource "aws_s3_bucket" "bucket" {
////  bucket = "3ri.teraform.demo"
////}
//
////resource "aws_elb" "bar" {
////  name               = "foobar-terraform-elb"
////  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
////
////
////  listener {
////    instance_port     = 80
////    instance_protocol = "http"
////    lb_port           = 80
////    lb_protocol       = "http"
////  }
////
////
////  health_check {
////    healthy_threshold   = 2
////    unhealthy_threshold = 2
////    timeout             = 3
////    target              = "HTTP:80/"
////    interval            = 30
////  }
////
////  instances                   = ["${aws_instance.ec2.id}"]
////  cross_zone_load_balancing   = true
////  idle_timeout                = 400
////  connection_draining         = true
////  connection_draining_timeout = 400
////
////  tags = {
////    Name = "cd-elb"
////  }
////}
//
//output "instance_ip" {
//  value = "${aws_instance.ec2.public_ip}"
//}