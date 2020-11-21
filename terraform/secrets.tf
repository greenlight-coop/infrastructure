# Argo CD

resource "kubernetes_secret" "argocd-github-ssh-key-secret" {
  metadata {
    name = "github-ssh-key"
    namespace = "argocd"
  }

  data = {
    sshPrivateKey = <<SSH
${local.bot_private_key}
    SSH
  }

  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}

resource "kubernetes_secret" "default-admin-password-secret" {
  metadata {
    name = "admin-password-secret"
    namespace = "default"
  }

  data = {
    password: ${local.admin_password}
  }

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

# Grafana

resource "kubernetes_secret" "grafana-datasources-secret" {
  metadata {
    name = "grafana-datasources"
    namespace = "default"
  }

  data = {
    datasource.yaml = <<DATASOURCES
${file("manifests/grafana-datasources.yaml")}
    DATASOURCES
  }

  depends_on = [
    google_container_node_pool.development_primary_nodes
  ]
}

# greenlight-pipelines

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
${local.bot_private_key}
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
          "email": "bot@greenlight.coop",
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
    webhookSecretValue = local.webhook_secret
  }

  depends_on = [
    kubernetes_namespace.greenlight-pipelines
  ]
}

