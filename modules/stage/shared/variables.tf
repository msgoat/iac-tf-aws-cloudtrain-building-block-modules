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

variable "public_dns_zone_name" {
  description = "Name of the public DNS zone to create"
  type        = string
}

variable "parent_dns_zone_id" {
  description = "Optional unique identifier of a public parent DNS zone the newly created DNS zone should be linked with"
  type        = string
}

variable "admin_principal_ids" {
  description = "List of principal IDs (groups or roles) which grant administrative access components of this solution"
  type        = list(string)
}
