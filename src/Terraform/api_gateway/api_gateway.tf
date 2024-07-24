resource "aws_api_gateway_rest_api" "movie_api" {
  name        = "MovieAPI"
  description = "API for fetching movie cover URLs"
}

resource "aws_api_gateway_resource" "movies" {
  rest_api_id = aws_api_gateway_rest_api.movie_api.id
  parent_id   = aws_api_gateway_rest_api.movie_api.root_resource_id
  path_part   = "movies"
}

resource "aws_api_gateway_method" "get_movies" {
  rest_api_id   = aws_api_gateway_rest_api.movie_api.id
  resource_id   = aws_api_gateway_resource.movies.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.movie_api.id
  resource_id = aws_api_gateway_resource.movies.id
  http_method = aws_api_gateway_method.get_movies.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.fetch_movie_cover.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_method.get_movies,
    aws_api_gateway_integration.lambda_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.movie_api.id
  stage_name  = "dev"
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}
