terraform {
  backend "s3" {
    bucket         = "ross-data-pipeline-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ross-data-pipeline-tfstate-locks"
    encrypt        = true
  }
}
