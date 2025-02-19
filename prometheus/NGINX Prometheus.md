# **Installing and Configuring NGINX Prometheus Exporter on Ubuntu**

This guide will walk you through the process of setting up the **NGINX Prometheus Exporter** on an Ubuntu system (or other Linux distributions). The exporter will allow Prometheus to scrape metrics from your NGINX server for monitoring purposes.

### **Prerequisites**
- An NGINX server running on the system.
- Prometheus installed and configured to scrape metrics from NGINX.
- A working Ubuntu machine or other Linux-based distributions.

### **Steps to Download and Install the `nginx-prometheus-exporter` for Ubuntu**

#### 1. **Download the Tarball**

To download the `nginx-prometheus-exporter` binary for Linux (amd64 architecture), run the following command:

```bash
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v1.4.0/nginx-prometheus-exporter_1.4.0_linux_amd64.tar.gz
```

#### 2. **Extract the Tarball**

Once the download is complete, extract the tarball:

```bash
tar -xzvf nginx-prometheus-exporter_1.4.0_linux_amd64.tar.gz
```

This will create a directory containing the `nginx-prometheus-exporter` binary.

#### 3. **Move the Binary to a System Directory**

Move the binary to `/usr/local/bin` (or another directory in your `PATH`):

```bash
sudo mv nginx-prometheus-exporter /usr/local/bin/
```

#### 4. **Create a Dedicated User for the Exporter**

It's best practice to run the exporter as a non-root user. Create a dedicated user for this task:

```bash
sudo useradd --no-create-home --shell /bin/false nginx_exporter
```

#### 5. **Set Permissions**

Ensure the binary has the correct ownership and permissions:

```bash
sudo chown nginx_exporter:nginx_exporter /usr/local/bin/nginx-prometheus-exporter
sudo chmod 755 /usr/local/bin/nginx-prometheus-exporter
```

#### 6. **Create a Systemd Service for the Exporter**

Now, you need to create a systemd service to run the exporter at startup. First, create the systemd service file:

```bash
sudo nano /etc/systemd/system/nginx-prometheus-exporter.service
```

Add the following content to the file:

```ini
[Unit]
Description=NGINX Prometheus Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nginx_exporter
Group=nginx_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/nginx-prometheus-exporter --web.listen-address=:19113 --nginx.scrape-uri=http://192.168.1.181:8080/nginx_status/stub_status  --log.level=error

[Install]
WantedBy=multi-user.target
```

In this configuration:
- The exporter will listen on port `19113`.
- The NGINX status page is assumed to be available at `http://192.168.1.181:8080/nginx_status/stub_status`. Replace `localhost` with your server's IP if needed.

#### 7. **Reload Systemd and Start the Service**

Now reload systemd to apply the new service configuration:

```bash
sudo systemctl daemon-reload
```

Start the service:

```bash
sudo systemctl start nginx-prometheus-exporter
```

Enable the service to start automatically on boot:

```bash
sudo systemctl enable nginx-prometheus-exporter
```

#### 8. **Verify the Service**

You can check the status of the service to ensure it's running correctly:

```bash
sudo systemctl status nginx-prometheus-exporter
```

To view logs, use:

```bash
sudo journalctl -u nginx-prometheus-exporter -f
```

#### 9. **Verify the Metrics Endpoint**

To test if the exporter is running and exposing metrics, you can access the following URL:

```bash
curl http://localhost:19113/metrics
```

This should return a list of Prometheus-compatible metrics.

#### 10. **Configure Prometheus to Scrape the Metrics**

To have Prometheus scrape the metrics, you need to update the Prometheus configuration (`prometheus.yml`) to include the new job.

Edit the `prometheus.yml` configuration:

```bash
sudo nano /etc/prometheus/prometheus.yml
```

Add the following scrape job under `scrape_configs`:

```yaml
scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['localhost:19113']
    labels:
      environment: 'production'
      instance: 'nginx-web-server'
      job: 'nginx-prometheus-exporter'
```

#### 11. **Reload Prometheus Configuration**

To apply the changes, reload Prometheus:

```bash
sudo systemctl reload prometheus
```

---

### **Configuring NGINX to Expose Metrics**

In order to scrape the NGINX metrics, you need to configure NGINX to expose the necessary `stub_status` page. Here’s how to do that:

1. **Create or Update the NGINX Status Configuration**

Edit the NGINX configuration to expose the `nginx_status` page:

```bash
sudo nano /etc/nginx/conf.d/status.conf
```

Add the following content:

```nginx
server {
    listen 8000;
    server_name 192.168.1.181;

    location /nginx_status {
        stub_status on;  
        access_log off;
        allow 192.168.1.0/24;  # Allow access from your network range
        deny all;              # Deny others
    }
}
```

2. **Reload NGINX**

After making changes to the NGINX configuration, reload it to apply the changes:

```bash
sudo systemctl reload nginx
```

---

### **Summary**

- **Download** the `nginx-prometheus-exporter` binary.
- **Extract** the tarball and move the binary to `/usr/local/bin`.
- **Create a dedicated user** for running the exporter.
- **Create a systemd service** to manage the exporter.
- **Configure NGINX** to expose the `stub_status` page for Prometheus to scrape.
- **Configure Prometheus** to scrape the metrics exposed by the exporter.

With this setup, you will be able to monitor your NGINX server with Prometheus and get valuable insights into its performance.

Let me know if you need further assistance!
