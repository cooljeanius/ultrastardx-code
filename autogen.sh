#!/bin/sh

echo "It'd probably be a better idea to just run \`autoreconf' (with whichever flags you choose) instead of running this script, but whatever..."

AUTOGEN_DIR=dists/autogen

set -ex

aclocal --force --install -I ${AUTOGEN_DIR}/m4 --warnings=all && autoconf --warnings=all --force
