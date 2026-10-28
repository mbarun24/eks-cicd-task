# ==========================================
# EKS Managed Add-ons
# Project: Product Catalog
# Region: ap-southeast-2
# ==========================================

# 1. Amazon VPC CNI
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Name = "product-catalog-vpc-cni"
  }
}

# 2. CoreDNS
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.main
  ]

  tags = {
    Name = "product-catalog-coredns"
  }
}

# 3. kube-proxy
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"

  tags = {
    Name = "product-catalog-kube-proxy"
  }
}

# 4. EKS Pod Identity Agent
resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [
    aws_eks_node_group.main
  ]

  tags = {
    Name = "product-catalog-pod-identity"
  }
}