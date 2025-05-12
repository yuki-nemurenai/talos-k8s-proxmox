data "http" "talos_schematic_id" {
  url          = "${var.talos_factory_url}/schematics"
  method       = "POST"
  request_body = file("${path.module}/templates/schematic.yaml")
}
