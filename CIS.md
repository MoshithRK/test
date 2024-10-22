

---

# PHP CIS Benchmark Configuration and Implementation (PHP 8.3.13)



## 1. **Introduction**
This document outlines steps to secure a PHP environment (version 8.3.13) following the recommendations of the CIS (Center for Internet Security) benchmark. These measures help mitigate security risks by properly configuring PHP.

## 2. **Prerequisites**
- Root or sudo access to the server.
- Basic knowledge of Linux and PHP.
- Access to the PHP configuration file (`php.ini`).

## 3. **PHP Version Identification**
Before making changes, identify the installed PHP version:

```bash
php -v
```

Download the corresponding CIS Benchmark guide from the [CIS website](https://www.cisecurity.org/cis-benchmarks/).

## 4. **Install and Update PHP**
Ensure that the latest version of PHP is installed and up to date:

```bash
sudo apt update && sudo apt upgrade
sudo apt install php8.3-cli php8.3-fpm
```

## 5. **Locate PHP Configuration File**
The main PHP configuration file is typically located at `/etc/php/8.3/fpm/php.ini` for FPM or `/etc/php/8.3/cli/php.ini` for the CLI. Find the location of the active `php.ini`:

```bash
php -i | grep 'Loaded Configuration File'
```

## 6. **Harden `php.ini` Settings**
Modify the following settings in your `php.ini` file. Make sure to take a backup before editing:

```bash
sudo cp /etc/php/8.3/fpm/php.ini /etc/php/8.3/fpm/php.ini.bak
sudo nano /etc/php/8.3/fpm/php.ini
```

### 6.1. **Disable Unnecessary Functions**
Prevent the execution of dangerous PHP functions that can compromise security:

```ini
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source
```

### 6.2. **Disable PHP Version Exposure**
Disable the PHP version exposure to attackers by setting:

```ini
expose_php = Off
```

### 6.3. **Error Handling and Logging**
Ensure error reporting is set properly to avoid revealing sensitive details:

```ini
display_errors = Off
log_errors = On
error_log = /var/log/php_errors.log
```

### 6.4. **File Uploads**
Restrict file upload size and limit types:

```ini
file_uploads = On
upload_max_filesize = 2M
max_file_uploads = 5
```

### 6.5. **Secure Session Configuration**
Configure session handling securely:

```ini
session.cookie_httponly = 1
session.cookie_secure = 1
session.use_strict_mode = 1
```

### 6.6. **Limit Resource Usage**
To avoid resource exhaustion, set limits:

```ini
max_execution_time = 30
memory_limit = 128M
post_max_size = 8M
max_input_time = 60
```

### 6.7. **Disable Remote Code Execution**
Disable dangerous features like remote code execution:

```ini
allow_url_fopen = Off
allow_url_include = Off
```

### 6.8. **Disable X-Powered-By Header**
Disable X-Powered-By header which can leak information about the server:

```ini
expose_php = Off
```

## 7. **Server Hardening Steps**

### 7.1. **Configure PHP-FPM**
Edit the PHP-FPM configuration file:

```bash
sudo nano /etc/php/8.3/fpm/pool.d/www.conf
```

Make the following changes:

```ini
; Ensure PHP-FPM runs as a non-root user
user = www-data
group = www-data

; Set process manager to 'ondemand' to minimize resource usage
pm = ondemand

; Limit maximum number of child processes
pm.max_children = 50

; Restrict process execution environment
chroot = /var/www
```

Restart PHP-FPM:

```bash
sudo systemctl restart php8.3-fpm
```

### 7.2. **Secure File Permissions**
Ensure correct file permissions for the PHP configuration files:

```bash
sudo chown root:root /etc/php/8.3/fpm/php.ini
sudo chmod 644 /etc/php/8.3/fpm/php.ini
```

### 7.3. **Secure Web Server Configuration**
Depending on whether you are using Apache or Nginx, follow these steps:

#### Nginx Security
For Nginx, ensure proper configuration for security:

- Disable directory listing:

  ```nginx
  location / {
      autoindex off;
  }
  ```

- Add security headers:

  ```nginx
  add_header X-Frame-Options "SAMEORIGIN";
  add_header X-XSS-Protection "1; mode=block";
  add_header X-Content-Type-Options "nosniff";
  ```

- Limit client request size and method:

  ```nginx
  client_max_body_size 2M;
  limit_except GET POST {
      deny all;
  }
  ```

#### Apache Security
For Apache, apply security best practices:

- Disable directory listing by ensuring:

  ```bash
  Options -Indexes
  ```

- Add security headers in the Apache configuration file:

  ```apache
  Header always set X-Frame-Options "SAMEORIGIN"
  Header always set X-XSS-Protection "1; mode=block"
  Header always set X-Content-Type-Options "nosniff"
  ```

## 8. **File Permissions and Ownership**
Ensure proper ownership and restrictive permissions for sensitive files.

```bash
sudo chown root:root /etc/php/8.3/fpm/php.ini
sudo chmod 640 /etc/php/8.3/fpm/php.ini
```

Set appropriate permissions for your web document root:

```bash
sudo chown www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

## 9. **Conclusion**
By following these steps, you can harden your PHP 8.3.13 environment and significantly reduce security risks. Regularly review and update your PHP configurations as new vulnerabilities arise to maintain a secure environment.

--- 
### References
- [PHP INI Configuration Options](https://www.php.net/manual/en/ini.list.php)
- [PHP Session Security](https://www.php.net/manual/en/session.security.php)
- [PHP Security Guide](https://www.php.net/manual/en/security.php)

--- 

This document focuses solely on securing the PHP environment based on CIS Benchmark guidelines, ensuring your PHP environment is protected from common vulnerabilities.
