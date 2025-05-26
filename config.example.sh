#!/bin/bash
############################################################################################################
# Example configuration file for LLM4SD
# Copy this file to config.sh and update with your actual API keys and endpoints
# Then source it before running any scripts: source config.sh
############################################################################################################

# OpenAI API Configuration
# -----------------------
# If using OpenAI API directly, only set API_KEY and leave Azure settings empty
export API_KEY='your_openai_api_key_here'

# Azure OpenAI Configuration
# -----------------------
# If using Azure OpenAI, set all the following variables:
export AZURE_ENDPOINT='https://your-resource-name.openai.azure.com'
export AZURE_API_VERSION='2023-05-15'
export AZURE_DEPLOYMENT='your_gpt4_deployment_name'

# The API_KEY above should also be set to your Azure OpenAI API key when using Azure

############################################################################################################
# Usage:
# 1. Copy this file: cp config.example.sh config.sh
# 2. Edit config.sh with your actual API keys and endpoints
# 3. Source the file before running scripts: source config.sh
# 4. Run the scripts as usual, e.g.: ./run_sider.sh
############################################################################################################