provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "web" {
  ami           = "ami-0629230e074c580f2"
  instance_type = "t2.micro"
  key_name = "chave_privada2" # Nome da Key gerada pelo ssk-keygem e upada na AWS
  tags = {
    Name = "Minha Maquina Simples EC2"
  }
  
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
}

output "instance_public_dns" {
  value = [
    aws_instance.web.public_ip,
    aws_instance.web.private_ip,
    aws_instance.web.public_dns,
    "ssh -i C:/Users/rafae/.ssh/chave_privada2.pem ubuntu@${aws_instance.web.public_ip}"
  ]
  description = "Mostra o DNS e os IPs publicos e privados da maquina criada."
}