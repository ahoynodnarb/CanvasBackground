export ARCHS = arm64 arm64e
export TARGET = iphone:clang:13.5:13.0
export PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = CanvasBackground
$(TWEAK_NAME)_FILES = $(wildcard *.xm)
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
