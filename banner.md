
# ✅ Login Banner and MOTD Customization Guide for Ubuntu EC2

## 🎯 Objective

1. Show a **custom login banner** (before authentication).
2. After login, **only show system stats** (CPU, disk, RAM, IP).
3. **Disable all other login messages**, like:

   * Welcome text
   * Ubuntu update suggestions
   * Unattended upgrades
   * Last login info
   * News headlines

---

## 🧱 Step 1: Connect to your EC2 instance

```bash
ssh -i /path/to/your-key.pem ubuntu@your-ec2-ip
```

---

## 📜 Step 2: Set a Custom Login Banner

The login banner is shown **before** the password prompt.

### 2.1 Edit the Banner File

```bash
sudo nano /etc/issue.net
```

Add your banner text, for example:

```
********************************************************
* Welcome to My EC2 Instance! Unauthorized access is prohibited.
********************************************************
```

Save and exit (`Ctrl+O`, then `Enter`, then `Ctrl+X`).

---

### 2.2 Enable the Banner in SSHD

Edit the SSH daemon config:

```bash
sudo nano /etc/ssh/sshd_config
```

Find and update this line:

```bash
Banner /etc/issue.net
```

> If it's commented out (starts with `#`), remove the `#`.

Save and restart SSH:

```bash
sudo systemctl restart sshd
```

---

## 🧼 Step 3: Disable Unwanted Login Messages (MOTD scripts)

Ubuntu dynamically generates the post-login Message of the Day (MOTD) using executable scripts in `/etc/update-motd.d/`.

### 3.1 Go to the MOTD scripts directory:

```bash
cd /etc/update-motd.d
```

### 3.2 Disable all scripts **except** `50-landscape-sysinfo`:

```bash
sudo chmod -x 00-header 10-help-text 50-motd-news 85-fwupd 90-updates-available 91-* 92-* 95-* 97-* 98-*
```

Now only `50-landscape-sysinfo` remains executable.

> ✅ `50-landscape-sysinfo` is responsible for displaying system stats like:
>
> * CPU load
> * Disk usage
> * Memory
> * IP address

---

## 🔇 Step 4: Disable “Last login” message

To remove the line that shows:

```
Last login: Tue Jun 10 04:52:08 2025 from x.x.x.x
```

Edit the SSH daemon config:

```bash
sudo nano /etc/ssh/sshd_config
```

Add or modify:

```bash
PrintLastLog no
```

Then restart SSH:

```bash
sudo systemctl restart sshd
```

---

## 🧪 Step 5: Test the Setup

1. **Open a new terminal** (don’t reuse an existing SSH session).
2. Connect again:

```bash
ssh -i /path/to/your-key.pem ubuntu@your-ec2-ip
```

### You should now see:

✅ Your custom **banner** (from `/etc/issue.net`)
✅ Only the **system info block** (from `50-landscape-sysinfo`)
❌ No update messages
❌ No Ubuntu links
❌ No last login info
❌ No news or MOTD clutter

---

## 🛠 Optional: Customize `50-landscape-sysinfo` Output

You can modify the fields shown (IP, memory, etc.) by editing the landscape sysinfo configuration:

```bash
sudo nano /etc/landscape/client.conf
```

Example options:

```ini
[sysinfo]
exclude_sysinfo_plugins = Temperature
```

Restart the landscape service:

```bash
sudo systemctl restart landscape-client
```

---

## 📦 Summary

| Feature                      | Enabled? | File/Setting                              |
| ---------------------------- | -------- | ----------------------------------------- |
| Custom pre-login banner      | ✅        | `/etc/issue.net`, `sshd_config`           |
| System info after login      | ✅        | `/etc/update-motd.d/50-landscape-sysinfo` |
| Ubuntu MOTD header/news/etc. | ❌        | `chmod -x` on unwanted scripts            |
| Last login info              | ❌        | `PrintLastLog no` in `sshd_config`        |

---

