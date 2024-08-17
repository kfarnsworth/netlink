# netlink

Netlink parent project for developing and testing netlink.

A top level Makefile for building the netlink-devices test code.

**Building**

Install libnl on your distro or build it here by using doing this:
    make libnl

    Note: Requires automake tools - `sudo apt-get install autoconf libtool pkg-config`
    Note: Must include dependencies bison and flex - `sudo apt-get install bison flex`

Make the netlink-devices sub-project:
    make netlink-devices

**Install**

    make netlink-devices-install

**Run**

    make run




