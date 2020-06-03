#!/bin/sh
URL="https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=16&distro=ubuntu"
TEMP=tmp.$$

DIRECT=$(curl -s "${URL}" | grep -Po '(?<=url=\")(\S+)(?=\")')
PKG=$(basename "${DIRECT}")
VERSION=$(echo "${PKG}" | sed -e 's/plexmediaserver_// ; s/_amd64.*/-debian/')
DEB=plexmediaserver_"${VERSION}"-sysvinit_amd64.deb
if [ -e "${DEB}" ] ; then
    No new version
    ls -Fl ${DEB}
    exit
fi
mkdir ${TEMP}
cd ${TEMP}
wget -N "${DIRECT}"
mkdir dist
dpkg -x "${PKG}" dist
mkdir -p wheezy/etc/default wheezy/etc/init.d
cp ../init.d-plexmediaserver wheezy/etc/init.d/plexmediaserver
chmod +x wheezy/etc/init.d/plexmediaserver
mkdir -p wheezy/usr/sbin
cp ../start_pms wheezy/usr/sbin
chmod +x wheezy/usr/sbin/start_pms
rsync -a ../DEBIAN wheezy/.
if [ -e dist/etc/default/plexmediaserver ] ; then
    sed -e 's/\(# *\)\?export //' dist/etc/default/plexmediaserver > wheezy/etc/default/plexmediaserver
else
    sed -i -e '/\/etc\/default\/plexmediaserver/d' wheezy/DEBIAN/conffiles
fi
sed -i -e 's/^Version:.*/Version: '"${VERSION}"/ wheezy/DEBIAN/control
mv dist/usr wheezy/.
dpkg-deb --build wheezy
mv wheezy.deb ../${DEB}
cd ..
rm -rf ${TEMP}
