export TARGET = iphone:clang:13.5:13.0
INSTALL_TARGET_PROCESSES = com.spotify.client


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CanvasBackgroundSpotify

CanvasBackgroundSpotify_FILES = Tweak.x
CanvasBackgroundSpotify_CFLAGS = -fobjc-arc
CanvasBackgroundSpotify_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk
