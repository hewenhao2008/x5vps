#!/bin/sh

tar xzf glorytun/glorytun-0.0.35.tar.gz
cd glorytun-0.0.35
./autogen.sh
./configure
make
cp glorytun /usr/local/bin/glorytun-tcp
cd ../
cp ./glorytun/glorytun-tcp-run /usr/local/bin/glorytun-tcp-run
chmod 755 /usr/local/bin/glorytun-tcp-run
cp ./glorytun/glorytun-tcp@.service /lib/systemd/system/glorytun-tcp@.service
mkdir -p /etc/glorytun-tcp
cp ./glorytun/post.sh /etc/glorytun-tcp/post.sh
chmod 755 /etc/glorytun-tcp/post.sh
cp ./glorytun/tun* /etc/glorytun-tcp/
echo 0123456789abcdef0123456789abcdef |od -vN "32" -An -tx1 | tr '[:lower:]' '[:upper:]' | tr -d " \n" > /etc/glorytun-tcp/tun0.key

systemctl enable glorytun-tcp@tun0.service
systemctl enable glorytun-tcp@tun1.service
systemctl enable glorytun-tcp@tun2.service
systemctl enable glorytun-tcp@tun3.service
systemctl enable glorytun-tcp@tun4.service
systemctl enable glorytun-tcp@tun5.service
systemctl enable glorytun-tcp@tun6.service
systemctl enable glorytun-tcp@tun6.service
systemctl enable glorytun-tcp@tun7.service
systemctl enable glorytun-tcp@tun8.service
systemctl enable glorytun-tcp@tun9.service

update-rc.d heartbeat defaults 90 10