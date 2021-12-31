# Terraform + Ansible + AWS (Project-6)

I started this project over the weekend where I created an AWS account and began diving into cloud infrastructure and Terraform.

With my Terraform code so far, I've deployed cloud infrastructure to AWS with Red Hat and Ubuntu EC2 instances, configured VPCs, subnets, routing tables, internet gateways, and security groups to allow ingress on ports 22, 80, and 443. Initially I had Terraform run a bash script to install, configure, and start an apache web server. I'm using key pairs for both the AWS account's IAM admin user and SSH. I'm mainly doing this via WSL Remote in VS Code.

I was then challenged to do the same thing as above, but using Ansible to install and configure the web server instead of the bash script. I also opted for nginx instead of apache. Initially I struggled to get Terraform to dynamically create and update the Ansible inventory file with the host information that isn't known until deployment.