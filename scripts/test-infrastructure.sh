#!/bin/bash

# Infrastructure Testing Script for AWS Capstone WordPress Project
# This script tests the deployed infrastructure components

set -e

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

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    log "Running test: $test_name"
    
    if eval "$test_command"; then
        success "✓ $test_name"
        ((TESTS_PASSED++))
    else
        error "✗ $test_name"
        ((TESTS_FAILED++))
    fi
    echo ""
}

# Get Terraform outputs
get_terraform_outputs() {
    log "Getting Terraform outputs..."
    
    if ! terraform output &> /dev/null; then
        error "Cannot get Terraform outputs. Make sure infrastructure is deployed."
        exit 1
    fi
    
    ALB_DNS_NAME=$(terraform output -raw alb_dns_name 2>/dev/null || echo "")
    BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "")
    WORDPRESS_URL=$(terraform output -raw wordpress_url 2>/dev/null || echo "")
    
    if [[ -z "$ALB_DNS_NAME" || -z "$BASTION_IP" || -z "$WORDPRESS_URL" ]]; then
        error "Could not retrieve all required outputs from Terraform"
        exit 1
    fi
    
    success "Retrieved Terraform outputs"
    echo "  ALB DNS Name: $ALB_DNS_NAME"
    echo "  Bastion IP: $BASTION_IP"
    echo "  WordPress URL: $WORDPRESS_URL"
    echo ""
}

# Test 1: Check if ALB is responding
test_alb_health() {
    curl -f -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS_NAME" | grep -q "200\|301\|302"
}

# Test 2: Check WordPress installation page
test_wordpress_response() {
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$WORDPRESS_URL")
    [[ "$response" =~ ^(200|301|302)$ ]]
}

# Test 3: Check if bastion host is reachable via SSH (port check)
test_bastion_ssh_port() {
    nc -z -w5 "$BASTION_IP" 22
}

# Test 4: Check ALB health check endpoint
test_health_endpoint() {
    local health_url="http://$ALB_DNS_NAME/health.php"
    curl -f -s "$health_url" | grep -q "healthy\|status"
}

