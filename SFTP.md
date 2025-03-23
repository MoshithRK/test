
---

# **🚀 Complete Setup for SFTP with Audit Logging to `/var/log/sftp.log`**

## **🔹 Step 1: Install Required Packages**
```bash
sudo apt update
sudo apt install -y openssh-server auditd rsync
```

---

## **🔹 Step 2: Create SFTP Users & Directories**
```bash
# Create a group for SFTP users
sudo groupadd sftpusers

# Create the SFTP user
sudo useradd -m -d /var/sftp/Apollosftp/apollo -s /sbin/nologin -G sftpusers apollo
sudo passwd apollo  # Set a password

# Create upload and download directories
sudo mkdir -p /var/sftp/Apollosftp/apollo/apollo_Uploads
sudo mkdir -p /var/sftp/Apollosftp/apollo/apollo_Downloads

# Set correct ownership and permissions
sudo chown root:root /var/sftp/Apollosftp/apollo
sudo chmod 755 /var/sftp/Apollosftp/apollo

sudo chown apollo:sftpusers /var/sftp/Apollosftp/apollo/apollo_Uploads
sudo chmod 750 /var/sftp/Apollosftp/apollo/apollo_Uploads

sudo chown apollo:sftpusers /var/sftp/Apollosftp/apollo/apollo_Downloads
sudo chmod 750 /var/sftp/Apollosftp/apollo/apollo_Downloads
```

---

## **🔹 Step 3: Configure OpenSSH for SFTP (`/etc/ssh/sshd_config`)**
```ini
# 🔹 Load additional configurations
Include /etc/ssh/sshd_config.d/*.conf

# 🔹 Listen on specific ports
Port 22
Port 2225

# 🔹 HostKey files
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# 🔹 Authentication Settings
LoginGraceTime 2m
PermitRootLogin prohibit-password
StrictModes yes
MaxAuthTries 6
MaxSessions 10
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no

# 🔹 Disable Keyboard Interactive Authentication
KbdInteractiveAuthentication no
UsePAM yes

# 🔹 Keep SSH connections stable
ClientAliveInterval 30
ClientAliveCountMax 3

# 🔹 Default Subsystem (Enable Detailed Logging for SFTP)
Subsystem sftp internal-sftp -l VERBOSE -f AUTH

# ======================================================
# BLOCK SFTP ON PORT 22 (ALLOW ONLY SSH)
# ======================================================
Match LocalPort 22
    AllowTcpForwarding yes
    X11Forwarding no
    ForceCommand /bin/bash  # Forces an interactive shell, preventing SFTP

# ======================================================
# ALLOW SFTP ON PORT 2225 (BLOCK SSH)
# ======================================================
Match LocalPort 2225
    ForceCommand internal-sftp -l VERBOSE  # Enable detailed logging for uploads/downloads
    PermitTTY no
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication yes
    PubkeyAuthentication no
    PermitRootLogin no

# ======================================================
# SFTP-ONLY CONFIGURATION (CHROOT)
# ======================================================
Match User apollo
    ChrootDirectory /var/sftp/Apollosftp/apollo/
    ForceCommand internal-sftp -l VERBOSE -d /apollo_Uploads  # Logs actions & default directory
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication yes

Match Group sftpusers
    ChrootDirectory /var/sftp/Apollosftp/apollo/
    ForceCommand internal-sftp -l VERBOSE -d /apollo_Uploads  # Logs actions & default directory
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication yes
```

Restart SSH:
```bash
sudo systemctl restart sshd
```

---

## **🔹 Step 4: Configure `auditd` to Log in `/var/log/sftp.log`**
### **🔹 Modify `auditd` Config (`/etc/audit/auditd.conf`)**
```ini
log_file = /var/log/sftp.log
```

Apply changes:
```bash
sudo systemctl restart auditd
```

---

### **🔹 Configure `auditd` Rules (`/etc/audit/rules.d/sftp.rules`)**
```ini
# Monitor uploads
-w /var/sftp/Apollosftp/apollo/apollo_Uploads/ -p wa -k sftp_upload
-w /var/sftp/Apollosftp/apollo/apollo_Uploads/ -p r -k sftp_download
-w /var/sftp/Apollosftp/apollo/apollo_Uploads/ -p w -k sftp_edit
-w /var/sftp/Apollosftp/apollo/apollo_Uploads/ -p a -k sftp_delete

# Monitor downloads
-w /var/sftp/Apollosftp/apollo/apollo_Downloads/ -p wa -k sftp_upload
-w /var/sftp/Apollosftp/apollo/apollo_Downloads/ -p r -k sftp_download
-w /var/sftp/Apollosftp/apollo/apollo_Downloads/ -p w -k sftp_edit
-w /var/sftp/Apollosftp/apollo/apollo_Downloads/ -p a -k sftp_delete
```

Apply changes:
```bash
sudo augenrules --load
```

---

## **🔹 Step 5: Set Correct Permissions for `/var/log/sftp.log`**
```bash
sudo touch /var/log/sftp.log
sudo chown root:root /var/log/sftp.log
sudo chmod 600 /var/log/sftp.log
```

---

## **🔹 Step 6: Configure Rsync for Automated Backups (`/usr/local/bin/sftp_backup.sh`)**
```bash
#!/bin/bash
SOURCE="/var/sftp/Apollosftp/apollo/apollo_Uploads/"
DEST="/var/backups/sftp-backup/"

rsync -avz --delete "$SOURCE" "$DEST"
```

Make the script executable:
```bash
sudo chmod +x /usr/local/bin/sftp_backup.sh
```

---

## **🔹 Step 7: Configure Cron Job for Automated Rsync (`crontab -e`)**
```ini
0 * * * * /usr/local/bin/sftp_backup.sh
```

---

## **🔹 Step 8: Restart & Enable Services**
```bash
sudo systemctl restart sshd
sudo systemctl restart auditd
```

---

## **🔹 Step 9: Testing Everything**
### ✅ **Test SFTP Login**
```bash
sftp -P 2225 apollo@<server-ip>
```

### ✅ **Check Audit Logs in `/var/log/sftp.log`**
```bash
sudo tail -f /var/log/sftp.log
```

### ✅ **Check Rsync Backup**
```bash
ls -l /var/backups/sftp-backup/
```

---

## **🚀 Summary**
✅ **SFTP configured with custom ports & restricted access**  
✅ **Audit logs stored in `/var/log/sftp.log`**  
✅ **Automated backups using `rsync`**  

This ensures a **secure and fully audited** SFTP setup. Let me know if you need any modifications! 🚀
