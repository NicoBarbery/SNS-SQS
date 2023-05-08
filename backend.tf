terraform {
  backend "s3" {
    #Bucket S3
    bucket = "nicob-terraform-state"
    key    = "projectF.tfstate"
    region = "us-east-1"
    #DynamoDB table partition key = LockID
    dynamodb_table = "nico-terraform-state"
  }
}