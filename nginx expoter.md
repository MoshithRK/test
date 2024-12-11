For **Ubuntu** (or other Linux distributions), you should use the `nginx-prometheus-exporter_1.4.0_linux_amd64.tar.gz` file, as it is the appropriate binary for Linux with an `amd64` architecture.

### Steps to Download and Install the `nginx-prometheus-exporter` for Ubuntu

#### 1. **Download the Tarball**
To download the `nginx-prometheus-exporter` binary for Linux (amd64 architecture), run the following `wget` command:

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
It's good practice to run the exporter as a non-root user. You can create a dedicated user for this:

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
Next, create a systemd service to manage the exporter.

Create the service file:

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
#use localhost ip(http://192.168.1.181:8080/nginx_status/stub_status)(use hostname -i)
[Install]
WantedBy=multi-user.target
```

In this example:
- The exporter will listen on port `19113`.
- The NGINX status page is assumed to be available at `http://localhost:8080/nginx_status/stub_status`. Replace `localhost` with your server's IP if needed.

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
You can test if the exporter is running and exposing metrics by accessing the following URL:

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
Reload Prometheus to apply the changes:

```bash
sudo systemctl reload prometheus
```

---

### Summary:
- **Download** the `nginx-prometheus-exporter_1.4.0_linux_amd64.tar.gz` file.
- **Extract** the tarball and move the binary to `/usr/local/bin`.
- **Create a dedicated user** for running the exporter.
- **Create a systemd service** to run the exporter on boot.
- **Configure Prometheus** to scrape the exporter metrics.

This setup will allow you to run the `nginx-prometheus-exporter` on your Ubuntu system and expose NGINX metrics for Prometheus to scrape. Let me know if you need any further assistance!


```bash
#:/etc/nginx/conf.d$ cat status.conf 
server {
    listen 8000;
    server_name 192.168.1.181;

    location /nginx_status {
        stub_status on;  
        access_log off;
        #access_log off;
        allow 192.168.1.0/24;
        deny all;
    }
}
```

