variable "region_name" {
  description = "The name of the region to deploy into."
  type        = string
}

variable "solution_name" {
  description = "The name of the cloud solution that owns all cloud resources."
  type        = string
}

variable "solution_stage" {
  description = "The name of the current solution stage."
  type        = string
}

variable "solution_fqn" {
  description = "The fully qualified name of the cloud solution."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be attached to all cloud resources"
  type        = map(string)
}

variable "network_cidr" {
  description = "The CIDR range of the network hosting the Kubernetes cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version of the Kubernetes cluster"
  type        = string
}

variable "kubernetes_cluster_name" {
  description = "Logical name of the Kubernetes cluster"
  type        = string
}

variable "kubernetes_api_access_cidrs" {
  description = "CIDR blocks defining source IP ranges allowed to access the Kubernetes API"
  type        = list(string)
}

variable "kubernetes_workload_access_cidrs" {
  description = "CIDR blocks defining source IP ranges allowed to access workload on the Kubernetes cluster"
  type        = list(string)
}

variable "zones_to_span" {
  description = "Number of availability zones the Kubernetes cluster is supposed to span"
  type        = number
  default     = 2
}

variable "node_group_templates" {
  description = "Templates for node groups attached to the Kubernetes cluster, will be replicated for each spanned zone"
  type = list(object({
    enabled            = optional(bool, true)  # controls if this node group gets actually created
    managed            = optional(bool, true)  # controls if this node group is a managed or unmanaged node group
    name               = string       # logical name of this nodegroup
    kubernetes_version = optional(string, null)       # Kubernetes version of this node group; will default to kubernetes_version of the cluster, if not specified but may differ from kubernetes_version during cluster upgrades
    min_size           = number       # minimum size of this node group
    max_size           = number       # maximum size of this node group
    desired_size       = optional(number, 0)       # desired size of this node group; will default to min_size if set to 0
    disk_size          = number       # size of attached root volume in GB
    capacity_type      = string       # defines the purchasing option for the EC2 instances in all node groups
    instance_types     = list(string) # EC2 instance types which should be used for the AWS EKS worker node groups ordered descending by preference
    labels             = optional(map(string), {})  # Kubernetes labels to be attached to each worker node
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), []) # Kubernetes taints to be attached to each worker node
    image_type         = optional(string, "AL2_x86_64") # Type of OS images to be used for EC2 instances; possible values are: AL2_x86_64 | AL2_x86_64_GPU | AL2_ARM_64 | CUSTOM | BOTTLEROCKET_ARM_64 | BOTTLEROCKET_x86_64 | BOTTLEROCKET_ARM_64_NVIDIA | BOTTLEROCKET_x86_64_NVIDIA; default is "AL2_x86_64"
  }))
}
