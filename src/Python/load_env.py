# load_env.py
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Export environment variables for Terraform
os.environ['TF_VAR_aws_region'] = os.getenv('AWS_REGION')
os.environ['TF_VAR_omdb_api_key'] = os.getenv('OMDB_API_KEY')

print("Environment variables loaded. You can now run Terraform commands manually.")