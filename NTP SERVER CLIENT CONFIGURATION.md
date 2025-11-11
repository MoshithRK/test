
---

# 🕒 **Chrony NTP Configuration — Complete Implementation Guide (Ubuntu, India Region)**

---

## 📘 **Overview**

This document provides a complete, step-by-step configuration for setting up **Chrony** as an **NTP (Network Time Protocol) Server** and **NTP Client** on Ubuntu systems.
The goal is to ensure all systems in the network synchronize to a common and accurate time source, using **Indian Regional NTP servers (`in.pool.ntp.org`)** as the reference.

---

## 🧭 **Network Topology Example**

| Role           | Hostname     | IP Address      | Purpose                           |
| -------------- | ------------ | --------------- | --------------------------------- |
| **NTP Server** | `ntp-server` | `172.31.25.242` | Provides time service to clients  |
| **NTP Client** | `app-server` | `172.31.28.255` | Synchronizes time from NTP server |

---

## ⚙️ **Part 1 — NTP Server Configuration**

### **1️⃣ Install Chrony**

```bash
sudo apt update
sudo apt install -y chrony
```

Verify version:

```bash
chronyd -v
```

✅ Example:

```
chronyd (chrony) version 4.3
```

---

### **2️⃣ Configure Chrony for Server Role**

Edit the main configuration:

```bash
sudo nano /etc/chrony/chrony.conf
```

Paste this configuration:

```conf
# ===============================================
# Chrony NTP SERVER CONFIGURATION (INDIA REGION)
# ===============================================
# Maintainer: Radiant Infrastructure / Admin Team
# Role      : NTP Time Server
# Notes     : Allows all clients to sync using India regional pool servers

# ------------------------------------------------
# Include modular configuration and source files
# ------------------------------------------------
confdir /etc/chrony/conf.d
sourcedir /etc/chrony/sources.d

# ------------------------------------------------
# Allow all clients to query and sync time
# ------------------------------------------------
allow all

# ------------------------------------------------
# Optional: provide local reference clock if upstream NTP fails
# ------------------------------------------------
local stratum 10

# ------------------------------------------------
# Drift file stores system clock drift
# ------------------------------------------------
driftfile /var/lib/chrony/chrony.drift

# ------------------------------------------------
# File containing authentication keys
# ------------------------------------------------
keyfile /etc/chrony/chrony.keys

# ------------------------------------------------
# Directory for NTS keys and cookies
# ------------------------------------------------
ntsdumpdir /var/lib/chrony

# ------------------------------------------------
# Enable kernel synchronization to RTC
# ------------------------------------------------
rtcsync

# ------------------------------------------------
# Step system clock if offset > 1s during first 3 updates
# ------------------------------------------------
makestep 1.0 3

# ------------------------------------------------
# Log files location
# ------------------------------------------------
logdir /var/log/chrony

# ------------------------------------------------
# Handle leap seconds
# ------------------------------------------------
leapsectz right/UTC

# ------------------------------------------------
# Allow localhost admin commands (chronyc)
# ------------------------------------------------
cmdallow 127.0.0.1
```

Save the file (**Ctrl+O**, Enter, **Ctrl+X**).

---

### **3️⃣ Add Indian Regional NTP Sources**

Create a modular configuration file:

```bash
sudo nano /etc/chrony/sources.d/india-ntp.sources
```

Add:

```conf
# Indian Regional NTP Servers
server 0.in.pool.ntp.org iburst
server 1.in.pool.ntp.org iburst
server 2.in.pool.ntp.org iburst
server 3.in.pool.ntp.org iburst
```

Save and exit.

---

### **4️⃣ Open NTP Port in Firewall**

If using UFW:

```bash
sudo ufw allow 123/udp
sudo ufw reload
sudo ufw status | grep 123
```

✅ Expected:

```
123/udp ALLOW Anywhere
```

If using iptables:

```bash
sudo iptables -A INPUT -p udp --dport 123 -j ACCEPT
```

---

### **5️⃣ Enable and Start Chrony**

```bash
sudo systemctl enable chrony
sudo systemctl restart chrony
sudo systemctl status chrony
```

✅ Expected Output:

```
Active: active (running)
```

---

### **6️⃣ Set System Timezone to India**

```bash
sudo timedatectl set-timezone Asia/Kolkata
timedatectl
```

✅ Output:

```
Time zone: Asia/Kolkata (IST, +0530)
System clock synchronized: yes
```

---

### **7️⃣ Verify NTP Sources**

```bash
chronyc sources
```

✅ Example:

```
MS Name/IP address         Stratum Poll Reach LastRx Last sample
^* 0.in.pool.ntp.org            2   6   377    15   +0.124ms[-0.142ms] +/- 11ms
```

Detailed tracking:

```bash
chronyc tracking
```

---

### **8️⃣ Verify UDP Port Listening**

```bash
sudo ss -anu | grep 123
```

✅ Output:

```
udp   UNCONN  0  0  0.0.0.0:123  0.0.0.0:*
```

---

## 💻 **Part 2 — NTP Client Configuration**

### **1️⃣ Install Chrony**

```bash
sudo apt update
sudo apt install -y chrony
```

---

### **2️⃣ Configure Chrony for Client Role**

Edit the configuration file:

```bash
sudo nano /etc/chrony/chrony.conf
```

Paste the following:

