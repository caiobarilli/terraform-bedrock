resource "docker_network" "bedrock_network" {
  name = "bedrock-network"
}

########################
# MYSQL
########################

resource "docker_image" "mysql" {
  name = "mysql:8.0"
}

resource "docker_container" "mysql" {
  name  = "bedrock-mysql"
  image = docker_image.mysql.image_id

  networks_advanced {
    name = docker_network.bedrock_network.name
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${var.mysql_root_password}",
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_USER=${var.mysql_user}",
    "MYSQL_PASSWORD=${var.mysql_password}"
  ]

  volumes {
    host_path      = abspath("${path.module}/../db")
    container_path = "/var/lib/mysql"
  }

  ports {
    internal = 3306
    external = 3306
  }
}

########################
# PHP
########################

resource "docker_image" "php" {
  name = "bedrock-php"

  build {
    context    = "${path.module}/../docker/php"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "php" {
  name  = "bedrock-php"
  image = docker_image.php.image_id

  user = "1000:1000"

  networks_advanced {
    name = docker_network.bedrock_network.name
  }

  volumes {
    host_path      = abspath("${path.module}/../project")
    container_path = "/var/www/html"
  }

  env = [
    "COMPOSER_MEMORY_LIMIT=-1",
    "COMPOSER_PROCESS_TIMEOUT=2000"
  ]

  depends_on = [
    docker_container.mysql
  ]
}

########################
# NGINX
########################

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx" {
  name  = "bedrock-nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.bedrock_network.name
  }

  volumes {
    host_path      = abspath("${path.module}/../docker/nginx/default.conf")
    container_path = "/etc/nginx/conf.d/default.conf"
  }

  volumes {
    host_path      = abspath("${path.module}/../project")
    container_path = "/var/www/html"
  }

  ports {
    internal = 80
    external = var.wordpress_port
  }

  depends_on = [
    docker_container.php
  ]
}

########################
# NODE (Sage / Vite)
########################

resource "docker_image" "node" {
  name = "node:25.8.1"
}

resource "docker_container" "node" {
  name  = "bedrock-node"
  image = docker_image.node.image_id
  user  = "1000:1000"

  networks_advanced {
    name = docker_network.bedrock_network.name
  }

  working_dir = "/var/www/html"

  volumes {
    host_path      = abspath("${path.module}/../project")
    container_path = "/var/www/html"
  }

  ports {
    internal = 5173
    external = 5173
  }

  tty = true
}
