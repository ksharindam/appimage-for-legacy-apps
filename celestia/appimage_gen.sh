#!/bin/bash
# Build System : Debian 10 Buster
check_dep()
{
  DEP=$1
  if [ -z $(which $DEP) ] ; then
    echo "Error : $DEP command not found"
    exit 0
  fi
}

check_dep appimagetool
check_dep linuxdeploy
check_dep gcc

MULTIARCH=`gcc -dumpmachine`
LIBDIR=lib/${MULTIARCH}

mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/scalable/apps

cd AppDir

APPDIR=`pwd`

# copy icon and create desktop file
cp /usr/share/pixmaps/celestia.png usr/share/icons/hicolor/scalable/apps
cat > usr/share/applications/space.celestia.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Exec=celestia
Icon=celestia
Name=Celestia
GenericName=Space Simulator
Comment=Explore the Universe in this detailed space simulation
Categories=Education;
EOF
cp ../AppRun.sh AppRun
chmod +x AppRun

# copy main program
cp /usr/bin/celestia-gnome usr/bin
cp -r /usr/share/celestia usr/share
# remove the celestia.cfg symlink and copy the actual file
rm usr/share/celestia/celestia.cfg
cp /etc/celestia.cfg usr/share/celestia

# copy gconf-service
# daemon
cp ../gconfd-2.sh usr/bin
cp /usr/${LIBDIR}/gconf/gconfd-2 usr/bin
# backends (env variable GCONF_BACKEND_DIR must be set)
mkdir -p usr/lib
cp -r /usr/${LIBDIR}/gconf/2 usr/lib/gconf

# org.gnome.GConf.service file must be copied to ~/.local/share/dbus-1/services
# directory at runtime, otherwise dbus daemon wont find the service (see AppRun script)

mkdir -p usr/share/gconf
# copy gconf path file. (it has no job here, just keeping it as an example)
cp /usr/share/gconf/default.path usr/share/gconf
# copy schema description. (it has no job here)
cp /usr/share/gconf/schemas/celestia.schemas usr/share/gconf
# this was generated from celestia.schemas and then copied from /var/lib/gconf/defaults
# it must be copied to a gconf source dir before launching gconfd-2 (see AppRun script)
cp ../%gconf-tree.xml usr/share/gconf


# Deploy dependencies
linuxdeploy --appdir . --deploy-deps-only=usr/lib/gconf

# remove absolute paths
sed -i -e "s#/usr#usr/#g" usr/bin/celestia-gnome
# does not work because gconfd does chdir to "/"
#sed -i -e "s#/etc#etc/#g" usr/bin/gconfd-2

cd ..
appimagetool AppDir
