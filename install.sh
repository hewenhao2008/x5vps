#!/bin/sh

#wget http://www.mine.com.cn/dl/install.tar.gz

# if grep 'DVD Binary' /etc/apt/sources.list;then
# sed  -i '/DVD Binary/d' /etc/apt/sources.list
# cat << EOF >> /etc/apt/sources.list
# deb http://mirrors.163.com/debian/ buster main non-free contrib
# deb http://mirrors.163.com/debian/ buster-updates main non-free contrib
# deb http://mirrors.163.com/debian/ buster-backports main non-free contrib
# deb http://mirrors.163.com/debian-security/ buster/updates main non-free contrib
# deb-src http://mirrors.163.com/debian/ buster main non-free contrib
# deb-src http://mirrors.163.com/debian/ buster-updates main non-free contrib
# deb-src http://mirrors.163.com/debian/ buster-backports main non-free contrib
# deb-src http://mirrors.163.com/debian-security/ buster/updates main non-free contrib
# EOF
# fi

# tar zxvf install.tar.gz
apt update
apt -y install pkg-config libpcre3-dev libmbedtls-dev libsodium-dev libc-ares-dev libev-dev  libtool automake make autoconf iperf3 ntp net-tools psmisc git python3-pip gcc
pip3 install speedtest-cli
dpkg -i linux-headers_amd64.deb
dpkg -i linux-image_amd64.deb
dpkg -i linux-libc-dev_amd64.deb

cd shadowsocks-libev-3.3.5/
./autogen.sh
./configure --disable-documentation 
make 
cp src/ss-server /bin/
cd ../
cp ./etc / -r
cp ./bin/* /bin -rf
cp .usr/bin/* /usr/bin -rf

update-rc.d ss-server defaults
update-rc.d iperf3 defaults

#change iptable
apt-get install iptables-persistent
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

rm -rf linux-headers_amd64.deb linux-image_amd64.deb linux-libc-dev_amd64.deb shadowsocks-libev-3.3.5/ /etc/sysctl.d/custom.conf


# tar zxvf openvpnconf.tar.gz -C /
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
	echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server/server.conf
	echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server.conf
done

sed -i '/port 1194/port 60010/' /etc/openvpn/server/server.conf
sed -i '/port 1194/port 60010/' /etc/openvpn/server.conf

ethname=`route -n |grep "^0.0.0.0"|head -n1 |awk '{print $8}'`
sed -i 's/eth0/'$ethname'/g' /etc/iptables/rules.v4
sed -i 's/eth0/'$ethname'/g' /etc/iptables/rules.v6

sed -i 's/4443/443/g' /etc/config.json

#install glorytun-tcp

sh ./glorytun-tcp.sh

echo "Install ok, please enable tcp 443 port(for ss),3389(for speedtest),60000-60010 for udp vpn"
echo "Please put 'reboot' to reboot the system!"
# reboot


