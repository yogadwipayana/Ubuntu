# /docker/pma/setup-pma.sh
# chmod +x setup-pma.sh
# sudo setup-pma.sh

# Script ini menjalan setup awal untuk phpMyAdmin dan mysql dengan docker
# komentar bila ada bagian yang tidak diperlukan

MYSQL_ROOT_PASSWORD="Password0"
PORT="8080"

sudo apt update && sudo apt upgrade -y

echo "Menyiapkan folder untuk data dan config pma..."
sudo mkdir -p /docker/pma
sudo mkdir -p /data/mysql-pma
sudo mkdir -p /data/mysql-conf
sudo mkdir -p /data/pma-tmp
sudo mkdir -p /data/php-conf

echo "Menyiapkan file konfigurasi pma dan mysql..."
# atur akses folder
sudo chmod 777 /data/pma-tmp
# buat file config php.ini 
sudo tee /data/php-conf/php.ini <<EOF
upload_max_filesize = 200M
post_max_size = 200M
memory_limit = 512M
max_execution_time = 300
EOF
# buat file config my.cnf 
sudo tee /data/mysql-conf/my.cnf <<EOF
[mysqld]
max_allowed_packet=512M
EOF

echo "Membuat file docker-compose untuk pma dan mysql..."
sudo tee /docker/pma/docker-compose.yml <<EOF
services:
  mysql:
    image: mysql:8.0.30
    container_name: mysql_container
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: my_database
      MYSQL_ROOT_HOST: '%'
    ports:
      - "3306:3306"
    volumes:
      - /data/mysql-pma:/var/lib/mysql
      - /data/mysql-conf/my.cnf:/etc/mysql/conf.d/my.cnf
    networks:
      - network1
  phpmyadmin:
    image: phpmyadmin
    container_name: phpmyadmin_container
    ports:
      - "${PORT}:80"
    environment:
      PMA_HOST: mysql
    networks:
      - network1
    volumes:
      - /data/pma-tmp:/tmp
      - /data/php-conf/php.ini:/usr/local/etc/php/conf.d/uploads.ini
networks:
  network1:
    driver: bridge
EOF

echo "Menjalankan docker-compose untuk pma dan mysql..."
cd /docker/pma
sudo docker compose up -d

echo "Password root PMA dan MySQL adalah: ${MYSQL_ROOT_PASSWORD}"
echo "Setup phpMyAdmin dan MySQL selesai. Akses phpMyAdmin di http://<server-ip>:${PORT}"