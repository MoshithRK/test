
# MySQLd Exporter Setup Guide

## Overview

This guide provides step-by-step instructions to install and configure MySQLd Exporter, which is used to expose MySQL server metrics for Prometheus monitoring.

## Prerequisites

- A Linux-based system (e.g., Ubuntu)
- Access to terminal with sudo privileges
- MySQL server running and accessible
- Basic knowledge of Linux commands and configuration files

## 1. **Installing MySQLd Exporter**

1. **Download MySQLd Exporter**:
   ```bash
   wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.15.1/mysqld_exporter-0.15.1.linux-amd64.tar.gz
   ```

2. **Extract the tarball**:
   ```bash
   tar -xzvf mysqld_exporter-0.15.1.linux-amd64.tar.gz
   ```

3. **Create a MySQLd Exporter user**:
   ```bash
   sudo useradd --no-create-home --shell /bin/false mysqld_exporter
   ```

4. **Move MySQLd Exporter files and set permissions**:
   ```bash
   sudo mv mysqld_exporter-0.15.1.linux-amd64/mysqld_exporter /usr/local/bin/
   sudo chown mysqld_exporter:mysqld_exporter /usr/local/bin/mysqld_exporter
   ```

5. **Create a MySQL user for MySQLd Exporter**:
   ```sql
    CREATE USER 'mysqld_exporter'@'localhost' IDENTIFIED BY 'Giraffe#LemonTree88!';
    GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'localhost';
    FLUSH PRIVILEGES;
   ```

6. **Create the MySQLd Exporter systemd service file**:
   ```bash
   sudo nano /etc/systemd/system/mysqld_exporter.service
   ```

   ```ini
   [Unit]
   Description=MySQLd Exporter
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=mysqld_exporter
   Group=mysqld_exporter
   ExecStart=/usr/local/bin/mysqld_exporter \
     --config.my-cnf=/etc/mysqld_exporter.cnf
   StandardOutput=syslog
   StandardError=syslog
   SyslogIdentifier=mysqld_exporter

   [Install]
   WantedBy=multi-user.target
   ```

7. **Create the MySQLd Exporter configuration file**:
   ```bash
   sudo nano /etc/mysqld_exporter.cnf
   ```

   ```ini
   [client]
   user=mysqld_exporter
   password=yourpassword
   ```

8. **Start and enable MySQLd Exporter**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start mysqld_exporter
   sudo systemctl enable mysqld_exporter
   ```

9. **Check the Logs**:

   Now, MySQLd Exporter should be logging to syslog. You can check the logs using:

   ```bash
   sudo tail -f /var/log/syslog | grep mysqld_exporter
   ```

## 2. **Configuring Prometheus**

Edit the Prometheus configuration file `/etc/prometheus/prometheus.yml` to include your MySQLd Exporter target:

```yaml
  # Scrape configuration for mysqld_exporter
  - job_name: 'mysqld_exporter'
    static_configs:
    - targets: ['localhost:19098']
      labels:
        environment: 'production'
        instance: 'erp'
        job: 'mysqld_exporter'

```

## 3. **Verifying the Installation**

1. **Access Metrics**:  
   Open a browser and navigate to `http://localhost:9104/metrics` to verify that MySQLd Exporter is exposing MySQL metrics.

2. **Expected Outcome**:
   You should see a list of metrics related to your MySQL server.

After completing this setup, Prometheus will start scraping MySQL metrics, which can be used for monitoring and alerting in your infrastructure.

---

By following these steps, you should have MySQLd Exporter installed and configured, ready to be monitored by Prometheus.
