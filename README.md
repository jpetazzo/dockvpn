# OpenVPN for Docker

Quick instructions:

Edit the environment variables half way down runDockVPN.sh and then run it:
```bash
vim runDockVPN.sh
./runDockVPN.sh
```
it will print out the directory where your OpenVPN configuration files
are stored and you should get those (SECURELY!!!) to your local directory:
```bash
rsync -avH --rsync-path="sudo rsync" userWithSudo@dockerHost:<directoryFromScript>/ OpenVPN-Config/
```
or
```bash
docker run -rm --volumes-from OpenVPN-Config busybox tar cvf - /etc/openvpn/ \
    | ssh mobile@jailBrokeniPhone "mkdir OpenVPN-Config; tar -xvf - -C OpenVPN-Config/"
```

then you can directly import those files into Ubuntu's Network Manager,
TunnelBlick, iPhone or Android's OpenVPN Connect, or pretty much anywhere.

Since the configuration files are in a seperate volume only container named OpenVPN-Config,
any reboots or restarts will start you back off where you were.  Just re-run the script.
If you need to add hosts to your server, just edit and re-run the script.  It will restart
OpenVPN, but it will re-create the needed files.  A new script to add hosts without a restart
is easy to create, and will hopefully be added later.

## OpenVPN details

We use `tun` mode, because it works on the widest range of devices.
`tap` mode, for instance, does not work on Android, except if the device
is rooted.

The topology used is `net30`, because it works on the widest range of OS.
`p2p`, for instance, does not work on Windows.

The TCP server uses `192.168.255.0/25` and the UDP server uses
`192.168.255.128/25`.

The client profile specifies `redirect-gateway def1`, meaning that after
establishing the VPN connection, all traffic will go through the VPN.
This might cause problems if you use local DNS recursors which are not
directly reachable, since you will try to reach them through the VPN
and they might not answer to you. If that happens, use public DNS
resolvers like those of Google (8.8.4.4 and 8.8.8.8) or OpenDNS
(208.67.222.222 and 208.67.220.220).
