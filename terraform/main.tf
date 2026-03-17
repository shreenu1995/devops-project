provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "k8s_nodes" {
  count         = 3
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.small"
  key_name      = "jenkins"

  tags = {
    Name = "k8s-node-${count.index}"
  }
}

output "public_ips" {
  value = aws_instance.k8s_nodes[*].public_ip
}
