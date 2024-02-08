# Terraform Building Blocks related to Kubernetes as a Service

The Terraform building blocks provided in this directory provision Kubernetes clusters based on AWS EKS.

Due to the nature of Terraform, a Kubernetes cluster has to be provisioned in two phases:

* Phase one (`Foundation`) creates a naked Kubernetes cluster plus all required network components like VPCs, Load Balancers.
* Phase two (`Bootstrap`) configures this naked Kubernetes cluster by adding required add-ons like ingress controllers 
and tool stacks like a monitoring stack, a logging stack and a tracing stack.

Each phase has to be executed in a dedicated `terraform apply` command.

## TODOs

* Add IPv6 support to Kubernetes clusters
* Switch to Bottlerocket images as default AMIs for node groups
* Make sure managed nodegroups are using GP3 volumes