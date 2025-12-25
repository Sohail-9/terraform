/*
  Terraform backend configuration for production-grade deployments.

  IMPORTANT: Create the S3 bucket and DynamoDB table before enabling this backend.
  Replace the placeholders below or move this configuration into a separate file
  with the correct bucket/table names in pipeline or CI.

  Example pre-create steps (once):

  aws s3api create-bucket --bucket my-terraform-state-bucket --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1
  aws dynamodb create-table --table-name terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

  Then configure the values below.
*/

terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_TFSTATE_BUCKET"
    key            = "eks/terraform.tfstate"
    region         = "REPLACE_WITH_REGION"
    dynamodb_table = "REPLACE_WITH_DYNAMODB_TABLE"
    encrypt        = true
  }
}
