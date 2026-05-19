output "load_balancer_dns" {
  description = "Cisty DNS nazev pridelely Load Balanceru od AWS"
  value       = aws_lb.main.dns_name
}

output "load_balancer_url" {
  description = "Kompletni URL adresa pro otestovani Nginx aplikace v prohlizeci nebo pres curl"
  value       = "http://${aws_lb.main.dns_name}"
}