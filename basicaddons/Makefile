export SDKVERSION=5.1
export FW_DEVICE_IP = 10.0.1.4

include theos/makefiles/common.mk

LIBRARY_NAME = Addon AddonHome
Addon_FILES = Addon.m GlobalAddon.m
Addon_FRAMEWORKS = UIKit
Addon_PRIVATE_FRAMEWORKS = GraphicsServices
Addon_INSTALL_PATH = /Library/Application Support/BeeKeyboard/Addons/Basic.bundle
Addon_LDFLAGS = -lsubstrate

AddonHome_FILES = Addon_home.m
AddonHome_FRAMEWORKS = UIKit
AddonHome_INSTALL_PATH = /Library/Application Support/BeeKeyboard/Addons/Homescreen.bundle

ADDITIONAL_CFLAGS = -std=c99

include $(THEOS_MAKE_PATH)/library.mk

internal-stage::
	$(ECHO_NOTHING)cp -r Resources/* $(THEOS_STAGING_DIR)/Library/Application\ Support/BeeKeyboard/Addons/Basic.bundle/$(ECHO_END) 
	$(ECHO_NOTHING)cp -r Resources_home/* $(THEOS_STAGING_DIR)/Library/Application\ Support/BeeKeyboard/Addons/Homescreen.bundle/$(ECHO_END) 
	$(ECHO_NOTHING)mv $(THEOS_STAGING_DIR)/Library/Application\ Support/BeeKeyboard/Addons/Homescreen.bundle/AddonHome.dylib $(THEOS_STAGING_DIR)/Library/Application\ Support/BeeKeyboard/Addons/Homescreen.bundle/Addon.dylib$(ECHO_END) 
ri:: all internal-ri #after-ri
internal-ri::
	ssh root@$(FW_DEVICE_IP) "rm /Library/Application\ Support/BeeKeyboard/Addons/Basic.bundle/Addon.dylib"
	scp "$(FW_PROJECT_DIR)/.theos/obj/Addon.dylib" "root@$(FW_DEVICE_IP):/Library/Application\ Support/BeeKeyboard/Addons/Basic.bundle/Addon.dylib"
	ssh root@$(FW_DEVICE_IP) "rm /Library/Application\ Support/BeeKeyboard/Addons/Homescreen.bundle/Addon.dylib"
	scp "$(FW_PROJECT_DIR)/.theos/obj/AddonHome.dylib" "root@$(FW_DEVICE_IP):/Library/Application\ Support/BeeKeyboard/Addons/Homescreen.bundle/Addon.dylib"
#after-ri::
#	ssh root@$(FW_DEVICE_IP) "killall -9 SpringBoard"