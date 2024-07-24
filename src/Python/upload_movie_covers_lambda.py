import json
import requests
import boto3
import os

# Initialize AWS Secrets Manager client
secrets_client = boto3.client('secretsmanager')

def get_secret(secret_name):
    response = secrets_client.get_secret_value(SecretId=secret_name)
    secret = json.loads(response['SecretString'])
    return secret

def lambda_handler(event, context):
    # Fetch the OMDb API key from AWS Secrets Manager
    secret_name = os.getenv('OMDB_SECRET_NAME', 'omdb_api_key')
    secrets = get_secret(secret_name)
    omdb_api_key = secrets['OMDB_API_KEY']
    
    # Get the movie title from the query parameters
    movie_title = event['queryStringParameters']['title']
    
    # Fetch movie data from OMDb API
    omdb_api_url = 'http://www.omdbapi.com/'
    params = {'t': movie_title, 'apikey': omdb_api_key}
    response = requests.get(omdb_api_url, params=params)
    data = response.json()
    
    # Check if the movie data contains a poster URL
    if 'Poster' in data and data['Poster'] != 'N/A':
        poster_url = data['Poster']
        return {
            'statusCode': 200,
            'body': json.dumps({'title': movie_title, 'poster_url': poster_url})
        }
    else:
        return {
            'statusCode': 404,
            'body': json.dumps({'error': 'Poster not found'})
        }
