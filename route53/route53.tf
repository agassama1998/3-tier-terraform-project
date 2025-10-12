resource "aws_route53_record" "dns_record" {
  zone_id = var.dns_zone_id # Replace with your Route 53 Hosted Zone ID
  name    = var.dns_name  # Replace with your desired domain name (e.g., "example.com")
  type    = "A" # Use "A" for IPv4 addresses or "AAAA" for IPv6 addresses to map a domain name to another domain name.

  alias {
    name                   = var.apci_jupiter_alb_dns_name   # Replace with your ALB DNS name
    zone_id                = var.apci_jupiter_alb_zone_id   # ALB's hosted zone ID
    evaluate_target_health = true   # Set to true to evaluate the health of the target group
  }
}