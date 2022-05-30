### Create bucket to hld state file
resource "aws_s3_bucket" "terraform_state" {
  bucket = "teraaform-state-cz65rv"
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


#### Create DynamoDB for state file locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-cz65rv"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}