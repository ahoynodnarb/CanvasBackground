export TARGET := iphone:clang:14.4

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CBShared

$(TWEAK_NAME)_FILES = Shared.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tweak.mk
