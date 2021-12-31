output "nginx-server" {
  value = "http://${aws_instance.nginx-server.0.public_ip}"
}