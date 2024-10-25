cluster_name       = "prod-cluster"
instance_count     = 3
instance_size      = "t2.micro"
region             = "us-west-2"
cluster_version    = "1.31" # 1.30
ami_id             = "ami-0814107b27da9b379" #ami-0cfd96d646e5535a8
vpc-cni-version    = "v1.18.5-eksbuild.1" #v1.18.2-eksbuild.1
kube-proxy-version = "v1.31.0-eksbuild.5" #v1.29.3-eksbuild.5