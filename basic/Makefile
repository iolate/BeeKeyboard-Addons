include theos/makefiles/common.mk

LIBRARY_NAME = Addon
Addon_FILES = Addon.m GlobalAddon.m FakeTouch.m
Addon_FRAMEWORKS = UIKit
Addon_PRIVATE_FRAMEWORKS = GraphicsServices
Addon_INSTALL_PATH = /Library/Application Support/BeeKeyboard/Addons/Basic.bundle

ADDITIONAL_CFLAGS = -std=c99

include $(THEOS_MAKE_PATH)/library.mk

internal-stage::
	$(ECHO_NOTHING)cp -r Resources/* $(THEOS_STAGING_DIR)/Library/Application\ Support/BeeKeyboard/Addons/Basic.bundle/$(ECHO_END) 

