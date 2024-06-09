cluster_name       = "prod-cluster"
instance_count     = 3
instance_size      = "t2.micro"
region             = "us-west-2"
cluster_version    = "1.29" # 1.29
ami_id             = "ami-0ef5558292b11416e" #ami-0ef5558292b11416e
vpc-cni-version    = "v1.18.2-eksbuild.1" #v1.18.2-eksbuild.1
kube-proxy-version = "v1.29.3-eksbuild.5" #v1.29.3-eksbuild.5