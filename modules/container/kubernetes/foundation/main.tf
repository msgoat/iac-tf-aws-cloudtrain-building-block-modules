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
  module_common_tags = merge(var.common_tags, { TerraformBuildingBlockName = "container/kubernetes/foundation" })
}

module network {
  source                = "../../../../../iac-tf-aws-cloudtrain-modules//modules/network/vpc"
  region_name           = var.region_name
  solution_name         = var.solution_name
  solution_stage        = var.solution_stage
  solution_fqn          = var.solution_fqn
  common_tags           = local.module_common_tags
  network_name          = var.kubernetes_cluster_name
  network_cidr          = var.network_cidr
  inbound_traffic_cidrs = var.kubernetes_workload_access_cidrs
  nat_strategy          = "NAT_GATEWAY_AZ"
  zones_to_span         = var.zones_to_span
  subnet_templates      = [
    {
      name          = "web"
      accessibility = "public"
      role          = "InternetFacingContainer"
      newbits       = 8
      tags          = { "kubernetes.io/role/elb" = "1" }
    },
    {
      name          = "nodes"
      accessibility = "private"
      role          = "NodeGroupContainer"
      newbits       = 4
      tags          = {}
    },
    {
      name          = "resources"
      accessibility = "private"
      role          = "ResourceContainer"
      newbits       = 8
      tags          = {}
    }
  ]
}

locals {
  node_group_subnet_ids = [ for sn in module.network.subnets : sn.subnet_id if sn.role == "NodeGroupContainer" ]
}

module "cluster" {
  source                = "../../../../../iac-tf-aws-cloudtrain-modules//modules/container/eks/cluster"
  region_name           = var.region_name
  solution_name         = var.solution_name
  solution_stage        = var.solution_stage
  solution_fqn          = var.solution_fqn
  common_tags           = local.module_common_tags
  kubernetes_api_access_cidrs = var.kubernetes_api_access_cidrs
  kubernetes_cluster_name = var.kubernetes_cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id = module.network.vpc_id
  node_group_subnet_ids = local.node_group_subnet_ids
  node_group_strategy = "MULTI_SINGLE_AZ"
  node_group_templates = var.node_group_templates
  zones_to_span = var.zones_to_span
}
