### Full Steps to Install and Configure **Postgres Exporter** on Ubuntu for Prometheus

Here is a complete guide to set up the **Postgres Exporter** on your Ubuntu system, including creating the necessary configuration files, systemd service, and setting up Prometheus to scrape the metrics.

---

### Prerequisites
- Ubuntu server (or similar Linux system).
- PostgreSQL server running and accessible.
- **Prometheus** installed (to scrape the metrics).
- **Root (or sudo) privileges** for configuration.
- Basic familiarity with the terminal and editing files.

---

### 1. **Install Postgres Exporter**

#### 1.1 Download Postgres Exporter

First, download the latest release of the Postgres Exporter from GitHub (e.g., version `v0.14.0`):

```bash
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.14.0/postgres_exporter-0.14.0.linux-amd64.tar.gz
```

#### 1.2 Extract the Tarball

Next, extract the downloaded tarball:

```bash
tar -xzvf postgres_exporter-0.14.0.linux-amd64.tar.gz
```

#### 1.3 Move the Postgres Exporter Binary

Move the `postgres_exporter` binary to `/usr/local/bin`:

```bash
sudo mv postgres_exporter-0.14.0.linux-amd64/postgres_exporter /usr/local/bin/
```

#### 1.4 Create a Dedicated User for Postgres Exporter

Create a new user for running the Postgres Exporter without login capabilities:

```bash
sudo useradd --no-create-home --shell /bin/false postgres_exporter
```

#### 1.5 Set Permissions

Set the proper permissions for the `postgres_exporter` binary:

```bash
sudo chown postgres_exporter:postgres_exporter /usr/local/bin/postgres_exporter
sudo chmod 755 /usr/local/bin/postgres_exporter
```

---

### 2. **Configure PostgreSQL for Postgres Exporter**

#### 2.1 Create a PostgreSQL User for Exporter

Login to PostgreSQL as the superuser:

```bash
sudo -u postgres psql
```

Create the `postgres_exporter` user and grant it the necessary permissions:

```sql
CREATE USER postgres_exporter WITH PASSWORD 'yourpassword';
GRANT CONNECT ON DATABASE postgres TO postgres_exporter;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO postgres_exporter;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres_exporter;
\q
```

- Replace `yourpassword` with a secure password for the `postgres_exporter` role.

#### 2.2 Create Environment File

Create a directory for the exporter configuration (if it doesn’t already exist):

```bash
sudo mkdir -p /opt/postgres_exporter
```

Create the `.postgres.env` environment file to store the PostgreSQL connection string:

```bash
sudo nano /opt/postgres_exporter/.postgres.env
```

Add the following line to the file (replace `yourpassword` with the actual password):

```bash
DATA_SOURCE_NAME="postgresql://postgres_exporter:yourpassword@localhost:5432/postgres?sslmode=disable"
```

Ensure the correct permissions are set for the environment file:

```bash
sudo chown postgres_exporter:postgres_exporter /opt/postgres_exporter/.postgres.env
sudo chmod 640 /opt/postgres_exporter/.postgres.env
```

---

### 3. **Create Systemd Service for Postgres Exporter**

#### 3.1 Create a Service File

Now, we will create the systemd service file to run the Postgres Exporter as a service.

Create the service file at `/etc/systemd/system/postgres_exporter.service`:

```bash
sudo nano /etc/systemd/system/postgres_exporter.service
```

Add the following configuration:

```ini
[Unit]
Description=Postgres Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=postgres_exporter
Group=postgres_exporter
Type=simple
Restart=on-failure
RestartSec=5s
WorkingDirectory=/opt/postgres_exporter
EnvironmentFile=/opt/postgres_exporter/.postgres.env
ExecStart=/usr/local/bin/postgres_exporter \
  --web.listen-address="0.0.0.0:19187" \
  --web.telemetry-path="/metrics" \
  --log.level=error

[Install]
WantedBy=multi-user.target
```

#### 3.2 Reload systemd Configuration

Reload the systemd configuration to apply the new service:

```bash
sudo systemctl daemon-reload
```

---

### 4. **Start and Enable Postgres Exporter Service**

#### 4.1 Start the Service

Start the Postgres Exporter service:

```bash
sudo systemctl start postgres_exporter
```

#### 4.2 Enable the Service to Start on Boot

Enable the service to start automatically when the system boots:

```bash
sudo systemctl enable postgres_exporter
```

#### 4.3 Check the Service Status

Check the status of the service to ensure it’s running without issues:

```bash
sudo systemctl status postgres_exporter
```

You should see an output indicating that the service is active and running. If there are any issues, check the logs using:

```bash
sudo journalctl -u postgres_exporter -f
```

---

### 5. **Verify Metrics Endpoint**

You can test the Postgres Exporter’s metrics endpoint by accessing `http://localhost:19187/metrics`. For example, you can use `curl`:

```bash
curl http://localhost:19187/metrics
```

This should return a list of Prometheus-compatible metrics.

---

### 6. **Configure Prometheus to Scrape Metrics**

#### 6.1 Edit Prometheus Configuration

Next, you need to configure Prometheus to scrape the Postgres Exporter metrics. Edit the Prometheus configuration file (`prometheus.yml`):

```bash
sudo nano /etc/prometheus/prometheus.yml
```

Add the following scrape job to the `scrape_configs` section:

```yaml
scrape_configs:
  - job_name: 'postgres_exporter'
    static_configs:
      - targets: ['localhost:19187']
    labels:
      environment: 'production'
      instance: 'postgres-db'
      job: 'postgres_exporter'
```

#### 6.2 Reload Prometheus Configuration

Once the configuration is updated, reload Prometheus to apply the changes:

```bash
sudo systemctl reload prometheus
```

---

### 7. **Troubleshooting and Logs**

- **Postgres Exporter Logs**: To view logs for the Postgres Exporter, run:

  ```bash
  sudo journalctl -u postgres_exporter -f
  ```

- **Prometheus Target Check**: Go to Prometheus web UI (typically available at `http://localhost:9090/targets`) and verify that the `postgres_exporter` target is up and running.

- **Metrics Check**: If Prometheus is not scraping metrics, ensure that Postgres Exporter is accessible at `http://localhost:19187/metrics`.

---

### Summary of Steps:

1. **Install Postgres Exporter** (download, extract, move binary).
2. **Create a PostgreSQL user** for Postgres Exporter with proper permissions.
3. **Create an environment file** with the correct database connection string.
4. **Create a systemd service** file to run the exporter as a service.
5. **Start and enable** the Postgres Exporter service.
6. **Verify metrics** using `curl` and ensure Prometheus can scrape them.
7. **Configure Prometheus** to scrape the metrics.

With these steps, your **Postgres Exporter** should be up and running, and Prometheus will be collecting and monitoring metrics from your PostgreSQL instance.
