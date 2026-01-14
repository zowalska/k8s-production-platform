terraform {
  backend "s3" {
    bucket         = "platform-terraform-state"
    key            = "platform/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "platform-terraform-locks"
    encrypt        = true
  }
}
