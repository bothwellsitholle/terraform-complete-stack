terraform {
  backend "s3" {
    bucket = "terra-g7-state"
    key    = "terraform/backend"
    region = "us-east-2"
  }
}