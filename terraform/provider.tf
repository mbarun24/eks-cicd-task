terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"

}
provider "helm" {
  kubernetes = {
    host = aws_eks_cluster.main.endpoint

    cluster_ca_certificate = base64decode(
      aws_eks_cluster.main.certificate_authority[0].data
    )

    exec = {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"

      args = [
        "eks",
        "get-token",
        "--cluster-name",
        aws_eks_cluster.main.name,
        "--region",
        "ap-southeast-2"
      ]
    }
  }
}