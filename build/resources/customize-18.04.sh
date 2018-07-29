#!/bin/sh

echo "nameserver 1.1.1.1" >> /etc/resolv.conf
apt update && apt -y upgrade
mkdir /etc/network/ # for netplan
apt -y install less vim-tiny net-tools iputils-ping systemd netplan.io cloud-init 

cat <<EOT >> /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
EOT

netplan generate

sed -i "s/^#NTP=/NTP=0.ubuntu.pool.ntp.org 1.ubuntu.pool.ntp.org 2.ubuntu.pool.ntp.org 3.ubuntu.pool.ntp.org/" /etc/systemd/timesyncd.conf
sed -i "s/^#FallbackNTP=ntp.ubuntu.com/FallbackNTP=ntp.ubuntu.com 0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org/" /etc/systemd/timesyncd.conf
sed -i "s/^#DNS=/DNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4/" /etc/systemd/resolved.conf
sed -i "s/#DNSSEC=no/DNSSEC=allow-downgrade/" /etc/systemd/resolved.conf
echo 'datasource_list: [ NoCloud ]' > /etc/cloud/cloud.cfg.d/90_dpkg.cfg

systemctl enable systemd-networkd
apt clean

exit 0
