provider "aws" {
  access_key = "**"
  secret_key = "**"
  region     = "ap-south-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0620d12a9cf777c87"
  instance_type = "t2.micro"
  key_name      = "AWSEC2"
  
}

