#!/usr/bin/env python3
import argparse
import openai
import time

def test_api_connection(api_key, model="gpt-4-turbo", azure_endpoint=None, azure_api_version=None, azure_deployment=None):
    """
    Test the OpenAI or Azure OpenAI API connection with the provided configuration.
    This is a simple test to verify your API settings are correctly configured.
    """
    openai.api_key = api_key
    
    # Configure for Azure OpenAI if endpoint is provided
    if azure_endpoint:
        print("Testing Azure OpenAI API connection...")
        openai.api_type = "azure"
        openai.api_base = azure_endpoint
        openai.api_version = azure_api_version
    else:
        print("Testing OpenAI API connection...")
    
    try:
        if azure_endpoint:
            # For Azure OpenAI, use deployment_id instead of model
            response = openai.ChatCompletion.create(
                deployment_id=azure_deployment,
                messages=[{"role": "user", "content": "Hello, please respond with a brief message to confirm the API is working."}],
                max_tokens=50
            )
        else:
            # For standard OpenAI
            response = openai.ChatCompletion.create(
                model=model,
                messages=[{"role": "user", "content": "Hello, please respond with a brief message to confirm the API is working."}],
                max_tokens=50
            )
        
        result = response["choices"][0]["message"]["content"].strip()
        print("✓ API connection successful!")
        print("Response:", result)
        return True
    except Exception as e:
        print("✗ API connection failed:")
        print(str(e))
        return False

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Test OpenAI or Azure OpenAI API configuration')
    parser.add_argument('--api_key', type=str, required=True, help='OpenAI or Azure OpenAI API Key')
    parser.add_argument('--model', type=str, default='gpt-4-turbo', help='OpenAI model to use (for standard OpenAI)')
    parser.add_argument('--azure_endpoint', type=str, default=None, help='Azure OpenAI endpoint URL')
    parser.add_argument('--azure_api_version', type=str, default='2023-05-15', help='Azure OpenAI API version')
    parser.add_argument('--azure_deployment', type=str, default=None, help='Azure OpenAI deployment name')
    
    args = parser.parse_args()
    
    # If azure_endpoint is provided but azure_deployment is not, prompt the user
    if args.azure_endpoint and not args.azure_deployment:
        print("Error: When using Azure OpenAI, you must also specify --azure_deployment")
        exit(1)
    
    test_api_connection(
        args.api_key,
        args.model,
        args.azure_endpoint,
        args.azure_api_version,
        args.azure_deployment
    )