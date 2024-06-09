# Create Security Group for the EKS  
resource "aws_security_group" "eks_security_group" {
  name   = "Worker node security group"
  vpc_id = var.vpc_id

  ingress {
    description = "All access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-EKS-security-group"
    Env  = var.env
    Type = var.type
  }
}