#!/bin/bash 

sudo git pull && sudo chown -R rmason:rmason . 

docker build -t="clashthebunny/dockvpn:0.1-$(dpkg --print-architecture 2>/dev/null || echo amd64)" .

# create a container that's just saving the state of /etc/openvpn/
# this won't overwrite something that exists
docker ps -a | grep -q OpenVPN-Config || docker run -v /etc/openvpn/ --name OpenVPN-Config busybox true

# delete any old builds
docker stop dockvpn; docker rm dockvpn

# run this new build
docker run -d --privileged --volumes-from OpenVPN-Config --name dockvpn                \
 -e "SERVER_TCP_PORT=1197"                     `# some unused port`                    \
 -e "SERVER_UDP_PORT=1197"                     `# same or different from above`        \
 -e "KEY_SIZE=2048"                            `# 2048 ought to be enough for anybody` \
 -e "CA_EXPIRE=3650"                           `# 10 years`                            \
 -e "KEY_EXPIRE=3650"                          `# still 10 years`                      \
 -e "KEY_COUNTRY=US"                           `# where are you`                       \
 -e "KEY_PROVINCE=Massachusetts"               `# no, really, where are you`           \
 -e "KEY_CITY=Boston"                          `# no, exactly, where are you`          \
 -e "KEY_ORG=MasonFamily"                      `# and where do you work`               \
 -e "KEY_EMAIL=randall@mason.ch"               `# and how can you be reached?`         \
 -e "KEY_OU=TheITGuy"                          `# IT, as disfunctional as that is`     \
 -e "KEY_NAME=DockVpN"                         `# This is the name of this system`     \
 -e "SERVERNAME=$(uname -n)"                   `# the hostname of the server, external`\
 -e "CLIENTNAMES=randall android iphone"       `# space seperated list of clients`     \
 clashthebunny/dockvpn:0.1-$(dpkg --print-architecture 2>/dev/null || echo amd64) bash -c 'bash -x $(which run)'

echo "now get your config files from here:"
echo $(docker inspect OpenVPN-Config | python -c 'import json,fileinput; print json.loads("".join(fileinput.input()))[0]["Volumes"]["/etc/openvpn"]')
