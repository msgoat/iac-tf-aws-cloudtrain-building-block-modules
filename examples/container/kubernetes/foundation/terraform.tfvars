region_name="eu-central-1"
solution_name="iactrain"
solution_stage="dev"
solution_fqn="iactrain-dev"
common_tags={
  Organization = "msg systems ag"
  BusinessUnit = "Branche Automotive"
  Department = "PG Cloud"
  ManagedBy = "Terraform"
}
network_cidr="10.17.0.0/16"
kubernetes_version="1.28"
kubernetes_cluster_name="k8stst2024"
kubernetes_api_access_cidrs=[ "0.0.0.0/0" ]
kubernetes_workload_access_cidrs=[ "0.0.0.0/0" ]
node_group_templates=[
  {
    name               = "appsblue"       # logical name of this nodegroup
    min_size           = 1       # minimum size of this node group
    max_size           = 2       # maximum size of this node group
    desired_size       = 1       # desired size of this node group; will default to min_size if set to 0
    disk_size          = 64       # size of attached root volume in GB
    capacity_type      = "SPOT"   # defines the purchasing option for the virtual machine instances in all node groups
    instance_types     = [ "t4g.xlarge" ] # virtual machine instance types which should be used for the worker node groups ordered descending by preference
    image_type         = "AL2_ARM_64"
  }
]
