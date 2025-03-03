# PHP and PHP-FPM Installation on Ubuntu

## Overview
This guide provides steps to install and configure PHP and PHP-FPM on an Ubuntu system.

## Prerequisites
- A server running Ubuntu
- User with sudo privileges

## Step 1: Update System Packages
Before installing, update the package list:
```bash
sudo apt update && sudo apt upgrade -y
```

## Step 2: Install PHP and PHP-FPM
To install the default PHP version:
```bash
sudo apt install php php-fpm -y
```
For a specific version like PHP 8.1:
```bash
sudo apt install php8.1 php8.1-fpm -y
```

## Step 3: Verify Installation
Check PHP version:
```bash
php -v
```
Check PHP-FPM service status:
```bash
systemctl status php-fpm
```
For a specific version:
```bash
systemctl status php8.1-fpm
```

## Step 4: Enable PHP-FPM to Start on Boot
```bash
sudo systemctl enable php-fpm
```
For PHP 8.1:
```bash
sudo systemctl enable php8.1-fpm
```

## Step 5: Configuration Files
PHP and PHP-FPM configuration files are located at:
- PHP CLI: `/etc/php/8.1/cli/php.ini`
- PHP-FPM: `/etc/php/8.1/fpm/php.ini`
- PHP-FPM pool settings: `/etc/php/8.1/fpm/pool.d/www.conf`

To edit configurations:
```bash
sudo nano /etc/php/8.1/fpm/php.ini
```
Restart PHP-FPM after making changes:
```bash
sudo systemctl restart php8.1-fpm
```

