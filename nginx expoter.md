Sure! To use port `19113` instead of the default `8080` for the NGINX Prometheus Exporter, you'll need to update the NGINX configuration and the systemd service file accordingly.

Here are the updated steps:

### 1. Install NGINX Prometheus Exporter

#### 1.1 Download NGINX Prometheus Exporter

First, download the NGINX Prometheus Exporter tarball for Linux from the official GitHub releases page. Use `wget` to fetch the file:

```bash
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v1.4.0/nginx-prometheus-exporter-1.4.0-linux-amd64.tar.gz
```

#### 1.2 Extract the Tarball

Next, extract the tarball using the `tar` command:

```bash
tar -xzvf nginx-prometheus-exporter-1.4.0-linux-amd64.tar.gz
```

This will extract the contents into a directory named `nginx-prometheus-exporter-1.4.0-linux-amd64/`.

#### 1.3 Move the NGINX Prometheus Exporter Binary

Now, move the binary to `/usr/local/bin` to make it available globally:

```bash
sudo mv nginx-prometheus-exporter-1.4.0-linux-amd64/nginx-prometheus-exporter /usr/local/bin/
```

#### 1.4 Create a Dedicated User for NGINX Prometheus Exporter

For security, it's best to run the NGINX Prometheus Exporter under its own user. Create a dedicated user without login capabilities:

```bash
sudo useradd --no-create-home --shell /bin/false nginx_exporter
```

#### 1.5 Set Permissions

Set the proper permissions for the NGINX Prometheus Exporter binary:

```bash
sudo chown nginx_exporter:nginx_exporter /usr/local/bin/nginx-prometheus-exporter
sudo chmod 755 /usr/local/bin/nginx-prometheus-exporter
```

### 2. Configure NGINX for NGINX Prometheus Exporter

#### 2.1 Configure NGINX to Expose Metrics on Port 19113

To collect metrics from NGINX, you need to ensure that NGINX is configured to expose status information in a format that the Prometheus Exporter can scrape. Add the following block to your NGINX configuration (e.g., `/etc/nginx/nginx.conf` or `/etc/nginx/conf.d/default.conf`):

```nginx
server {
    listen 127.0.0.1:19113;

    location /metrics {
        stub_status on;
        access_log off;
        allow 127.0.0.1;  # Allow Prometheus Exporter to access the status page
        deny all;
    }
}
```

This configuration exposes the status page on `localhost:19113/metrics`. Make sure to reload or restart NGINX to apply the changes:

```bash
sudo systemctl reload nginx
```

#### 2.2 Create Environment File (Optional)

If you want to store the NGINX configuration as an environment file (for example, if you're using a custom port or other options), you can create a file to store the configuration.

Create the environment file `/opt/nginx_exporter/.nginx.env` and add the following content:

```bash
NGINX_STATUS_URL="http://localhost:19113/metrics"
```

Make sure the environment file has the correct permissions:

```bash
sudo chown nginx_exporter:nginx_exporter /opt/nginx_exporter/.nginx.env
sudo chmod 640 /opt/nginx_exporter/.nginx.env
```

### 3. Create Systemd Service for NGINX Prometheus Exporter

#### 3.1 Create a Service File

To run NGINX Prometheus Exporter as a service, create a systemd service file at `/etc/systemd/system/nginx-prometheus-exporter.service`:

```bash
sudo nano /etc/systemd/system/nginx-prometheus-exporter.service
```

Add the following content to the service file:

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
WorkingDirectory=/opt/nginx_exporter
EnvironmentFile=/opt/nginx_exporter/.nginx.env
ExecStart=/usr/local/bin/nginx-prometheus-exporter \
  -nginx.scrape-uri=$NGINX_STATUS_URL

[Install]
WantedBy=multi-user.target
```

This configuration tells systemd how to start the exporter, including any environment variables (like the NGINX status URL).

#### 3.2 Reload Systemd Configuration

Reload the systemd configuration to apply the new service:

```bash
sudo systemctl daemon-reload
```

### 4. Start and Enable NGINX Prometheus Exporter Service

#### 4.1 Start the Service

Start the NGINX Prometheus Exporter service:

```bash
sudo systemctl start nginx-prometheus-exporter
```

#### 4.2 Enable the Service to Start on Boot

Enable the service to start automatically on boot:

```bash
sudo systemctl enable nginx-prometheus-exporter
```

#### 4.3 Check the Service Status

Check the status of the service to ensure it is running properly:

```bash
sudo systemctl status nginx-prometheus-exporter
```

If the service is running correctly, you should see an output indicating the service is active. If not, you can check the logs:

```bash
sudo journalctl -u nginx-prometheus-exporter -f
```

### 5. Verify Metrics Endpoint

To verify that the NGINX Prometheus Exporter is working, you can check the metrics endpoint by navigating to:

```bash
curl http://localhost:19113/metrics
```

You should see a list of Prometheus-compatible metrics related to NGINX.

### 6. Configure Prometheus to Scrape Metrics

#### 6.1 Edit Prometheus Configuration

To have Prometheus scrape the NGINX metrics, you need to edit the `prometheus.yml` configuration file:

```bash
sudo nano /etc/prometheus/prometheus.yml
```

Add the following scrape configuration under `scrape_configs`:

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

#### 6.2 Reload Prometheus Configuration

Once you've updated the configuration, reload Prometheus to apply the changes:

```bash
sudo systemctl reload prometheus
```

### 7. Troubleshooting and Logs

#### NGINX Prometheus Exporter Logs

If there are any issues with the NGINX Prometheus Exporter, you can check its logs:

```bash
sudo journalctl -u nginx-prometheus-exporter -f
```

#### Prometheus Target Check

To verify if Prometheus is successfully scraping the NGINX metrics, you can go to the Prometheus web UI (typically available at `http://localhost:9090/targets`). Check if the `nginx-prometheus-exporter` target is up and running.

#### Metrics Check

If Prometheus is not scraping metrics, make sure that the NGINX Prometheus Exporter is accessible at `http://localhost:19113/metrics` and that the NGINX status page is working correctly.

---

That's it! You've successfully installed, configured, and set up NGINX Prometheus Exporter to expose metrics from NGINX on port `19113`, and have Prometheus scrape those metrics.
