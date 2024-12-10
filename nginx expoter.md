Got it! You want to configure the NGINX Prometheus Exporter to listen on port `19113` and scrape NGINX metrics from a remote NGINX server at `http://10.102.3.100:8080/nginx_status/stub_status`.

Here’s how to update the **systemd service** to use the remote NGINX status page URL.

### Full Steps to Install and Configure NGINX Prometheus Exporter with Remote NGINX Status URL

### 1. **Download and Extract NGINX Prometheus Exporter**

#### 1.1 Download the Exporter

Use `wget` to download the NGINX Prometheus Exporter tarball from GitHub:

```bash
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v1.4.0/nginx-prometheus-exporter-1.4.0-linux-amd64.tar.gz
```

#### 1.2 Extract the Tarball

Extract the tarball using the `tar` command:

```bash
tar -xzvf nginx-prometheus-exporter-1.4.0-linux-amd64.tar.gz
```

#### 1.3 Move the Binary

Move the extracted binary to `/usr/local/bin`:

```bash
sudo mv nginx-prometheus-exporter-1.4.0-linux-amd64/nginx-prometheus-exporter /usr/local/bin/
```

#### 1.4 Set Permissions

Ensure the binary has the correct permissions:

```bash
sudo chown nginx_exporter:nginx_exporter /usr/local/bin/nginx-prometheus-exporter
sudo chmod 755 /usr/local/bin/nginx-prometheus-exporter
```

### 2. **Configure NGINX to Expose Metrics (on Remote Server)**

Assuming that NGINX is running on a remote server (`10.102.3.100`), you need to make sure the NGINX configuration on that server exposes the `stub_status` page.

On **remote NGINX server (`10.102.3.100`)**, add this to the `nginx.conf` (or `/etc/nginx/conf.d/default.conf`):

```nginx
server {
    listen 8080;

    location /nginx_status {
        stub_status on;
        access_log off;
        allow 10.102.3.0/24;  # Allow internal network to access the status page
        deny all;
    }
}
```

Make sure the `nginx_status` page is available by reloading or restarting NGINX on the remote server:

```bash
sudo systemctl reload nginx
```

### 3. **Create Systemd Service for NGINX Prometheus Exporter**

#### 3.1 Create the Service File

On the **Prometheus server**, create the systemd service for NGINX Prometheus Exporter. The key change here is to use the remote NGINX status URL (`http://10.102.3.100:8080/nginx_status/stub_status`).

Create the service file at `/etc/systemd/system/nginx-prometheus-exporter.service`:

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
ExecStart=/usr/local/bin/nginx-prometheus-exporter \
  --web.listen-address=:19113 \
  --nginx.scrape-uri=http://10.102.3.100:8080/nginx_status/stub_status \
  --log.level=error

[Install]
WantedBy=multi-user.target
```

**Explanation of parameters**:
- `--web.listen-address=:19113`: This configures the exporter to listen for Prometheus scrape requests on port `19113`.
- `--nginx.scrape-uri=http://10.102.3.100:8080/nginx_status/stub_status`: This tells the exporter where to scrape the NGINX metrics (on a remote server `10.102.3.100`).
- `--log.level=error`: This sets the logging level to `error`, which minimizes unnecessary log output.

#### 3.2 Reload systemd Configuration

Reload the systemd configuration to register the new service:

```bash
sudo systemctl daemon-reload
```

### 4. **Start and Enable NGINX Prometheus Exporter Service**

#### 4.1 Start the Service

Start the NGINX Prometheus Exporter service:

```bash
sudo systemctl start nginx-prometheus-exporter
```

#### 4.2 Enable the Service on Boot

Enable the service to start automatically when the system boots:

```bash
sudo systemctl enable nginx-prometheus-exporter
```

#### 4.3 Check Service Status

To ensure that the service is running properly, check its status:

```bash
sudo systemctl status nginx-prometheus-exporter
```

If there are any issues, you can view the logs:

```bash
sudo journalctl -u nginx-prometheus-exporter -f
```

### 5. **Verify Metrics Endpoint**

To verify that the NGINX Prometheus Exporter is correctly exposing metrics on `localhost:19113`, use `curl`:

```bash
curl http://localhost:19113/metrics
```

You should see a list of Prometheus-compatible metrics related to NGINX.

### 6. **Configure Prometheus to Scrape Metrics**

#### 6.1 Edit Prometheus Configuration

To have Prometheus scrape the NGINX metrics, edit the Prometheus configuration file (`/etc/prometheus/prometheus.yml`):

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

This tells Prometheus to scrape the metrics from `localhost:19113`, where the exporter is running.

#### 6.2 Reload Prometheus Configuration

Once you've updated the configuration, reload Prometheus to apply the changes:

```bash
sudo systemctl reload prometheus
```

### 7. **Troubleshooting and Logs**

#### NGINX Prometheus Exporter Logs

If you encounter any issues with the NGINX Prometheus Exporter, you can check its logs:

```bash
sudo journalctl -u nginx-prometheus-exporter -f
```

#### Prometheus Target Check

To verify that Prometheus is scraping the NGINX metrics, go to the Prometheus web UI (typically at `http://localhost:9090/targets`). You should see the `nginx-prometheus-exporter` target listed as up and scraping.

#### Metrics Check

If Prometheus is not scraping metrics, ensure the exporter is accessible at `http://localhost:19113/metrics` and that the NGINX status page on `http://10.102.3.100:8080/nginx_status/stub_status` is available.

---

### Summary of Key Changes
- **Remote NGINX status URL**: You have configured the `nginx-prometheus-exporter` to scrape the status page from `http://10.102.3.100:8080/nginx_status/stub_status`.
- **Exporter listens on port 19113**: The exporter is configured to expose Prometheus metrics on port `19113`.
- **NGINX Configuration**: On the remote server (`10.102.3.100`), NGINX is configured to expose the `stub_status` page at `http://localhost:8080/nginx_status`.

This setup will allow Prometheus to scrape NGINX metrics from a remote server and monitor NGINX performance.
