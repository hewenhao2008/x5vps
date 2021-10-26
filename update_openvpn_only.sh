#!/bin/sh

# if [ ! -f openvpnconf.tar.gz ];then
# 	wget https://gitee.com/link4all_admin/vps/raw/master/openvpnconf.tar.gz -O openvpnconf.tar.gz
# fi
# tar zxvf openvpnconf.tar.gz -C /
if curl -s cip.cc|grep "中国";then
git clone https://gitee.com/link4all_admin/x5vps.git
else
git clone https://github.com/hewenhao2008/x5vps.git
fi
cd x5vps 
cp ./etc/ / -r
echo "Install OpenVPN"
rm -f /var/lib/dpkg/lock
rm -f /var/lib/dpkg/lock-frontend
rm -f /lib/systemd/network/openvpn.network
apt-get -y install openvpn easy-rsa

systemctl enable openvpn@server
systemctl enable openvpn
systemctl enable openvpn-server@server
systemctl start openvpn-server@server


if grep -q '^nameserver 127.0.0.53' "/etc/resolv.conf"; then
	resolv_conf="/run/systemd/resolve/resolv.conf"
else
	resolv_conf="/etc/resolv.conf"
fi
# Obtain the resolvers from resolv.conf and use them for OpenVPN
sed -i '/dhcp-option DNS/d' /etc/openvpn/server/server.conf
sed -i '/dhcp-option DNS/d' /etc/openvpn/server.conf

grep -v '^#\|^;' "$resolv_conf" | grep '^nameserver' | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | while read line; do
	echo "\npush \"dhcp-option DNS $line\"" >> /etc/openvpn/server/server.conf
	echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
done
ethname=`route -n |grep "^0.0.0.0"|head -n1 |awk '{print $8}'`
sed -i 's/eth0/'$ethname'/g' /etc/iptables/rules.v4
sed -i 's/eth0/'$ethname'/g' /etc/iptables/rules.v6

sed -i 's/4443/443/g' /etc/config.json

sed -i '/port 1194/port 6010/' /etc/openvpn/server/server.conf
sed -i '/port 1194/port 6010/' /etc/openvpn/server.conf

echo "Install ok, please enable tcp 443 port(for ss),3389(for speedtest),60000-60010 for udp vpn"
echo "Please put 'reboot' to reboot the system!"
# reboot