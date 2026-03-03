# NextCloud Pi Server on Raspberry Pi 2 

## Overview
This project documents the deployment and routine maintenance of a self-hosted NextCloud server running on Raspberry Pi 2. 

The goal of this project was to:
- Build a personal cloud storage solution
- Learn Linux server administration
- Practice network configuration and security hardening
- Implement automated backup strategies

## Hardware
- Raspberry Pi 2
- 32GB microSD
- 512GB external USB
- Ethernet cable

## Software Stack
- Raspberry Pi OS Lite (Bookworm)
- Apache
- PHP
- MariaDB
- NextCloud
- SSH for headless administration

## Architecture
See '/docs/architecture.md' for full details.

## Security Measures 
- UFW firewall configuration
- SSH key authentication
- Disabled root login

## Backup strategy 
Automated backup script, see '/scripts/login-backup.sh' for full details. 
Backups are triggered upon login from my primary machine and use rsync over SSH. 

## Lessons Learned
- Perfoemance tuning on limited software
- Database optimization
- Importance of automated backups
- Managing permissions on Linux (Bazzite Fedora)
