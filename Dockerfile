FROM clashthebunny/debian-armel:jessie
MAINTAINER randall@mason.ch

RUN apt-get update -q
RUN apt-get install -qy openvpn iptables socat zip easy-rsa curl
ADD ./bin /usr/local/sbin
EXPOSE 443/tcp 1194/udp 8080/tcp
CMD run
