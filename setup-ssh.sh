# /data/bin/setup-ssh.sh

# Script ini menjalankan setup awal untuk menambahkan ssh dan menonaktifkan login root via ssh
# komentar bila ada bagian yang tidak diperlukan

PUBLIC_KEY="ISI_PUBLIC_KEY_INI"

echo "Membuat folder ssh..."
sudo mkdir -p ~/.ssh
sudo chmod 700 ~/.ssh

echo "Menambahkan public key ke authorized_keys..."
sudo tee ~/.ssh/authorized_keys <<EOF
${PUBLIC_KEY}
EOF
sudo chmod 600 ~/.ssh/authorized_keys

echo "Mematikan login via password..."
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

echo "Izinkan hanya login via key (lebih aman)..."
sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

echo "Restart SSH..."
systemctl restart ssh

echo "Setup Firewall UFW..."
ufw allow OpenSSH
ufw allow 80
ufw allow 443
ufw --force enable

echo "============================================="
echo "Setup VPS Selesai!"  
echo "Login sekarang dengan:"
echo "public key=${PUBLIC_KEY}"
echo "ssh root@IP_VPS"
echo "============================================="