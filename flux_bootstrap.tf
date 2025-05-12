resource "flux_bootstrap_git" "this" {
  depends_on = [helm_release.cilium]
  embedded_manifests = true
  path               = var.flux.path
}