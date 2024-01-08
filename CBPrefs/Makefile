TARGET := iphone:clang:14.4

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CBPrefs

CBPrefs_FILES = CNVSRootListController.m
CBPrefs_FRAMEWORKS = UIKit
CBPrefs_PRIVATE_FRAMEWORKS = Preferences
CBPrefs_INSTALL_PATH = /Library/PreferenceBundles
CBPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
