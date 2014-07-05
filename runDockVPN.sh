#!/bin/bash 

# Bash inline comments per: http://stackoverflow.com/a/12797512/317670

TAG="clashthebunny/dockvpn:0.1-$(dpkg --print-architecture 2>/dev/null || echo amd64)"
docker build -t="$TAG" .

# create a container that's just saving the state of /etc/openvpn/
# this won't overwrite something that exists.  If you set this to
# something other than /etc/openvpn, be sure to change $CONFIG_DIR.
CONFIG_DIR="/etc/openvpn"
docker ps -a | grep -q OpenVPN-Config || docker run -v $CONFIG_DIR --name OpenVPN-Config busybox true

SERVER_PORT=${SERVER_PORT:-1194}
SERVER_PROTO=${SERVER_PROTO:-udp}

UPNP_URL=$(upnpc -s | grep IGD | sed -e 's/.*http/http/g')
# TODO: add pagekite and/or ngrok support

# delete any old builds or running vpn clients.
docker ps | grep -q " dockvpn-$SERVER_PROTO-$SERVER_PORT " && docker stop dockvpn-$SERVER_PROTO-$SERVER_PORT
docker ps -a | grep -q " dockvpn-$SERVER_PROTO-$SERVER_PORT " && docker rm dockvpn-$SERVER_PROTO-$SERVER_PORT

# Run this new build.  All the environment variables below are the default in the run script and therefore optional
# You can always override everything by adding a command on the end of the tag.  This is because I don't use entrypoint
# This means that once you have a good stable config and openvpn command, just run the openvpn command at the end of the
# line and drop all of the environment variables.
docker run --privileged -t -i --volumes-from OpenVPN-Config                                 \
 --name dockvpn-$SERVER_PROTO-$SERVER_PORT                                                  \
 -e "UPNP_URL=$UPNP_URL"                      `# url to control router`                     \
 -e "SERVER_PORT=$SERVER_PORT"                `# some unused port`                          \
 -e "SERVER_PROTO=$SERVER_PROTO"              `# udp or tcp`                                \
 -e "SERVER_USER=nobody"                      `# DROP ROOT PRIVELEGES`                      \
 -e "SERVER_GROUP=nogroup"                    `# DROP ROOT GROUP`                           \
 -e "SERVER_DEV=tun"                          `# tun will create the next tunX dev`         \
 -e "SERVER_TOPOLOGY=subnet"                  `# subnet, p2p, or net30`                     \
 -e "SERVER_MAX_CLIENTS=20"                   `# You know, how many phones you got?`        \
 -e "SERVER_NETWORK=192.168.255.0"            `# A uniq address space among clients`        \
 -e "SERVER_NETMASK=255.255.255.128"          `# netmask for above network`                 \
 -e "DNS_SERVER=8.8.8.8"                      `# Google\'s last service: xkcd.com/1361/`    \
 -e "CONFIG_DIR=$CONFIG_DIR"                  `# What does OpenVPN-Config share`            \
 -e "KEY_SIZE=2048"                           `# 2048 ought to be enough for anybody...`    \
 -e "CA_EXPIRE=3650"                          `# 10 years`                                  \
 -e "KEY_EXPIRE=3650"                         `# still 10 years`                            \
 -e "KEY_COUNTRY=US"                          `# where are you`                             \
 -e "KEY_PROVINCE=Massachusetts"              `# no, really, where are you`                 \
 -e "KEY_CITY=Boston"                         `# no, exactly, where are you`                \
 -e "KEY_ORG=MasonFamily"                     `# and where do you work`                     \
 -e "KEY_EMAIL=randall@mason.ch"              `# and how can you be reached?`               \
 -e "KEY_OU=TheITGuy"                         `# IT, as disfunctional as that is`           \
 -e "KEY_NAME=DockVpN"                        `# This is the name of this system`           \
 -e "SERVER_NAME=${SERVER_NAME:-$(uname -n)}" `# the hostname of the server, external`      \
 -e "CLIENTNAMES=randall android iphone"      `# space seperated list of clients`           \
 `# there is one optional argument without a default if all hell breaks loose with DNS`     \
 `# -e "SERVER_IP=123.456.789.ABC"`           `# great for situations without internet`     \
 "$TAG" "$@"

echo "now get your config files from here:"
#echo $(docker inspect OpenVPN-Config | python -c 'import json,fileinput; print json.loads("".join(fileinput.input()))[0]["Volumes"]["/etc/openvpn"]')
#echo $(docker inspect OpenVPN-Config | grep -A1 Volumes | cut -d \" -f 4 | grep "\/")
echo $(docker inspect -f "{{ .Volumes }}" OpenVPN-Config | cut -d : -f 2- | cut -d \] -f 1)
