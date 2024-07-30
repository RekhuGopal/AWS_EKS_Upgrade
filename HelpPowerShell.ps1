$kubernetesVersion = "1.30"
$jsonOutput = eksctl utils describe-addon-versions --kubernetes-version $kubernetesVersion 
$jsonOutput > result.json

# aws eks update-kubeconfig --name prod-cluster
# kubectl port-forward svc/nginx-service 8080:80