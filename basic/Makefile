export FW_DEVICE_IP = 10.0.1.3

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

ri:: all internal-ri# after-ri
internal-ri::
	ssh root@$(FW_DEVICE_IP) "rm /Library/Application\ Support/BeeKeyboard/Addons/Basic.bundle/$(LIBRARY_NAME).dylib"
	scp "$(FW_PROJECT_DIR)/.theos/obj/$(LIBRARY_NAME).dylib" "root@$(FW_DEVICE_IP):/Library/Application\ Support/BeeKeyboard/Addons/Basic.bundle/"
#after-ri::
#	ssh root@$(FW_DEVICE_IP) "killall -9 SpringBoard"