# iac-tf-aws-cloudtrain-building-blocks Terraform Building Blocks for AWS

Terraform module library which provides coarse-grained cloud infrastructure building blocks for AWS.

Cloud infrastructure buildings blocks encapsulate complex cloud infrastructure artifacts like Kubernetes clusters,
managed databases etc
* which are simple to use
* which feel kind of the same across multiple cloud providers.

They are based on best practices, established security baselines like CIS benchmarks and well architected.

For the sake of simplicity, their API is based on the configuration-by-exception principle:
* By default, the underlying cloud infrastructure artifact is built according to well-established defaults which meet most requirements without the need to provide complex configuration.
* If you need to deviate from the default, you still can do so by providing specific configuration.