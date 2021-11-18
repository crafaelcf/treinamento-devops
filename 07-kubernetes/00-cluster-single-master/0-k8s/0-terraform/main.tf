provider "aws" {
  region = "us-east-2"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com" # outra opção "https://ifconfig.me"
}

resource "aws_subnet" "my_subnet_c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "171.31.0.0/16"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1a-fernandes"
  }
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "171.31.0.0/16"

  tags = {
    Name = "treinamento-fernandes2"
  }
}

resource "aws_instance" "maquina_master" {
  ami = "ami-0629230e074c580f2"
  #subnet_id =  "${aws_subnet.my_subnet_c.id}"
  #subnet_id     = "subnet-061ee529ff557a85d"
  associate_public_ip_address = "true"
  instance_type = "t2.medium"
  key_name      = "chave_privada2"
  

  root_block_device {
    encrypted   = true
    volume_size = 8
  }
  tags = {
    Name = "k8s-master"
  }
  vpc_security_group_ids = ["${aws_security_group.acessos_master_single_master.id}"]
  depends_on = [
    aws_instance.workers,
  ]
}

resource "aws_instance" "workers" {
  ami = "ami-0629230e074c580f2"
  #subnet_id  =  "${aws_subnet.my_subnet_c.id}"
  #subnet_id     = "subnet-061ee529ff557a85d"
  associate_public_ip_address = "true"
  instance_type = "t2.medium"
  key_name      = "chave_privada2"

  tags = {
    Name = "k8s-node-${count.index + 1}"
  }
  vpc_security_group_ids = ["${aws_security_group.acessos_workers_single_master.id}"]
  count                  = 3
}

resource "aws_security_group" "acessos_master_single_master" {
  name        = "acessos_master_single_master"
  description = "acessos_master_single_master inbound traffic"

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
    # coloquei depois para subir minha aplicação
        {
      description      = "SSH from VPC"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups = [
        #"${aws_security_group.acessos_workers_single_master.id}",
        "sg-0aafb41b49828090b"
      ]
      self    = false
      to_port = 0
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 65535
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "acessos_master_single_master"
  }
}


resource "aws_security_group" "acessos_workers_single_master" {
  name        = "acessos_workers_single_master"
  description = "acessos_workers_single_master inbound traffic"

  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups = [
        "${aws_security_group.acessos_master_single_master.id}",
      ]
      self    = false
      to_port = 0
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "acessos_workers_single_master"
  }
}




# terraform refresh para mostrar o ssh
output "maquina_master" {
  value = [
    "master - ${aws_instance.maquina_master.public_ip} - ssh -i ~/.ssh/chave_privada2.pem ubuntu@${aws_instance.maquina_master.public_dns}"
  ]
}

# terraform refresh para mostrar o ssh
output "maquina_workers" {
  value = [
    for key, item in aws_instance.workers :
    "worker ${key + 1} - ${item.public_ip} - ssh -i ~/.ssh/chave_privada2.pem ubuntu@${item.public_dns}"
  ]
}