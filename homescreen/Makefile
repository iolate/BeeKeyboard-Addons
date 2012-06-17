include theos/makefiles/common.mk

LIBRARY_NAME = Addon
Addon_FILES = Addon.m
Addon_INSTALL_PATH = /Library/Application Support/BeeKeyboard/Addons/Homescreen.bundle

ADDITIONAL_CFLAGS = -std=c99

include $(THEOS_MAKE_PATH)/library.mk

internal-stage::
	$(ECHO_NOTHING)cp -r Resources/* $(THEOS_STAGING_DIR)/Library/Application\ Support/BeeKeyboard/Addons/Homescreen.bundle/$(ECHO_END) 

pi:: all internal-pi# after-pi
internal-pi::
	

	ssh root@$(FW_DEVICE_IP) "rm /Library/Application\ Support/BeeKeyboard/Addons/Basic.bundle/$(LIBRARY_NAME).dylib"
	scp "$(FW_PROJECT_DIR)/.theos/obj/$(LIBRARY_NAME).dylib" "root@$(FW_DEVICE_IP):/Library/Application\ Support/BeeKeyboard/Addons/Basic.bundle/"
#after-pi::
#	ssh root@$(FW_DEVICE_IP) "killall -9 SpringBoard"