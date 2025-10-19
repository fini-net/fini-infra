# data.tf

data "terraform_remote_state" "logs_cdn" {
  backend = "s3"

  config = {
    endpoints = {
      s3 = "https://nyc3.digitaloceanspaces.com"
    }

    bucket = "fini-terraform-state"
    key    = "l4_data/logs-cdn"

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    region                      = "us-east-1"
  }
}
