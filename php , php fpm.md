To install PHP and PHP-FPM on Ubuntu, follow these steps:

1. **Update the package list**  
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install PHP and PHP-FPM**  
   ```bash
   sudo apt install php php-fpm -y
   ```

   If you need a specific version, like PHP 8.1, use:  
   ```bash
   sudo apt install php8.1 php8.1-fpm -y
   ```

3. **Verify installation**  
   Check PHP version:  
   ```bash
   php -v
   ```
   Check PHP-FPM status:  
   ```bash
   systemctl status php-fpm
   ```
   For a specific version:  
   ```bash
   systemctl status php8.1-fpm
   ```

4. **Enable PHP-FPM to start on boot**  
   ```bash
   sudo systemctl enable php-fpm
   ```
   For PHP 8.1:  
   ```bash
   sudo systemctl enable php8.1-fpm
   ```

5. **Configuration files location**  
   - PHP CLI: `/etc/php/8.1/cli/php.ini`  
   - PHP-FPM: `/etc/php/8.1/fpm/php.ini`  
   - PHP-FPM pool: `/etc/php/8.1/fpm/pool.d/www.conf`

   To edit:  
   ```bash
   sudo nano /etc/php/8.1/fpm/php.ini
   ```

6. **Restart PHP-FPM after changes**  
   ```bash
   sudo systemctl restart php8.1-fpm
   ```

7. **Test PHP installation**  
   Create a test file:  
   ```bash
   echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
   ```
   Access it in a browser:  
   ```
   http://your_server_ip/info.php
   ```

This ensures PHP and PHP-FPM are installed and running properly. 🚀
