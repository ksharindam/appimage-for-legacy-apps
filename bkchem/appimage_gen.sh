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

# copy executable, icon and desktop file
cp /usr/share/icons/hicolor/48x48/apps/bkchem.png usr/share/icons/hicolor/scalable/apps
cp /usr/share/applications/bkchem.desktop usr/share/applications/org.bkchem.desktop
cp ../AppRun.sh AppRun
chmod +x AppRun


# copy main program
mkdir -p ${APPDIR}/usr/lib/bkchem
cp -r /usr/lib/bkchem/bkchem usr/lib/bkchem
cp -r /usr/share/bkchem usr/share

# this inserts two lines at line 3, which fixes problems with absolute file path
sed -i "3i import os\n\
USR_PATH = os.path.dirname(__file__)+\"/../../../..\"" usr/lib/bkchem/bkchem/site_config.py

sed -i -e "s#\"/usr#USR_PATH+\"/usr#g" usr/lib/bkchem/bkchem/site_config.py

# copy python2 and python2-stdlib
mkdir -p ${APPDIR}/usr/lib/python2.7/dist-packages
cp /usr/bin/python2 usr/bin

cd /usr/lib/python2.7
cat ${APPDIR}/../python2.7-minimal.txt | sed -e "s/x86_64-linux-gnu/${MULTIARCH}/" | xargs -I % cp -r --parents % ${APPDIR}/usr/lib/python2.7
cat ${APPDIR}/../python2.7-stdlib.txt | sed -e "s/x86_64-linux-gnu/${MULTIARCH}/" | xargs -I % cp -r --parents % ${APPDIR}/usr/lib/python2.7


# copy python modules (tkinter and pil)
cp lib-dynload/_tkinter.so ${APPDIR}/usr/lib/python2.7/lib-dynload

cp -r dist-packages/PIL ${APPDIR}/usr/lib/python2.7/dist-packages

# end copying python modules, leaving /usr/lib/python2.7
cd $APPDIR

# copy tcl8.6 and tk8.6 files
cp -r /usr/share/tcltk/tcl8.6 usr/lib
cp -r /usr/share/tcltk/tk8.6 usr/lib

# copy extra copyright files
mkdir -p usr/share/doc/python
cp /usr/share/doc/python/copyright usr/share/doc/python

# delete python bytecodes
find -name *.pyc -delete


# Deploy dependencies
linuxdeploy --appdir .

# compile python bytecodes
#find usr/lib -iname '*.py' -exec python2 -m py_compile {} \;

cd ..
appimagetool AppDir
