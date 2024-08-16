

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
   Description=Prometheus
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=prometheus
   Group=prometheus
   ExecStart=/usr/local/bin/prometheus \
     --config.file=/etc/prometheus/prometheus.yml \
     --storage.tsdb.path=/var/lib/prometheus/data \
     --storage.tsdb.retention.time=90d \
     --web.console.templates=/usr/local/share/prometheus/consoles \   
     --web.console.libraries=/usr/local/share/prometheus/console_libraries \
     --web.listen-address=0.0.0.0:8080 \
     --log.level=info
   StandardOutput=syslog
   StandardError=syslog
   SyslogIdentifier=prometheus

   [Install]
   WantedBy=multi-user.target


   ```

6. **Start and enable Prometheus**:
   ```bash
   sudo systemctl stop prometheus
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
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=node_exporter
   Group=node_exporter
   ExecStart=/usr/local/bin/node_exporter \
     --web.listen-address=:7777 \
     --log.level=info
   StandardOutput=syslog
   StandardError=syslog
   SyslogIdentifier=node_exporter

   [Install]
   WantedBy=multi-user.target



   ```

6. **Start and enable Node Exporter**:
   ```bash
   sudo systemctl stop node_exporter
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

## 4. **Creating Alert Rules**

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


---

## 5. **Integration with Slack**

To integrate Alertmanager with Slack for sending alerts, follow these steps:

1. **Open Slack in your Web Browser**
   - Open your Slack workspace in a web browser.

2. **Access App Management**
   - Go to the top left corner of Slack.
   - Click on your name to open the menu.
   - Select `Tools and Settings`.
   - Click on `Manage Apps`.
     
![Image](https://github.com/devopsflash/test/blob/main/Screenshot%20from%202024-08-14%2015-17-16.png)
     

3. **Add Incoming Webhooks**
   - In the Slack App Directory, type "Incoming Webhooks" into the search bar.
   - Select "Incoming Webhooks" from the search results.
   - Click `Add to Slack`.

![Image](https://github.com/devopsflash/test/blob/main/Screenshot%20from%202024-08-14%2015-20-04.png)

4. **Configure Incoming Webhook**
   - Choose the Slack channel where you want the alerts to be sent.
   - Click `Add Incoming Webhook Integration`.
   - A Webhook URL will be generated for you.

![Image](https://github.com/devopsflash/test/blob/main/Screenshot%20from%202024-08-14%2015-20-20.png)



5. **Copy the Webhook URL**
   - Copy the generated Webhook URL. You will need this URL to configure Alertmanager.


![Image](https://github.com/devopsflash/test/blob/main/Screenshot%20from%202024-08-14%2015-22-10.png)


6. **Update Alertmanager Configuration**
   - Paste the copied Webhook URL into the `alertmanager.yml` file under the `receivers` section.

7. **Save Changes**
   - Save the changes to `alertmanager.yml` and exit the editor.

![Image](https://github.com/devopsflash/test/blob/main/Screenshot%20from%202024-08-14%2015-23-56.png)

### **Alertmanager Configuration (`/etc/alertmanager/alertmanager.yml`)**

```yaml
global:
  resolve_timeout: 5m

route:
  receiver: 'critical-slack'
  routes:
    - match:
        severity: critical
      receiver: 'critical-slack'
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h

    - match:
        severity: warning
      receiver: 'warning-slack'
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 30m

    - match:
        severity: info
      receiver: 'info-slack'
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h

receivers:
  - name: 'critical-slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/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'
        channel: '#critical-slack'
        username: 'alertmanager'
        icon_emoji: ':warning:'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}\n{{ .Annotations.description }}\n<{{ .GeneratorURL }}|View in Prometheus>{{ end }}'
        send_resolved: true

  - name: 'warning-slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/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'
        channel: '#warning-info-slack'
        username: 'alertmanager'
        icon_emoji: ':warning:'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}\n{{ .Annotations.description }}\n<{{ .GeneratorURL }}|View in Prometheus>{{ end }}'
        send_resolved: true

  - name: 'info-slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/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'
        channel: '#info-slack'
        username: 'alertmanager'
        icon_emoji: ':information_source:'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}\n{{ .Annotations.description }}\n<{{ .GeneratorURL }}|View in Prometheus>{{ end }}'
        send_resolved: true

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'instance']
```

---


## 5. **Configuring Prometheus**

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
      - targets: ['localhost:8080']

  - job_name: 'local_node_exporter'
    static_configs:
      - targets: ['localhost:7777']

  - job_name: 'remote_node_exporter'
    static_configs:
      - targets: ['192.168.1.181:7777']


```

