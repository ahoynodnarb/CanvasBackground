export ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.4
export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

SUBPROJECTS += SpringBoard Spotify

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
