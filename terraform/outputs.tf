output "wordpress_url" {
  value = "http://localhost:${var.wordpress_port}"
}

output "mysql_host" {
  value = "localhost:3306"
}
