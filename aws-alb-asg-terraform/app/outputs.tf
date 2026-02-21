output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "curl_test" {
  value = "curl http://${module.alb.alb_dns_name}"
}
