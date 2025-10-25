# main.tf

resource "digitalocean_spaces_key" "key-fini-web-content" {
  name = "rw-fini-web-content"
  grant {
    bucket     = "fini-web-content"
    permission = "readwrite"
  }
}
