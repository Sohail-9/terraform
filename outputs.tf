output "cluster_id" {
  description = "EKS cluster name"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_data" {
  description = "Base64 encoded cluster CA cert"
  value       = module.eks.cluster_certificate_authority_data
}

output "kubeconfig_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_id} --region ${var.aws_region}"
}
output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "kubeconfig_note" {
  value = "Run 'aws eks update-kubeconfig --name ${module.eks.cluster_id} --region ${var.aws_region}' to configure kubectl."
}
