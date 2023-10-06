export ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.4
export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

INSTALL_TARGET_PROCESSES = SpringBoard
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CanvasBackground
$(TWEAK_NAME)_FILES = $(wildcard */*.m) $(wildcard */*.x)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tweak.mk
