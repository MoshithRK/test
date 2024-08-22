
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






To add the domain name `promethus.scanslips.in` and configure the SSL certificate, follow these steps:

## 7. **Configuring SSL for Prometheus**

### **Step 1: Prepare Your SSL Certificate**

1. **Place your SSL certificate files** on the server. These usually include:
   - `your_domain.crt` (or `your_domain.pem`): The public certificate
   - `your_domain.key`: The private key
   - `your_domain.ca-bundle` (optional): The CA bundle file if provided

   Ensure these files are securely stored, for example:
   ```bash
   sudo mkdir -p /etc/nginx/ssl
   sudo cp your_domain.crt /etc/nginx/ssl/
   sudo cp your_domain.key /etc/nginx/ssl/
   sudo cp your_domain.ca-bundle /etc/nginx/ssl/
   ```

### **Step 2: Update Nginx Configuration**

1. **Edit the Nginx configuration file**:
   ```bash
   sudo nano /etc/nginx/sites-available/prometheus
   ```

2. **Modify the configuration to include SSL**:
   ```nginx
   server {
       listen 443 ssl;
       server_name promethus.scanslips.in;

       ssl_certificate /etc/nginx/ssl/your_domain.crt;
       ssl_certificate_key /etc/nginx/ssl/your_domain.key;

       # Optional: If you have a CA bundle
       ssl_trusted_certificate /etc/nginx/ssl/your_domain.ca-bundle;

       ssl_protocols TLSv1.2 TLSv1.3;
       ssl_ciphers HIGH:!aNULL:!MD5;

       location / {
           proxy_pass http://localhost:19091;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }

   server {
       listen 80;
       server_name promethus.scanslips.in;
       return 301 https://$host$request_uri;
   }
   ```

   - This configuration listens on port 443 for SSL connections and redirects HTTP traffic from port 80 to HTTPS.
   - Replace `your_domain.crt`, `your_domain.key`, and `your_domain.ca-bundle` with the actual file names if they differ.

3. **Test the Nginx configuration**:
   ```bash
   sudo nginx -t
   ```

4. **Reload Nginx to apply the changes**:
   ```bash
   sudo systemctl reload nginx
   ```

### **Step 3: Verify the SSL Setup**

1. **Access Prometheus via your domain name**:
   - Open a web browser and navigate to `https://promethus.scanslips.in/`.
   - You should see the Prometheus UI, and the connection should be secure (indicated by the padlock icon).

2. **Ensure HTTPS is enforced**:
   - Verify that navigating to `http://promethus.scanslips.in/` redirects to the HTTPS version.

By following these steps, your Prometheus instance will be accessible securely via `https://promethus.scanslips.in/`, using your SSL certificate.





2. **Check the status of the `remote_node_exporter` target**:
   - Go to `Status > Targets` in the Prometheus UI.
   - Ensure that `remote_node_exporter` with the `node1` instance is listed and showing as "UP."

