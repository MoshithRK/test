It looks like the URL you tried to download from points to an older version (`v0.11.1`) that no longer exists, and the latest release is `v1.4.0`. To install the **Nginx Prometheus Exporter** version `1.4.0` (or any latest version), you can follow the updated steps below.

---

### **Step 1: Download the Latest Nginx Prometheus Exporter**

You can download the latest version (`v1.4.0`) from the official GitHub releases page. Use the appropriate command for your system architecture.

For **64-bit Linux** systems (amd64 architecture):

```bash
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v1.4.0/nginx-prometheus-exporter_1.4.0_linux_amd64.tar.gz
```

### **Step 2: Extract the Downloaded Tarball**

After the download is complete, extract the tarball:

```bash
tar -xzvf nginx-prometheus-exporter_1.4.0_linux_amd64.tar.gz
```

### **Step 3: Move the Binary to `/usr/local/bin`**

Move the extracted binary (`nginx-prometheus-exporter`) to a directory like `/usr/local/bin` for system-wide usage:

```bash
sudo mv nginx-prometheus-exporter_1.4.0_linux_amd64/nginx-prometheus-exporter /usr/local/bin/
```

### **Step 4: Create a Dedicated User for the Nginx Exporter**

Create a user to run the exporter without login capabilities:

```bash
sudo useradd --no-create-home --shell /bin/false nginx_exporter
```

### **Step 5: Set Proper Permissions**

Set the appropriate permissions for the Nginx Prometheus Exporter binary:

```bash
sudo chown nginx_exporter:nginx_exporter /usr/local/bin/nginx-prometheus-exporter
sudo chmod 755 /usr/local/bin/nginx-prometheus-exporter
```

---

### **Step 6: Configure Nginx for Exporter**

You need to enable the **stub_status** module in Nginx, which is used by the exporter to gather metrics.

1. **Edit the Nginx Configuration File:**

   Open the Nginx config file for editing:

   ```bash
   sudo nano /etc/nginx/nginx.conf
   ```

2. **Add the Status Page Location Block:**

   Inside the `http` block, add the following:

   ```nginx
   server {
       listen 127.0.0.1:8080;  # Expose status page locally
       server_name localhost;

       location /nginx_status {
           stub_status on;
           access_log off;
           allow 127.0.0.1;  # Allow only local connections
           deny all;
       }
   }
   ```

3. **Reload Nginx Configuration:**

   Apply the changes by reloading Nginx:

   ```bash
   sudo systemctl reload nginx
   ```

---

### **Step 7: Create a Systemd Service for Nginx Prometheus Exporter**

Now, let's create a systemd service for the exporter.

1. **Create a Service File:**

   Create the service file `/etc/systemd/system/nginx_exporter.service`:

   ```bash
   sudo nano /etc/systemd/system/nginx_exporter.service
   ```

   Add the following configuration:

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

2. **Reload Systemd Configuration:**

   Reload the systemd daemon to apply the new service file:

   ```bash
   sudo systemctl daemon-reload
   ```

---

### **Step 8: Start and Enable Nginx Prometheus Exporter**

1. **Start the Service:**

   Start the Nginx Exporter service:

   ```bash
   sudo systemctl start nginx_exporter
   ```

2. **Enable the Service to Start on Boot:**

   Enable the service to start automatically on system boot:

   ```bash
   sudo systemctl enable nginx_exporter
   ```

3. **Check Service Status:**

   Check if the Nginx Prometheus Exporter is running:

   ```bash
   sudo systemctl status nginx_exporter
   ```

   If it's not running or there are issues, check the logs with:

   ```bash
   sudo journalctl -u nginx_exporter -f
   ```

---

### **Step 9: Verify the Metrics Endpoint**

You can check if the exporter is serving metrics by running:

```bash
curl http://localhost:9113/metrics
```

This should return a list of Prometheus-compatible metrics.

---

### **Step 10: Configure Prometheus to Scrape Metrics**

1. **Edit Prometheus Configuration:**

   Open the Prometheus config file (`prometheus.yml`):

   ```bash
   sudo nano /etc/prometheus/prometheus.yml
   ```

2. **Add a Scrape Job for Nginx Exporter:**

   Under the `scrape_configs` section, add the following:

   ```yaml
   scrape_configs:
     - job_name: 'nginx'
       static_configs:
         - targets: ['localhost:9113']
       labels:
         environment: 'production'
         instance: 'nginx-server'
   ```

3. **Reload Prometheus Configuration:**

   Reload Prometheus to apply the changes:

   ```bash
   sudo systemctl reload prometheus
   ```

---

### **Step 11: Troubleshooting and Logs**

- **Exporter Logs**: To view logs for the Nginx Exporter:

  ```bash
  sudo journalctl -u nginx_exporter -f
  ```

- **Prometheus Target Check**: Go to Prometheus web UI (usually at `http://localhost:9090/targets`) and check if the Nginx exporter target is listed and "up."

- **Metrics Check**: If Prometheus isn't scraping the metrics, ensure that the Nginx Exporter is accessible at `http://localhost:9113/metrics`.

---

### **Summary**

- **Download** and **extract** the Nginx Prometheus Exporter.
- **Enable** the Nginx status page (`stub_status` module).
- **Create** a **systemd service** to run the Nginx Prometheus Exporter.
- **Start** and **enable** the service.
- **Configure Prometheus** to scrape the exporter metrics.
- **Verify** metrics at `http://localhost:9113/metrics`.

You should now be set up to monitor Nginx using Prometheus! Let me know if you encounter any issues.
