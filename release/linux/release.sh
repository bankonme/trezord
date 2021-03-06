#!/bin/sh

set -e

cd $(dirname $0)

TARGET=$1
BUILDDIR=build${TARGET:+-$TARGET}
VERSION=$(cat ../../VERSION)

cd ../../$BUILDDIR

install -D -m 0755 trezord                          ./usr/bin/trezord
install -D -m 0644 ../release/linux/trezor.rules    ./usr/lib/udev/rules.d/23-trezor.rules
install -D -m 0755 ../release/linux/trezord.init    ./etc/init.d/trezord
install -D -m 0644 ../release/linux/trezord.service ./usr/lib/systemd/system/trezord.service

NAME=trezor-bridge

rm -f *.deb *.rpm *.tar.bz2
tar cfj $NAME-$VERSION.tar.bz2 ./etc ./usr

for TYPE in "deb" "rpm"; do
	if [ $TARGET = "lin64" ]; then
		if [ $TYPE = "deb" ]; then
			ARCH=amd64
		else
			ARCH=x86_64
		fi
	else
		ARCH=i386
	fi
	fpm \
		-s tar \
		-t $TYPE \
		-a $ARCH \
		-n $NAME \
		-v $VERSION \
		--license "GPL-3.0" \
		--vendor "SatoshiLabs" \
		--maintainer "stick@satoshilabs.com" \
		--url "http://bitcointrezor.com/" \
		--category "Productivity/Security" \
		--before-install ../release/linux/fpm.before-install.sh \
		--after-install ../release/linux/fpm.after-install.sh \
		--before-remove ../release/linux/fpm.before-remove.sh \
		$NAME-$VERSION.tar.bz2
done

rm -rf ./etc ./usr
