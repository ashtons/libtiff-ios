#!/bin/sh
#Based on original script found at http://pastebin.com/Pgiy3rYJ

GLOBAL_OUTDIR="`pwd`/dependencies"
LOCAL_OUTDIR="./outdir"
PNG_LIB="`pwd`/libpng-1.6.9"

IOS_BASE_SDK="7.0"
IOS_DEPLOY_TGT="5.1"
LIPO="xcrun -sdk iphoneos lipo"

setenv_all()
{
# Add internal libs
export CFLAGS="-O2 $CFLAGS -I$GLOBAL_OUTDIR/include -L$GLOBAL_OUTDIR/lib"

export CXX=`xcrun -find -sdk iphoneos clang++`
export CC=`xcrun -find -sdk iphoneos clang`

export LD=`xcrun -find -sdk iphoneos ld`
export AR=`xcrun -find -sdk iphoneos ar`
export AS=`xcrun -find -sdk iphoneos as`
export NM=`xcrun -find -sdk iphoneos nm`
export RANLIB=`xcrun -find -sdk iphoneos ranlib`
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
setenv_arm64()
{
unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS

export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk

export CFLAGS="-arch arm64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/"

setenv_all
}

setenv_x86_64()
{
unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS

export DEVROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer
export SDKROOT=$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk

export CFLAGS="-arch x86_64 -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT"

setenv_all
}

create_outdir_lipo()
{
echo "create_outdir_lipo"
for lib_i386 in `find $LOCAL_OUTDIR/i386 -name "lib*\.a"`; do
lib_armv7=`echo $lib_i386 | sed "s/i386/armv7/g"`
lib_armv7s=`echo $lib_i386 | sed "s/i386/armv7s/g"`
lib_arm64=`echo $lib_i386 | sed "s/i386/arm64/g"`
lib_x86_64=`echo $lib_i386 | sed "s/i386/x86_64/g"`
lib=`echo $lib_i386 | sed "s/i386//g"`
${LIPO} -arch armv7 $lib_armv7 -arch armv7s $lib_armv7s -arch arm64 $lib_arm64 -arch i386 $lib_i386 -arch x86_64 $lib_x86_64 -create -output $lib
done
}

#######################
# PNG
#######################

cd $PNG_LIB
rm -rf $LOCAL_OUTDIR
mkdir -p $LOCAL_OUTDIR/armv7 $LOCAL_OUTDIR/arm64 $LOCAL_OUTDIR/armv7s $LOCAL_OUTDIR/i386

make clean 2> /dev/null
make distclean 2> /dev/null
echo "SETENV_i386"
setenv_i386
echo "CONFIGURE"
./configure --enable-shared=no --prefix=`pwd`/$LOCAL_OUTDIR/i386
echo "MAKE"
make -j4
echo "MAKE INSTALL"
make install

make clean 2> /dev/null
make distclean 2> /dev/null
echo "SETENV_ARMV7"
setenv_armv7
echo "CONFIGURE"
./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=`pwd`/$LOCAL_OUTDIR/armv7
echo "MAKE"
make -j4
echo "MAKE INSTALL"
make install

make clean 2> /dev/null
make distclean 2> /dev/null
echo "SETENV_ARMV7S"
setenv_armv7s
echo "CONFIGURE"
./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=`pwd`/$LOCAL_OUTDIR/armv7s
echo "MAKE"
make -j4
echo "MAKE INSTALL"
make install

make clean 2> /dev/null
make distclean 2> /dev/null
echo "SETENV_ARM64"
setenv_arm64
echo "CONFIGURE"
./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=`pwd`/$LOCAL_OUTDIR/arm64
echo "MAKE"
make -j4
echo "MAKE INSTALL"
make install

make clean 2> /dev/null
make distclean 2> /dev/null
echo "SETENV_x86_64"
setenv_x86_64
echo "CONFIGURE"
./configure --host=arm-apple-darwin7 --enable-shared=no --prefix=`pwd`/$LOCAL_OUTDIR/x86_64
echo "MAKE"
make -j4
echo "MAKE INSTALL"
make install

mkdir -p $LOCAL_OUTDIR/lib
create_outdir_lipo
mkdir -p $GLOBAL_OUTDIR/include
cp -rvf $LOCAL_OUTDIR/i386/include/*.h $GLOBAL_OUTDIR/include
mkdir -p $GLOBAL_OUTDIR/lib
cp -rvf $LOCAL_OUTDIR/lib/lib*.a $GLOBAL_OUTDIR/lib
cd ..

echo "Finished!"
