
---

## **1. Setup on Master Server**

### Step 1: Install MySQL
1. Update and install MySQL:
   ```bash
   sudo apt update
   sudo apt install mysql-server -y
   ```

2. Verify MySQL is running:
   ```bash
   sudo systemctl status mysql
   ```

---

### Step 2: Create a Database and Populate Data
1. Log in to MySQL:
   ```bash
   sudo mysql
   ```

2. Create a database and table, and insert sample data:
   ```sql
   CREATE DATABASE replication_test;
   USE replication_test;
   CREATE TABLE test_table (
       id INT AUTO_INCREMENT PRIMARY KEY,
       message VARCHAR(255)
   );
   INSERT INTO test_table (message) VALUES ('Initial data from Master');
   ```

3. Verify the data:
   ```sql
   SELECT * FROM test_table;
   ```

4. Exit MySQL:
   ```sql
   EXIT;
   ```

---

### Step 3: Configure Master Server
1. Edit MySQL configuration:
   ```bash
   sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
   ```

2. Add the following under `[mysqld]`:
   ```ini
   server-id=1                 # Unique ID for Master
   log_bin=/var/log/mysql/mysql-bin.log
   binlog_do_db=replication_test   # Specify the database to replicate
   ```

3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

4. Restart MySQL:
   ```bash
   sudo systemctl restart mysql
   ```

---

### Step 4: Create a Replication User
1. Log back into MySQL:
   ```bash
   sudo mysql
   ```

2. Create the replication user and grant privileges:
   ```sql
   CREATE USER 'replicator'@'%' IDENTIFIED BY 'replication_password';
   GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';
   FLUSH PRIVILEGES;
   ```

3. Check Master status and note the `File` and `Position`:
   ```sql
   SHOW MASTER STATUS;
   ```

   Example output:
   ```
   +------------------+----------+--------------+------------------+
   | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
   +------------------+----------+--------------+------------------+
   | mysql-bin.000001 |      154 | replication_test |              |
   +------------------+----------+--------------+------------------+
   ```

4. Exit MySQL:
   ```sql
   EXIT;
   ```

---

### Step 5: Take a Database Dump
1. Create a dump of the database:
   ```bash
   sudo mysqldump -u root --databases replication_test --source-data > master_dump.sql
   ```

2. Transfer the dump file to the Slave server:
   ```bash
   scp master_dump.sql user@slave_ip:/path/to/destination/
   ```

---

## **2. Setup on Slave Server**

### Step 6: Install MySQL
1. Update and install MySQL:
   ```bash
   sudo apt update
   sudo apt install mysql-server -y
   ```

2. Verify MySQL is running:
   ```bash
   sudo systemctl status mysql
   ```

---

### Step 7: Import Database Dump
1. Ensure the dump file is on the Slave server.

2. Import the dump:
   ```bash
   mysql -u root < /path/to/master_dump.sql
   ```

3. Verify the data:
   ```bash
   sudo mysql -e "USE replication_test; SELECT * FROM test_table;"
   ```

---

### Step 8: Configure Slave Server
1. Edit the MySQL configuration:
   ```bash
   sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
   ```

2. Add the following under `[mysqld]`:
   ```ini
   server-id=2                 # Unique ID for Slave
   relay_log=/var/log/mysql/mysql-relay-bin.log
   log_bin=/var/log/mysql/mysql-bin.log
   ```

3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).

4. Restart MySQL:
   ```bash
   sudo systemctl restart mysql
   ```

---

### Step 9: Configure Replication
1. Log in to MySQL on the Slave server:
   ```bash
   sudo mysql
   ```

2. Configure replication using the Master’s details:
   ```sql
   CHANGE MASTER TO
   MASTER_HOST='master_ip',                  -- Replace with Master server's IP
   MASTER_USER='replicator',                 -- Replication user
   MASTER_PASSWORD='replication_password',   -- Replication password
   MASTER_LOG_FILE='mysql-bin.000001',       -- File from Master
   MASTER_LOG_POS=154;                       -- Position from Master
   ```

3. Start the replication process:
   ```sql
   START SLAVE;
   ```

4. Check the Slave status:
   ```sql
   SHOW SLAVE STATUS\G
   ```

   Ensure:
   - `Slave_IO_Running: Yes`
   - `Slave_SQL_Running: Yes`

---

## **3. Verify Replication**
1. On the Master server, add more data:
   ```bash
   sudo mysql
   ```

   ```sql
   USE replication_test;
   INSERT INTO test_table (message) VALUES ('Replication test data from Master');
   ```

2. On the Slave server, check if the data is replicated:
   ```bash
   sudo mysql
   ```

   ```sql
   USE replication_test;
   SELECT * FROM test_table;
   ```

---


# Resolving MySQL Replication Connection Issue

This guide provides steps to resolve the `Slave_IO_Running: Connecting` issue in MySQL replication caused by the `caching_sha2_password` authentication plugin requiring a secure connection.

## Problem Statement

The MySQL replication slave fails to connect to the master server, and the `SHOW SLAVE STATUS\G` output shows:

```
Last_IO_Error: Error connecting to source 'repl@172.31.34.49:3306'. This was attempt 6/86400, with a delay of 60 seconds between attempts. Message: Authentication plugin 'caching_sha2_password' reported error: Authentication requires secure connection.
```

## Resolution Steps

### 1. Verify Master's Authentication Plugin
Log in to the MySQL master server and check the authentication plugin used by the `repl` user:

```sql
SELECT user, host, plugin FROM mysql.user WHERE user = 'repl';
```

### 2. Switch Authentication Plugin (if necessary)
If the plugin is `caching_sha2_password`, switch it to `mysql_native_password` for compatibility:

```sql
ALTER USER 'repl'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'your_password';
```

Replace `your_password` with the actual password for the `repl` user.

### 3. Ensure SSL Connection (if preferred)
To use `caching_sha2_password` with SSL, configure SSL on both the master and the slave:

- On the master:
  ```sql
  ALTER USER 'repl'@'%' REQUIRE SSL;
  ```
- On the slave, update the `CHANGE MASTER TO` statement to include SSL settings:
  ```sql
  CHANGE MASTER TO MASTER_SSL=1,
    MASTER_SSL_CA='/path/to/ca-cert.pem',
    MASTER_SSL_CERT='/path/to/client-cert.pem',
    MASTER_SSL_KEY='/path/to/client-key.pem';
  ```

### 4. Restart Replication
Stop and restart the slave replication with updated credentials:

```sql
STOP SLAVE;
CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='your_password';
START SLAVE;
```

### 5. Verify Replication Status
Check the replication status to confirm the issue is resolved:

```sql
SHOW SLAVE STATUS\G;
```

Ensure the following:
- `Slave_IO_Running: Yes`
- `Slave_SQL_Running: Yes`

### 6. Check Network Connectivity
Verify that there are no firewall rules or network issues blocking the connection to the master server on port 3306.

## Additional Notes
- Use `caching_sha2_password` with SSL for enhanced security.
- Ensure all changes are tested in a staging environment before applying to production.

### References
  - [MySQL Documentation](https://www.linuxtrainingacademy.com/mysql-master-slave-replication-ubuntu-linux/)



## **Final Notes**
- If `Slave_IO_Running` or `Slave_SQL_Running` shows errors, check the `Last_IO_Error` or `Last_SQL_Error` in `SHOW SLAVE STATUS\G` and address the issues.
- Use strong passwords for the replication user for security.

