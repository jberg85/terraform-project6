resource "aws_key_pair" "main-key" {
  key_name   = "main-key"
  public_key = "${file(var.public_key)}"
}

/*
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  enable_classiclink   = "false"

  tags = {
    Name = "VPC"
  }
}
*/

resource "aws_instance" "nginx-server" {
  count = "${var.instance_count}"
  ami           = "${var.ami}"
  instance_type = "${var.instance}"
  key_name      = "${aws_key_pair.main-key.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.web.id}",
    "${aws_security_group.ssh.id}",
    "${aws_security_group.egress-tls.id}",
    "${aws_security_group.ping-ICMP.id}",
	  "${aws_security_group.web_server.id}"
  ]

  connection {
    private_key = "${file(var.private_key)}"
    user        = "${var.ansible_user}"
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo apt-get -qq install python3.9 -y"]
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
	  >nginx.ini;
	  echo "[nginx]" | tee -a nginx.ini;
	  echo "${aws_instance.nginx-server[0].public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a nginx.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
	  ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i nginx.ini ../playbooks/install_nginx.yaml
    EOT
  }

  tags = {
    Name     = "nginx-server-${count.index +1 }"
  }
}

resource "aws_security_group" "web" {
  name        = "default-web"
  description = "Security group for web that allows web traffic from internet"
  #vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-default-vpc"
  }
}

resource "aws_security_group" "ssh" {
  name        = "default-ssh"
  description = "Security group for nat instances that allows SSH and VPN traffic from internet"
  #vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-default-vpc"
  }
}

resource "aws_security_group" "egress-tls" {
  name        = "default-egress-tls"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  #vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "egress-tls-default-vpc"
  }
}

resource "aws_security_group" "ping-ICMP" {
  name        = "default-ping"
  description = "Default security group that allows to ping the instance"
  #vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ping-ICMP-default-vpc"
  }
}

resource "aws_security_group" "web_server" {
  name        = "default-web_server"
  description = "Default security group that allows to use port 8080"
  #vpc_id      = "${aws_vpc.vpc.id}"
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_server-default-vpc"
  }
}
