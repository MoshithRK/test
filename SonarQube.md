

---

### **Installation Process for SonarQube on Ubuntu using Docker Compose**

---

#### **Step 1: SSH into the Server**
1. SSH into your Ubuntu server:

   ```bash
   ssh -i your-key.pem ubuntu@your-instance-ip
   ```

---

#### **Step 2: Update the Server**
1. Update your server to ensure all packages are up-to-date:

   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

#### **Step 3: Install Docker**
1. Install Docker:

   ```bash
   sudo apt install -y docker.io
   ```

2. Enable Docker to start on boot:

   ```bash
   sudo systemctl enable --now docker
   ```

3. Verify Docker installation:

   ```bash
   docker --version
   ```

---

#### **Step 4: Install Docker Compose**
1. Download and install Docker Compose:

   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   ```

2. Make it executable:

   ```bash
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. Verify Docker Compose installation:

   ```bash
   docker-compose --version
   ```

---

#### **Step 5: Add Your User to the Docker Group**
1. Add your user to the `docker` group to run Docker commands without `sudo`:

   ```bash
   sudo usermod -aG docker $USER
   ```

2. Apply the group changes by either logging out and logging back in or running:

   ```bash
   newgrp docker
   ```

3. Verify Docker access:

   ```bash
   docker ps
   ```

---

#### **Step 6: Set Up SonarQube with Docker Compose**
1. **Create a directory for SonarQube**:

   ```bash
   mkdir sonar-instance
   cd sonar-instance
   ```

2. **Create the `docker-compose.yml` file**:

   ```bash
   nano docker-compose.yml
   ```

3. **Paste the following configuration** into the `docker-compose.yml` file:

   ```yaml
   version: '3'
   services:
     sonarqube:
       image: sonarqube:lts
       container_name: sonarqube
       environment:
         - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
         - SONARQUBE_JDBC_USERNAME=sonar
         - SONARQUBE_JDBC_PASSWORD=sonar
       ports:
         - "9000:9000"
       depends_on:
         - db
       networks:
         - sonar-network
       restart: always

     db:
       image: postgres:13
       container_name: sonarqube_db
       environment:
         - POSTGRES_USER=sonar
         - POSTGRES_PASSWORD=sonar
         - POSTGRES_DB=sonar
       volumes:
         - sonar-db-data:/var/lib/postgresql/data
       networks:
         - sonar-network
       restart: always

   networks:
     sonar-network:
       driver: bridge

   volumes:
     sonar-db-data:
       driver: local
   ```

4. **Save and close** the file (`CTRL + X`, then `Y`, and `Enter`).

---

#### **Step 7: Launch SonarQube and PostgreSQL**
1. Run the following command to start SonarQube and PostgreSQL using Docker Compose:

   ```bash
   docker-compose up -d
   ```

2. **Check the status** of the containers:

   ```bash
   docker-compose ps
   ```

3. **View SonarQube logs** to ensure everything is running correctly:

   ```bash
   docker-compose logs -f
   ```

---

#### **Step 8: Access SonarQube Web Interface**
1. Once the containers are up, open a web browser and go to:

   ```
   http://your-instance-ip:9000
   ```

2. **Login to SonarQube**:
   - **Username**: `admin`
   - **Password**: `admin`

---

This process installs and launches SonarQube on your Ubuntu server using Docker Compose, including all necessary steps for Docker and Docker Compose installation.

