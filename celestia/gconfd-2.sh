#!/bin/bash
DIR=$(readlink -f "$(dirname "$0")")
APPDIR="$DIR/../.."
export GCONF_BACKEND_DIR="$APPDIR/usr/lib/gconf"
$APPDIR/usr/bin/gconfd-2
