######## LOAD BALACE FOR BEAN STALK ########

resource "aws_security_group" "vprofile-bean-elb-sg" {
  name        = "vprofile-bean-elb-sg"
  description = "security group for bean-elb"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]

  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]

  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "vprofile-bean-elb-sg"
  }
}



####### BASTION HOST ########

resource "aws_security_group" "vprofile-bastion-sg" {
  name        = "vprofile-bastion-sg"
  description = "security group for bastionisoner ec2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "vprofile-bastion-sg"
  }
}

####### BEAN STALK EC2 INSTANCE ########

resource "aws_security_group" "vprofile-prod-sg" {
  name        = "vprofile-prod-sg"
  description = "security group for bean stalk ec2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "SSH from Bastion hosts"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile-bastion-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "vprofile-prod-sg"
  }
}


####### ACTIVE MQ ########

resource "aws_security_group" "vprofile-backend-sg" {
  name        = "vprofile-backend-sg"
  description = "security group for RDS, active mq, elastic cache"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.vprofile-prod-sg.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.vprofile-bastion-sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "vprofile-backend-sg"
  }
}

####### ALLOWING SERVICES IN BACKEND TO COMMUNICATE WITH EACH OTHER ########

resource "aws_security_group_rule" "sec_group_allow_itself" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vprofile-backend-sg.id
  source_security_group_id = aws_security_group.vprofile-backend-sg.id
}