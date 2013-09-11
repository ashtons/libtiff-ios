#!/bin/sh
#Based on original script found at http://pastebin.com/Pgiy3rYJ

GLOBAL_OUTDIR="`pwd`/dependencies"
LOCAL_OUTDIR="./outdir"
TIFF_LIB="`pwd`/tiff-4.0.3"
JPEG_INC="`pwd`/dependencies/include"
JPEG_LIB="`pwd`/dependencies/lib"

IOS_BASE_SDK="6.1"
IOS_DEPLOY_TGT="5.0"
LIPO="xcrun -sdk iphoneos lipo"

setenv_all()
{
# Add internal libs
export CFLAGS="-O2 $CFLAGS -I$GLOBAL_OUTDIR/include -L$GLOBAL_OUTDIR/lib"

export CXX="$DEVROOT/usr/bin/llvm-g++"
export CC="$DEVROOT/usr/bin/llvm-gcc"

export LD=$DEVROOT/usr/bin/ld
export AR=$DEVROOT/usr/bin/ar
export AS=$DEVROOT/usr/bin/as
export NM=$DEVROOT/usr/bin/nm
export RANLIB=$DEVROOT/usr/bin/ranlib
export LDFLAGS="-L$SDKROOT/usr/lib/ -L$GLOBAL_OUTDIR/lib -lz"

export CPPFLAGS=$CFLAGS
export CXXFLAGS=$CFLAGS
}

setenv_armv7()
{
unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS

export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk

export CFLAGS="-arch armv7 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"

setenv_all
}
setenv_armv7s()
{
unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS

export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk

export CFLAGS="-arch armv7s -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"

setenv_all
}
setenv_i386()
{
unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS

export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk

export CFLAGS="-arch i386 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT"

setenv_all
}

create_outdir_lipo()
{
for lib_i386 in `find $LOCAL_OUTDIR/i386 -name "lib*\.a"`; do
lib_armv7=`echo $lib_i386 | sed "s/i386/armv7/g"`
lib_armv7s=`echo $lib_i386 | sed "s/i386/armv7s/g"`
lib=`echo $lib_i386 | sed "s/i386//g"`
${LIPO} -arch armv7 $lib_armv7 -arch armv7s $lib_armv7s -arch i386 $lib_i386 -create -output $lib
done
}

#######################
# LIBTIFF
#######################

cd $TIFF_LIB
rm -rf $LOCAL_OUTDIR
mkdir -p $LOCAL_OUTDIR/armv7 $LOCAL_OUTDIR/armv7s $LOCAL_OUTDIR/i386

make clean 2> /dev/null
make distclean 2> /dev/null
echo "SETENV_i386"
setenv_i386
echo "CONFIGURE"
./configure --enable-shared=no --prefix=`pwd`/$LOCAL_OUTDIR/i386 --with-jpeg-include-dir=$JPEG_INC --with-jpeg-lib-dir=$JPEG_LIB
echo "MAKE"
make -j4
echo "MAKE INSTALL"
make install

make clean 2> /dev/null
make distclean 2> /dev/null
echo "SETENV_ARMV7"
setenv_armv7
echo "CONFIGURE"
./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=`pwd`/$LOCAL_OUTDIR/armv7 --with-jpeg-include-dir=$JPEG_INC --with-jpeg-lib-dir=$JPEG_LIB
echo "MAKE"
make -j4
echo "MAKE INSTALL"
make install

make clean 2> /dev/null
make distclean 2> /dev/null
echo "SETENV_ARMV7S"
setenv_armv7s
echo "CONFIGURE"
./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=`pwd`/$LOCAL_OUTDIR/armv7s --with-jpeg-include-dir=$JPEG_INC --with-jpeg-lib-dir=$JPEG_LIB
echo "MAKE"
make -j4
echo "MAKE INSTALL"
make install

# since we're installing the libraries into LOCAL_OUTDIR/<arch>/lib
# create_outdir_lipo will try to put them in LOCAL_OUTDIR/lib
mkdir -p $LOCAL_OUTDIR/lib
create_outdir_lipo
mkdir -p $GLOBAL_OUTDIR/include
cp -rvf $LOCAL_OUTDIR/i386/include/*.h $GLOBAL_OUTDIR/include
mkdir -p $GLOBAL_OUTDIR/lib
cp -rvf $LOCAL_OUTDIR/lib/lib*.a $GLOBAL_OUTDIR/lib
cd ..

echo "Finished!"