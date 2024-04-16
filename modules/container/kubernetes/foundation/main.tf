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

# Network --------------------------------------------------------------------

module "network" {
  source                = "../../../../../iac-tf-aws-cloudtrain-modules//modules/network/vpc2"
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
  subnet_templates = [
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

# TLS certificate for load balancer ------------------------------------------

data "aws_route53_zone" "given" {
  zone_id = var.public_dns_zone_id
}

module "tls_certificate" {
  source                   = "../../../../../iac-tf-aws-cloudtrain-modules//modules/security/certificate"
  region_name              = var.region_name
  solution_name            = var.solution_name
  solution_stage           = var.solution_stage
  solution_fqn             = var.solution_fqn
  common_tags              = local.module_common_tags
  domain_name              = data.aws_route53_zone.given.name
  certificate_name         = var.kubernetes_cluster_name
  hosted_zone_id           = data.aws_route53_zone.given.id
  alternative_domain_names = []
}

# Load balancer --------------------------------------------------------------

module "loadbalancer" {
  source                  = "../../../../../iac-tf-aws-cloudtrain-modules//modules/network/application-loadbalancer"
  region_name             = var.region_name
  solution_name           = var.solution_name
  solution_stage          = var.solution_stage
  solution_fqn            = var.solution_fqn
  common_tags             = local.module_common_tags
  loadbalancer_name       = var.kubernetes_cluster_name
  loadbalancer_subnet_ids = [for sn in module.network.subnets : sn.subnet_id if sn.role == "InternetFacingContainer"]
  cm_certificate_arn      = module.tls_certificate.cm_certificate_arn
  public_hosted_zone_id   = var.public_dns_zone_id
  host_names              = var.host_names
}

locals {
  node_group_subnet_ids = [for sn in module.network.subnets : sn.subnet_id if sn.role == "NodeGroupContainer"]
  aws_image_types = {
    "X86_64" = "BOTTLEROCKET_x86_64"
    "ARM_64" = "BOTTLEROCKET_ARM_64"
  }
  aws_node_group_templates = [for ngt in var.node_group_templates : {
    enabled            = ngt.enabled
    managed            = ngt.managed
    name               = ngt.name
    kubernetes_version = ngt.kubernetes_version
    min_size           = ngt.min_size
    max_size           = ngt.max_size
    desired_size       = ngt.desired_size
    disk_size          = ngt.disk_size
    capacity_type      = ngt.payment_option
    instance_types     = ngt.instance_types
    labels             = ngt.labels
    taints             = ngt.taints
    image_type         = local.aws_image_types[ngt.cpu_architecture]
  }]
}

# Kubernetes cluster ---------------------------------------------------------

module "cluster" {
  source                      = "../../../../../iac-tf-aws-cloudtrain-modules//modules/container/eks/cluster2"
  region_name                 = var.region_name
  solution_name               = var.solution_name
  solution_stage              = var.solution_stage
  solution_fqn                = var.solution_fqn
  common_tags                 = local.module_common_tags
  kubernetes_api_access_cidrs = var.kubernetes_api_access_cidrs
  kubernetes_cluster_name     = var.kubernetes_cluster_name
  kubernetes_version          = var.kubernetes_version
  vpc_id                      = module.network.vpc_id
  node_group_subnet_ids       = local.node_group_subnet_ids
  node_group_strategy         = "MULTI_SINGLE_AZ"
  node_group_templates        = local.aws_node_group_templates
  zones_to_span               = var.zones_to_span
}
