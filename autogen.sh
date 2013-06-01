#!/bin/sh

echo "It'd probably be a better idea to just run \`autoreconf' (with whichever flags you choose) instead of running this script, but whatever..."

AUTOGEN_DIR=dists/autogen
aclocal -I ${AUTOGEN_DIR}/m4 && autoconf
