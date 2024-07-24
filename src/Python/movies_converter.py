import csv
import json
import boto3

# Define the input and output file paths
input_file = 'movies.csv'
output_file = 'movies.json'

# Read the CSV file
with open(input_file, 'r', newline='', encoding='utf-8') as csvfile:
    reader = csv.DictReader(csvfile)
    movies = [row for row in reader if row['titleType'] == 'movie']

# Rename keys and write the JSON data to a file
movie_dicts = []
for movie in movies:
    genres = movie['genres'].replace(',', ', ')  # Add space after each comma in genres
    movie_dict = {
        'MovieID': movie['movie_id'],
        'Title': movie['title'],
        'ReleaseYear': movie['startYear'],
        'RuntimeMinutes': movie['runtimeMinutes'],
        'Genres': genres,
        'coverURL': f"https://your-s3-bucket/movie-covers/{movie['title'].replace(' ', '-').lower()}.jpg"
    }
    movie_dicts.append(movie_dict)

with open(output_file, 'w', encoding='utf-8') as jsonfile:
    json.dump(movie_dicts, jsonfile, ensure_ascii=False, indent=4)

print(f"Converted {input_file} to {output_file}")

# Initialize DynamoDB resource
dynamodb = boto3.resource('dynamodb')

# Select your DynamoDB table
table = dynamodb.Table('Movies')

# Insert data into DynamoDB table
for movie in movie_dicts:
    item = {
        'MovieID': movie['MovieID'],
        'Title': movie['Title'],
        'ReleaseYear': int(movie['ReleaseYear']) if movie['ReleaseYear'].isdigit() else None,
        'RuntimeMinutes': int(movie['RuntimeMinutes']) if movie['RuntimeMinutes'].isdigit() else None,
        'Genres': movie['Genres'].split(', ') if movie['Genres'] else [],
        'coverURL': movie['coverURL']
    }
    table.put_item(Item=item)
    print(f"Inserted {movie['Title']} into DynamoDB")