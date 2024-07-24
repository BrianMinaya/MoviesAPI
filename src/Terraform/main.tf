provider "aws" {
    region = "us-east-1"                            # Specifies region for resource creation 
}

                                                    # Define the DynamoDB table
resource "aws_dynamodb_table" "movies" {
    name                    = "Movies"
    billing_mode            = "PAY_PER_REQUEST"
    hash_key                = "movie_id"             # Primary key 

attribute {
    name = "movie_id"
    type = "S"                                          # 'S' stands for type String
}

tags = {
    Name = "MoviesTable"
    }
}

                                                        # Define the S3 bucket
resource "aws_s3_bucket" "movie_data" {
    bucket = "movie-data-bucket-20240627"

  tags = {
    Name = "MovieDataBucket"
  }
}
                                                        # Define a bucket policy to deny public access
resource "aws_s3_bucket_policy" "movie_data_policy" {
  bucket = aws_s3_bucket.movie_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = [
          "s3:GetBucketPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetBucketPolicyStatus",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
        ]
        Resource = [
          "${aws_s3_bucket.movie_data.arn}",
          "${aws_s3_bucket.movie_data.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}


                                                        # Creates a placeholder object to simulate a folder
resource "aws_s3_object" "movie_covers_placeholder" {
    bucket = aws_s3_bucket.movie_data.bucket
    key    = "Movie_Covers/.keep"                       # Creates a "Movie_Covers" folder with a placeholder file
    content = ""
}
                                                        # Output the name of the S3 bucket
output "s3_bucket_name" {
  value = aws_s3_bucket.movie_data.bucket
}

# Include other Terraform files
module "lambda" {
  source = "./lambda"
}

module "api_gateway" {
  source = "./api_gateway"
  lambda_function_arn = module.lambda.lambda_function_arn
}

module "secrets_manager" {
  source = "./secrets_manager"
}