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

## 5. **Creating Alert Rules**

Prometheus uses rule files to define alerts. Below are the rule files used in this setup.

### **Critical Alerts (`/etc/prometheus/linux.yml`)**

```yaml
groups:
  - name: critical-alerts
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 2m
        labels:
          severity: critical
          category: instance
        annotations:
          summary: "Instance Down"
          description: "An instance is down and not responding."

      - alert: RootDiskAlert
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) < 0.1
        for: 2m
        labels:
          severity: critical
          category: disk
        annotations:
          summary: "Low Root Disk Space"
          description: "Root disk space is below 10%."

      - alert: TcpListeningPortAlert
        expr: sum by (instance) (node_netstat_Tcp_Tw) > 0
        for: 2m
        labels:
          severity: critical
          category: network
        annotations:
          summary: "TCP Listening Port Issue"
          description: "There are issues with TCP listening ports."

      - alert: TcpEstablishedPortAlert
        expr: sum by (instance) (node_netstat_Tcp_ActiveOpens) < 1
        for: 2m
        labels:
          severity: critical
          category: network
        annotations:
          summary: "TCP Established Port Issue"
          description: "No active TCP connections established."

      - alert: MemoryAlert
        expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1
        for: 2m
        labels:
          severity: critical
          category: memory
        annotations:
          summary: "Low Available Memory"
          description: "Available memory is below 10%."

      - alert: HighCpuUsageAlert
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 90
        for: 2m
        labels:
          severity: critical
          category: cpu
        annotations:
          summary: "High CPU Usage"
          description: "CPU usage

 exceeds 90%."
```

### **Warning Alerts (`/etc/prometheus/linux1.yml`)**

```yaml
groups:
  - name: warning-alerts
    rules:
      - alert: NetworkConnectionWarning
        expr: node_netstat_Tcp_RetransSegs > 100
        for: 2m
        labels:
          severity: warning
          category: network
        annotations:
          summary: "Network Connectivity Issues"
          description: "TCP retransmissions exceeded 100. Investigate potential network issues."

      - alert: ProcessCountWarning
        expr: count(node_procs_running) > 500
        for: 2m
        labels:
          severity: warning
          category: system
        annotations:
          summary: "High Process Count"
          description: "Running processes exceeded 500. Consider optimizing applications or increasing resources."

      - alert: SystemLoadWarning
        expr: node_load5 > 10
        for: 2m
        labels:
          severity: warning
          category: system
        annotations:
          summary: "System Load High"
          description: "5-minute load average exceeds 10. Investigate potential causes."

      - alert: SwapUsageWarning
        expr: node_memory_SwapUsed > 1 * 1024 * 1024 * 1024
        for: 2m
        labels:
          severity: warning
          category: memory
        annotations:
          summary: "High Swap Usage"
          description: "Swap usage exceeds 1GB. Consider increasing RAM or optimizing applications."
```

### **Info Alerts (`/etc/prometheus/linux2.yml`)**

```yaml
groups:
  - name: info-alerts
    rules:
      - alert: UserLoginAlert
        expr: increase(node_boot_time_seconds[5m]) > 0
        for: 2m
        labels:
          severity: info
          category: security
        annotations:
          summary: "User Login Detected"
          description: "A user has logged in via SSH."
```
