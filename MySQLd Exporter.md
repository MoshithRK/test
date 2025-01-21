
# MySQLd Exporter Setup Guide

## Overview

This guide provides step-by-step instructions to install and configure MySQLd Exporter, which is used to expose MySQL server metrics for Prometheus monitoring.

## Prerequisites

- A Linux-based system (e.g., Ubuntu)
- Access to terminal with sudo privileges
- MySQL server running and accessible
- Basic knowledge of Linux commands and configuration files

---

### Step 1: Update and Install MySQL
1. Update the package list:
   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```

2. Install MySQL server:
   ```bash
   sudo apt install mysql-server -y
   ```

3. Start and enable MySQL service:
   ```bash
   sudo systemctl start mysql
   sudo systemctl enable mysql
   ```

---

### Step 2: Create `mysqld_exporter` User in MySQL
1. Log in to MySQL:
   ```bash
   sudo mysql
   ```

2. Create the `mysqld_exporter` user and grant all privileges:
   ```sql
   CREATE USER 'mysqld_exporter'@'localhost' IDENTIFIED BY 'exporter_password';
   GRANT ALL PRIVILEGES ON *.* TO 'mysqld_exporter'@'localhost' WITH GRANT OPTION;
   FLUSH PRIVILEGES;
   ```

3. Exit MySQL:
   ```sql
   EXIT;
   ```

---

### Step 3: Download and Install `mysqld_exporter`
1. Download the exporter binary:
   ```bash
   wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.16.0/mysqld_exporter-0.16.0.linux-amd64.tar.gz
   ```

2. Extract the archive:
   ```bash
   tar -xvzf mysqld_exporter-0.16.0.linux-amd64.tar.gz
   ```

3. Move the binary to `/usr/local/bin`:
   ```bash
   sudo mv mysqld_exporter-0.16.0.linux-amd64/mysqld_exporter /usr/local/bin/
   ```

4. Set ownership and permissions:
   ```bash
   sudo chown mysqld_exporter:mysqld_exporter /usr/local/bin/mysqld_exporter
   sudo chmod +x /usr/local/bin/mysqld_exporter
   ```

---

### Step 4: Create `mysqld_exporter` User and Group
1. Create a system user and group for `mysqld_exporter`:
   ```bash
   sudo useradd --no-create-home --shell /bin/false mysqld_exporter
   ```

---

### Step 5: Configure MySQL Exporter Authentication
1. Create a MySQL exporter configuration file:
   ```bash
   sudo nano /etc/mysqld_exporter.cnf
   ```

2. Add the following contents:
   ```ini
   [client]
   user=mysqld_exporter
   password=exporter_password
   ```

3. Set appropriate permissions for the file:
   ```bash
   sudo chown mysqld_exporter:mysqld_exporter /etc/mysqld_exporter.cnf
   sudo chmod 600 /etc/mysqld_exporter.cnf
   ```

---

### Step 6: Configure `mysqld_exporter` as a Service
1. Create a systemd service file:
   ```bash
   sudo nano /etc/systemd/system/mysqld_exporter.service
   ```

2. Add the following content:
   ```ini
   [Unit]
   Description=Prometheus MySQL Exporter
   After=network.target

   [Service]
   Type=simple
   Restart=always
   RestartSec=5s
   User=mysqld_exporter
   Group=mysqld_exporter
   ExecStart=/usr/local/bin/mysqld_exporter \
     --config.my-cnf=/etc/mysqld_exporter.cnf \
     --web.telemetry-path=/metrics \
     --web.listen-address=0.0.0.0:19104 \
     --log.level=error

   [Install]
   WantedBy=multi-user.target
   ```

3. Reload systemd and start the service:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start mysqld_exporter
   sudo systemctl enable mysqld_exporter
   ```

---

### Step 7: Verify Exporter is Running
1. Check the service status:
   ```bash
   sudo systemctl status mysqld_exporter
   ```

2. Confirm the exporter is listening on port 19104:
   ```bash
   curl http://localhost:19104/metrics
   ```

---

### Step 8: Configure Prometheus to Scrape MySQL Metrics
1. Edit your Prometheus configuration file (e.g., `/etc/prometheus/prometheus.yml`):
   ```bash
   sudo nano /etc/prometheus/prometheus.yml
   ```

2. Add the following scrape configuration:
   ```yaml
   - job_name: mysqld
     static_configs:
       - targets:
           - localhost:19104
         labels:
           instance: mysql-server
   ```

3. Reload Prometheus to apply the changes:
   ```bash
   sudo systemctl reload prometheus
   ```

---

Your MySQL Exporter is now set up and Prometheus is scraping metrics from it. 🎉
## 3. **Verifying the Installation**

1. **Access Metrics**:  
   Open a browser and navigate to `http://localhost:9104/metrics` to verify that MySQLd Exporter is exposing MySQL metrics.

2. **Expected Outcome**:
   You should see a list of metrics related to your MySQL server.

After completing this setup, Prometheus will start scraping MySQL metrics, which can be used for monitoring and alerting in your infrastructure.

---

By following these steps, you should have MySQLd Exporter installed and configured, ready to be monitored by Prometheus.
