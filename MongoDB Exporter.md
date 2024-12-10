
---

# MongoDB Exporter Setup Guide

## Overview

This guide provides step-by-step instructions to install and configure **MongoDB Exporter**, which exposes MongoDB server metrics for Prometheus monitoring.

## Prerequisites

- A Linux-based system (e.g., Ubuntu)
- Access to terminal with `sudo` privileges
- MongoDB server running and accessible
- Basic knowledge of Linux commands and configuration files

## 1. **Installing MongoDB Exporter**

1. **Download MongoDB Exporter**:
   ```bash
   wget https://github.com/prometheus/mongodb_exporter/releases/download/v0.32.0/mongodb_exporter-0.32.0.linux-amd64.tar.gz
   ```

2. **Extract the tarball**:
   ```bash
   tar -xzvf mongodb_exporter-0.32.0.linux-amd64.tar.gz
   ```

3. **Move MongoDB Exporter files to `/usr/local/bin/`**:
   ```bash
   sudo mv mongodb_exporter-0.32.0.linux-amd64/mongodb_exporter /usr/local/bin/
   ```

4. **Verify that MongoDB Exporter is executable**:
   ```bash
   sudo chmod +x /usr/local/bin/mongodb_exporter
   ```

5. **Create a MongoDB Exporter user**:
   ```bash
   sudo useradd --no-create-home --shell /bin/false mongodb_exporter
   ```

6. **Set up MongoDB Exporter permissions**:

   MongoDB Exporter needs read access to MongoDB metrics. The user you create must have sufficient privileges to collect these metrics. You can create a MongoDB user for this purpose.

   Log in to MongoDB shell and create the necessary user:

   ```bash
   mongo
   ```

   Then, in the MongoDB shell, run:

   ```js
   db.createUser({
     user: "mongodb_exporter",
     pwd: "yourpassword",
     roles: [{ role: "clusterMonitor", db: "admin" }]
   })
   ```

   This grants the `mongodb_exporter` user read-only access to the MongoDB server's metrics.

## 2. **Create the MongoDB Exporter Systemd Service File**

1. **Create the service file**:
   ```bash
   sudo nano /etc/systemd/system/mongodb_exporter.service
   ```

2. **Add the following contents to the service file**:

   ```ini
   [Unit]
   Description=MongoDB Exporter
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=mongodb_exporter
   Group=mongodb_exporter
   ExecStart=/usr/local/bin/mongodb_exporter --mongodb.uri="mongodb://mongodb_exporter:yourpassword@localhost:27017"
   Restart=always
   StandardOutput=syslog
   StandardError=syslog
   SyslogIdentifier=mongodb_exporter

   [Install]
   WantedBy=multi-user.target
   ```

   Replace `yourpassword` with the password you set for the `mongodb_exporter` user in MongoDB.

3. **Reload systemd to apply the new service**:
   ```bash
   sudo systemctl daemon-reload
   ```

4. **Start and enable MongoDB Exporter**:
   ```bash
   sudo systemctl start mongodb_exporter
   sudo systemctl enable mongodb_exporter
   ```

## 3. **Configuring Prometheus**

To scrape MongoDB metrics with Prometheus, you need to add MongoDB Exporter as a target in your Prometheus configuration.

1. **Edit Prometheus configuration file** (`/etc/prometheus/prometheus.yml`):
   ```yaml
   scrape_configs:
     - job_name: 'mongodb_exporter'
       static_configs:
         - targets: ['localhost:9216']
           labels:
             environment: 'production'
             instance: 'mongo-db'
             job: 'mongodb_exporter'
   ```

2. **Restart Prometheus** to apply the changes:
   ```bash
   sudo systemctl restart prometheus
   ```

## 4. **Verifying the Installation**

1. **Access Metrics**:
   Open a browser or use `curl` to check if MongoDB Exporter is exposing metrics:

   ```bash
   curl http://localhost:9216/metrics
   ```

2. **Expected Outcome**:
   You should see a list of MongoDB-related metrics in the response, such as `mongodb_up`, `mongodb_connections`, `mongodb_op_latency_ms`, etc.

## 5. **Troubleshooting**

1. **Check MongoDB Exporter Logs**:
   If MongoDB Exporter is not starting correctly, you can check its logs with:

   ```bash
   sudo journalctl -u mongodb_exporter -f
   ```

2. **Check Prometheus Logs**:
   If Prometheus is not scraping MongoDB metrics, check Prometheus logs:

   ```bash
   sudo journalctl -u prometheus -f
   ```

## 6. **Configuring Grafana (Optional)**

If you want to visualize MongoDB metrics, you can use Grafana.

1. **Add Prometheus as a data source** in Grafana.

2. **Import a MongoDB Dashboard** from Grafana's dashboard repository or create your own dashboards based on the metrics exposed by MongoDB Exporter.

---

## Conclusion

By following these steps, you should have MongoDB Exporter installed, configured, and exposing metrics for Prometheus to scrape. You can now monitor the performance of your MongoDB instance and integrate it with Grafana for visualization and alerting.

