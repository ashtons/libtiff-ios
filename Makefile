PNG_NAME        = libpng-1.6.18
JPEG_SRC_NAME   = jpegsrc.v9a# filename at the server
JPEG_DIR_NAME   = jpeg-9a# folder name after the JPEG_SRC_NAME archive has been unpacked
TIFF_NAME       = tiff-4.0.4

SDK_IPHONEOS_PATH=$(shell xcrun --sdk iphoneos --show-sdk-path)
SDK_IPHONESIMULATOR_PATH=$(shell xcrun --sdk iphonesimulator --show-sdk-path)
XCODE_DEVELOPER_PATH=/Applications/Xcode.app/Contents/Developer
XCODETOOLCHAIN_PATH=$(XCODE_DEVELOPER_PATH)/Toolchains/XcodeDefault.xctoolchain
IOS_DEPLOY_TGT="7.0"

IMAGE_SRC = $(shell pwd)
PNG_SRC   = $(IMAGE_SRC)/$(PNG_NAME)
JPEG_SRC = $(IMAGE_SRC)/$(JPEG_DIR_NAME)
TIFF_SRC = $(IMAGE_SRC)/$(TIFF_NAME)

IMAGE_LIB_DIR = $(shell pwd)/dependencies/lib/
IMAGE_INC_DIR = $(shell pwd)/dependencies/include/
LIB_FAT_DIR   = $(shell pwd)/dependencies/lib

libpngfiles = libpng.a
libjpegfiles = libjpeg.a
libtifffiles = libtiff.a

sdks = $(SDK_IPHONEOS_PATH) $(SDK_IPHONEOS_PATH) $(SDK_IPHONEOS_PATH) $(SDK_IPHONESIMULATOR_PATH) $(SDK_IPHONESIMULATOR_PATH)
archs = armv7 armv7s arm64 i386 x86_64
arch_names = arm-apple-darwin7 arm-apple-darwin7s arm-apple-darwin64 i386-apple-darwin x86_64-apple-darwin

libpngfolders  = $(foreach arch, $(arch_names), $(PNG_SRC)/$(arch)/)
libjpegfolders = $(foreach arch, $(arch_names), $(JPEG_SRC)/$(arch)/)
libtifffolders = $(foreach arch, $(arch_names), $(TIFF_SRC)/$(arch)/)

libpngmakefile  = $(foreach folder, $(libpngfolders), $(addprefix $(folder), Makefile) )
libjpegmakefile = $(foreach folder, $(libjpegfolders), $(addprefix $(folder), Makefile) )
libtiffmakefile = $(foreach folder, $(libtifffolders), $(addprefix $(folder), Makefile) )

libpngfat  = $(addprefix $(IMAGE_LIB_DIR), $(libpngfiles))
libjpegfat = $(addprefix $(IMAGE_LIB_DIR), $(libjpegfiles))
libtifffat = $(addprefix $(IMAGE_LIB_DIR), $(libtifffiles))

libpng     = $(foreach folder, $(libpngfolders), $(addprefix $(folder)/lib/, $(libpngfiles)) )
libjpeg    = $(foreach folder, $(libjpegfolders), $(addprefix $(folder)/lib/, $(libjpegfiles)) )
libtiff    = $(foreach folder, $(libtifffolders), $(addprefix $(folder)/lib/, $(libtifffiles)) )

libpngconfig  = $(PNG_SRC)/configure
libjpegconfig = $(JPEG_SRC)/configure
libtiffconfig = $(TIFF_SRC)/configure

index = $(words $(shell a="$(2)";echo $${a/$(1)*/$(1)} ))
swap  = $(word $(call index,$(1),$(2)),$(3))

dependant_libs = libpng libjpeg libtiff

.PHONY : all
all : $(dependant_libs)

#######################
# Build libtiff and all of it's dependencies
#######################
libtiff : $(libtifffat)

$(libtifffat) : $(libtiff)
	mkdir -p $(@D)
	xcrun lipo $(addsuffix lib/$(@F), $(libtifffolders)) -create -output $@
	mkdir -p $(IMAGE_INC_DIR)
	cp -rvf $(firstword $(libtifffolders))/include/*.h $(IMAGE_INC_DIR)

$(libtiff) :  $(libtiffmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(TIFF_SRC)/%/Makefile : $(libtiffconfig)
	export SDKROOT="$(call swap, $*, $(arch_names), $(sdks))" ; \
	export CFLAGS="-Qunused-arguments -arch $(call swap, $*, $(arch_names), $(archs)) -pipe -no-cpp-precomp -isysroot $$SDKROOT -miphoneos-version-min=$(IOS_DEPLOY_TGT) -O2" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="$$CFLAGS -Wno-deprecated-register"; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../configure --host=$* --enable-fast-install --enable-shared=no --prefix=`pwd` --without-x --with-jpeg-include-dir=$(abspath $(@D)/../../$(JPEG_DIR_NAME)/$*/include) --with-jpeg-lib-dir=$(abspath $(@D)/../../$(JPEG_DIR_NAME)/$*/lib)

