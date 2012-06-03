include theos/makefiles/common.mk

export FW_DEVICE_IP = 10.0.1.3

LIBRARY_NAME = Homescreen
Homescreen_FILES = Homescreen.m
Homescreen_FRAMEWORKS = UIKit QuartzCore

ADDITIONAL_CFLAGS = -std=c99

include $(THEOS_MAKE_PATH)/library.mk

ri:: all internal-ri after-ri
internal-ri::
	ssh root@$(FW_DEVICE_IP) "rm /Library/Application\ Support/Blueteeth/KeyboardAddons/$(LIBRARY_NAME).dylib"
	scp "$(FW_PROJECT_DIR)/.theos/obj/$(LIBRARY_NAME).dylib" "root@$(FW_DEVICE_IP):/Library/Application\ Support/Blueteeth/KeyboardAddons/"
after-ri::
	ssh root@$(FW_DEVICE_IP) "killall -9 SpringBoard"