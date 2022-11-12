#!/bin/bash
set -e

# be verbose if $DEBUG=1 is set
if [ ! -z "$DEBUG" ] ; then
  env
  set -x
fi

BIN="usr/bin/python2 usr/lib/bkchem/bkchem/bkchem.py"


if [ -z $APPDIR ] ; then
  APPDIR=$(readlink -f "$(dirname "$0")")
fi


# export environment variables
export PATH="${APPDIR}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${APPDIR}/usr/lib:${LD_LIBRARY_PATH}"
export PYTHONPATH="${APPDIR}/usr/lib/python2:${PYTHONPATH}"
export XDG_DATA_DIRS="${APPDIR}/usr/share/:${XDG_DATA_DIRS}"
#export XDG_CONFIG_DIRS="${APPDIR}/etc:${XDG_CONFIG_DIRS}"

export PYTHONDONTWRITEBYTECODE=1


cd "$APPDIR"

# call the executable
$BIN "$@"
