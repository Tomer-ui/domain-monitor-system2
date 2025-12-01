provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg_final"
  description = "Allow SSH, Jenkins UI, and JNLP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins_master" {
  ami           = "ami-0f5fcdfbd140e4ab7" # Ubuntu 24.04
  instance_type = "t3.micro"
  key_name      = "my-key"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  root_block_device { volume_size = 15 }
  tags = { Name = "Jenkins-Master" }
}

resource "aws_instance" "jenkins_node" {
  ami           = "ami-0f5fcdfbd140e4ab7"
  instance_type = "t3.micro"
  key_name      = "my-key"
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  root_block_device { volume_size = 15 }
  tags = { Name = "Jenkins-Node" }
}