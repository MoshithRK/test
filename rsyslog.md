# Installation and configuration of rsyslog server and clients on ubuntu

### Installation of Syslog Server (rsyslog-server):

1. Install the rsyslog package
```sh
sudo apt update
sudo apt install rsyslog

sudo  hostnamectl set-hostname syslog-server
```
2. Edit the rsyslog configuration file /etc/rsyslog.conf:
```sh
## sudo vim /etc/rsyslog.conf

# Provides UDP syslog reception
module(load="imudp")
input(type="imudp" port="514")

# Provides TCP syslog reception
module(load="imtcp")
input(type="imtcp" port="514")

# Remote Logs Access
$template RemoteLogs,"/var/log/%HOSTNAME%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~
```
3. Restart rsyslog.
```sh
sudo systemctl restart rsyslog
```
4. Verify the listening port 514. if the 514 port is not listening, enable the port using the syslog configuration.
```sh
sudo ss -tulpn | grep 514
```

### Installation of Syslog Client Server (syslog):
1.  Install rsyslog (if not installed):
```sh
sudo apt update
sudo apt install rsyslog

sudo  hostnamectl set-hostname syslog-client-server
```
2. Edit the rsyslog configuration file /etc/rsyslog.conf:
```sh
# sudo nano /etc/rsyslog.conf

# add the below in the configuration file
*.* @syslog-server-public-ip:514
```
3. Restart rsyslog.
```sh
sudo systemctl restart rsyslog
```
4. Check the connectivity between syslog client server to syslog server
```sh
sudo nc -vz (syslog-server-public-ip) 514
```
5. Check the rsyslog configuration file for any errors:
```sh
sudo rsyslogd -N1
```
### TESTING SYSLOG SERVER
Check the syslog server to see if the log entries are being received:
```sh
sudo tail -f /var/log/
```
We will see the two folders,
1. rsyslog-server
2. syslog-client-server

![Image](https://github.com/rcms-org/issues-and-incidents/assets/91359308/16290a39-70ce-4532-b0cb-5bff695b9f2d)

## How to configure RSyslog on Ubuntu to forward Apache HTTP Access Logs and error logs

1. Install the apache2 webserver on syslog-client-server
```sh
sudo apt update
sudo apt install apache2

sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2
```
2. Create a file under /etc/rsyslog.d/ named 02-apache2.access.conf:
```sh
sudo vim  /etc/rsyslog.d/logs.conf
```
3. Add the below line
```sh
# sudo vim /etc/rsyslog.d/logs.conf

module(load="imfile" PollingInterval="10")
ruleset(name="ApacheLogs") {
action(
type="omfwd"
target="Rsyslog Server IP"
port="514"
protocol="udp"
queue.SpoolDirectory="/var/spool/rsyslog"
queue.FileName="remote"
queue.MaxDiskSpace="1g"
queue.SaveOnShutdown="on"
queue.Type="LinkedList"
ResendLastMSGOnReconnect="on"
)
stop
}
input(type="imfile" ruleset="ApacheLogs" Tag="apache2_access" File="/var/log/apache2/access.log")
input(type="imfile" ruleset="ApacheLogs" Tag="apache2_error" File="/var/log/apache2/error.log")
```
4. Run the following command to verify the configuration:
```sh
sudo rsyslogd -N1 -f /etc/rsyslog.d/logs.conf
```
7. Restart the RSyslog service:
```sh
sudo systemctl restart rsyslog
```
8. Check the syslog client server logs in syslog server

![Image](https://github.com/rcms-org/issues-and-incidents/assets/91359308/3b93aefe-a002-4f39-bdfa-5de3406c25d4)

## How to configure RSyslog on Ubuntu to forward MySQL Logs
1. Install mysql (if is not installed):
```sh
sudo apt install mysql-server -y
sudo systemctl start mysql.service
sudo systemctl enable mysql.service
sudo systemctl status mysql.service
```
2. Enable the General Logs on mysql configuration file.
```sh
sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf

# add the below line in the configuration file
general_log             = 1
general_log_file        = /var/log/mysql/mysql.log
```
3. Check the logs whether it is printed or not.
```sh
cd /var/log/mysql
tail mysql.log
```
4. After checked the mysql logs, we need to push the mysql logs to syslog-server.
```sh
sudo vim /etc/rsyslog.d/logs.conf

# add the lines in the configuration file
input(type="imfile" ruleset="MysqlLogs" Tag="mysql_access" File="/var/log/mysql/access.log")
input(type="imfile" ruleset="MysqlLogs" Tag="mysql_error" File="/var/log/mysql/error.log")
input(type="imfile" ruleset="MysqlLogs" Tag="mysql_db_login" File="/var/log/mysql/mysql.log")
```
5. Restart the RSyslog service syslog client and syslog server's:
```sh
sudo systemctl restart rsyslog
```
Reference:
https://www.youtube.com/watch?v=MtSpChq6tIg&t=1032s

https://www.ibm.com/support/pages/qradar-how-configure-rsyslog-ubuntu-forward-apache-http-access-logs

https://github.com/rsyslog/rsyslog/issues/5030
