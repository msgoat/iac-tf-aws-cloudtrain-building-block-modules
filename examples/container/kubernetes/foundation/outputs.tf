output "k8s_cluster_id" {
  description = "Unique identifier of the Kubernetes cluster"
  value       = module.k8s_foundation.k8s_cluster_id
}

output "k8s_cluster_fqn" {
  description = "Fully qualified name of the Kubernetes cluster"
  value       = module.k8s_foundation.k8s_cluster_fqn
}
