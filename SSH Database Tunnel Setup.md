---

# 📘 SSH Database Tunnel Setup

## 🎯 What this setup does

This allows you to securely connect to a **private MySQL database** from your local system.

* You connect to a **bastion server**
* The bastion connects to the **database (10.25.2.11)**
* You access the DB locally via **127.0.0.1:3307**

---


# ⚠️ IMPORTANT (VERY IMPORTANT)

You MUST replace the following:

### 1. Linux username

Replace:

```bash
<your-username>
```

Example:

```bash
moshith
```

---

### 2. SSH username (MOST IMPORTANT)

Replace this:

```bash
SSH_USER="dev-user"
```

👉 With your actual SSH username.

### Example:

If your name is **Moshith**, then:

```bash
SSH_USER="dev-Moshith"
```

If your name is **John**, then:

```bash
SSH_USER="dev-John"
```

---

# ✅ Step 1: Create a folder (clean setup)

```bash
mkdir -p /home/<your-username>/db-tunnel
```

Example:

```bash
mkdir -p /home/moshith/db-tunnel
```

---

# ✅ Step 2: Create the tunnel script

```bash
nano /home/<your-username>/db-tunnel/start-db-tunnel.sh
```

Paste this:

```bash
#!/bin/bash

SSH_USER="dev-user"   # 🔴 CHANGE THIS
SSH_HOST="dev-bastion.radiantcms.in"
KEY_PATH="/home/<your-username>/.ssh/dev_key" # 🔴 CHANGE THIS
LOCAL_PORT=3307
REMOTE_HOST="10.25.2.11"
REMOTE_PORT=3306

echo "Starting SSH tunnel on port $LOCAL_PORT..."

exec ssh -i $KEY_PATH -p 2255 \
-o ServerAliveInterval=60 \
-o ServerAliveCountMax=3 \
-N -L $LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT \
$SSH_USER@$SSH_HOST
```

---

## 🔧 Edit these TWO lines

### 1. SSH user

```bash
SSH_USER="dev-user"
```

Example:

```bash
SSH_USER="dev-Moshith"
```

---

### 2. Key path

```bash
KEY_PATH="/home/<your-username>/.ssh/dev_key"
```

Example:

```bash
KEY_PATH="/home/moshith/.ssh/dev_key"
```

---

### 👉 Save file

```
CTRL + O → Enter → CTRL + X
```

---

### 👉 Make executable

```bash
chmod +x /home/<your-username>/db-tunnel/start-db-tunnel.sh
```

---

# ✅ Step 3: Check SSH key

```bash
ls /home/<your-username>/.ssh/dev_key
```

If not found → contact admin

Fix permission:

```bash
chmod 600 /home/<your-username>/.ssh/dev_key
```

---

# ✅ Step 4: Create systemd service

```bash
sudo nano /etc/systemd/system/db-tunnel.service
```

Paste this:

```ini
[Unit]
Description=SSH DB Tunnel Service
After=network.target

[Service]
User=<your-username> # 🔴 CHANGE THIS
ExecStart=/home/<your-username>/db-tunnel/start-db-tunnel.sh # 🔴 CHANGE THIS
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

---

## 🔧 Replace username in BOTH places

Example:

```ini
User=moshith
ExecStart=/home/moshith/db-tunnel/start-db-tunnel.sh
```

---

### 👉 Save

```
CTRL + O → Enter → CTRL + X
```

---

# ✅ Step 5: Start the service

Run one by one:

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl start db-tunnel
sudo systemctl enable db-tunnel
```

---

# ✅ Step 6: Verify

```bash
sudo systemctl status db-tunnel
```

You should see:

```
Active: active (running)
```

---

### 👉 Check port

```bash
ss -tulnp | grep 3307
```

---

# ✅ Step 7: Connect to database

Use:

```text
Host: 127.0.0.1
Port: 3307
Username: <db-username>
Password: <db-password>
```

---

# ⚠️ Common Issues

## ❌ Port already in use

```bash
sudo lsof -i :3307
```

👉 Change port to **3308** in script

---

## ❌ Service not starting

```bash
journalctl -u db-tunnel -f
```

---

## ❌ SSH permission issue

```bash
chmod 600 /home/<your-username>/.ssh/dev_key
```

---

# ✅ Final Result

* Fully automated SSH tunnel
* Starts on system boot
* No manual commands needed
* Secure DB access

---

## 👍 Simple Checklist

Before running, confirm:

* ✔ Username replaced
* ✔ SSH_USER updated (dev-YourName)
* ✔ Key path correct
* ✔ Script path correct

---

