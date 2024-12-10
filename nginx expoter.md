Got it! Below are the detailed steps to install and configure the **Nginx Exporter** on Ubuntu to monitor Nginx with **Prometheus**.

---

## **Prerequisites**:
1. **Ubuntu server** or similar Linux system.
2. **Nginx** installed and running.
3. **Prometheus** installed to scrape the metrics.
4. **Root** (or **sudo**) privileges for configuration.
5. **Basic familiarity** with the terminal and file editing.

---

## **1. Install Nginx Exporter**

### **1.1 Download Nginx Exporter**
First, download the latest release of the Nginx Exporter from GitHub. Replace the version number if needed:

```bash
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.11.1/nginx-prometheus-exporter-0.11.1-linux-amd64.tar.gz
```

### **1.2 Extract the Tarball**

Extract the downloaded tarball to get the binary:

```bash
tar -xzvf nginx-prometheus-exporter-0.11.1-linux-amd64.tar.gz
```

### **1.3 Move the Nginx Exporter Binary**

Move the `nginx-prometheus-exporter` binary to `/usr/local/bin`:

```bash
sudo mv nginx-prometheus-exporter-0.11.1-linux-amd64/nginx-prometheus-exporter /usr/local/bin/
```

### **1.4 Create a Dedicated User for Nginx Exporter**

Create a user for the exporter with no login capabilities:

```bash
sudo useradd --no-create-home --shell /bin/false nginx_exporter
```

### **1.5 Set Permissions**

Set proper permissions for the `nginx-prometheus-exporter` binary:

```bash
sudo chown nginx_exporter:nginx_exporter /usr/local/bin/nginx-prometheus-exporter
sudo chmod 755 /usr/local/bin/nginx-prometheus-exporter
```

---

## **2. Configure Nginx for Exporter**

### **2.1 Enable the Nginx Status Page**

In order for the Nginx exporter to fetch metrics from Nginx, you must enable the **stub_status** module. This is usually enabled by default on most Nginx setups, but if it's not, you can enable it by adding the following location block in your Nginx configuration.

Edit the Nginx configuration file:

```bash
sudo nano /etc/nginx/nginx.conf
```

Add the following `location` block inside the `server` block (under the `http` section):

```nginx
server {
    listen 127.0.0.1:8080;  # Export metrics locally
    server_name localhost;

    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;  # Allow only local connections
        deny all;
    }
}
```

- **Explanation**: This config exposes Nginx's status page at `http://localhost:8080/nginx_status`. You can change the port number if needed, but ensure it's consistent with the exporter configuration.

After updating the Nginx config, **reload Nginx** to apply the changes:

```bash
sudo systemctl reload nginx
```

---

## **3. Create Systemd Service for Nginx Exporter**

### **3.1 Create a Service File**

Now, let's create a systemd service file to run the Nginx Exporter as a service.

Create the file `/etc/systemd/system/nginx_exporter.service`:

```bash
sudo nano /etc/systemd/system/nginx_exporter.service
```

Add the following content to the file:

```ini
[Unit]
Description=Nginx Prometheus Exporter
After=network.target

[Service]
User=nginx_exporter
Group=nginx_exporter
ExecStart=/usr/local/bin/nginx-prometheus-exporter -nginx.scrape-uri=http://localhost:8080/nginx_status
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

- **Explanation**:
  - The `ExecStart` command runs the exporter, pointing it to `http://localhost:8080/nginx_status` (Nginx's status page).
  - The service will restart automatically in case of failure.

### **3.2 Reload systemd Configuration**

Reload the systemd daemon to apply the new service configuration:

```bash
sudo systemctl daemon-reload
```

---

## **4. Start and Enable Nginx Exporter Service**

### **4.1 Start the Service**

Start the Nginx Exporter service:

```bash
sudo systemctl start nginx_exporter
```

### **4.2 Enable the Service to Start on Boot**

Enable the service to start automatically on boot:

```bash
sudo systemctl enable nginx_exporter
```

### **4.3 Check Service Status**

Check the status of the Nginx Exporter service to ensure it's running:

```bash
sudo systemctl status nginx_exporter
```

If there are any issues, check the logs for troubleshooting:

```bash
sudo journalctl -u nginx_exporter -f
```

---

## **5. Verify Metrics Endpoint**

Verify that the Nginx Exporter is correctly scraping the metrics from Nginx. The exporter exposes a `/metrics` endpoint, which Prometheus will scrape.

You can test this by running:

```bash
curl http://localhost:9113/metrics
```

This should return a list of Prometheus-compatible metrics like `nginx_connections_active`, `nginx_connections_handled`, and others.

---

## **6. Configure Prometheus to Scrape Nginx Metrics**

Now, configure **Prometheus** to scrape metrics from the Nginx Exporter.

### **6.1 Edit Prometheus Configuration**

Edit the Prometheus configuration file (`prometheus.yml`):

```bash
sudo nano /etc/prometheus/prometheus.yml
```

Add the following `scrape_configs` section for Nginx:

```yaml
scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['localhost:9113']
    labels:
      environment: 'production'
      instance: 'nginx-server'
```

### **6.2 Reload Prometheus Configuration**

After editing `prometheus.yml`, reload Prometheus to apply the changes:

```bash
sudo systemctl reload prometheus
```

---

## **7. Troubleshooting and Logs**

- **Exporter Logs**: To view logs for the Nginx Exporter, use:

  ```bash
  sudo journalctl -u nginx_exporter -f
  ```

- **Prometheus Target Check**: To check if Prometheus is successfully scraping the metrics, navigate to the Prometheus web UI (usually at `http://localhost:9090/targets`). Ensure that the `nginx` target is listed and its status is "up."

- **Metrics Endpoint**: If Prometheus is not scraping metrics, ensure that the Nginx Exporter is accessible at `http://localhost:9113/metrics`.

---

## **Summary of Steps**:

1. **Install Nginx Exporter** (download, extract, and move the binary).
2. **Enable Nginx status page** by configuring the `stub_status` module.
3. **Create a systemd service** to run the Nginx Exporter.
4. **Start and enable the service** to run on boot.
5. **Verify metrics** by accessing the `/metrics` endpoint.
6. **Configure Prometheus** to scrape Nginx metrics.
7. **Troubleshoot** if necessary by checking logs.

With these steps, you should now be able to monitor your Nginx server with Prometheus using the Nginx Exporter!

Let me know if you need further assistance!
