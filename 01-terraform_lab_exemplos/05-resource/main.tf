
# criando máquina na AWS de forma automatica
# ///////// do fernando zerati //////
provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "web" {
  count = 1
  subnet_id     = "subnet-061ee529ff557a85d"
  ami= "ami-0629230e074c580f2"
  instance_type = "t2.micro"
  associate_public_ip_address = true  
  root_block_device {
    encrypted = true
    volume_size = 8
  }
  tags = {
    Name = "ec2-fernandes-tf-${(count.index+1)}"
  }
}







# https://www.terraform.io/docs/language/values/outputs.html
output "instance_public_dns" {
  value = [
      aws_instance.web[0].public_ip, 
      aws_instance.web[0].private_ip,
      "ssh -i C:/Users/rafae/.ssh/chave_privada2.pem ubuntu@${aws_instance.web.public_ip}"
  ]
  description = "Mostra o DNS e os IPs publicos e privados da maquina criada."
}