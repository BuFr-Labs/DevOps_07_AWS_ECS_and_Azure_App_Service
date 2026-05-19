output "load_balancer_dns" {
  description = "Čistý DNS název přidělený Load Balanceru od AWS"
  value       = aws_lb.main.dns_name
}

output "load_balancer_url" {
  description = "Kompletní URL adresa pro otestování Nginx aplikace v prohlížeči nebo přes curl"
  value       = "http://${aws_lb.main.dns_name}"
}