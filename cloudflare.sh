#!/bin/bash

#global configs
conf_file=cf.conf
opt="allow"
space="  "
tmp=""
#get ip-v4 list
v4=$(curl -s https://www.cloudflare.com/ips-v4)

#get ip-v6 list
v6=$(curl -s https://www.cloudflare.com/ips-v6)

#generate nginx config
tmp+="#ipv4"
for i in $v4
do
    tmp+="\n$opt$space$i;"
done

tmp+="\n#ipv6"
for i in $v6
do
    tmp+="\n$opt$space$i;"
done

if [ $opt == "allow" ]; then
    tmp+="\n\ndeny all;"
elif [ $opt == "deny" ]; then
    tmp+="\n\nallow all;"
fi

#write to conf_file
echo -e $tmp > ${conf_file}

