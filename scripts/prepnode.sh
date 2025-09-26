# !/bin/bash
# Kolla pre-install prep for ubuntu 24.04 nodes
sudo systemctl status apparmor
sudo systemctl stop apparmor
sudo systemctl disable apparmor

# Some prereq's from https://www.linuxtechi.com/install-kubernetes-on-ubuntu-24-04/
sudo swapoff -a 
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Upgrade kernel to 6.8 hwe
sudo apt install linux-image-6.8.0-52-generic linux-headers-6.8.0-52-generic linux-modules-6.8.0-52-generic -y
sudo apt install linux-generic-hwe-22.04 -y
sudo update-grub

# Generic Resize Disk  Ubuntu 24
sudo growpart /dev/sda 3
sudo pvresize /dev/sda3
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

sudo reboot now 
