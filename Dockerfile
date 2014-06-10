FROM ubuntu:trusty
MAINTAINER randall@mason.ch

RUN apt-get update -q
RUN apt-get install -qy openvpn iptables socat zip easy-rsa curl gettext-base miniupnpc
ADD ./bin /usr/local/sbin

CMD ["/usr/local/sbin/run"]
