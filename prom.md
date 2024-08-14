Sure! Below is a sample `README.md` file for setting up Prometheus, including Node Exporter and Alertmanager, based on the details from our conversation.

---

# Prometheus Setup Guide

## Overview

This guide covers setting up Prometheus along with Node Exporter and Alertmanager. It includes configuration details, steps to set up services, and troubleshooting tips.

## Prerequisites

- A Linux-based system (e.g., Ubuntu)
- Access to terminal with sudo privileges
- Basic knowledge of Linux commands and configuration files

## 1. **Installing Prometheus**

1. **Download Prometheus**:
   ```bash
   wget https://github.com/prometheus/prometheus/releases/download/v2.54.0-rc.1/prometheus-2.54.0-rc.1.linux-amd64.tar.gz
   ```

2. **Extract the tarball**:
   ```bash
   tar -xzvf prometheus-2.54.0-rc.1.linux-amd64.tar.gz
   ```

3. **Create a Prometheus user**:
   ```bash
   sudo useradd --no-create-home --shell /bin/false prometheus
   ```

4. **Move Prometheus files and set permissions**:
   ```bash
   sudo mv prometheus-2.54.0-rc.1.linux-amd64/prometheus /usr/local/bin/
   sudo mv prometheus-2.54.0-rc.1.linux-amd64/promtool /usr/local/bin/
   sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
   sudo mkdir /etc/prometheus
   sudo mkdir /var/lib/prometheus
   sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
   ```

5. **Create the Prometheus systemd service file**:
   ```bash
   sudo nano /etc/systemd/system/prometheus.service
   ```

   ```ini
   [Unit]
   Description=Prometheus Monitoring
   Documentation=https://prometheus.io/docs/introduction/overview/
   After=network-online.target

   [Service]
   User=prometheus
   Group=prometheus
   ExecStart=/usr/local/bin/prometheus \
     --config.file /etc/prometheus/prometheus.yml \
     --storage.tsdb.path /var/lib/prometheus/ \
     --web.console.templates=/usr/share/prometheus/consoles \
     --web.console.libraries=/usr/share/prometheus/console_libraries

   [Install]
   WantedBy=multi-user.target
   ```

6. **Start and enable Prometheus**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start prometheus
   sudo systemctl enable prometheus
   ```

## 2. **Installing Node Exporter**

1. **Download Node Exporter**:
   ```bash
   wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
   ```

2. **Extract the tarball**:
   ```bash
   tar -xzvf node_exporter-1.8.2.linux-amd64.tar.gz
   ```

3. **Create a Node Exporter user**:
   ```bash
   sudo useradd --no-create-home --shell /bin/false node_exporter
   ```

4. **Move Node Exporter files and set permissions**:
   ```bash
   sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
   sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
   ```

5. **Create the Node Exporter systemd service file**:
   ```bash
   sudo nano /etc/systemd/system/node_exporter.service
   ```

   ```ini
   [Unit]
   Description=Node Exporter
   Documentation=https://prometheus.io/docs/guides/node-exporter/
   After=network-online.target

   [Service]
   User=node_exporter
   Group=node_exporter
   ExecStart=/usr/local/bin/node_exporter

   [Install]
   WantedBy=multi-user.target
   ```

6. **Start and enable Node Exporter**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start node_exporter
   sudo systemctl enable node_exporter
   ```

## 3. **Installing Alertmanager**

1. **Download Alertmanager**:
   ```bash
   wget https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz
   ```

2. **Extract the tarball**:
   ```bash
   tar -xzvf alertmanager-0.27.0.linux-amd64.tar.gz
   ```

3. **Create an Alertmanager user**:
   ```bash
   sudo useradd --no-create-home --shell /bin/false alertmanager
   ```

4. **Move Alertmanager files and set permissions**:
   ```bash
   sudo mv alertmanager-0.27.0.linux-amd64/alertmanager /usr/local/bin/
   sudo mv alertmanager-0.27.0.linux-amd64/amtool /usr/local/bin/
   sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager /usr/local/bin/amtool
   sudo mkdir /etc/alertmanager
   sudo chown -R alertmanager:alertmanager /etc/alertmanager
   ```

5. **Create the Alertmanager systemd service file**:
   ```bash
   sudo nano /etc/systemd/system/alertmanager.service
   ```

   ```ini
   [Unit]
   Description=Alertmanager
   Documentation=https://prometheus.io/docs/alerting/latest/alertmanager/
   After=network-online.target

   [Service]
   User=alertmanager
   Group=alertmanager
   ExecStart=/usr/local/bin/alertmanager \
     --config.file /etc/alertmanager/alertmanager.yml

   [Install]
   WantedBy=multi-user.target
   ```

6. **Start and enable Alertmanager**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start alertmanager
   sudo systemctl enable alertmanager
   ```

## 4. **Configuring Prometheus**

Edit the Prometheus configuration file `/etc/prometheus/prometheus.yml` to include your Node Exporter and Alertmanager targets:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
  - static_configs:
    - targets: ['localhost:9093']

rule_files:
  - /etc/prometheus/linux.yml
  - /etc/prometheus/linux1.yml
  - /etc/prometheus/linux2.yml

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'local_node_exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'remote_node_exporter'
    static_configs:
      - targets: ['192.168.1.181:9100']
```

## 5. **Troubleshooting**

- **Node Exporter Not Accessible**: Ensure Node Exporter is running and reachable. Check the network connection and firewall settings.
- **Prometheus Errors**: Review Prometheus logs for errors and ensure that the configuration file is correctly formatted.

## Conclusion

You now have Prometheus, Node Exporter, and Alertmanager set up and running. Customize your configurations as needed, and start monitoring your systems effectively.

---
