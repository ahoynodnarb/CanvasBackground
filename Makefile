export ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.4
export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

include $(THEOS)/makefiles/common.mk
SUBPROJECTS = SpringBoard Spotify Shared
include $(THEOS_MAKE_PATH)/aggregate.mk
