export TARGET := iphone:clang:14.4
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CBSpringBoard

$(TWEAK_NAME)_FILES = CBInfoForwarder.m CBViewController.m SpringBoard.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tweak.mk
