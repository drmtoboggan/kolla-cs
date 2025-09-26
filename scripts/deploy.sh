#!/bin/bash
# scripts/deploy.sh

set -euo pipefail

ENVIRONMENT=${1:-development}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Deploying OpenStack to environment: $ENVIRONMENT"

# Validate environment
if [[ ! -d "inventories/$ENVIRONMENT" ]]; then
    echo "Error: Environment $ENVIRONMENT not found"
    exit 1
fi

# Activate virtual environment
source venv/bin/activate

# Run pre-deployment validation
echo "Running pre-deployment checks..."
kolla-ansible -i "inventories/$ENVIRONMENT/hosts.yml" bootstrap-servers
kolla-ansible -i "inventories/$ENVIRONMENT/hosts.yml" prechecks

# Deploy OpenStack
echo "Deploying OpenStack services..."
kolla-ansible -i "inventories/$ENVIRONMENT/hosts.yml" deploy

# Post-deployment configuration
echo "Running post-deployment setup..."
kolla-ansible -i "inventories/$ENVIRONMENT/hosts.yml" post-deploy

# Generate OpenRC file
echo "Generating OpenRC credentials..."
mkdir -p credentials
cp /etc/kolla/admin-openrc.sh "credentials/$ENVIRONMENT-admin-openrc.sh"

# Run health checks
echo "Performing health checks..."
ansible-playbook -i "inventories/$ENVIRONMENT/hosts.yml" playbooks/operations/health-check.yml

echo "Deployment completed successfully!"
echo "OpenRC file: credentials/$ENVIRONMENT-admin-openrc.sh"