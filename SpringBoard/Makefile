export TARGET := iphone:clang:14.4
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CanvasBackgroundSB

$(TWEAK_NAME)_FILES = $(wildcard *.m) SpringBoard.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
# $(TWEAK_NAME)_LIBRARIES = mryipc
$(TWEAK_NAME)_LIBRARIES = rocketbootstrap
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk
