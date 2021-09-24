export ARCHS = arm64 arm64e
export TARGET = iphone:clang:13.5:13.0
export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

SUBPROJECTS += Spotify SpringBoard

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
