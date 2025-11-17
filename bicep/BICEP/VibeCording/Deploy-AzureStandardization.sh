#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ENV=""
SUBSCRIPTION_ID=""
LOCATION="japaneast"

usage() {
    echo "Usage: $0 -e <environment> -s <subscription-id> [-l <location>]"
    echo ""
    echo "Options:"
    echo "  -e    Environment (dev, stag, prod)"
    echo "  -s    Azure Subscription ID"
    echo "  -l    Azure Location (default: japaneast)"
    echo ""
    echo "Example:"
    echo "  $0 -e dev -s 00000000-0000-0000-0000-000000000000"
    exit 1
}

while getopts "e:s:l:h" opt; do
    case $opt in
        e)
            ENV=$OPTARG
            ;;
        s)
            SUBSCRIPTION_ID=$OPTARG
            ;;
        l)
            LOCATION=$OPTARG
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [ -z "$ENV" ] || [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Error: Environment and Subscription ID are required."
    usage
fi

if [[ ! "$ENV" =~ ^(dev|stag|prod)$ ]]; then
    echo "Error: Environment must be dev, stag, or prod."
    exit 1
fi

PARAM_FILE="${SCRIPT_DIR}/${ENV}-standard.bicepparam"
MAIN_FILE="${SCRIPT_DIR}/main-standard.bicep"

if [ ! -f "$PARAM_FILE" ]; then
    echo "Error: Parameter file not found: $PARAM_FILE"
    exit 1
fi

if [ ! -f "$MAIN_FILE" ]; then
    echo "Error: Main Bicep file not found: $MAIN_FILE"
    exit 1
fi

echo "=========================================="
echo "Azure Standardization Template Deployment"
echo "=========================================="
echo "Environment:     $ENV"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Location:        $LOCATION"
echo "Parameter File:  $PARAM_FILE"
echo "Main File:       $MAIN_FILE"
echo "=========================================="
echo ""

read -p "Do you want to proceed with the deployment? (yes/no): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo "Setting Azure subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

DEPLOYMENT_NAME="azure-standard-${ENV}-$(date +%Y%m%d-%H%M%S)"

echo "Starting deployment: $DEPLOYMENT_NAME"
echo ""

az deployment sub create \
    --name "$DEPLOYMENT_NAME" \
    --location "$LOCATION" \
    --template-file "$MAIN_FILE" \
    --parameters "$PARAM_FILE" \
    --verbose

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Deployment completed successfully!"
    echo "Deployment Name: $DEPLOYMENT_NAME"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "Deployment failed!"
    echo "=========================================="
    exit 1
fi
