resource "kubernetes_secret" "greenlight-pipelines-git-auth" {
  metadata {
    name = "git-auth"
    namespace = "greenlight-pipelines"
    annotations = {
      "tekton.dev/git-0" = "github.com"
    }
  }

  data = {
    known_hosts = <<KNOWN_HOSTS
github.com,192.30.253.112 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
    KNOWN_HOSTS
    ssh-privatekey = <<SSH
${var.bot_private_key}
    SSH
  }
  type = "kubernetes.io/ssh-auth"

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

resource "kubernetes_secret" "greenlight-pipelines-docker-registry-credentials" {
  metadata {
    name = "docker-registry-credentials"
    namespace = "greenlight-pipelines"
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
    {
      "auths": {
        "https://index.docker.io/v1/": {
          "username": "greenlightcoopbot",
          "password": "${var.bot_password}",
          "email": "${var.bot_email}",
          "auth": "${base64encode("greenlightcoopbot:${var.bot_password}")}"
        },
        "https://hub.docker.com/v2/": {
          "username": "greenlightcoopbot",
          "password": "${var.bot_password}",
          "email": "${var.bot_email}",
          "auth": "${base64encode("greenlightcoopbot:${var.bot_password}")}"
        }
      }
    }
    DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

resource "kubernetes_secret" "greenlight-pipelines-bot-github-token" {
  metadata {
    name = "bot-github-token"
    namespace = "greenlight-pipelines"
  }

  data = {
    botGithubTokenValue = var.bot_github_token
  }

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

resource "kubernetes_secret" "greenlight-pipelines-webhook-secret" {
  metadata {
    name = "webhook-secret"
    namespace = "greenlight-pipelines"
  }

  data = {
    webhookSecretValue = var.webhook_secret
  }

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

resource "kubernetes_secret" "greenlight-pipelines-buildkit-client-certs" {
  metadata {
    name = "buildkit-client-certs"
    namespace = "greenlight-pipelines"
  }

  data = {
    "ca.pem" = file("${path.module}/.certs/client/ca.pem")
    "cert.pem" = file("${path.module}/.certs/client/cert.pem")
    "key.pem" = file("${path.module}/.certs/client/key.pem")
  }

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

resource "kubernetes_secret" "greenlight-pipelines-buildkit-daemon-certs" {
  metadata {
    name = "buildkit-daemon-certs"
    namespace = "greenlight-pipelines"
  }

  data = {
    "ca.pem" = file("${path.module}/.certs/daemon/ca.pem")
    "cert.pem" = file("${path.module}/.certs/daemon/cert.pem")
    "key.pem" = file("${path.module}/.certs/daemon/key.pem")
  }
  
  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}


resource "kubernetes_secret" "greenlight-pipelines-snyk-token" {
  metadata {
    name = "snyk"
    namespace = "greenlight-pipelines"
  }

  data = {
    token = var.snyk_token
  }
  
  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

resource "kubernetes_secret" "greenlight-pipelines-verdaccio-htpasswd" {
  metadata {
    name = "verdaccio-htpasswd"
    namespace = "greenlight-pipelines"
  }

  data = {
    "htpasswd" = <<-EOF
      ${var.bot_username}:${bcrypt(var.bot_password)}
    EOF
  }

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