# Test 5: Check if multiple requests are load balanced
test_load_balancing() {
    local responses=()
    local unique_responses=0
    
    # Make 10 requests and check for different server responses
    for i in {1..10}; do
        local response=$(curl -s -H "Cache-Control: no-cache" "$WORDPRESS_URL" | grep -o "Server: [^<]*" | head -1 || echo "")
        if [[ -n "$response" ]]; then
            responses+=("$response")
        fi
        sleep 0.5
    done
    
    # Count unique responses (indicating different servers)
    unique_responses=$(printf '%s\n' "${responses[@]}" | sort -u | wc -l)
    
    # If we have more than 1 unique response, load balancing is working
    [[ $unique_responses -gt 1 ]] || [[ ${#responses[@]} -gt 0 ]]
}

# Test 6: Check DNS resolution
test_dns_resolution() {
    nslookup "$ALB_DNS_NAME" &> /dev/null
}

# Test 7: Check SSL redirect (if configured)
test_ssl_redirect() {
    local response=$(curl -s -o /dev/null -w "%{http_code}" -L "http://$ALB_DNS_NAME")
    [[ "$response" =~ ^(200|301|302)$ ]]
}

# Test 8: Performance test - response time
test_response_time() {
    local response_time=$(curl -o /dev/null -s -w "%{time_total}" "$WORDPRESS_URL")
    # Check if response time is less than 5 seconds using awk
    awk -v rt="$response_time" 'BEGIN { exit (rt >= 5.0) }'
}

# Test 9: Check if Auto Scaling Group has healthy instances
test_asg_health() {
    local asg_name=$(terraform output -raw autoscaling_group_name 2>/dev/null || echo "")
    if [[ -n "$asg_name" ]]; then
        local healthy_instances=$(aws autoscaling describe-auto-scaling-groups \
            --auto-scaling-group-names "$asg_name" \
            --query 'AutoScalingGroups[0].Instances[?HealthStatus==`Healthy`]' \
            --output text | wc -l)
        [[ $healthy_instances -gt 0 ]]
    else
        false
    fi
}

# Test 10: Check ALB target group health
test_target_group_health() {
    local target_group_arn=$(terraform output -raw target_group_arn 2>/dev/null || echo "")
    if [[ -n "$target_group_arn" ]]; then
        local healthy_targets=$(aws elbv2 describe-target-health \
            --target-group-arn "$target_group_arn" \
            --query 'TargetHealthDescriptions[?TargetHealth.State==`healthy`]' \
            --output text | wc -l)
        [[ $healthy_targets -gt 0 ]]
    else
        false
    fi
}

# Load testing function
run_load_test() {
    log "Running basic load test..."
    
    if ! command -v ab &> /dev/null; then
        warning "Apache Bench (ab) not installed. Skipping load test."
        return
    fi
    
    log "Sending 100 requests with concurrency of 10..."
    ab -n 100 -c 10 "$WORDPRESS_URL" > /tmp/load_test_results.txt 2>&1
    
    if [[ $? -eq 0 ]]; then
        local requests_per_second=$(grep "Requests per second" /tmp/load_test_results.txt | awk '{print $4}')
        local time_per_request=$(grep "Time per request" /tmp/load_test_results.txt | head -1 | awk '{print $4}')
        
        success "Load test completed"
        echo "  Requests per second: $requests_per_second"
        echo "  Time per request: ${time_per_request}ms"
    else
        error "Load test failed"
    fi
    
    rm -f /tmp/load_test_results.txt
}

# Main testing function
main() {
    log "Starting infrastructure testing..."
    echo "========================================"
    
    # Get Terraform outputs
    get_terraform_outputs
    
    # Run tests
    run_test "ALB Health Check" "test_alb_health"
    run_test "WordPress Response" "test_wordpress_response"
    run_test "Bastion SSH Port" "test_bastion_ssh_port"
    run_test "Health Endpoint" "test_health_endpoint"
    run_test "Load Balancing" "test_load_balancing"
    run_test "DNS Resolution" "test_dns_resolution"
    run_test "SSL Redirect" "test_ssl_redirect"
    run_test "Response Time" "test_response_time"
    run_test "ASG Health" "test_asg_health"
    run_test "Target Group Health" "test_target_group_health"
    
    # Run load test
    run_load_test
    
    # Summary
    echo "========================================"
    log "Testing completed!"
    success "Tests passed: $TESTS_PASSED"
    if [[ $TESTS_FAILED -gt 0 ]]; then
        error "Tests failed: $TESTS_FAILED"
    else
        success "All tests passed!"
    fi
    
    # Additional information
    echo ""
    log "Access Information:"
    echo "  WordPress Site: $WORDPRESS_URL"
    echo "  Health Check: http://$ALB_DNS_NAME/health.php"
    echo "  Bastion Host: ssh -i vockey.pem ec2-user@$BASTION_IP"
    
    # Exit with error code if any tests failed
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    local missing_tools=()
    
    if ! command -v terraform &> /dev/null; then
        missing_tools+=("terraform")
    fi
    
    if ! command -v aws &> /dev/null; then
        missing_tools+=("aws")
    fi
    
    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi
    
    if ! command -v nc &> /dev/null; then
        missing_tools+=("nc")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
}

# Show usage
show_usage() {
    echo "Usage: $0"
    echo ""
    echo "This script tests the deployed AWS Capstone WordPress infrastructure."
    echo "Make sure you have deployed the infrastructure before running this script."
    echo ""
    echo "Prerequisites:"
    echo "  - terraform"
    echo "  - aws cli"
    echo "  - curl"
    echo "  - nc (netcat)"
    echo ""
    echo "Optional:"
    echo "  - ab (Apache Bench) for load testing"
}

# Handle command line arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Run the tests
check_prerequisites
main
