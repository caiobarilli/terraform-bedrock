# Terraform Bedrock Development Environment

Ambiente de desenvolvimento local para **WordPress Bedrock + Sage** provisionado com **Terraform** e executado em **Docker**.

---

# Arquitetura

O ambiente cria os seguintes serviços:

| Serviço        | Função              |
| -------------- | ------------------- |
| nginx          | Web server          |
| php-fpm        | Executa WordPress   |
| mysql          | Banco de dados      |
| node           | Build do Sage       |
| docker network | Comunicação interna |

Fluxo da aplicação:

Browser → Nginx → PHP-FPM → WordPress → MySQL

---

# Estrutura do Projeto

```
terraform-bedrock
│
├ terraform
│  ├ providers.tf
│  ├ main.tf
│  ├ variables.tf
│  ├ outputs.tf
│  └ terraform.tfvars
│
├ docker
│  ├ nginx
│  │  └ default.conf
│  └ php
│     └ Dockerfile
│     └ php.ini
│
└ project
   └ (WordPress Bedrock será instalado aqui)
```

---

# Requisitos

Antes de iniciar, instale:

- Docker Desktop
- Terraform >= 1.3
- Git
- Node.js (opcional para desenvolvimento local)

---

# Inicializando o Ambiente

Crie a pasta para o projeto WordPress Bedrock:

```
mkdir -p ./project       # cria a pasta
sudo chown -R 1000:1000 ./project   # dá permissão para o container (UID 1000)
```

Entre no diretório Terraform:

```
cd terraform
```

Inicialize o Terraform:

```
terraform init
```

Verifique o plano de infraestrutura:

```
terraform plan
```

Crie o ambiente:

```
terraform apply
```

Confirme digitando:

```
yes
```

---

# Containers Criados

Após o `apply`, os seguintes containers estarão rodando:

```
bedrock-nginx
bedrock-php
bedrock-node
bedrock-mysql
```

Verifique com:

```
docker ps
```

---

# Instalar WordPress Bedrock

Entre no container PHP:

```
docker exec -it bedrock-php bash
```

Instale o Bedrock:

```
composer create-project roots/bedrock . --prefer-dist
```

Instale o Sage:

```
cd ./web/app/themes

composer create-project roots/sage mytheme
```

---

# Configuração do Banco

Edite o arquivo `.env` gerado pelo Bedrock:

```
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=wordpress
DB_HOST=bedrock-mysql

WP_HOME='http://localhost:8080'
```

---

# Acessar WordPress

Abra no navegador:

```
http://localhost:8080
```

O instalador do WordPress aparecerá. Lembre-se de ativar o tema Sage após a instalação.

---

# Configurar o Sage

Entre no container Node:

```
docker exec -it bedrock-node bash
```

Instale dependências:

```
cd ./web/app/themes/mytheme

npm install
```

Edite o arquivo `vite.config.js` do tema Sage:

```

// Set APP_URL if it doesn't exist for Laravel Vite plugin
if (! process.env.APP_URL) {
  process.env.APP_URL = 'http://localhost:8080';
}

export default defineConfig(({ command }) => ({
  base: command === 'build'
    ? '/app/themes/sage/public/build/'
    : '/',

  server: {
    host: '0.0.0.0',
    port: 5173,
    hmr: {
      host: 'localhost',
    },
  },

  ...
  
}))


```

Inicie o build do Sage:

```
npm run build
```

Ou inicie o modo desenvolvimento:

```
npm run dev
```

---

# Comandos Úteis

Entrar no container PHP

```
docker exec -it bedrock-php bash
```

Entrar no container Node

```
docker exec -it bedrock-node bash
```

Ver logs

```
docker logs bedrock-nginx
```

---

# Destruir o Ambiente

Para remover todos os containers e infraestrutura:

```
terraform destroy
```

---

# Tecnologias Utilizadas

- Terraform
- Docker
- Nginx
- PHP-FPM
- MySQL
- WordPress Bedrock
- Sage
- Node.js
