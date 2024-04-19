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
  module_common_tags = merge(var.common_tags, { TerraformBuildingBlockName = "container/kubernetes/bootstrap" })
}

# Kubernetes Add-Ons ---------------------------------------------------------

data "aws_route53_zone" "given" {
  zone_id = var.public_dns_zone_id
}

module "k8s_addons" {
  source                          = "../../../../../iac-tf-aws-cloudtrain-modules//modules/container/eks/addons"
  region_name                     = var.region_name
  solution_name                   = var.solution_name
  solution_stage                  = var.solution_stage
  solution_fqn                    = var.solution_fqn
  common_tags                     = local.module_common_tags
  cert_manager_enabled            = true
  eks_cluster_admin_role_names    = var.admin_principal_ids
  eks_cluster_id                  = var.k8s_cluster_id
  hosted_zone_name                = data.aws_route53_zone.given.name
  host_names                      = var.host_names
  letsencrypt_account_name        = var.letsencrypt_account_name
  kubernetes_cluster_architecture = var.kubernetes_cluster_architecture
  loadbalancer_id                 = var.loadbalancer_id
  opentelemetry_enabled           = var.opentelemetry_enabled
  opentelemetry_collector_host    = var.opentelemetry_collector_host
  opentelemetry_collector_port    = var.opentelemetry_collector_port
}

module "k8s_tools" {
  source                             = "../../../../../iac-tf-aws-cloudtrain-modules//modules/container/eks/tools"
  region_name                        = var.region_name
  solution_name                      = var.solution_name
  solution_stage                     = var.solution_stage
  solution_fqn                       = var.solution_fqn
  common_tags                        = local.module_common_tags
  cert_manager_enabled               = true
  cert_manager_cluster_issuer_name   = module.k8s_addons.production_cluster_certificate_issuer_name
  eks_cluster_id                     = var.k8s_cluster_id
  kubernetes_ingress_class_name      = module.k8s_addons.kubernetes_ingress_class_name
  kubernetes_ingress_controller_type = module.k8s_addons.kubernetes_ingress_controller_type
  grafana_host_name                  = data.aws_route53_zone.given.name
  grafana_path                       = "/grafana"
  prometheus_host_name               = data.aws_route53_zone.given.name
  prometheus_path                    = "/prometheus"
  kibana_host_name                   = data.aws_route53_zone.given.name
  kibana_path                        = "/kibana"
  jaeger_host_name                   = data.aws_route53_zone.given.name
  jaeger_path                        = "/jaeger"
  depends_on                         = [module.k8s_addons]
}

module "k8s_namespaces" {
  source                             = "../../../../../iac-tf-aws-cloudtrain-modules//modules/container/eks/namespaces"
  region_name                        = var.region_name
  solution_name                      = var.solution_name
  solution_stage                     = var.solution_stage
  solution_fqn                       = var.solution_fqn
  common_tags                        = local.module_common_tags
  eks_cluster_id                     = var.k8s_cluster_id
  kubernetes_namespace_templates     = var.kubernetes_namespace_templates
}