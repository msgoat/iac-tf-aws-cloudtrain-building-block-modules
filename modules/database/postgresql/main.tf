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

data "aws_region" "current" {
  name = var.region_name
}

data "aws_caller_identity" "current" {

}

locals {
  module_common_tags = merge(var.common_tags, { TerraformBuildingBlockName = "database/postgresql" })
}

locals {
  postgresql_template_names = [for pgt in var.postgresql_templates : pgt.instance_name]
  postgresql_templates_by_name = zipmap(local.postgresql_template_names, var.postgresql_templates)
}

data aws_subnets given {
  filter {
    name = "vpc-id"
    values = [ var.vpc_id ]
  }
  tags = {
    Role = "ResourceContainer"
  }
}

module postgresql {
  for_each = local.postgresql_templates_by_name
  source                          = "../../../../iac-tf-aws-cloudtrain-modules//modules/database/postgresql/rds"
  region_name                     = var.region_name
  solution_name                   = var.solution_name
  solution_stage                  = var.solution_stage
  solution_fqn                    = var.solution_fqn
  common_tags                     = var.common_tags
  db_instance_name = each.value.instance_name
  db_database_name = each.value.database_name
  db_instance_class = each.value.instance_type
  db_min_storage_size = each.value.min_storage_size
  db_max_storage_size = each.value.max_storage_size
  db_storage_type = each.value.storage_type
  db_version = each.value.version
  vpc_id = var.vpc_id
  db_subnet_ids = data.aws_subnets.given.ids
}

module k8s_secret {
  for_each = module.postgresql
  source                          = "../../../../iac-tf-aws-cloudtrain-modules//modules/container/eks/secret/postgresql"
  region_name                     = var.region_name
  solution_name                   = var.solution_name
  solution_stage                  = var.solution_stage
  solution_fqn                    = var.solution_fqn
  common_tags                     = var.common_tags
  eks_cluster_id = var.k8s_cluster_id
  db_instance_id = each.value.db_instance_id
  sm_secret_id = each.value.db_secret_id
  kubernetes_namespace_names = ["cloudtrain"] # @TODO: make configurable via template
}

locals {
  postgresql_infos = [
    for m in module.postgresql : {
      instance_name = m.db_instance_name
      instance_id   = m.db_instance_id
      secret_name  = m.db_secret_name
      secret_id  = m.db_secret_id
    }
  ]
}