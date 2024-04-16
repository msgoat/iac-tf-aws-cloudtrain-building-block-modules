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
  description = "Names of availability zones the Kubernetes cluster is supposed to span"
  type        = list(string)
}

variable "node_group_templates" {
  description = "Templates for node groups attached to the Kubernetes cluster"
  type = list(object({
    enabled                = optional(bool, true)          # controls if this node group gets actually created
    managed                = optional(bool, true)          # controls if this node group is a managed or unmanaged node group
    name                   = string                        # logical name of this nodegroup
    role                   = optional(string, "WORKER")    # role of the node group; must be either "MASTER" or "WORKER"
    kubernetes_version     = optional(string, null)        # Kubernetes version of this node group; will default to kubernetes_version of the cluster, if not specified but may differ from kubernetes_version during cluster upgrades
    min_size               = number                        # minimum size of this node group
    max_size               = number                        # maximum size of this node group
    desired_size           = optional(number, 0)           # desired size of this node group; will default to min_size if set to 0
    disk_size              = number                        # size of node root volume in GB
    payment_option         = optional(string, "ON_DEMAND") # defines the payment option to be applied when allocating the instances; possible values are: "ON_DEMAND" (default), "SAVING_PLAN", "SPOT", "RESERVED"
    payment_reservation_id = optional(string, null)        # defines the unique identifier of a saving plan or reservation the instances should be allocated from; only required if payment_option is "SAVING_PLAN" or "RESERVED"
    instance_types         = list(string)                  # instance types which should be used for the node group ordered descending by preference
    labels                 = optional(map(string), {})     # Kubernetes labels to be attached to each worker node
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])                                      # Kubernetes taints to be attached to each worker node
    cpu_architecture = optional(string, "X86_64") # CPU architecture type to be used for the instances; possible values are: X86_64 | ARM_64; default is "X86_64"
  }))
}

variable "public_dns_zone_id" {
  default = "Unique identifier of the public DNS zone hosting all DNS records of this solution"
  type    = string
}

variable "host_names" {
  description = "Host names of all hosts whose traffic should be routed to this solution"
  type        = list(string)
  default     = []
}
