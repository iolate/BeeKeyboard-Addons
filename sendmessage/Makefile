export FW_DEVICE_IP = 10.0.1.4

include theos/makefiles/common.mk

LIBRARY_NAME = Addon
Addon_FILES = Addon.m
Addon_FRAMEWORKS = UIKit
Addon_INSTALL_PATH = /Library/Application Support/BeeKeyboard/Addons/SendMessages.bundle

Addon_CFLAGS = -std=c99

#include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/library.mk

internal-stage::
	$(ECHO_NOTHING)cp -r Resources/* $(THEOS_STAGING_DIR)/Library/Application\ Support/BeeKeyboard/Addons/SendMessages.bundle/$(ECHO_END) 
