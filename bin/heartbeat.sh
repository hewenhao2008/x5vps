#!/bin/sh

url="gl.mine.com.cn"
path="/api/device/postserverinfo"
path2="/api/device/checkstatus"

ip="121.37.243.25"
location="huanan"

header='Content-type':'application/json'
poststr="{\"ip\":\"$ip\",\"locate\":\"$location\",\"vpnport\":{\"startport\":60000,\"endport\":60009},\"fixports\":[{\"fixport\":60010}]}"

echo $poststr

curl  -X POST -H $header -d $poststr ${url}${path}

curl ${url}${path2}