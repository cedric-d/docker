#!/bin/bash

set -e
set -u


sudo rm -rf /output/*

if [ -n "${FFNVCODEC_VERSION-}" ]; then

git clone -b n${FFNVCODEC_VERSION} --single-branch https://github.com/FFmpeg/nv-codec-headers.git
pushd nv-codec-headers
sudo make install
popd

fi


wget "https://sourceforge.net/projects/avidemux/files/avidemux/${AVIDEMUX_VERSION}/avidemux_${AVIDEMUX_VERSION}.tar.gz/download" -O avidemux_${AVIDEMUX_VERSION}.tar.gz

# build packages
if [ -z "${SKIP_PACKAGES-}" ]; then

tar xvf avidemux_${AVIDEMUX_VERSION}.tar.gz
pushd avidemux_${AVIDEMUX_VERSION}
bash createDebFromSourceUbuntu.bash --no-install
sudo cp -av debs /output/
popd
rm -rf avidemux_${AVIDEMUX_VERSION}

fi

# build tree for direct install
if [ -z "${SKIP_TREE-}" ]; then

tar xvf avidemux_${AVIDEMUX_VERSION}.tar.gz
pushd avidemux_${AVIDEMUX_VERSION}
# add custom rpath
sed -i '/^PROJECT/a \set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib")' avidemux/*/CMakeLists.txt
sed -i '/^PROJECT/a \set(CMAKE_INSTALL_RPATH "\$ORIGIN")' avidemux_core/CMakeLists.txt \
                                                          avidemux_plugins/CMakeLists.txt
sed -i '/^MACRO(ADM_FF_SET_DEFAULT)/a \    xadd("--enable-rpath")' cmake/admFFmpegBuild_helpers.cmake
bash createDebFromSourceUbuntu.bash --deps-only
bash bootStrap.bash --prefix=/opt/avidemux
sudo cp -av install /output/
popd
rm -rf avidemux_${AVIDEMUX_VERSION}

fi
