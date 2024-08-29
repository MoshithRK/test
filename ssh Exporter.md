
---

# SSH Login Exporter

This project provides a Prometheus exporter that monitors SSH login activity on your server. It collects the number of currently logged-in SSH users and provides the data to Prometheus.

## Features

- Tracks the number of SSH users currently logged in.
- Lists the usernames of the logged-in SSH users.
- Exposes the metrics on port `9101` for Prometheus to scrape.

## Prerequisites

- Ubuntu 18.04 or later
- Python 3.x
- Prometheus

## Installation

### Step 1: Install Required Packages

1. Update your package list and install Python 3 and `pip`:

   ```bash
   sudo apt-get update
   sudo apt-get install python3 python3-pip python3-venv -y
   ```

2. Create a virtual environment for the project:

   ```bash
   python3 -m venv myenv
   source myenv/bin/activate
   ```

3. Install the `prometheus_client` library:

   ```bash
   pip install prometheus-client
   ```

### Step 2: Setup SSH Login Exporter

1. Create the directory for the SSH Login Exporter script:

   ```bash
   sudo mkdir -p /opt/prometheus_exporters
   sudo chown $USER:$USER /opt/prometheus_exporters
   sudo chmod 755 /opt/prometheus_exporters
   ```

2. Copy the following Python script to `/opt/prometheus_exporters/ssh_login_exporter.py`:

   ```python
   from prometheus_client import start_http_server, Gauge, Info
   import time
   import subprocess

   ssh_user_count_gauge = Gauge('ssh_user_count', 'Number of SSH users currently logged in')
   ssh_users_info = Info('ssh_users', 'List of SSH users currently logged in')

   def collect_ssh_metrics():
       users = get_ssh_users()
       ssh_user_count_gauge.set(len(users))
       if users:
           ssh_users_info.info({'users': ','.join(users)})
       else:
           ssh_users_info.info({'users': 'none'})

   def get_ssh_users():
       try:
           ssh_users_list = subprocess.check_output(["who", "-q"]).decode("utf-8").splitlines()
           users = ssh_users_list[0].split()
           return users
       except subprocess.CalledProcessError as e:
           print(f"Error fetching SSH users: {e}")
           return []

   if __name__ == '__main__':
       start_http_server(9101)
       print("SSH Login Exporter started on port 9101.")
       while True:
           collect_ssh_metrics()
           time.sleep(15)
   ```

3. Make the script executable:

   ```bash
   sudo chmod +x /opt/prometheus_exporters/ssh_login_exporter.py
   ```

### Step 3: Create a Systemd Service

1. Create a systemd service file at `/etc/systemd/system/ssh_login_exporter.service`:

   ```ini
   [Unit]
   Description=Prometheus SSH Login Exporter
   After=network.target

   [Service]
   Type=simple
   ExecStart=/bin/bash -c 'source /home/ubuntu/myenv/bin/activate && /home/ubuntu/myenv/bin/python /opt/prometheus_exporters/ssh_login_exporter.py'
   Restart=always
   User=ubuntu
   Group=ubuntu

   [Install]
   WantedBy=multi-user.target
   ```

2. Reload systemd and start the service:

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start ssh_login_exporter.service
   ```

3. Enable the service to start on boot:

   ```bash
   sudo systemctl enable ssh_login_exporter.service
   ```

4. Check the status of the service:

   ```bash
   sudo systemctl status ssh_login_exporter.service
   ```

### Step 4: Integrate with Prometheus

1. Update your Prometheus configuration (`/opt/prometheus/prometheus.yml`) to include the SSH Login Exporter:

   ```yaml
   scrape_configs:
     - job_name: 'ssh_login_exporter'
       static_configs:
         - targets: ['localhost:9101']
   ```

2. Reload Prometheus to apply the changes:

   ```bash
   sudo systemctl restart prometheus.service
   ```

## Usage

The SSH Login Exporter exposes metrics at `http://localhost:9101/metrics`. Prometheus can scrape this endpoint to collect SSH login metrics.

Example metrics:

- `ssh_user_count`: Number of SSH users currently logged in.
- `ssh_users`: List of SSH users currently logged in.

## Troubleshooting

- If the service does not start, check the logs with:

  ```bash
  journalctl -u ssh_login_exporter.service
  ```

- Ensure that the virtual environment is activated and the correct Python interpreter is being used.