```conf
# ===============================================
# Chrony NTP CLIENT CONFIGURATION (India Region)
# ===============================================
# Maintainer: Radiant Infrastructure / Admin Team
# Purpose   : Configure client to sync with internal NTP server
# Timezone  : Asia/Kolkata (IST, +05:30)
# Notes     : Syncs time from internal NTP server (172.31.25.242)
# ===============================================

# ------------------------------------------------
# Internal NTP server (replace IP if needed)
# ------------------------------------------------
server 172.31.25.242 iburst

# ------------------------------------------------
# Optionally add a backup Indian pool (fallback)
# ------------------------------------------------
server 0.in.pool.ntp.org iburst
server 1.in.pool.ntp.org iburst

# ------------------------------------------------
# Store clock drift data for long-term stability
# ------------------------------------------------
driftfile /var/lib/chrony/chrony.drift

# ------------------------------------------------
# Step the system clock if the adjustment is larger than 1 second
# ------------------------------------------------
makestep 1.0 3

# ------------------------------------------------
# Enable periodic synchronization of system clock to RTC
# ------------------------------------------------
rtcsync

# ------------------------------------------------
# Log files directory
# ------------------------------------------------
logdir /var/log/chrony

# ------------------------------------------------
# Maximum rate of clock updates to avoid sudden changes
# ------------------------------------------------
maxupdateskew 100.0

# ------------------------------------------------
# Authentication keys file
# ------------------------------------------------
keyfile /etc/chrony/chrony.keys

# ------------------------------------------------
# Save NTS keys and cookies
# ------------------------------------------------
ntsdumpdir /var/lib/chrony

# ------------------------------------------------
# Handle leap seconds
# ------------------------------------------------
leapsectz right/UTC
```

Save the file (**Ctrl+O**, Enter, **Ctrl+X**).

---

### **3️⃣ Disable DHCP NTP (AWS Default)**

Comment out this line if it exists:

```conf
# sourcedir /run/chrony-dhcp
```

Reload:

```bash
sudo chronyc reload sources
```

---

### **4️⃣ Enable and Start Chrony**

```bash
sudo systemctl enable chrony
sudo systemctl restart chrony
sudo systemctl status chrony
```

✅ Output:

```
Active: active (running)
```

---

### **5️⃣ Set Timezone to India**

```bash
sudo timedatectl set-timezone Asia/Kolkata
timedatectl
```

✅ Output:

```
Time zone: Asia/Kolkata (IST, +0530)
System clock synchronized: yes
```

---

### **6️⃣ Verify Client Sync**

```bash
chronyc sources
```

✅ Example:

```
MS Name/IP address         Stratum Poll Reach LastRx Last sample
^* 172.31.25.242                3   6   377    12   +0.123ms[-0.087ms] +/- 2ms
```

Detailed tracking:

```bash
chronyc tracking
```

---

### **7️⃣ Force Immediate Sync**

```bash
sudo chronyc makestep
```

---

## 🔍 **Part 3 — Verification and Testing**

### **A. Verify Clients from Server**

Run on the **NTP Server**:

```bash
sudo chronyc clients
```

✅ Example Output:

```
Hostname                      NTP   Drop Int IntL Last     Cmd   Drop Int  Last
172.31.28.255                   1     0   6   6   -         0     0   6   10
```

**Explanation:**

* `Hostname` → client IP connected to the NTP server
* `NTP` → number of NTP packets received
* This confirms your client (`172.31.28.255`) is receiving time from your NTP server.

If you see `501 Not authorised`, add to `/etc/chrony/chrony.conf`:

```conf
cmdallow 127.0.0.1
```

Then restart:

```bash
sudo systemctl restart chrony
```

---

### **B. Verify Client Connection**

```bash
sudo chronyd -Q 'server 172.31.25.242 iburst'
```

✅ Output:

```
System clock synchronized successfully
```

---

### **C. Check Server Listening on UDP 123**

```bash
sudo ss -anu | grep 123
```

✅ Output:

```
udp   UNCONN  0  0  0.0.0.0:123  0.0.0.0:*
```

---

## ✅ **Final Verification Checklist**

| Check          | Command                            | Expected Result       |
| -------------- | ---------------------------------- | --------------------- |
| Server running | `sudo systemctl status chrony`     | Active (running)      |
| Server sync    | `chronyc sources`                  | Using in.pool.ntp.org |
| Client sync    | `chronyc sources`                  | Using 172.31.25.242   |
| Client visible | `sudo chronyc clients` (on server) | IP listed             |
| Port open      | `sudo ufw status`                  | UDP 123 allowed       |
| Timezone       | `timedatectl`                      | Asia/Kolkata (IST)    |

---

## 🧰 **Maintenance Commands**

| Task                   | Command                         |
| ---------------------- | ------------------------------- |
| Check NTP sources      | `chronyc sources -v`            |
| Show sync status       | `chronyc tracking`              |
| Show connected clients | `sudo chronyc clients`          |
| Force sync immediately | `sudo chronyc makestep`         |
| Reload sources         | `sudo chronyc reload sources`   |
| Restart service        | `sudo systemctl restart chrony` |

---

## 🔐 **Security Recommendation**

For production environments, **replace**:

```conf
allow all
```

with your internal subnet:

```conf
allow 172.31.0.0/16
```

and restrict UDP 123 to internal IPs via firewall.

---

## 🕒 **Final Result**

✅ All systems synchronize accurately to **India Standard Time (IST)**
✅ Chrony server provides NTP services to clients
✅ Verified via:

* `chronyc sources`
* `chronyc tracking`
* `sudo chronyc clients`
* `timedatectl`

✅ Time drift remains within microseconds across the network.

---

Would you like me to export this as a **ready-to-share `.docx` (Word)** or **`.md` (Markdown)** file for your internal documentation system (with formatting, tables, and code preserved)?
