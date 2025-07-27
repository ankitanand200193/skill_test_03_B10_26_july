provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gateway"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2_sg" {
  name        = "allow_ssh_docker"
  description = "Allow SSH and ports 3000-3004"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Docker App Ports"
    from_port   = 3000
    to_port     = 3004
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_instance" "docker_host" {
  ami                    = "ami-0f918f7e67a3323f0" # Ubuntu 22.04 in ap-south-1
  instance_type          = "t3.medium"            # <--- updated here
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name               = "AnkitAnandHeroViredB10"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("C:/Users/Ankit Anand/Downloads/AnkitAnandHeroViredB10.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "sudo apt-get update -y && sudo apt-get upgrade -y",
      "sudo apt-get install -y ca-certificates curl gnupg unzip lsb-release",
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo systemctl enable docker && sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",

      "sudo docker pull ankit200193/frontend:latest",
      "sudo docker pull ankit200193/user-service:latest",
      "sudo docker pull ankit200193/product-service:latest",
      "sudo docker pull ankit200193/cart-service:latest",
      "sudo docker pull ankit200193/order-service:latest",

      "sudo docker run -d --rm -p 3001:3001 -e PORT=3001 -e MONGODB_URI=mongodb+srv://username:password@cluster0.ou9e6.mongodb.net/ecommerce_users ankit200193/user-service:latest"
      "sudo docker run -d --rm -p 3002:3002 -e PORT=3002 -e MONGODB_URI=mongodb+srv://username:password@cluster0.ou9e6.mongodb.net/ecommerce_products ankit200193/product-service:latest"
      "sudo docker run -d --rm -p 3003:3003 -e PORT=3003 -e MONGODB_URI=mongodb+srv://username:password@cluster0.ou9e6.mongodb.net/ecommerce_carts -e PRODUCT_SERVICE_URL=http://13.234.202.151:3002 ankit200193/cart-service:latest"

      "sudo docker run -d --rm -p 3004:3004 -e PORT=3004 -e MONGODB_URI=mongodb+srv://username:password@cluster0.ou9e6.mongodb.net/ecommerce_orders -e CART_SERVICE_URL=http://EC2_IP:3003 -e PRODUCT_SERVICE_URL=http://13.234.202.151:3002 -e USER_SERVICE_URL=http://EC2_IP:3001 ankit200193/order-service:latest"

      "sudo docker run -d --rm -p 3000:3000 -e PORT=3000 -e REACT_APP_USER_SERVICE_URL=http://EC2_IP:3001 -e REACT_APP_PRODUCT_SERVICE_URL=http://EC2_IP:3002 -e REACT_APP_CART_SERVICE_URL=http://EC2_IP:3003 -e REACT_APP_ORDER_SERVICE_URL=http://EC2_IP:3004 ankit200193/frontend:latest"
    ]
  }

  tags = {
    Name = "docker-app-server"
  }
}
