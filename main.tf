provider "aws" {
  region     = "eu-north-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "MainSubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainIGW"
  }
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "MainRouteTable"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_rt.id
}

resource "aws_security_group" "main_sg" {
  name        = "main_sg"
  description = "Allow SSH, HTTP and HTTPS"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MainSecurityGroup"
  }
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "my_key"
  public_key = file("/home/adminsys/.ssh/my_key.pub")
  tags = {
    Name = "DeployerKey"
  }
}

resource "aws_s3_bucket" "nextcloud_data" {
  bucket = "nextcloud-data-${random_id.suffix.hex}"
 

  tags = {
    Name        = "NextcloudData"
    Environment = "prod"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_iam_role" "ec2_access_role" {
  name               = "ec2_access"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
EOF
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy for EC2 to access S3"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:PutObject", "s3:ListBucket"],
    "Resource": [
      "${aws_s3_bucket.nextcloud_data.arn}",
      "${aws_s3_bucket.nextcloud_data.arn}/*"
    ]
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.ec2_access_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "S3AccessProfile"
  role = aws_iam_role.ec2_access_role.name
}

resource "aws_instance" "project" {
  count                       = var.instance_count
  ami                         = "ami-0c1ac8a41498c1a9c"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.main_subnet.id
  private_ip                  = "${var.private_ip_base}.${count.index + 10}"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.main_sg.id]
  key_name                    = aws_key_pair.deployer_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.s3_access_profile.name
  tags = {
    Name = "${var.instance_names[count.index]}"
  }
}