#!/bin/bash

# Define the Terraform version
TERRAFORM_VERSION="1.9.0"

# Download the Terraform binary
curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Unzip the downloaded file
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Move the binary to /usr/local/bin
sudo mv terraform /usr/local/bin/

# Cleanup
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Verify the installation
terraform --version