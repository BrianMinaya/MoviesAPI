resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_secrets_policy" {
  name = "lambda_secrets_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "secretsmanager:GetSecretValue",
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "fetch_movie_cover" {
  filename         = "function.zip"
  function_name    = "fetchMovieCover"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("function.zip")
  runtime          = "python3.8"

  environment {
    variables = {
      OMDB_SECRET_NAME = "omdb_api_key"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution, aws_iam_role_policy.lambda_secrets_policy]
}