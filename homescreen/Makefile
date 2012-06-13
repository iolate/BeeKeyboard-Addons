include theos/makefiles/common.mk

LIBRARY_NAME = Addon
Addon_FILES = Addon.m
Addon_INSTALL_PATH = /Library/Application Support/BeeKeyboard/Addons/Homescreen.bundle

ADDITIONAL_CFLAGS = -std=c99

include $(THEOS_MAKE_PATH)/library.mk

internal-stage::
	$(ECHO_NOTHING)cp -r Resources/* $(THEOS_STAGING_DIR)/Library/Application\ Support/BeeKeyboard/Addons/Homescreen.bundle/$(ECHO_END) 
