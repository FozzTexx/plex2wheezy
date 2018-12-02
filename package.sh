#!/bin/sh
URL="https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu"
TEMP=tmp.$$

DIRECT=$(curl -s "${URL}" | grep -Po '(?<=url=\")(\S+)(?=\")')
echo ${DIRECT}
mkdir ${TEMP}
cd ${TEMP}
wget -N "${DIRECT}"
PKG=$(basename "${DIRECT}")
mkdir dist
dpkg -x "${PKG}" dist
mkdir -p wheezy/etc/default wheezy/etc/init.d
sed -e 's/\(# *\)\?export //' dist/etc/default/plexmediaserver > wheezy/etc/default/plexmediaserver
cp ../init.d-plexmediaserver wheezy/etc/init.d/plexmediaserver
chmod +x wheezy/etc/init.d/plexmediaserver
rsync -a ../DEBIAN wheezy/.
VERSION=$(echo "${PKG}" | sed -e 's/plexmediaserver_// ; s/_amd64.*/-debian/')
sed -i -e 's/^Version:.*/Version: '"${VERSION}"/ wheezy/DEBIAN/control
mv dist/usr wheezy/.
dpkg-deb --build wheezy
mv wheezy.deb ../plexmediaserver_"${VERSION}"-sysvinit_amd64.deb
cd ..
rm -rf ${TEMP}
