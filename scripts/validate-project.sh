#!/bin/bash

# Project Structure Validation Script
# This script validates the project structure and configuration

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Validation counters
CHECKS_PASSED=0
CHECKS_FAILED=0

# Function to run a validation check
run_check() {
    local check_name="$1"
    local check_command="$2"
    
    log "Checking: $check_name"
    
    if eval "$check_command" 2>/dev/null; then
        success "✓ $check_name"
        ((CHECKS_PASSED++))
    else
        error "✗ $check_name"
        ((CHECKS_FAILED++))
    fi
    echo ""
}

# Check if required files exist
check_file_exists() {
    [[ -f "$1" ]]
}

check_directory_exists() {
    [[ -d "$1" ]]
}

# Check Terraform syntax
check_terraform_syntax() {
    terraform fmt -check=true -diff=true . >/dev/null 2>&1
}

# Check if all modules have required files
check_module_structure() {
    local module_path="$1"
    [[ -f "$module_path/main.tf" ]] && \
    [[ -f "$module_path/variables.tf" ]] && \
    [[ -f "$module_path/outputs.tf" ]]
}

# Main validation function
main() {
    log "Starting project structure validation..."
    echo "========================================"
    
    # Check core Terraform files
    run_check "Core Terraform files" "
        check_file_exists 'terraform.tf' && \
        check_file_exists 'providers.tf' && \
        check_file_exists 'variables.tf' && \
        check_file_exists 'locals.tf' && \
        check_file_exists 'data.tf' && \
        check_file_exists 'main.tf' && \
        check_file_exists 'outputs.tf'
    "
    
    # Check modules directory structure
    run_check "Modules directory structure" "
        check_directory_exists 'modules' && \
        check_directory_exists 'modules/networking' && \
        check_directory_exists 'modules/security' && \
        check_directory_exists 'modules/database' && \
        check_directory_exists 'modules/compute' && \
        check_directory_exists 'modules/monitoring'
    "
    
    # Check each module has required files
    run_check "Networking module structure" "check_module_structure 'modules/networking'"
    run_check "Security module structure" "check_module_structure 'modules/security'"
    run_check "Database module structure" "check_module_structure 'modules/database'"
    run_check "Compute module structure" "check_module_structure 'modules/compute'"
    run_check "Monitoring module structure" "check_module_structure 'modules/monitoring'"
    
    # Check environments directory
    run_check "Environment configurations" "
        check_directory_exists 'environments' && \
        check_directory_exists 'environments/dev' && \
        check_directory_exists 'environments/staging' && \
        check_directory_exists 'environments/prod' && \
        check_file_exists 'environments/dev/terraform.tfvars' && \
        check_file_exists 'environments/staging/terraform.tfvars' && \
        check_file_exists 'environments/prod/terraform.tfvars'
    "
    
    # Check scripts directory
    run_check "Scripts directory" "
        check_directory_exists 'scripts' && \
        check_file_exists 'scripts/deploy.sh' && \
        check_file_exists 'scripts/test-infrastructure.sh' && \
        check_file_exists 'scripts/wordpress-userdata.sh' && \
        check_file_exists 'scripts/bastion-userdata.sh'
    "
    
    # Check script permissions
    run_check "Script permissions" "
        [[ -x 'scripts/deploy.sh' ]] && \
        [[ -x 'scripts/test-infrastructure.sh' ]]
    "
    
    # Check documentation files
    run_check "Documentation files" "
        check_file_exists 'README.md' && \
        check_file_exists 'MIGRATION-GUIDE.md' && \
        check_file_exists 'IMPROVEMENTS-SUMMARY.md' && \
        check_file_exists 'CLEANUP-SUMMARY.md'
    "
    
    # Check backup directory
    run_check "Backup directory" "
        check_directory_exists 'backup' && \
        check_directory_exists 'backup/old-structure'
    "
    
    # Check .gitignore
    run_check "Git ignore file" "check_file_exists '.gitignore'"
    
    # Check Terraform formatting (if terraform is available)
    if command -v terraform &> /dev/null; then
        run_check "Terraform formatting" "check_terraform_syntax"
    else
        warning "Terraform not found, skipping syntax check"
    fi
    
    # Summary
    echo "========================================"
    log "Validation completed!"
    success "Checks passed: $CHECKS_PASSED"
    if [[ $CHECKS_FAILED -gt 0 ]]; then
        error "Checks failed: $CHECKS_FAILED"
        echo ""
        error "Please fix the failed checks before proceeding."
        return 1
    else
        success "All checks passed! Project structure is valid."
        echo ""
        log "Project is ready for deployment!"
        echo "Next steps:"
        echo "  1. Review environment configurations in environments/"
        echo "  2. Run: ./scripts/deploy.sh dev plan"
        echo "  3. Run: ./scripts/deploy.sh dev apply"
        echo "  4. Run: ./scripts/test-infrastructure.sh"
        return 0
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0"
    echo ""
    echo "This script validates the AWS Capstone Project structure."
    echo "It checks for required files, directories, and configurations."
}

# Handle command line arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Run the validation
main
exit $?
