# eks-cluster/lbc-irsa.tf
#
# Sets up IRSA (IAM Roles for Service Accounts) for the AWS Load Balancer
# Controller: an IAM role that ONLY the "aws-load-balancer-controller"
# ServiceAccount in the kube-system namespace can assume, scoped to exactly
# the permissions the controller needs (via AWS's official policy doc).

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy-${var.cluster_name}"
  description = "Permissions required by the AWS Load Balancer Controller"
  policy      = file("${path.module}/iam/iam-policy.json")
}

resource "aws_iam_role" "alb_controller" {
  name = "${var.cluster_name}-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
            "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

output "alb_controller_role_arn" {
  description = "IAM role ARN for the aws-load-balancer-controller ServiceAccount"
  value       = aws_iam_role.alb_controller.arn
}