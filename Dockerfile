FROM ubuntu:bionic
RUN echo deb http://archive.ubuntu.com/ubuntu/ bionic main universe > /etc/apt/sources.list.d/bionic.list
RUN apt-get update -q
RUN apt-get install -qy openvpn iptables socat curl
ADD ./bin /usr/local/sbin
VOLUME /etc/openvpn
EXPOSE 443/tcp 1194/udp 8080/tcp
CMD run
