# main.tf
# Hund.io Status Page Configuration for status.fini.net

# for https://github.com/hundio/terraform-provider-hund/issues/13
# resource "hund_group" "websites" {
#   name = "Web Sites"
# }

# this also gives a Value Conversion error
# from https://registry.terraform.io/providers/hundio/hund/latest/docs/data-sources/groups

# data "hund_groups" "example" {
# }

# data "hund_components" "components" {
#   group = one([for g in data.hund_groups.example.groups : g.id if g.name == "Web Sites"])
# }

# output "component_names" {
#   value = data.hund_components.components.components[*].name
# }
