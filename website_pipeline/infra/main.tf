terraform {
  backend "s3" {
    bucket         = "ross-data-pipeline-tfstate"
    key            = "financial-data-pipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

resource "aws_s3_bucket" "raw_data" {
  bucket = "${replace(lower(var.project_name), "/","-")}-raw-data"
  acl    = "private"
}

resource "aws_iam_role" "airflow_ecs" {
  name               = "${replace(lower(var.project_name), "/","-")}-airflow-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
