##
## Makefile for building netlink lib and test code
##

TOPDIR=${PWD}

## Default compilers
CC ?= gcc

## install destination default
DESTDIR ?= ${TOPDIR}/sysrootfs

## libnl library
LIBNL_VERSION=3.2.25
LIBNL_DIR=${TOPDIR}/libnl-$(LIBNL_VERSION)
LIBNL_REPO=https://github.com/tgraf/libnl.git
LIBNL_TAG=libnl$(subst .,_,$(LIBNL_VERSION))

## target test executable dir
NETLINK_DEVICES_DIR=${TOPDIR}/netlink-devices

default: netlink-devices

#
# Requires autoconf & automake and supporting pkgs - i.e. sudo apt-get install autoconf libtool pkg-config
# Also requires bison and flex - i.e. sudo apt-get install bison flex
$(LIBNL_DIR)/configure.ac:
	git clone -b $(LIBNL_TAG) $(LIBNL_REPO) libnl-$(LIBNL_VERSION)

$(LIBNL_DIR)/configure: $(LIBNL_DIR)/configure.ac
	cd $(LIBNL_DIR); autoreconf --install --force && autoconf

$(LIBNL_DIR)/Makefile.in: $(LIBNL_DIR)/configure
	cd $(LIBNL_DIR); automake --add-missing

$(LIBNL_DIR)/Makefile: $(LIBNL_DIR)/Makefile.in
	cd $(LIBNL_DIR); ./configure --prefix=/usr --sysconfdir=/etc --disable-static

libnl-build: $(LIBNL_DIR)/Makefile
	make -C $(LIBNL_DIR)

libnl-install:
	make -C $(LIBNL_DIR) install DESTDIR=$(DESTDIR)
	# install private headers
	cp -fr $(LIBNL_DIR)/include/netlink-private $(DESTDIR)/usr/include/libnl3/.

libnl: libnl-build libnl-install

libnl-clean:
	make -C $(LIBNL_DIR) distclean

netlink-devices-build:
	make -C $(NETLINK_DEVICES_DIR) CC="$(CC)" SYSROOTFS=${DESTDIR} build

netlink-devices-install:
	make -C $(NETLINK_DEVICES_DIR) install DESTDIR=$(DESTDIR)

netlink-devices: netlink-devices-build netlink-devices-install

netlink-devices-clean:
	make -C $(NETLINK_DEVICES_DIR) clean

install: netlink-devices-install

run:
	LD_LIBRARY_PATH=$(DESTDIR)/usr/lib $(DESTDIR)/usr/bin/nltest

clean: netlink-devices-clean

clean-all: clean
	rm -rf ${TOPDIR}/sysrootfs

.PHONY: libnl-build libnl-clean libnl netlink-devices-build netlink-devices-install netlink-devices run clean clean-all

