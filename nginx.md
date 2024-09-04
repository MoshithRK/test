

# Setting Up a Reverse Proxy for Prometheus Using Nginx

This guide explains how to configure Nginx as a reverse proxy for Prometheus. The reverse proxy will allow you to access Prometheus via a custom domain name, secure it using SSL, and optionally restrict access using HTTP Basic Authentication.

## Prerequisites

- A server running Prometheus on port `19091`.
- A domain name (e.g., `prometheus.radianterp.in`).
- Basic knowledge of Nginx and the Linux command line.
- **Optional**: SSL certificate (recommended for securing access).

## Step 1: Install Nginx

If Nginx is not already installed on your server, you can install it using the following commands:

```bash
sudo apt update
sudo apt install nginx
```

## Step 2: Create Nginx Configuration for Prometheus

Create a new configuration file for Prometheus in the Nginx configuration directory:

```bash
sudo nano /etc/nginx/sites-available/prometheus
```

Add the following configuration to the file:

```nginx
server {
    listen 80;
    server_name prometheus.radianterp.in;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name prometheus.radianterp.in;

    ssl_certificate /etc/nginx/ssl/radianterp.in/STAR_radianterp_in.chained.crt;
    ssl_certificate_key /etc/nginx/ssl/radianterp.in/private.key;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;

    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload" always;

    access_log /var/log/nginx/prometheus.radianterp.in.access.log;
    error_log /var/log/nginx/prometheus.radianterp.in.error.log;

    location / {
        auth_basic "Restricted Access";               
        auth_basic_user_file /etc/nginx/.htpasswd;     

        proxy_pass http://localhost:19091;             
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 3600s;
        proxy_connect_timeout 3600s;
        proxy_send_timeout 3600s;
    }
}

```

## Step 3: Enable the Configuration

Enable the Nginx configuration by creating a symbolic link in the `sites-enabled` directory:

```bash
sudo ln -s /etc/nginx/sites-available/prometheus /etc/nginx/sites-enabled/
```

## Step 4: Set Up HTTP Basic Authentication

To restrict access using HTTP Basic Authentication:

1. Install `apache2-utils` to get the `htpasswd` tool:

    ```bash
    sudo apt install apache2-utils
    ```

2. Create the password file and add a user:

    ```bash
    sudo htpasswd -c /etc/nginx/.htpasswd yourusername
    ```

    Replace `yourusername` with the desired username. You'll be prompted to enter a password.

3. **Optional**: Add more users without the `-c` option:

    ```bash
    sudo htpasswd /etc/nginx/.htpasswd anotheruser
    ```

## Step 5: Test Nginx Configuration

Test the Nginx configuration to ensure there are no syntax errors:

```bash
sudo nginx -t
```

## Step 6: Restart Nginx

Apply the changes by restarting Nginx:

```bash
sudo systemctl restart nginx
```

## Step 7: Verify the Setup

Access Prometheus using your domain name in a web browser (e.g., `http://prometheus.radianterp.in`). You should be prompted to enter the username and password configured in the `.htpasswd` file.