libpng : $(libpngfat)

$(libpngfat) : $(libpng)
	mkdir -p $(@D)
	xcrun lipo $(addsuffix lib/$(@F), $(libpngfolders)) -create -output $@
	mkdir -p $(IMAGE_INC_DIR)
	cp -rvf $(firstword $(libpngfolders))/include/*.h $(IMAGE_INC_DIR)

$(libpng) : $(libpngmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(PNG_SRC)/%/Makefile : $(libpngconfig)
	export SDKROOT="$(call swap, $*, $(arch_names), $(sdks))" ; \
	export CFLAGS="-Qunused-arguments -arch $(call swap, $*, $(arch_names), $(archs)) -pipe -no-cpp-precomp -isysroot $$SDKROOT -miphoneos-version-min=$(IOS_DEPLOY_TGT) -O2" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="$$CFLAGS -Wno-deprecated-register"; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../configure --host=$* --enable-shared=no --prefix=`pwd`

libjpeg : $(libjpegfat)

$(libjpegfat) : $(libjpeg)
	mkdir -p $(@D)
	xcrun lipo $(addsuffix lib/$(@F), $(libjpegfolders)) -create -output $@
	mkdir -p $(IMAGE_INC_DIR)
	cp -rvf $(firstword $(libjpegfolders))/include/*.h $(IMAGE_INC_DIR)

$(libjpeg) : $(libjpegmakefile)
	cd $(abspath $(@D)/..) ; \
	$(MAKE) -sj8 && $(MAKE) install

$(JPEG_SRC)/%/Makefile : $(libjpegconfig)
	export SDKROOT="$(call swap, $*, $(arch_names), $(sdks))" ; \
	export CFLAGS="-Qunused-arguments -arch $(call swap, $*, $(arch_names), $(archs)) -pipe -no-cpp-precomp -isysroot $$SDKROOT -miphoneos-version-min=$(IOS_DEPLOY_TGT) -O2" ; \
	export CPPFLAGS=$$CFLAGS ; \
	export CXXFLAGS="$$CFLAGS -Wno-deprecated-register"; \
	mkdir -p $(@D) ; \
	cd $(@D) ; \
	../configure --host=$* --enable-shared=no --prefix=`pwd`

#######################
# Download sources
#######################
$(libtiffconfig) :
	curl ftp://ftp.remotesensing.org/pub/libtiff/$(TIFF_NAME).tar.gz | tar -xpf-

$(libjpegconfig) :
	curl http://www.ijg.org/files/$(JPEG_SRC_NAME).tar.gz | tar -xpf-

$(libpngconfig) :
	curl ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng16/$(PNG_NAME).tar.gz | tar -xpf-

#######################
# Clean
#######################
.PHONY : clean
clean : cleanpng cleantiff cleanjpeg

.PHONY : cleanpng
cleanpng :
	for folder in $(libpngfolders); do \
		if [ -d $$folder ]; then \
			cd $$folder; \
			$(MAKE) clean; \
		fi; \
	done

.PHONY : cleanjpeg
cleanjpeg :
	for folder in $(libjpegfolders); do \
		if [ -d $$folder ]; then \
			cd $$folder; \
			$(MAKE) clean; \
		fi; \
	done

.PHONY : cleantiff
cleantiff :
	for folder in $(libtifffolders); do \
		if [ -d $$folder ]; then \
			cd $$folder; \
			$(MAKE) clean; \
		fi; \
    done

.PHONY : mostlyclean
mostlyclean : mostlycleanpng mostlycleantiff mostlycleanjpeg

.PHONY : mostlycleanpng
mostlycleanpng :
	for folder in $(libpngfolders); do \
		if [ -d $$folder ]; then \
			cd $$folder; \
			$(MAKE) mostlyclean; \
		fi; \
    done

.PHONY : mostlycleantiff
mostlycleantiff :
	for folder in $(libtifffolders); do \
		if [ -d $$folder ]; then \
			cd $$folder; \
			$(MAKE) mostlyclean; \
		fi; \
	done

.PHONY : mostlycleanjpeg
mostlycleanjpeg :
	for folder in $(libjpegfolders); do \
		if [ -d $$folder ]; then \
			cd $$folder; \
			$(MAKE) mostlyclean; \
		fi; \
    done

.PHONY : distclean
distcleanimage :
	-rm -rf $(IMAGE_LIB_DIR)
	-rm -rf $(IMAGE_INC_DIR)
	-rm -rf $(IMAGE_SRC)

