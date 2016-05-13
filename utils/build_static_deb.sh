#!/bin/sh

PKG=$1
DEBVERSION=$2
BINPATH=$3

usage(){
  echo "$0 PKG_NAME DIR_WITH_BINARIES VERSION"
}

if [ -z "$PKG" ] ||  [ -z "$DEBVERSION" ] || [ -z "$BINPATH" ] ; then
  usage
  exit 1
fi

BUILD_DIR="/tmp/${PKG}_build"
CWD=$(cd `dirname $0` && pwd -P)

# Cleanup
mkdir -p $BUILD_DIR
test -d "$BUILD_DIR" && rm -rf $BUILD_DIR/*

SOURCEBINPATH=$(cd $BINPATH && pwd -P)
DEBFOLDERNAME="$BUILD_DIR/$PKG-$DEBVERSION"

# Create your scripts source dir
mkdir $DEBFOLDERNAME

# Copy your script to the source dir
cd $DEBFOLDERNAME

# Create the packaging skeleton (debian/*)
dh_make -s --indep --createorig --email adidenko@mirantis.com --yes

# Remove make calls
grep -v makefile debian/rules > debian/rules.new
mv debian/rules.new debian/rules

# debian/install must contain the list of scripts to install
# as well as the target directory
for SOURCEBIN in `find $SOURCEBINPATH -type f -executable`; do
  cp $SOURCEBIN $DEBFOLDERNAME
  BINFILE=${SOURCEBIN##*/}
  echo $BINFILE usr/bin >> debian/install
  file $SOURCEBIN | grep ELF && \
    echo $BINFILE >> debian/source/include-binaries
done

# Remove the example files
rm debian/*.ex

# Build the package.
debuild

# Copy DEB file into current dir
cp $BUILD_DIR/*_all.deb $CWD/

# Cleanup
test -d "$BUILD_DIR" && rm -rf $BUILD_DIR
