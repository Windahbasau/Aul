bash
#!/bin/bash

# Variabel
PTERO_VERSION="1.11.0"
DB_HOST="localhost"
DB_USERNAME="pterodactyl"
DB_PASSWORD="password"
DB_NAME="pterodactyl"

# Periksa hak akses
if [ "$(id -u)" != "0" ]; then
  echo "Harus menjalankan sebagai root!"
  exit 1
fi

# Instalasi dependensi
echo "Menginstal dependensi..."
apt update
apt install -y nginx mysql-server php7.4-fpm php7.4-mysql php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml php7.4-zip

# Konfigurasi MySQL
echo "Mengkonfigurasi MySQL..."
mysql -u root -e "CREATE DATABASE $DB_NAME;"
mysql -u root -e "CREATE USER '$DB_USERNAME'@'%' IDENTIFIED BY '$DB_PASSWORD';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USERNAME'@'%';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Instalasi Pterodactyl
echo "Menginstal Pterodactyl..."
wget https://github.com/Pterodactyl/Pterodactyl/archive/refs/tags/$PTERO_VERSION.zip
unzip $PTERO_VERSION.zip
mv Pterodactyl-$PTERO_VERSION /var/www/pterodactyl
chmod -R 755 /var/www/pterodactyl

# Konfigurasi Pterodactyl
echo "Mengkonfigurasi Pterodactyl..."
cp /var/www/pterodactyl/.env.example /var/www/pterodactyl/.env
sed -i "s/DB_HOST=.*/DB_HOST=$DB_HOST/" /var/www/pterodactyl/.env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" /var/www/pterodactyl/.env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" /var/www/pterodactyl/.env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" /var/www/pterodactyl/.env

# Instalasi composer
echo "Menginstal composer..."
composer install --no-dev --prefer-dist

# Konfigurasi nginx
echo "Mengkonfigurasi nginx..."
cp /var/www/pterodactyl/contrib/nginx.conf.example /etc/nginx/sites-available/pterodactyl
sed -i "s/server_name.*/server_name pterodactyl.example.com;/" /etc/nginx/sites-available/pterodactyl
ln -s /etc/nginx/sites-available/pterodactyl /etc/nginx/sites-enabled/
service nginx restart

# Konfigurasi systemd
echo "Mengkonfigurasi systemd..."
cp /var/www/pterodactyl/contrib/systemd.service.example /etc/systemd/system/pterodactyl.service
sed -i "s/User=.*/User=www-data/" /etc/systemd/system/pterodactyl.service
sed -i "s/Group=.*/Group=www-data/" /etc/systemd/system/pterodactyl.service
systemctl daemon-reload
systemctl enable pterodactyl
systemctl start pterodactyl

echo "Instalasi selesai!"
```
