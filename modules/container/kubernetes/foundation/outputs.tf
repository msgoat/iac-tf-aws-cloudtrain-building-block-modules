output "k8s_cluster_id" {
  description = "Unique identifier of the Kubernetes cluster"
  value       = module.cluster.eks_cluster_id
}

output "k8s_cluster_fqn" {
  description = "Fully qualified name of the Kubernetes cluster"
  value       = module.cluster.eks_cluster_name
}

output "network_id" {
  description = "Unique identifier name of the network hosting the Kubernetes cluster"
  value       = module.network.vpc_id
}

output "network_fqn" {
  description = "Fully qualified name of the network hosting the Kubernetes cluster"
  value       = module.network.vpc_name
}

output "loadbalancer_id" {
  description = "Unique identifier of the load balancer supposed to route traffic to the Kubernetes cluster"
  value       = module.loadbalancer.loadbalancer_id
}

output "loadbalancer_fqn" {
  description = "Fully qualified name of the load balancer supposed to route traffic to the Kubernetes cluster"
  value       = module.loadbalancer.loadbalancer_fqn
}
