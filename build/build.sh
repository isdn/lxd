#!/bin/sh

TS=`date +%s`
DATE=`date --date="@${TS}" +%Y%m%d`
VERSION="18.04"
RELEASE="bionic"
ID="custom-v5" # custom ID
BUILD_DIR="build_${TS}"
RES_DIR="resources"
CFILE="customize-${VERSION}.sh"

if [ ! -f "ubuntu-base-${VERSION}-base-amd64.tar.gz" ]; then
  wget http://cdimage.ubuntu.com/ubuntu-base/releases/${VERSION}/release/ubuntu-base-${VERSION}-base-amd64.tar.gz
fi
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/rootfs ${BUILD_DIR}/templates
cp ${RES_DIR}/metadata.yaml ${BUILD_DIR}
cp ${RES_DIR}/*.tpl ${BUILD_DIR}/templates

sed -i "s/%ts%/${TS}/" ${BUILD_DIR}/metadata.yaml
sed -i "s/%version%/${VERSION}/" ${BUILD_DIR}/metadata.yaml
sed -i "s/%release%/${RELEASE}/" ${BUILD_DIR}/metadata.yaml
sed -i "s/%date%/${DATE}/" ${BUILD_DIR}/metadata.yaml

cat <<EOT >> ${BUILD_DIR}/rootfs/${CFILE}
#!/bin/sh

echo "nameserver 1.1.1.1" >> /etc/resolv.conf
apt update && apt -y upgrade
mkdir /etc/network/ # for netplan
apt -y install less vim-tiny net-tools iputils-ping systemd netplan.io cloud-init

cat <<_EOT >> /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
_EOT

netplan generate

sed -i "s/^#NTP=/NTP=0.ubuntu.pool.ntp.org 1.ubuntu.pool.ntp.org 2.ubuntu.pool.ntp.org 3.ubuntu.pool.ntp.org/" /etc/systemd/timesyncd.conf
sed -i "s/^#FallbackNTP=ntp.ubuntu.com/FallbackNTP=ntp.ubuntu.com 0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org/" /etc/systemd/timesyncd.conf
sed -i "s/^#DNS=/DNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4/" /etc/systemd/resolved.conf
sed -i "s/#DNSSEC=no/DNSSEC=allow-downgrade/" /etc/systemd/resolved.conf
echo 'datasource_list: [ NoCloud ]' > /etc/cloud/cloud.cfg.d/90_dpkg.cfg

systemctl enable systemd-networkd
apt clean

exit 0
EOT

chmod 755 ${BUILD_DIR}/rootfs/${CFILE}
cd ${BUILD_DIR}/rootfs
tar -zxpvf ../../ubuntu-base-${VERSION}-base-amd64.tar.gz

chroot . /bin/bash -c "./${CFILE}"

rm -f ${CFILE}

cd ..
tar -zcpvf ../ubuntu-base-${VERSION}-base-amd64-${ID}.tar.gz *

cd ..
rm -rf ${BUILD_DIR}
