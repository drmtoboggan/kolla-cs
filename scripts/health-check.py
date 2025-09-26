#!/usr/bin/env python3
# scripts/health-check.py

import json
import sys
import requests
from openstack import connection
import argparse
import logging

class OpenStackHealthCheck:
    def __init__(self, cloud_config):
        self.conn = connection.Connection(**cloud_config)
        self.results = {
            'timestamp': None,
            'overall_status': 'PASS',
            'services': {}
        }

    def check_keystone(self):
        """Test Keystone authentication"""
        try:
            token = self.conn.identity.get_token()
            self.results['services']['keystone'] = {
                'status': 'PASS',
                'message': 'Authentication successful',
                'response_time': 0.1  # Placeholder
            }
        except Exception as e:
            self.results['services']['keystone'] = {
                'status': 'FAIL', 
                'message': str(e)
            }
            self.results['overall_status'] = 'FAIL'

    def check_nova(self):
        """Test Nova compute service"""
        try:
            flavors = list(self.conn.compute.flavors())
            self.results['services']['nova'] = {
                'status': 'PASS',
                'message': f'Found {len(flavors)} flavors',
                'details': {'flavor_count': len(flavors)}
            }
        except Exception as e:
            self.results['services']['nova'] = {
                'status': 'FAIL',
                'message': str(e)
            }
            self.results['overall_status'] = 'FAIL'

    def run_all_checks(self):
        """Execute all health checks"""
        from datetime import datetime
        self.results['timestamp'] = datetime.utcnow().isoformat()
        
        self.check_keystone()
        self.check_nova()
        # Add more service checks as needed
        
        return self.results

def main():
    parser = argparse.ArgumentParser(description='OpenStack Health Check')
    parser.add_argument('--environment', required=True, help='Environment to check')
    parser.add_argument('--output', default='json', choices=['json', 'table'])
    args = parser.parse_args()

    # Load cloud configuration
    cloud_config = {
        'auth': {
            'auth_url': os.getenv('OS_AUTH_URL'),
            'username': os.getenv('OS_USERNAME'), 
            'password': os.getenv('OS_PASSWORD'),
            'project_name': os.getenv('OS_PROJECT_NAME'),
            'user_domain_name': 'Default',
            'project_domain_name': 'Default'
        },
        'interface': 'internal'
    }
    
    health_checker = OpenStackHealthCheck(cloud_config)
    results = health_checker.run_all_checks()
    
    if args.output == 'json':
        print(json.dumps(results, indent=2))
    else:
        # Table format output
        print(f"Overall Status: {results['overall_status']}")
        print("-" * 50)
        for service, details in results['services'].items():
            print(f"{service.upper()}: {details['status']} - {details['message']}")
    
    sys.exit(0 if results['overall_status'] == 'PASS' else 1)

if __name__ == '__main__':
    main()