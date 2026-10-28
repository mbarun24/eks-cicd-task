resource "aws_eks_access_entry" "console_role" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::245716172720:role/managed/AccountFullAccessRole"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "console_view" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.console_role.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy"

  access_scope {
    type = "cluster"
  }
}