# VPS Setup Scripts

Repository ini berisi kumpulan script shell untuk memudahkan setup awal VPS (Virtual Private Server) dengan berbagai konfigurasi yang umum digunakan.

## 📋 Daftar Isi

- [Tentang Project](#tentang-project)
- [Daftar Script](#daftar-script)
  - [setup-pma.sh](#setup-pmash)
  - [setup-ssh.sh](#setup-sshshh)
- [Prasyarat](#prasyarat)
- [Cara Penggunaan](#cara-penggunaan)
- [Konfigurasi](#konfigurasi)
- [Troubleshooting](#troubleshooting)

---

## 📖 Tentang Project

Project ini dibuat untuk mempermudah proses setup dan konfigurasi VPS Ubuntu dengan mengotomatisasi instalasi dan konfigurasi berbagai service yang sering digunakan seperti:
- Docker & Docker Compose
- MySQL Database
- phpMyAdmin
- SSH Security Hardening
- UFW Firewall

---

## 📝 Daftar Script

### setup-pma.sh

**Deskripsi:**  
Script untuk menginstal dan mengkonfigurasi phpMyAdmin dan MySQL menggunakan Docker. Script ini akan:
- Menginstal Docker dan Docker Compose
- Membuat folder-folder yang diperlukan untuk data dan konfigurasi
- Mengatur konfigurasi PHP untuk upload file berukuran besar (hingga 200MB)
- Mengatur konfigurasi MySQL untuk max_allowed_packet (512MB)
- Menjalankan container MySQL dan phpMyAdmin

**Lokasi:** `/data/bin/setup-pma.sh`

**Port Default:**
- MySQL: `3306`
- phpMyAdmin: `8080`

**Cara Mengeksekusi:**

```bash
# 1. Berikan izin eksekusi pada file
chmod +x setup-pma.sh

# 2. Edit konfigurasi password dan port (PENTING!)
nano setup-pma.sh
# Ubah nilai:
# - MYSQL_ROOT_PASSWORD="GantiPasswordIni"
# - PORT="8080"

# 3. Jalankan script dengan sudo
sudo ./setup-pma.sh
```

**Konfigurasi yang Dapat Diubah:**
- `MYSQL_ROOT_PASSWORD`: Password untuk user root MySQL (default: "GantiPasswordIni")
- `PORT`: Port untuk akses phpMyAdmin (default: "8080")

**File Konfigurasi yang Dibuat:**
- `/data/php-conf/php.ini`: Konfigurasi PHP untuk phpMyAdmin
- `/data/mysql-conf/my.cnf`: Konfigurasi MySQL
- `/docker/pma/docker-compose.yml`: Docker Compose file

**Akses phpMyAdmin:**
```
URL: http://<IP-SERVER>:8080
Username: root
Password: <MYSQL_ROOT_PASSWORD yang Anda set>
```

---

### setup-ssh.sh

**Deskripsi:**  
Script untuk mengkonfigurasi SSH dengan keamanan yang lebih baik. Script ini akan:
- Membuat folder `.ssh` dengan permission yang benar
- Menambahkan public key untuk SSH key-based authentication
- Menonaktifkan login root via password (hanya key-based)
- Mengkonfigurasi UFW firewall untuk membuka port yang diperlukan

**Lokasi:** `/data/bin/setup-ssh.sh`

**Port yang Dibuka:**
- SSH (OpenSSH)
- HTTP (80)
- HTTPS (443)

**Cara Mengeksekusi:**

```bash
# 1. Generate SSH key di komputer lokal Anda (jika belum punya)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# Public key akan ada di: ~/.ssh/id_rsa.pub

# 2. Salin isi public key Anda
cat ~/.ssh/id_rsa.pub

# 3. Edit script dan masukkan public key
nano setup-ssh.sh
# Ubah nilai:
# - PUBLIC_KEY="ISI_PUBLIC_KEY_INI"

# 4. Berikan izin eksekusi
chmod +x setup-ssh.sh

# 5. Jalankan script dengan sudo
sudo ./setup-ssh.sh
```

**⚠️ PERINGATAN PENTING:**
- Pastikan Anda sudah memasukkan public key yang benar sebelum menjalankan script
- Setelah script dijalankan, login via password akan dinonaktifkan
- Simpan private key Anda dengan aman, karena ini satu-satunya cara untuk login

**Login Setelah Setup:**
```bash
ssh root@<IP-VPS>
# Atau jika menggunakan private key di lokasi khusus:
ssh -i /path/to/private_key root@<IP-VPS>
```

---

## 🔧 Prasyarat

- VPS dengan Ubuntu (tested on Ubuntu 20.04/22.04)
- Akses root atau sudo privileges
- Koneksi internet yang stabil
- Untuk `setup-ssh.sh`: SSH key pair (public & private key)

---

## 🚀 Cara Penggunaan

### Setup Lengkap VPS Baru

Untuk setup VPS baru dari awal, ikuti urutan berikut:

```bash
# 1. Login ke VPS
ssh root@<IP-VPS>

# 2. Buat folder untuk script
sudo mkdir -p /data/bin
cd /data/bin

# 3. Upload atau copy script ke VPS
# Gunakan scp, rsync, atau copy manual

# 4. Jalankan setup SSH terlebih dahulu (PENTING!)
chmod +x setup-ssh.sh
nano setup-ssh.sh  # Edit PUBLIC_KEY
sudo ./setup-ssh.sh

# 5. Test SSH dengan key (buka terminal baru, jangan tutup yang lama)
ssh root@<IP-VPS>

# 6. Jika SSH berhasil, jalankan setup phpMyAdmin
chmod +x setup-pma.sh
nano setup-pma.sh  # Edit PASSWORD dan PORT
sudo ./setup-pma.sh
```

---

## ⚙️ Konfigurasi

### Mengubah Port phpMyAdmin Setelah Instalasi

```bash
# Edit docker-compose.yml
sudo nano /docker/pma/docker-compose.yml
# Ubah port di bagian phpmyadmin -> ports

# Restart container
cd /docker/pma
sudo docker-compose down
sudo docker-compose up -d
```

### Menambahkan Port Baru di Firewall

```bash
sudo ufw allow <PORT-NUMBER>
sudo ufw status
```

### Melihat Status Container Docker

```bash
sudo docker ps
sudo docker-compose -f /docker/pma/docker-compose.yml logs
```

---

## 🔍 Troubleshooting

### phpMyAdmin tidak bisa diakses

```bash
# Cek status container
sudo docker ps

# Cek logs
cd /docker/pma
sudo docker-compose logs

# Restart container
sudo docker-compose restart
```

### Tidak bisa login SSH setelah setup

```bash
# Jika masih punya terminal yang terbuka:
# 1. Cek apakah public key sudah benar
cat ~/.ssh/authorized_keys

# 2. Restore SSH config
sudo sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
```

### MySQL container error

```bash
# Cek logs MySQL
sudo docker logs mysql_container

# Reset data MySQL (HATI-HATI: akan menghapus semua data!)
sudo docker-compose -f /docker/pma/docker-compose.yml down
sudo rm -rf /data/mysql-pma/*
sudo docker-compose -f /docker/pma/docker-compose.yml up -d
```

---

## 📄 Lisensi

Silakan digunakan dan dimodifikasi sesuai kebutuhan Anda.

---

## 🤝 Kontribusi

Jika Anda menemukan bug atau ingin menambahkan fitur baru, silakan buat issue atau pull request.

---

**Dibuat dengan ❤️ untuk mempermudah setup VPS**