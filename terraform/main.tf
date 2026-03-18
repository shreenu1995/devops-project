provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "k8s_nodes" {
  count         = 3
  ami           = "ami-0f559c3642608c138"
  instance_type = "t2.medium"
  key_name      = "jenkins"

  tags = {
    Name = "k8s-node-${count.index}"
  }
}

output "public_ips" {
  value = aws_instance.k8s_nodes[*].public_ip
}
