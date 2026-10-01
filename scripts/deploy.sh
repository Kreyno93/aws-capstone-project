#!/bin/bash

# Deployment script for AWS Capstone WordPress Infrastructure
# Usage: ./scripts/deploy.sh [environment] [action]
# Example: ./scripts/deploy.sh dev plan
# Example: ./scripts/deploy.sh dev apply
# Example: ./scripts/deploy.sh dev destroy

set -e

# Default values
ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Validate inputs
validate_inputs() {
    if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
        error "Invalid environment: $ENVIRONMENT. Must be one of: dev, staging, prod"
        exit 1
    fi

    if [[ ! "$ACTION" =~ ^(plan|apply|destroy|init|validate|fmt|output)$ ]]; then
        error "Invalid action: $ACTION. Must be one of: plan, apply, destroy, init, validate, fmt, output"
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi

    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi

    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi

    # Check if key pair exists (for non-init actions)
    if [[ "$ACTION" != "init" && "$ACTION" != "validate" && "$ACTION" != "fmt" ]]; then
        local key_pair_name=$(grep -E '^key_pair_name' "environments/$ENVIRONMENT/terraform.tfvars" | cut -d'"' -f2)
        if ! aws ec2 describe-key-pairs --key-names "$key_pair_name" &> /dev/null; then
            warning "Key pair '$key_pair_name' not found in AWS. Please create it or update the configuration."
        fi
    fi

    success "Prerequisites check completed"
}

# Initialize Terraform
terraform_init() {
    log "Initializing Terraform..."
    cd "$PROJECT_ROOT"
    terraform init -upgrade
    success "Terraform initialized"
}

# Validate Terraform configuration
terraform_validate() {
    log "Validating Terraform configuration..."
    cd "$PROJECT_ROOT"
    terraform validate
    success "Terraform configuration is valid"
}

# Format Terraform files
terraform_fmt() {
    log "Formatting Terraform files..."
    cd "$PROJECT_ROOT"
    terraform fmt -recursive
    success "Terraform files formatted"
}

# Plan Terraform deployment
terraform_plan() {
    log "Planning Terraform deployment for environment: $ENVIRONMENT"
    cd "$PROJECT_ROOT"
    
    terraform plan \
        -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
        -out="$ENVIRONMENT.tfplan"
    
    success "Terraform plan completed. Review the plan above."
    log "To apply this plan, run: ./scripts/deploy.sh $ENVIRONMENT apply"
}

# Apply Terraform deployment
terraform_apply() {
    log "Applying Terraform deployment for environment: $ENVIRONMENT"
    cd "$PROJECT_ROOT"
    
    # Check if plan file exists
    if [[ -f "$ENVIRONMENT.tfplan" ]]; then
        log "Using existing plan file: $ENVIRONMENT.tfplan"
        terraform apply "$ENVIRONMENT.tfplan"
        rm -f "$ENVIRONMENT.tfplan"
    else
        log "No plan file found. Running apply with auto-approve..."
        terraform apply \
            -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
            -auto-approve
    fi
    
    success "Terraform deployment completed!"
    
    # Show outputs
    log "Deployment outputs:"
    terraform output
}

# Destroy Terraform deployment
terraform_destroy() {
    log "Destroying Terraform deployment for environment: $ENVIRONMENT"
    
    warning "This will destroy all resources in the $ENVIRONMENT environment!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        log "Destruction cancelled."
        exit 0
    fi
    
    cd "$PROJECT_ROOT"
    terraform destroy \
        -var-file="environments/$ENVIRONMENT/terraform.tfvars" \
        -auto-approve
    
    success "Terraform resources destroyed"
}

# Show Terraform outputs
terraform_output() {
    log "Showing Terraform outputs for environment: $ENVIRONMENT"
    cd "$PROJECT_ROOT"
    terraform output
}

# Main execution
main() {
    log "Starting deployment script for environment: $ENVIRONMENT, action: $ACTION"
    
    validate_inputs
    check_prerequisites
    
    case $ACTION in
        init)
            terraform_init
            ;;
        validate)
            terraform_validate
            ;;
        fmt)
            terraform_fmt
            ;;
        plan)
            terraform_init
            terraform_validate
            terraform_plan
            ;;
        apply)
            terraform_init
            terraform_validate
            terraform_apply
            ;;
        destroy)
            terraform_destroy
            ;;
        output)
            terraform_output
            ;;
        *)
            error "Unknown action: $ACTION"
            exit 1
            ;;
    esac
    
    success "Script completed successfully!"
}

# Show usage if no arguments provided
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 [environment] [action]"
    echo ""
    echo "Environments: dev, staging, prod"
    echo "Actions: init, validate, fmt, plan, apply, destroy, output"
    echo ""
    echo "Examples:"
    echo "  $0 dev plan     # Plan deployment for dev environment"
    echo "  $0 dev apply    # Apply deployment for dev environment"
    echo "  $0 prod destroy # Destroy prod environment"
    echo "  $0 dev output   # Show outputs for dev environment"
    exit 1
fi

# Run main function
main
