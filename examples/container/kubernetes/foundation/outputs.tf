output "k8s_cluster_arn" {
  description = "Unique identifier of the Kubernetes cluster"
  value       = module.k8s_foundation.k8s_cluster_arn
}

output "k8s_cluster_fqn" {
  description = "Fully qualified name of the Kubernetes cluster"
  value       = module.k8s_foundation.k8s_cluster_fqn
}
