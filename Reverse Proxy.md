
## 6. **Setting Up a Reverse Proxy**

In this section, we'll configure a reverse proxy to forward traffic from a specified port to Prometheus.

### **Step 1: Install Nginx**

1. **Update your package list and install Nginx**:
   ```bash
   sudo apt update
   sudo apt install nginx -y
   ```

### **Step 2: Configure Nginx**

1. **Create a new Nginx configuration file**:
   ```bash
   sudo nano /etc/nginx/sites-available/prometheus
   ```

2. **Add the reverse proxy configuration**:
   ```nginx
   server {
       listen 10000;

       location / {
           proxy_pass http://localhost:19091;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

3. **Enable the configuration by creating a symbolic link**:
   ```bash
   sudo ln -s /etc/nginx/sites-available/prometheus /etc/nginx/sites-enabled/
   ```

4. **Test the Nginx configuration**:
   ```bash
   sudo nginx -t
   ```

5. **Reload Nginx to apply the changes**:
   ```bash
   sudo systemctl reload nginx
   ```

### **Step 3: Update Prometheus Scrape Configuration**

1. **Edit your Prometheus configuration file**:
   ```bash
   sudo nano /etc/prometheus/prometheus.yml
   ```

2. **Modify the `remote_node_exporter` target to use the new port (10000)**:
   ```yaml
   - job_name: 'remote_node_exporter'
     static_configs:
       - targets: ['192.168.1.181:10000']
         labels:
           instance: 'node1'
   ```

3. **Save and exit the file**.

4. **Reload Prometheus to apply the new configuration**:
   ```bash
   sudo systemctl reload prometheus
   ```

### **Step 4: Verify the Configuration**

1. **Access Prometheus via the reverse proxy**:
   - Open a web browser and navigate to `http://<server-ip>:10000/`.
   - You should see the Prometheus UI.

2. **Check the status of the `remote_node_exporter` target**:
   - Go to `Status > Targets` in the Prometheus UI.
   - Ensure that `remote_node_exporter` with the `node1` instance is listed and showing as "UP."

