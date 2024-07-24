resource "aws_secretsmanager_secret" "omdb_api_secret" {
  name = "omdb_api_key"
}

resource "aws_secretsmanager_secret_version" "omdb_api_secret_version" {
  secret_id     = aws_secretsmanager_secret.omdb_api_secret.id
  secret_string = jsonencode({
    OMDB_API_KEY = var.omdb_api_key
  })
}
