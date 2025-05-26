#!/bin/bash
############################################################################################################
# Test script for OpenAI/Azure OpenAI API configuration
# This script demonstrates how to source the config file and test the API configuration
############################################################################################################

# Check if config.sh exists
if [ ! -f "config.sh" ]; then
    echo "Error: config.sh does not exist."
    echo "Please create a config.sh file by copying config.example.sh:"
    echo "  cp config.example.sh config.sh"
    echo "Then edit config.sh with your API keys and settings."
    exit 1
fi

# Source the config file
source config.sh

echo "Loading API configuration from config.sh..."

# Check if API_KEY is set
if [ -z "$API_KEY" ]; then
    echo "Error: API_KEY is not set in config.sh."
    exit 1
fi

# Check if using Azure OpenAI
if [ -n "$AZURE_ENDPOINT" ] && [ -n "$AZURE_DEPLOYMENT" ]; then
    echo "Testing Azure OpenAI API configuration..."
    python test_api_config.py --api_key "$API_KEY" \
                             --azure_endpoint "$AZURE_ENDPOINT" \
                             --azure_api_version "$AZURE_API_VERSION" \
                             --azure_deployment "$AZURE_DEPLOYMENT"
else
    echo "Testing standard OpenAI API configuration..."
    python test_api_config.py --api_key "$API_KEY"
fi