# Creating EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = var.master_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = [var.public_subnet_az1_id, var.public_subnet_az2_id]
  }

  tags = {
    key   = var.env
    value = var.type
  }
}

# Using Data Source to get all Avalablility Zones in Region
data "aws_availability_zones" "available_zones" {}

# Fetching Ubuntu 20.04 AMI ID
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Creating kubectl server
resource "aws_instance" "kubectl-server" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_size
  associate_public_ip_address = true
  subnet_id                   = var.public_subnet_az1_id
  vpc_security_group_ids      = [var.eks_security_group_id]

  tags = {
    Name = "${var.cluster_name}-kubectl"
    Env  = var.env
    Type = var.type
  }
}

# Creating Launch Template for Worker Nodes
resource "aws_launch_template" "worker-node-launch-template" {
  name = "worker-node-launch-template"
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  image_id      = var.image_id
  instance_type = "t2.micro"
  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="
--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
/etc/eks/bootstrap.sh prod-cluster
--==MYBOUNDARY==--\
  EOF
)


  vpc_security_group_ids = [var.eks_security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Worker-Nodes"
    }
  }
}

# Creating Worker Node Group
resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "Worker-Node-Group"
  node_role_arn   = var.worker_arn
  subnet_ids      = [var.public_subnet_az1_id, var.public_subnet_az2_id]

  launch_template {
    name    = aws_launch_template.worker-node-launch-template.name
    version = aws_launch_template.worker-node-launch-template.latest_version
  }

  labels = {
    env = "Prod"
  }

  scaling_config {
    desired_size = var.worker_node_count
    max_size     = var.worker_node_count
    min_size     = var.worker_node_count
  }

  update_config {
    max_unavailable = 1
  }
}

locals {
  eks_addons = {
    "vpc-cni" = {
      version           = var.vpc-cni-version
      resolve_conflicts = "OVERWRITE"
    },
    "kube-proxy" = {
      version           = var.kube-proxy-version
      resolve_conflicts = "OVERWRITE"
    }
  }
}

# Creating the EKS Addons
resource "aws_eks_addon" "example" {
  for_each = local.eks_addons

  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_update = each.value.resolve_conflicts
}