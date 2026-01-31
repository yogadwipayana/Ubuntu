apt update && apt upgrade -y

apt install nano -y
apt install curl -y

rm /etc/localtime
rm /etc/timezone

ln -sf /usr/share/zoneinfo/Asia/Makassar /etc/localtime

sudo systemctl disable --now apache2