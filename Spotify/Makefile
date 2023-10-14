export TARGET := iphone:clang:14.4
INSTALL_TARGET_PROCESSES = Spotify


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CanvasBackgroundSpotify

$(TWEAK_NAME)_FILES = Spotify.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_LIBRARIES = mryipc

include $(THEOS_MAKE_PATH)/tweak.mk
