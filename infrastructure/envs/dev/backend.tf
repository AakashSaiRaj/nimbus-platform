terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket = "aim-tfstate-aakashpb-978236789366"
    key    = "envs/dev/terraform.tfstate"
    region = "us-east-1"

    encrypt      = true # encrypt state at rest (bucket also has default encryption; belt + suspenders)
    use_lockfile = true # native S3 locking, requires Terraform >= 1.10. No DynamoDB needed.
  }
}
