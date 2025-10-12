output "apci_jupiter_alb_sg" {
  value = aws_security_group.apci_jupiter_alb_sg.id
}


output "apci_jupiter_tg" {
  value = aws_lb_target_group.apci_jupiter_tg.arn
}

output "apci_jupiter_alb_dns_name" {
  value = aws_lb.apci_jupiter_alb.dns_name
}

output "apci_jupiter_alb_zone_id" {
  value = aws_lb.apci_jupiter_alb.zone_id
  
}