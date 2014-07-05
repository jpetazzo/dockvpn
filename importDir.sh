cd etc_openvpn; tar -cf - ./ | docker run --rm -i --volumes-from OpenVPN-Config --name vpnImport ubuntu:trusty bash -c "mkdir -p /etc/openvpn/; tar -xvf - -C /etc/openvpn/"
