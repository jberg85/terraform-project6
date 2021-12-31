variable "profile" {
  default = "Administrator"
}

variable "region" {
  default = "us-east-2"
}

variable "instance" {
  default = "t2.micro"
}

variable "instance_count" {
  default = "1"
}

variable "public_key" {
  default = "~/.ssh/main-key.pub"
}

variable "private_key" {
  default = "~/.ssh/main-key.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}

variable "ami" {
  default = "ami-0fb653ca2d3203ac1"
}
