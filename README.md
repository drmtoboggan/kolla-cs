# Enterprise OpenStack Deployment - Kolla-Ansible 2025.1

[![CI Status](https://github.com/company/openstack-deployment/workflows/CI/badge.svg)](https://github.com/company/openstack-deployment/actions)
[![Security Scan](https://github.com/company/openstack-deployment/workflows/Security%20Scan/badge.svg)](https://github.com/company/openstack-deployment/actions)
[![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://docs.company.com/openstack)

Enterprise-grade OpenStack deployment using Kolla-Ansible 2024.2 (Dalmatian) with comprehensive automation, security hardening, and operational excellence.

## Architecture Overview

This deployment provides a **highly available, scalable OpenStack cloud** with:

- **3-node Controller Cluster**: HA services with ProxySQL and MariaDB Galera
- **Scalable Compute**: 10+ compute nodes with live migration support
- **Distributed Storage**: Ceph integration with multiple pools
- **Advanced Networking**: Neutron with OVS/OVN and DVR support
- **Enterprise Security**: TLS everywhere, RBAC, and compliance frameworks

### Key Features (Kolla-Ansible 2025.1)

- **Enhanced ProxySQL**: Default MySQL connection handling with 10-second failover 
- **Transient Quorum Queues**: Improved RabbitMQ resilience 
- **Modern TLS Configuration**: Mozilla "modern" security standards 
- **Container Engine Flexibility**: Docker and Podman support 
- **Multi-Architecture**: AMD64 and ARM64 support

## Quick Start

### Prerequisites

- **Operating System**: Rocky Linux 9, Ubuntu 24.04 LTS, or Ubuntu 22.04 LTS 
- **Python Version**: 3.10 or higher 
- **Network**: Dedicated management and external network interfaces
- **Storage**: Minimum 500GB per controller, 200GB per compute node
- **RAM**: 64GB per controller, 32GB minimum per compute node 

### Installation
```bash

Deployment Environments
Development Environment

Purpose: Testing and development
Scale: 1 controller + 2 compute nodes
Storage: Local storage with basic redundancy
Access: Development team access

Staging Environment

Purpose: Pre-production validation
Scale: 3 controllers + 5 compute nodes
Storage: Ceph cluster with production-like configuration
Access: QA and operations teams

Production Environment

Purpose: Live workloads
Scale: 3 controllers + 20+ compute nodes
Storage: High-availability Ceph with enterprise features
Access: Restricted operations team access

Security Features
Secrets Management

Ansible Vault: Configuration and database passwords
Git-crypt: Repository-wide encryption for sensitive files
HashiCorp Vault: Runtime secrets and certificate management
SOPS Integration: Cloud KMS encryption support

Security Hardening

TLS Everywhere: All service communication encrypted
RBAC Implementation: Role-based access controls
Security Scanning: Automated vulnerability assessment
Compliance Framework: SOC 2 and ISO 27001 alignment

Operational Procedures
Daily Operations

Health Monitoring: Automated service health checks
Log Aggregation: Centralized logging with ELK stack
Backup Verification: Database and configuration backups
Performance Monitoring: Real-time metrics with Prometheus

Maintenance Procedures

Rolling Updates: Zero-downtime service updates
Certificate Renewal: Automated TLS certificate management
Capacity Planning: Resource utilization monitoring
Disaster Recovery: Automated backup and restore procedures

Documentation Structure

Architecture Guide: System design and component overview
Deployment Guide: Step-by-step deployment instructions
Operations Manual: Daily operations and maintenance
Troubleshooting: Common issues and solutions
Security Procedures: Security policies and procedures
API Documentation: Custom modules and plugins CioPagesInvgate

Contributing
Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.
Development Workflow

Fork the repository
Create a feature branch (git checkout -b feature/amazing-feature)
Run tests (molecule test)
Commit changes (git commit -m 'Add amazing feature')
Push to branch (git push origin feature/amazing-feature)
Create a Pull Request

Support and Contact

Documentation: https://docs.company.com/openstack
Issue Tracker: https://github.com/company/openstack-deployment/issues
Slack Channel: #openstack-ops
Operations Team: ops-team@company.com
Security Team: security@company.com

License
This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

### Procedure 


# Releases: https://releases.openstack.org/teams/kolla.html 

## Cheat Sheet

# Open shell
python3 -m venv /kolla
source /kolla/bin/activate

# Kolla Check Health 
kolla-ansible check -i /kolla/multinode



# Recover Mariadb
kolla-ansible mariadb-recovery -i /kolla/multinode

# Upgrade
kolla-ansible upgrade -i /kolla/multinode

## End Cheat Sheet 

OS: Ubuntu 24.04 hwe-lowlatency kernel
Specs: 4x4 in most cases, ctl units are 8x16G RAM
Interfaces: 1=VL27, 2=VL28 (unaddressed)
HDD: 60GB Primary 

Function Build-VM ($vmname) {
   $computetarget = '192.168.1.10'
   $storageformat = 'Thin'
   $folder = 'Kolla'
   $network = 'VL27'
   $Template = Get-Template -Name 'ubuntu24template'
   $subnetmask = '255.255.255.0'
   $defaultgateway = '10.10.27.1'

   Write-Host 'Building VM $vmname…' -Foregroundcolor Green 
   New-VM -Name $vmname -Template $Template -VMHost $computetarget -Location $folder -NetworkName $network -Confirm:$false
   Get-vm $vmname | set-vm -NumCPU 4 -MemoryGB 4 -confirm:$false
   Get-HardDisk -vm $vmname | Where {$_.Name -eq "Hard disk 1"} | Set-HardDisk -CapacityGB 60 -Confirm:$false
  # 1..3 | % { New-HardDisk -VM $vmname -CapacityGB 50 -ThinProvisioned -Confirm:$false }
   $specscustom = get-OSCustomizationSpec 'Linux Server Customization' 
   $nicMapping = Get-OSCustomizationNicMapping –OSCustomizationSpec $specscustom
   $nicMapping | Set-OSCustomizationNicMapping –IpMode UseStaticIP –IpAddress $staticip –SubnetMask $subnetmask –DefaultGateway $defaultgateway
   Set-VM –VM $vmname –OSCustomizationSpec $specscustom –Confirm:$false
  # Start-vm -vm $vmname 
   Remove-Variable specscustom, nicMapping
   Write-Host 'Done.' -Foregroundcolor Green 
}

$vmname = 'ctl'
$staticip = '10.10.27.6'
Build-VM $vmname 

$vmname = 'ka-ctl1.region.com'
$staticip = '10.10.27.200'
Build-VM $vmname 

$vmname = 'ka-ctl2.region.com'
$staticip = '10.10.27.201'
Build-VM $vmname 

$vmname = 'ka-ctl3.region.com'
$staticip = '10.10.27.202'
Build-VM $vmname 

$vmname = 'ka-net1.region.com'
$staticip = '10.10.27.203'
Build-VM $vmname 

$vmname = 'ka-net2.region.com'
$staticip = '10.10.27.204'
Build-VM $vmname 

$vmname = 'ka-str1.region.com'
$staticip = '10.10.27.206'
Build-VM $vmname 

$vmname = 'ka-hv1.region.com'
$staticip = '10.10.27.212'
Build-VM $vmname 

$vmname = 'ka-hv2.region.com'
$staticip = '10.10.27.213'
Build-VM $vmname 


## OOB Configuration
# Passwordless sudo 
sudo visudo
# add to bottom
user ALL=(ALL) NOPASSWD:ALL
# save and quit 

# fix hostname
sudo hostnamectl set-hostname ka-.region.com
sudo vi /etc/hosts

# Build Stuff
sudo apt update  -y && sudo apt upgrade -y && sudo apt install open-vm-tools -y

### 
echo "https://drmtoboggan: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@github.com" > ~/.git-credentials
git config --global credential.helper store
git clone https://github.com/drmtoboggan/kolla-cs.git
cd kolla-cs
chmod +x ./scripts/*.sh
### 

# Run Node Prep on All Nodes - Will reboot upon completion
./scripts/prepnode.sh 


########## Once the precheck comes back ok, Snap VMs
$snapname = 'Try 2 - Clean'
$description = get-date

Get-vm ctl2,ka-ctl1.region.com,ka-ctl2.region.com,ka-ctl3.region.com,ka-net1.region.com,ka-net2.region.com,ka-str1.region.com,ka-mon1.region.com,ka-hv1.region.com,ka-hv2.region.com | new-snapshot -Name $snapname -Description $description -Quiesce -Memory
########## 

# Key Gen on deployment host ctl 
ssh-keygen
# enter passphrase, use no password

# Copy Keys
ssh-copy-id user@ka-ctl1.region.com
ssh-copy-id user@ka-ctl2.region.com
ssh-copy-id user@ka-ctl3.region.com
ssh-copy-id user@ka-net1.region.com
ssh-copy-id user@ka-net2.region.com
ssh-copy-id user@ka-hv1.region.com
ssh-copy-id user@ka-hv2.region.com
ssh-copy-id user@ka-str1.region.com




# Prepare the controller
./scripts/bootstrap.sh development 


# Create shell
tee ~/shell.sh << EOF
python3 -m venv /kolla
source /kolla/bin/activate
EOF
chmod +x ~/shell.sh
~/shell.sh


# Install Kolla Ansible
pip install git+https://opendev.org/openstack/kolla-ansible
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla

# Install ansible galaxy
kolla-ansible install-deps

# Fix ansible version requirements 
pip uninstall ansible ansible-core

# Install compatible versions for kolla-ansible 18.8.0
pip install 'ansible>=8.0,<9.0' 'ansible-core>=2.15,<2.17'

# Update the following files
vi ~/kolla-cs/inventories/development/hosts.yml
sudo vi /etc/kolla/globals.yml

# Update /etc/kolla/globals.yml
#sudo mv /etc/kolla/globals.yml /etc/kolla/globals.yml.bak
#sudo cp ~/kolla-cs/config/globals.yml /etc/kolla/globals.yml 


# Vault setup
echo "testpassword" > .vault_pass
chmod 600 .vault_pass

# Now generate the actual passwords
cp /kolla/share/kolla-ansible/etc_examples/kolla/passwords.yml /etc/kolla/
cp /kolla/share/kolla-ansible/etc_examples/kolla/globals.yml /etc//kolla/
kolla-genpwd -p /etc/kolla/passwords.yml
sudo chmod +r /etc/kolla/passwords.yml

##################################### Ceph Integration Setup

# Create pools (adjust replication size as needed)
ceph osd pool create images 64 64
ceph osd pool create volumes 64 64
ceph osd pool create backups 64 64
ceph osd pool create vms 64 64
ceph osd pool create gnocchi 64 64

# Enable RBD application on pools
ceph osd pool application enable images rbd
ceph osd pool application enable volumes rbd
ceph osd pool application enable backups rbd
ceph osd pool application enable vms rbd
ceph osd pool application enable gnocchi rbd

# Create Ceph users, use this information in the next section
ceph auth get-or-create client.glance mon 'profile rbd' osd 'profile rbd pool=images'
ceph auth get-or-create client.cinder mon 'profile rbd' osd 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd-read-only pool=images'
ceph auth get-or-create client.cinder-backup mon 'profile rbd' osd 'profile rbd pool=backups'
ceph auth get-or-create client.nova mon 'profile rbd' osd 'profile rbd pool=vms, profile rbd pool=images'
ceph auth get-or-create client.gnocchi mon 'profile rbd' osd 'profile rbd pool=gnocchi'


### Create keyring files on the ctl2 machine
sudo mkdir -p /etc/kolla/config/glance/
sudo mkdir -p /etc/kolla/config/cinder/
sudo mkdir -p /etc/kolla/config/nova/
sudo mkdir -p /etc/kolla/config/gnocchi/

## You must edit out any proceeding whitespace for the sake of ansible. ***
sudo cat << EOF > /etc/kolla/config/glance/ceph.client.glance.keyring
[client.glance]
key = AQDg8tdo+aZbLRAAnWn46djXq0173A93iXP63w==
EOF

sudo cat << EOF > /etc/kolla/config/cinder/ceph.client.cinder.keyring
[client.cinder]
key = AQDh8tdoLBTDBhAA4frQkni54buoOAu1Nw2JhA==
EOF

####
sudo mkdir -p /etc/kolla/config/cinder/cinder-volume/

# Copy the keyring to the expected location
sudo cp /etc/kolla/config/cinder/ceph.client.cinder.keyring /etc/kolla/config/cinder/cinder-volume/ceph.client.cinder.keyring

# Ensure proper permissions
sudo chmod 644 /etc/kolla/config/cinder/cinder-volume/ceph.client.cinder.keyring

sudo mkdir -p /etc/kolla/config/cinder/cinder-backup/

# Copy both required keyring files
sudo cp /etc/kolla/config/cinder/ceph.client.cinder.keyring /etc/kolla/config/cinder/cinder-backup/ceph.client.cinder.keyring
sudo cp /etc/kolla/config/cinder/ceph.client.cinder-backup.keyring /etc/kolla/config/cinder/cinder-backup/ceph.client.cinder-backup.keyring

# Set proper permissions
sudo chmod 644 /etc/kolla/config/cinder/cinder-backup/ceph.client.*.keyring

####

sudo cat << EOF > /etc/kolla/config/cinder/ceph.client.cinder-backup.keyring
[client.cinder-backup]
key = AQDh8tdoAKnZFhAAU/kD6qGPhjFoEtlKrVi03A==
EOF

sudo cat << EOF > /etc/kolla/config/nova/ceph.client.nova.keyring
[client.nova]
key = AQDh8tdoewByJBAAiCsbw06uECMMBP1aiJs4tg==
EOF

sudo cat << EOF > /etc/kolla/config/gnocchi/ceph.client.gnocchi.keyring
[client.gnocchi]
key = AQDh8tdol02hMxAAUN3VQrIE/J/LRBVJSg6StA==
EOF

#### This is the ceph.conf from the mgr node that needs to be in each directory as well
sudo cat << EOF > /etc/kolla/config/glance/ceph.conf
# minimal ceph.conf for ad9e8f76-3aae-11f0-9498-0fcbb987ca56
[global]
fsid = ad9e8f76-3aae-11f0-9498-0fcbb987ca56
mon_host = [v2:10.10.28.6:3300/0,v1:10.10.28.6:6789/0]
[mon.mgr1]
public network = 10.10.28.0/24
EOF

sudo cat << EOF > /etc/kolla/config/cinder/ceph.conf
# minimal ceph.conf for ad9e8f76-3aae-11f0-9498-0fcbb987ca56
[global]
fsid = ad9e8f76-3aae-11f0-9498-0fcbb987ca56
mon_host = [v2:10.10.28.6:3300/0,v1:10.10.28.6:6789/0]
[mon.mgr1]
public network = 10.10.28.0/24
EOF



sudo cat << EOF > /etc/kolla/config/nova/ceph.conf
# minimal ceph.conf for ad9e8f76-3aae-11f0-9498-0fcbb987ca56
[global]
fsid = ad9e8f76-3aae-11f0-9498-0fcbb987ca56
mon_host = [v2:10.10.28.6:3300/0,v1:10.10.28.6:6789/0]
[mon.mgr1]
public network = 10.10.28.0/24
EOF

sudo cat << EOF > /etc/kolla/config/gnocchi/ceph.conf
# minimal ceph.conf for ad9e8f76-3aae-11f0-9498-0fcbb987ca56
[global]
fsid = ad9e8f76-3aae-11f0-9498-0fcbb987ca56
mon_host = [v2:10.10.28.6:3300/0,v1:10.10.28.6:6789/0]
[mon.mgr1]
public network = 10.10.28.0/24
EOF

# Set permissions
sudo chmod 644 /etc/kolla/config/glance/ceph.client.glance.keyring
sudo chmod 644 /etc/kolla/config/cinder/ceph.client.cinder.keyring  
sudo chmod 644 /etc/kolla/config/nova/ceph.client.nova.keyring

# Also ensure the directories are readable
sudo chmod 755 /etc/kolla/config/glance/
sudo chmod 755 /etc/kolla/config/cinder/
sudo chmod 755 /etc/kolla/config/nova/


# Copy keyring files to their appropriate positions on the ansible controller (ctl)
# On the deployment host (ka-ctl2), create the required directory structure
sudo mkdir -p /etc/kolla/config/nova/ka-hv1/
sudo mkdir -p /etc/kolla/config/nova/ka-hv2/
sudo mkdir -p /etc/kolla/config/nova/

# Copy the cinder keyring to the expected locations
sudo cp /etc/kolla/config/cinder/ceph.client.cinder.keyring /etc/kolla/config/nova/
sudo cp /etc/kolla/config/cinder/ceph.client.cinder.keyring /etc/kolla/config/nova/ka-hv1/
sudo cp /etc/kolla/config/cinder/ceph.client.cinder.keyring /etc/kolla/config/nova/ka-hv2/

# Set proper permissions
sudo chmod 644 /etc/kolla/config/nova/ceph.client.cinder.keyring
sudo chmod 644 /etc/kolla/config/nova/ka-hv1/ceph.client.cinder.keyring
sudo chmod 644 /etc/kolla/config/nova/ka-hv2/ceph.client.cinder.keyring




### Generate UUID and put it in globals.yml
uuiden 

## Test connectivity
sudo apt install ceph-common -y

sudo ceph -s --conf /etc/kolla/config/glance/ceph.conf --keyring /etc/kolla/config/glance/ceph.client.glance.keyring --user glance

sudo ceph -s --conf /etc/kolla/config/cinder/ceph.conf --keyring /etc/kolla/config/cinder/ceph.client.cinder.keyring --user cinder 

sudo ceph -s --conf /etc/kolla/config/nova/ceph.conf --keyring /etc/kolla/config/nova/ceph.client.nova.keyring --user nova

##################################### End Ceph



# Octavia fix
sudo mkdir /etc/kolla/config/octavia
sudo chown $USER:$USER /etc/kolla/config/octavia
kolla-ansible octavia-certificates -i inventories/development/hosts.yml

# Fix missing package - do during bootstrap
sudo apt install git-crypt -y


# 2. Configuration deployment
kolla-ansible bootstrap-servers -i inventories/development/hosts.yml
kolla-ansible prechecks -i  inventories/development/hosts.yml

# 3. Core service deployment
kolla-ansible deploy -i  inventories/development/hosts.yml

# Troubleshooting services deployment
kolla-ansible deploy -i  inventories/development/hosts.yml --tags octavia,ironic,masakari

# 4. Post-deployment configuration
kolla-ansible post-deploy -i  inventories/development/hosts.yml


# 5. Service validation
sudo apt  install python3-openstackclient -y
source /etc/kolla/admin-openrc.sh
openstack endpoint list

/kolla/share/kolla-ansible/init-runonce  # Create initial networks and flavors
openstack server create --image cirros --flavor m1.tiny --network demo-net test-vm




# List Service Endpoints
openstack endpoint list

# Service List
openstack service list

# Compute Healthcheck
openstack compute service list

# Network Healthcheck
openstack network agent list

# Storage Healthcheck
openstack volume service list

# Image Healthcheck
openstack image list

# Show back end storage services
openstack volume service list

## Skyline db connection fix. It doesn’t seem to like the 'pmsql' part of the connection string.
# Create a custom skyline.yaml with the corrected database URL
sudo mkdir -p /etc/kolla/config/skyline
sudo bash -c 'cat > /etc/kolla/config/skyline/skyline.yaml << EOF
default:
  database_url: mysql://skyline:ciSKM2hquswyplaukd8IvMqAl2tYs8cyLeACJyxh@10.10.27.250:3306/skyline
EOF'

kolla-ansible reconfigure -i inventories/development/hosts.yml -t skyline
## 


########## Once the precheck comes back ok, Snap VMs
$snapname = 'Try 2 - Installed'
$description = get-date

Get-vm ctl2,ka-ctl1.region.com,ka-ctl2.region.com,ka-ctl3.region.com,ka-net1.region.com,ka-net2.region.com,ka-str1.region.com,ka-hv1.region.com,ka-hv2.region.com | new-snapshot -Name $snapname -Description $description -Quiesce -Memory
########## 

