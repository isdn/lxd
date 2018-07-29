#!/bin/sh

TS=`date +%s`
DATE=`date --date="@${TS}" +%Y%m%d`
VERSION="18.04"
RELEASE="bionic"
ID="custom-v5" # custom ID
BUILD_DIR="build_${TS}"
RES_DIR="resources"

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

cp ${RES_DIR}/customize-${VERSION}.sh ${BUILD_DIR}/rootfs
chmod 755 ${BUILD_DIR}/rootfs/customize-${VERSION}.sh
cd ${BUILD_DIR}/rootfs
tar -zxpvf ../../ubuntu-base-${VERSION}-base-amd64.tar.gz

chroot . /bin/bash -c "./customize-${VERSION}.sh"

rm -f customize-${VERSION}.sh

cd ..
tar -zcpvf ../ubuntu-base-${VERSION}-base-amd64-${ID}.tar.gz *

cd ..
rm -rf ${BUILD_DIR}
