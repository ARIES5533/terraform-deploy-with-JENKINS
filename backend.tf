terraform {
  backend "s3" {
    bucket  = "jenkins-terraform-state-bucket-5533"
    key     = "jenkins-infra/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    ## enable native locking
    use_lockfile = true
  }
}
