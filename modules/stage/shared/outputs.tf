output "public_dns_zone_id" {
  description = "Unique identifier of the public DNS zone owning all DNS records of this solution"
  value       = module.public_dns.public_dns_zone_id
}
