=============================
Tiny Core Ironic Python Agent
=============================

WARNING: This is experimental!

Build script requirements
-------------------------
- wget
- pip
- unzip
- sudo
- awk
- advdef (from the package advancecomp)

Instructions:
-------------
To create a new ramdisk, run:

./build_tinyipa.sh

This will create two new files once completed:

tinyipa.vmlinuz
tinyipa.gz

These are your two files to upload to glance for use with Ironic.
