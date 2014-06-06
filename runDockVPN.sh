docker build -t="dockvpn" .          # Build this Dockerfile

# create a container that's just saving the state of /etc/openvpn/
# this won't overwrite something that exists
docker ps -a | grep -q OpenVpn-Config || docker run -v /etc/openvpn/ --name OpenVPN-Config busybox true

# delete any old builds
docker stop dockvpn; docker rm dockvpn

# run this new build
docker run -d --privileged --volumes-from OpenVPN-Config --name dockvpn \
 -e "SERVER_TCP_PORT=1197" \
 -e "SERVER_UDP_PORT=1197" \
 -e "KEY_SIZE=2048" \
 -e "CA_EXPIRE=3650" \
 -e "KEY_EXPIRE=3650" \
 -e "KEY_COUNTRY=US" \
 -e "KEY_PROVINCE=Massachusetts" \
 -e "KEY_CITY=Boston" \
 -e "KEY_ORG=MasonFamily" \
 -e "KEY_EMAIL=randall@mason.ch" \
 -e "KEY_OU=TheITGuy" \
 -e "KEY_NAME=DockVpN" \
 -e "SERVERNAME=vpn3.boston.mason.ch" \
 -e "CLIENTNAMES=\"randall android iphone\"" \
 dockvpn run
