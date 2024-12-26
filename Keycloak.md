
---

# **Installing Keycloak on Ubuntu 22.04**

Keycloak is a powerful open-source Identity and Access Management (IAM) solution. This guide walks through setting up Keycloak with PostgreSQL as the backend database and Nginx as a reverse proxy with SSL.

---

## **1. System Preparation**

Ensure your system is updated and has the required tools and dependencies.

### Update the System and Install Utilities
Run the following commands to update your system and install essential utilities:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget vim
```

### Install Java (OpenJDK 21)
Keycloak requires Java to run. Install the OpenJDK package:
```bash
sudo apt-get install -y default-jdk openjdk-21-jre
```

Verify the installation:
```bash
java -version
```

---

## **2. Install Keycloak**

### Download and Extract Keycloak
1. Navigate to the `/opt` directory to store Keycloak files:
   ```bash
   cd /opt
   ```

2. Download the Keycloak tarball:
   ```bash
   sudo wget -O keycloak.tar.gz https://github.com/keycloak/keycloak/releases/download/26.0.5/keycloak-26.0.5.tar.gz
   ```

3. Extract the downloaded file into the `/opt/keycloak` directory:
   ```bash
   sudo mkdir -p /opt/keycloak
   sudo tar -xzvf keycloak.tar.gz -C /opt/keycloak --strip-components=1
   sudo rm keycloak.tar.gz
   ```

---

## **3. Set Up PostgreSQL**

Keycloak requires a database to store user data, configurations, and sessions. Here’s how to configure PostgreSQL.

### Install PostgreSQL
Install the database server:
```bash
sudo apt update
sudo apt install -y postgresql postgresql-contrib
```

Enable and start the PostgreSQL service:
```bash
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

### Configure the Database and User
1. Log in to the PostgreSQL prompt:
   ```bash
   sudo -i -u postgres
   ```

2. Create the Keycloak database and a dedicated user:
   ```sql
   CREATE DATABASE keycloak;
   CREATE USER keycloak WITH PASSWORD 'YourSecurePassword';
   GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;
   ```

3. Exit the PostgreSQL shell:
   ```bash
   exit
   ```

### Update PostgreSQL Authentication
1. Edit the `pg_hba.conf` file to enable password-based authentication:
   ```bash
   sudo vim /etc/postgresql/14/main/pg_hba.conf
   ```

   Replace `peer` authentication with `md5` for local and network connections:
   ```
   local   all             all                                     md5
   host    all    all    0.0.0.0/0    md5
   ```

2. Restart PostgreSQL to apply changes:
   ```bash
   sudo systemctl restart postgresql
   ```

---

## **4. Configure Nginx as a Reverse Proxy**

Nginx will handle incoming requests and route them securely to the Keycloak server.

### Install and Set Up Nginx
Install Nginx and start the service:
```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Set Up SSL Certificates
If you already have an SSL certificate, copy it to a secure directory:
```bash
sudo mkdir -p /etc/nginx/ssl/yourdomain/
```

### Configure Nginx for Keycloak
1. Create an Nginx configuration file for Keycloak:
   ```bash
   sudo vim /etc/nginx/conf.d/keycloak.conf
   ```

2. Add the following configuration (replace placeholders with your actual domain and paths):
   ```
   server {
       listen 443 ssl;
       server_name yourdomain.com;

       ssl_certificate /etc/nginx/ssl/yourdomain/certificate.crt;
       ssl_certificate_key /etc/nginx/ssl/yourdomain/private.key;

       location / {
           proxy_pass http://localhost:8080;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       }
   }
   ```

3. Test the Nginx configuration:
   ```bash
   sudo nginx -t
   ```

4. Reload Nginx to apply changes:
   ```bash
   sudo systemctl reload nginx
   ```

---

## **5. Configure Keycloak**

### Adjust Keycloak Settings
Edit the `keycloak.conf` file to specify configurations such as database connection and hostname:
```bash
sudo vim /opt/keycloak/conf/keycloak.conf
```

Example configuration:
```
db=postgres
db-url=jdbc:postgresql://localhost/keycloak
db-username=keycloak
db-password=YourSecurePassword
```

---

## **6. Set Up Keycloak as a Service**

### Create a Dedicated Keycloak User
Create a non-root user to run the Keycloak service:
```bash
sudo groupadd keycloak
sudo useradd -r -g keycloak -d /opt/keycloak -s /sbin/nologin keycloak
sudo chown -R keycloak:keycloak /opt/keycloak
```

### Create a Systemd Service File
Define a systemd service to manage Keycloak:
```bash
sudo vim /etc/systemd/system/keycloak.service
```

Example service file:
```
[Unit]
Description=Keycloak Service
After=network.target

[Service]
User=keycloak
Group=keycloak
WorkingDirectory=/opt/keycloak
ExecStart=/opt/keycloak/bin/kc.sh start
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start the Keycloak service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable keycloak
sudo systemctl start keycloak
```

Check the service status:
```bash
sudo systemctl status keycloak
```

---

## **7. Bootstrap Admin User**

Create an admin user for managing Keycloak:
```bash
cd /opt/keycloak/bin
./kc.sh bootstrap-admin --user admin --password YourAdminPassword
```

Rebuild Keycloak:
```bash
./kc.sh build
```

---

## **8. Access Keycloak**

Visit your Keycloak instance in a browser:
```
https://yourdomain.com
```

Log in using the admin credentials you set up earlier.

---

### **Next Steps**
- Configure Keycloak realms, clients, and users as per your application requirements.
- Integrate Keycloak with external identity providers if needed.

---

This revised guide adds more detailed explanations for each step and uses alternative phrasing to improve clarity and readability. Let me know if you'd like further refinements!
