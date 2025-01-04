# MySQL Group Replication in Multi-Primary Mode

This document provides step-by-step instructions for setting up MySQL Group Replication in **multi-primary mode** across three nodes.

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Configuration Steps](#configuration-steps)
    - [Install MySQL](#1-install-mysql)
    - [Configure MySQL on Each Node](#2-configure-mysql-on-each-node)
    - [Create Replication User](#3-create-replication-user)
    - [Install Group Replication Plugin](#4-install-group-replication-plugin)
    - [Bootstrap the Group](#5-bootstrap-the-group)
    - [Verify Group Membership](#6-verify-group-membership)
4. [Testing Multi-Primary Mode](#testing-multi-primary-mode)
5. [Troubleshooting](#troubleshooting)

---

## Overview
MySQL Group Replication enables highly available, fault-tolerant MySQL setups. In **multi-primary mode**, all nodes can accept write operations simultaneously, ensuring high scalability and availability.

### Nodes in This Setup:
- **Node 1:** `172.31.34.49`
- **Node 2:** `172.31.40.226`
- **Node 3:** `172.31.34.181`

---

## Prerequisites
1. Three servers with MySQL installed.
2. Open required ports:
   - **3306:** MySQL connections
   - **33061:** Group Replication communication
3. Root access to all servers.

---

## Configuration Steps

### 1. Install MySQL
Run the following commands on all nodes:
```bash
sudo apt update
sudo apt install mysql-server -y
```

---

### 2. Configure MySQL on Each Node
Edit the MySQL configuration file:
```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```
Add the following configurations under `[mysqld]`, adjusting the `server-id` and `loose-group_replication_local_address` for each node.

#### Node 1 (`172.31.34.49`):
```ini
server-id=1
bind-address=0.0.0.0
log_bin=mysql-bin
binlog_format=ROW
gtid_mode=ON
enforce_gtid_consistency=ON
master_info_repository=TABLE
relay_log_info_repository=TABLE
transaction_write_set_extraction=XXHASH64
loose-group_replication_group_name="9e992cee-6279-4ca3-9672-c12bcbb31bed"
loose-group_replication_start_on_boot=OFF
loose-group_replication_local_address="172.31.34.49:33061"
loose-group_replication_group_seeds="172.31.34.49:33061,172.31.40.226:33061,172.31.34.181:33061"
loose-group_replication_bootstrap_group=OFF
loose-group_replication_single_primary_mode=OFF
```

#### Node 2 (`172.31.40.226`):
```ini
server-id=2
bind-address=0.0.0.0
log_bin=mysql-bin
binlog_format=ROW
gtid_mode=ON
enforce_gtid_consistency=ON
master_info_repository=TABLE
relay_log_info_repository=TABLE
transaction_write_set_extraction=XXHASH64
loose-group_replication_group_name="9e992cee-6279-4ca3-9672-c12bcbb31bed"
loose-group_replication_start_on_boot=OFF
loose-group_replication_local_address="172.31.40.226:33061"
loose-group_replication_group_seeds="172.31.34.49:33061,172.31.40.226:33061,172.31.34.181:33061"
loose-group_replication_bootstrap_group=OFF
loose-group_replication_single_primary_mode=OFF
```

#### Node 3 (`172.31.34.181`):
```ini
server-id=3
bind-address=0.0.0.0
log_bin=mysql-bin
binlog_format=ROW
gtid_mode=ON
enforce_gtid_consistency=ON
master_info_repository=TABLE
relay_log_info_repository=TABLE
transaction_write_set_extraction=XXHASH64
loose-group_replication_group_name="9e992cee-6279-4ca3-9672-c12bcbb31bed"
loose-group_replication_start_on_boot=OFF
loose-group_replication_local_address="172.31.34.181:33061"
loose-group_replication_group_seeds="172.31.34.49:33061,172.31.40.226:33061,172.31.34.181:33061"
loose-group_replication_bootstrap_group=OFF
loose-group_replication_single_primary_mode=OFF
```
Save and restart MySQL on all nodes:
```bash
sudo systemctl restart mysql
```

---

### 3. Create Replication User
Log in to MySQL on each node:
```bash
sudo mysql -u root -p
```
Run the following commands:
```sql
CREATE USER 'repl'@'%' IDENTIFIED BY '123456789';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
```

---

### 4. Install Group Replication Plugin
Run this command on all nodes:
```sql
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
```

---

### 5. Bootstrap the Group
On **Node 1 (`172.31.34.49`)**:
```sql
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
```

On **Node 2** and **Node 3**:
```sql
START GROUP_REPLICATION;
```

---

### 6. Verify Group Membership
On any node, run:
```sql
SELECT * FROM performance_schema.replication_group_members;
```
You should see all three nodes listed.

---

## Testing Multi-Primary Mode

1. On **Node 1**, create a test database and table:
    ```sql
    CREATE DATABASE testdb;
    USE testdb;
    CREATE TABLE demo (id INT PRIMARY KEY, value VARCHAR(50));
    INSERT INTO demo VALUES (1, 'Test Value');
    ```

2. On **Node 2** and **Node 3**, verify the data:
    ```sql
    USE testdb;
    SELECT * FROM demo;
    ```
   All nodes should reflect the same data.

---

## Troubleshooting
- **Ensure required ports are open:**
    ```bash
    sudo ufw allow 3306
    sudo ufw allow 33061
    sudo ufw reload
    ```
- **Check logs:**
    ```bash
    sudo tail -f /var/log/mysql/error.log
    ```
- **Verify configurations:** Ensure `server-id`, `group_replication_local_address`, and `group_replication_group_seeds` are correctly set on all nodes.

---

## License
This setup guide is provided under the MIT License.

Steps:
Install MySQL
apt-get update; apt-get -y install mysql-server-8.0

Open up access to the ports 3306 and 33061 in the firewall
ufw allow 3306

Server 1
ufw allow from server2_ip to any port 33061
ufw allow from server3_ip to any port 33061

Server 2
ufw allow from server1_ip to any port 33061
ufw allow from server3_ip to any port 33061

Server 3
ufw allow from server1_ip to any port 33061
ufw allow from server2_ip to any port 33061

Generate UUID
uuidgen
Output
168dcb64-7cce-473a-b338-6501f305e561

Modify the configuration of server 1.
vi /etc/mysql/my.cnf

ALL MYSQL
[mysqld]

General replication settings
disabled_storage_engines="MyISAM,BLACKHOLE,FEDERATED,ARCHIVE,MEMORY"
gtid_mode = ON
enforce_gtid_consistency = ON
master_info_repository = TABLE
relay_log_info_repository = TABLE
binlog_checksum = NONE
log_replica_updates = ON
log_bin = binlog
binlog_format = ROW
transaction_write_set_extraction = XXHASH64
loose-group_replication_bootstrap_group = OFF
loose-group_replication_start_on_boot = OFF
loose-group_replication_ssl_mode = REQUIRED
loose-group_replication_recovery_use_ssl = 1

Shared replication group configuration
loose-group_replication_group_name = "168dcb64-7cce-473a-b338-6501f305e561"
loose-group_replication_ip_allowlist = "mysql1,mysql2,mysql3"
loose-group_replication_group_seeds = "mysql1:33061,mysql2:33061,mysql3:33061"

For multi-primary mode, where any host can accept writes
loose-group_replication_single_primary_mode = OFF
loose-group_replication_enforce_update_everywhere_checks = ON

Host specific replication configuration
bind-address = "0.0.0.0"
server_id = " "
report_host = " "
loose-group_replication_local_address = " :33061"

Restart mysql
systemctl restart mysql

Configuring Replication Users and Enabling Group Replication Plugin
mysql

SET SQL_LOG_BIN=0;
CREATE USER 'repl'@'%' IDENTIFIED BY 'Password123!' REQUIRE SSL;
GRANT REPLICATION SLAVE ON . TO 'repl'@'%';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE REPLICATION SOURCE TO SOURCE_USER='repl', SOURCE_PASSWORD='Password123!' FOR CHANNEL 'group_replication_recovery';
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
SHOW PLUGINS;

Starting Group Replication
Server 1
SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;
SELECT * FROM performance_schema.replication_group_members\G;

Server 2 and Server 3
START GROUP_REPLICATION;
SELECT * FROM performance_schema.replication_group_members;

Test replication
Server 3
CREATE DATABASE lazy;

Server 1
SHOW DATABASES;
USE lazy;
CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

Server 2
SHOW DATABASES;
USE lazy;
SHOW TABLES;

