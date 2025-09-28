#!/bin/bash
# scripts/bootstrap.sh

set -euo pipefail

ENVIRONMENT=${1:-development}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Bootstrapping OpenStack deployment for environment: $ENVIRONMENT"

# Install dependencies
echo "Installing system dependencies..."
if command -v dnf >/dev/null; then
    sudo dnf install -y python3-pip python3-venv git
elif command -v apt >/dev/null; then
    sudo apt update
    sudo apt install -y python3-pip python3-venv git
fi

# Creating vdir
sudo mkdir /kolla
sudo chown $USER:$USER /kolla

# Create Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate


# Install Python dependencies
pip install --upgrade pip
pip install ansible kolla-ansible

# Install Ansible collections and roles
echo "Installing Ansible dependencies..."
ansible-galaxy install -r requirements.yml --ignore-errors
ansible-galaxy collection install -r collections/requirements.yml

# Generate passwords
if [[ ! -f "config/kolla/passwords.yml" ]]; then
    echo "Generating OpenStack passwords..."
    kolla-genpwd -p config/kolla/passwords.yml
fi

# Copy default configuration
if [[ ! -f "config/kolla/globals.yml" ]]; then
    echo "Copying default configuration..."
    cp /usr/share/kolla-ansible/etc_examples/kolla/globals.yml config/kolla/
fi

# Initialize git-crypt if needed
if [[ -d ".git" && ! -d ".git/git-crypt" ]]; then
    echo "Initializing git-crypt..."
    git-crypt init
fi

echo "Bootstrap completed successfully!"
echo "Next steps:"
echo "1. Configure inventories/$ENVIRONMENT/hosts.yml"
echo "2. Update config/kolla/globals.yml"
echo "3. Run: ./scripts/deploy.sh $ENVIRONMENT"