resource "atlas_artifact" "consul_client" {
  name = "${var.atlas_username}/consul_client"
  type = "amazon.image"
}

resource "atlas_artifact" "consul_multiregion" {
  name = "${var.atlas_username}/consul_multiregion"
  type = "amazon.image"
}
