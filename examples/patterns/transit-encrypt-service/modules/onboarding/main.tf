resource "vault_transit_secret_backend_key" "this" {
  backend          = var.transit_path
  name             = var.test_id
  deletion_allowed = true
}

resource "aws_s3_bucket" "deployment" {
  for_each = { for k, v in toset([var.test_id]) : k => v if strcontains(var.test_id, "0001") }

  bucket        = var.deployment_id
  force_destroy = true

  tags = {
    deployment = var.deployment_id
  }
}

resource "aws_s3_object" "source" {
  for_each = aws_s3_bucket.deployment
  
  bucket = each.value.bucket
  key    = "/source/${var.test_file}"
  source = "${path.root}/examples/${var.test_file}"
}