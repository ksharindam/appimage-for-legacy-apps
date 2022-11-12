#!/bin/bash
set -e

# be verbose if $DEBUG=1 is set
if [ ! -z "$DEBUG" ] ; then
  env
  set -x
fi

BIN="usr/bin/celestia-gnome"


if [ -z $APPDIR ] ; then
  APPDIR=$(readlink -f "$(dirname "$0")")
fi

cd "$APPDIR"

# copy schema database
if [[ ! -e "$HOME/.config/gconf/%gconf-tree.xml" ]]; then
    echo "copying %gconf-tree.xml to $HOME/.config/gconf"
    mkdir -p "$HOME/.config/gconf"
    cp usr/share/gconf/%gconf-tree.xml "$HOME/.config/gconf"
fi


mkdir -p "$HOME/.local/share/dbus-1/services"
cat > $HOME/.local/share/dbus-1/services/org.gnome.GConf.service << EOF
[D-BUS Service]
Name=org.gnome.GConf
Exec=${APPDIR}/usr/bin/gconfd-2.sh
EOF



# call the executable
$BIN "$@"

rm "$HOME/.local/share/dbus-1/services/org.gnome.GConf.service"

pkill gconfd-2
