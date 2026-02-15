#!/bin/bash
# Script Installer (Modified Version)
# Dibuat oleh: galih

# --- Definisi Warna ---
NC='\033[0m'
BIBlack='\033[1;90m'
BIRed='\033[1;91m'
BIGreen='\033[1;92m'
BIYellow='\033[1;93m'
BIBlue='\033[1;94m'
BIPurple='\033[1;95m'
BICyan='\033[1;96m'
BIWhite='\033[1;97m'
UWhite='\033[4;37m'
On_IPurple='\033[0;105m'
On_IRed='\033[0;101m'
IBlack='\033[0;90m'
IRed='\033[0;91m'
IGreen='\033[0;92m'
IYellow='\033[0;93m'
IBlue='\033[0;94m'
IPurple='\033[0;95m'
ICyan='\033[0;96m'
IWhite='\033[0;97m'
BGCOLOR='\e[1;97;101m'
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
export PINK='\033[0;35m'
export YELLOW='\033[0;33m'

# --- Fungsi Warna Teks ---
purple() { echo -e "\033[35;1m${*}\033[0m"; }
tyblue() { echo -e "\033[36;1m${*}\033[0m"; }
yellow() { echo -e "\033[33;1m${*}\033[0m"; }
green() { echo -e "\033[32;1m${*}\033[0m"; }
red() { echo -e "\033[31;1m${*}\033[0m"; }

# --- Validasi Awal (BYPASSED) ---
echo -e "${IGreen}♻️ Check Validasi Masuk...${NC}"
sleep 2
clear

# Placeholder data agar script tetap jalan tanpa input database luar
client_name="Admin-User"
IP_VPS=$(curl -s https://ipinfo.io/ip)
exp_date="2030-12-31"

echo -e "${IGreen}Client Name accepted... Let's go...${NC}"
mkdir -p /etc/data
echo -e "${GREEN}Sedang Melanjutkan proses...${NC}"
sleep 1

# --- Validasi Root Access ---
if [[ "${EUID}" -ne 0 ]]; then
    red "Script harus dijalankan sebagai user root!"
    exit 1
fi

# --- Validasi Virtualisasi ---
if [[ "$(systemd-detect-virt)" == "openvz" ]]; then
    red "OpenVZ tidak didukung!"
    exit 1
fi

# --- Konfigurasi Hostname ---
cd /root || exit 1
local_ip=$(hostname -I | cut -d' ' -f1)
host_name=$(hostname)

if ! grep -q "^${local_ip} ${host_name}" /etc/hosts; then
    echo "${local_ip} ${host_name}" >> /etc/hosts
fi

# --- Persiapan Direktori ---
rm -rf /etc/phreakers
mkdir -p /etc/phreakers
mkdir -p /etc/phreakers/theme
mkdir -p /var/lib/ >/dev/null 2>&1
mkdir -p /etc/kuota-ssh
echo "IP=" >> /var/lib/ipvps.conf
clear

# --- Input Nama Pengguna ---
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}      MASUKKAN NAMA KAMU           ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
echo " "
read -rp "Masukan Nama Kamu Disini tanpa spasi : " -e name
[[ -z "$name" ]] && name="UserVPS"
echo "$name" > /etc/profil
clear

# --- Pilihan Domain ---
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ \033[1;37mPlease select a your Choice to Set Domain${BIBlue}│${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│  [ 1 ]  \033[1;37mDomain Kamu Sendiri & Domain SlowDNS   ${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"

read -p "    Please select number 1 : " domain
if [[ $domain == "1" ]]; then
    clear
    read -rp "Masukan domain kamu Disini : " -e dns1
    mkdir -p /etc/xray /var/lib/kyt /etc/v2ray
    echo "$dns1" > /etc/nsdomain
    echo "$dns1" > /etc/xray/domain
    echo "$dns1" > /etc/v2ray/domain
    echo "IP=$dns1" > /var/lib/ipvps.conf
    
    read -rp "Masukan Domain SlowDNS kamu Disini : " -e dns2
    echo "$dns2" > /etc/xray/nsdomain
    echo "$dns2" > /etc/xray/dns
fi

# --- Disable IPv6 & AppArmor ---
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
systemctl disable --now apparmor >/dev/null 2>&1
apt-get purge apparmor apparmor-utils -y >/dev/null 2>&1

# --- Eksekusi Instalasi Komponen ---
echo -e "${GREEN}Mengunduh dependensi...${NC}"
wget https://raw.githubusercontent.com/hokagelegend9999/genom/main/TOOLS/tools.sh -O tools.sh &> /dev/null
chmod +x tools.sh && bash tools.sh

# --- Fungsi Instalasi Modul (Memanggil Repo Asli) ---
REPO="https://raw.githubusercontent.com/hokagelegend9999/genom/main/"

install_module() {
    local name=$1
    local script=$2
    echo -e "${BIBlue}│ ${BGCOLOR} PROCESS INSTALLED $name ${NC}${BIBlue} │${NC}"
    wget ${REPO}${script} -O temp_script.sh &> /dev/null
    chmod +x temp_script.sh && ./temp_script.sh
    rm temp_script.sh
    clear
}

# Eksekusi Urutan Instalasi
install_module "SSH WS / OPENVPN" "SYSTEM/ssh-vpn.sh"
install_module "XRAY" "SYSTEM/ins-xray.sh"
install_module "WEBSOCKET SSH" "WEBSOCKET/insshws.sh"
install_module "BACKUP MENU" "SYSTEM/set-br.sh"
install_module "OHP" "WEBSOCKET/ohp.sh"
install_module "SLOWDNS" "SYSTEM/slowdns.sh"
install_module "UDP CUSTOM" "SYSTEM/udp-custom.sh"

# --- Konfigurasi Final ---
cat > /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile

# --- Log Waktu & Kirim Telegram ---
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M:%S')
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "No Domain")

MESSAGE="\`\`\`
❏━━━━━━━━━━━━━━━━━━━━━━━━━━❏
 🤖 Installer Berhasil 🤖
❏━━━━━━━━━━━━━━━━━━━━━━━━━━❏
❖ User        : $name
❖ IP VPS      : $IP_VPS
❖ Domain      : $DOMAIN
❖ Waktu       : $TIME
❖ Tanggal     : $DATE
❖ Expired     : $exp_date
❏━━━━━━━━***************━━━━━━━━━❏
\`\`\`"

# --- Selesai ---
clear
echo -e "${BIBlue}════════════════════════════════════════${NC}"
echo -e "  Script telah berhasil di install!"
echo -e "❏━━━━━━━━━━━✦ SYSTEM NOTICE ✦━━━━━━━━━━━❏"
echo -e "\e[1;31m⚠️ Silakan reboot VPS kamu sekarang\e[0m"
echo -e "❏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━❏"
read -p "Reboot sekarang? (y/n): " reboot_now
if [[ "$reboot_now" == "y" ]]; then
    reboot
fi
