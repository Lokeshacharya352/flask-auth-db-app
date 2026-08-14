output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_security_group_id" {
  description = "EKS-managed security group shared by the control plane and worker nodes (since no custom SG was set on the node group). This is what RDS should allow inbound access from."
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider, needed to build IRSA trust policies for IAM roles (e.g. AWS Load Balancer Controller)"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL (without https://), used in IRSA trust policy conditions"
  value       = replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
}