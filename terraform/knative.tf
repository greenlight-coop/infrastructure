# # Downloaded from https://github.com/knative/serving/releases/download/v0.18.0/serving-crds.yaml
# resource "null_resource" "knative-serving-crds" {
#   provisioner "local-exec" {
#     command = "kubectl apply --filename manifests/knative-serving-crds.yaml"
#   }
#   depends_on = [
#     helm_release.ingress-nginx,
#     helm_release.cert-manager
#   ]
# }

# # Downloaded from https://github.com/knative/serving/releases/download/v0.18.0/serving-core.yaml
# resource "null_resource" "knative-serving-core" {
#   provisioner "local-exec" {
#     command = "kubectl apply --filename manifests/knative-serving-core.yaml"
#   }
#   depends_on = [
#     null_resource.knative-serving-crds
#   ]
# }

# resource "null_resource" "istioctl-install" {
#   provisioner "local-exec" {
#     command = "istioctl install --skip-confirmation"
#   }
#   depends_on = [
#     null_resource.knative-serving-core,
#   ]
# }

# resource "null_resource" "istio-minimal-operator" {
#   provisioner "local-exec" {
#     command = "istioctl manifest install -f manifests/istio-minimal-operator.yaml"
#   }
#   depends_on = [
#     null_resource.istioctl-install
#   ]
# }

data "kubernetes_service" "istio-ingressgateway" {
  metadata {
    namespace = "istio-system"
    name      = "istio-ingressgateway"
  }
  depends_on = [
    k8s_manifest.argocd-apps-application
  ]
}

# resource "null_resource" "enable-serving-istio-injection" {
#   provisioner "local-exec" {
#     command = "kubectl label namespace knative-serving istio-injection=enabled"
#   }
#   depends_on = [
#     null_resource.istio-minimal-operator,
#   ]
# }

# resource "k8s_manifest" "knative-serving-permissive" {
#   content = <<-EOT
#     apiVersion: "security.istio.io/v1beta1"
#     kind: "PeerAuthentication"
#     metadata:
#       name: "default"
#       namespace: "knative-serving"
#     spec:
#       mtls:
#         mode: PERMISSIVE
#   EOT
#   depends_on = [
#     null_resource.enable-serving-istio-injection
#   ]
# }

# # Downloaded from https://github.com/knative/net-istio/releases/download/v0.18.0/release.yaml
# resource "null_resource" "knative-serving-istio" {
#   provisioner "local-exec" {
#     command = "kubectl apply --filename manifests/knative-serving-istio.yaml"
#   }
#   depends_on = [
#     k8s_manifest.knative-serving-permissive
#   ]
# }

# resource "null_resource" "knative-serving-config-domain" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       kubectl patch configmap/config-domain \
#         --namespace knative-serving \
#         --type merge \
#         --patch '{"data":{"${local.knative_domain_name}":""}}'
#     EOT
#   }
#   depends_on = [
#     null_resource.knative-serving-istio,
#     null_resource.knative-serving-core,
#     google_dns_record_set.wildcard-knative-greenlightcoop-dev-a-record
#   ]
# }

# # Downloaded from https://github.com/knative/net-certmanager/releases/download/v0.18.0/release.yaml
# resource "null_resource" "knative-serving-certmanager-extension" {
#   provisioner "local-exec" {
#     command = "kubectl apply --filename manifests/knative-serving-certmanager-extension.yaml"
#   }
#   depends_on = [
#     null_resource.knative-serving-config-domain
#   ]
# }

# # Edited to include installed letsencrypt ClusterIssuer configuration per instructions at
# # https://knative.dev/docs/serving/using-auto-tls/#configure-config-certmanager-configmap
# resource "null_resource" "knative-serving-certmanager-extension-issuer" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       cat <<EOF | kubectl apply -f -
#       ${templatefile("manifests/knative-serving-certmanager-extension-issuer.yaml", {tls_cert_issuer = local.tls_cert_issuer})}
#       EOF
#     EOT
#   }
#   depends_on = [
#     null_resource.knative-serving-certmanager-extension
#   ]
# }

# resource "null_resource" "knative-serving-config-network-tls" {
#   provisioner "local-exec" {
#     command = "kubectl apply --filename manifests/knative-serving-config-network-tls.yaml"
#   }
#   depends_on = [
#     null_resource.knative-serving-certmanager-extension-issuer
#   ]
# }
