# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module public_dns {
  source                = "../../../../iac-tf-aws-cloudtrain-modules//modules/dns/public-hosted-zone"
  region_name           = var.region_name
  solution_name         = var.solution_name
  solution_stage        = var.solution_stage
  solution_fqn          = var.solution_fqn
  common_tags           = var.common_tags
  dns_zone_name = var.public_dns_zone_name
  link_to_parent_domain = true
  parent_dns_zone_id = var.parent_dns_zone_id
}
