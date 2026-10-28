# ==========================================
# Product Catalog - Terraform Outputs
# Region: ap-southeast-2
# ==========================================

# AWS Region
output "aws_region" {
  description = "AWS deployment region"
  value       = "ap-southeast-2"
}

# ==========================================
# VPC and Networking
# ==========================================

output "vpc_id" {
  description = "Product Catalog VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes"
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

# ==========================================
# EKS Cluster
# ==========================================

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  description = "EKS Kubernetes API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version"
  value       = aws_eks_cluster.main.version
}

output "eks_cluster_oidc_issuer" {
  description = "EKS OIDC issuer URL"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# ==========================================
# EKS Node Group
# ==========================================

output "eks_node_group_name" {
  description = "Managed node group name"
  value       = aws_eks_node_group.main.node_group_name
}

# ==========================================
# IAM Roles
# ==========================================

output "eks_cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  description = "EKS worker node IAM role ARN"
  value       = aws_iam_role.eks_node_role.arn
}

# ==========================================
# ECR
# ==========================================

output "ecr_repository_url" {
  description = "Product Catalog ECR repository URL"
  value       = aws_ecr_repository.product_catalog.repository_url
}