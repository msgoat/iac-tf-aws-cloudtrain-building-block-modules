variable region_name {
  description = "The AWS region to deploy into."
  type = string
}

variable solution_name {
  description = "The name of the AWS solution that owns all AWS resources."
  type = string
}

variable solution_stage {
  description = "The name of the current AWS solution stage."
  type = string
}

variable solution_fqn {
  description = "The fully qualified name of the current AWS solution."
  type = string
}

variable common_tags {
  description = "Common tags to be attached to all AWS resources"
  type = map(string)
}

variable vpc_id {
  description = "Unique identifier of the VPC supposed to host the database"
  type = string
}

variable "k8s_cluster_id" {
  description = "Unique identifier of the target Kubernetes cluster"
  type        = string
}

variable postgresql_templates {
  description = "Templates to provision PostgreSQL instances as managed services"
  type = list(object({
    instance_name = string # Logical name of the PostgreSQL instance
    database_name = string # Name of the database to create within the PostgreSQL instance
    instance_type = string # Instance type of virtual machine running the PostgreSQL instance
    min_storage_size = number # Minimum storage size of the PostgreSQL instance in gigabytes
    max_storage_size = number # Maximum storage size of the PostgreSQL instance in gigabytes
    storage_type = optional(string, "gp3") # Block storage type used for the PostgreSQL instance
    version = optional(string, "16.1") # PostgreSQL version"
    snapshot_id = optional(string) # Optional unique identifier of a previously created final snapshot the PostgreSQL instance should be restored from
    final_snapshot_enabled = optional(bool, true) # Controls if a final snapshot should be created before the PostgreSQL instance is deleted; default is `true`
  }))
}
