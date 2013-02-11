#import "BeeKeyboard.h";
#import <UIKit/UIKit.h>
#import <GraphicsServices/GSEvent.h>

#define ADDON_BUNDLE [NSBundle bundleWithPath:@"/Library/Application Support/BeeKeyboard/Addons/Basic.bundle"]
#define LOCALIZED_TABLE_NAME @"global"
#define LS(a) [ADDON_BUNDLE localizedStringForKey:a value:a table: LOCALIZED_TABLE_NAME]

@interface UIApplication (SpringBoard)
/*- (void)setBacklightLevel:(float)fp8;
- (void)setBacklightLevel:(float)fp8 permanently:(BOOL)fp12;*/
- (float)currentBacklightLevel;
@endx


@interface SBUIController
+(SBUIController *)sharedInstance;
-(BOOL)isSwitcherShowing;
-(void)dismissSwitcherAnimated:(BOOL)fp8;
-(void)dismissSwitcher;
-(void)_toggleSwitcher;
- (void)programmaticSwitchAppGestureMoveToLeft;
- (void)programmaticSwitchAppGestureMoveToRight;
-(BOOL)respondsToSelector:(SEL)fp8;
@end

@interface SBBulletinListController
+(SBBulletinListController *)sharedInstance;
-(BOOL)listViewIsActive;
-(void)hideListViewAnimated:(BOOL)fp8;
-(void)showListViewAnimated:(BOOL)fp8;
@end

@interface SBWiFiManager 
+ (id)sharedInstance;
-(BOOL)wiFiEnabled;
-(void)setWiFiEnabled:(BOOL)enabled;
@end

@interface SBMediaController
+ (id)sharedInstance;
- (BOOL)isRingerMuted;
- (void)setRingerMuted:(BOOL)fp8;
@end

@interface SBTelephonyManager
+ (id)sharedTelephonyManager;
- (BOOL)isInAirplaneMode;
- (void)setIsInAirplaneMode:(BOOL)fp8;
@end

@interface BluetoothManager
+ (id)sharedInstance;
- (BOOL)enabled;
- (BOOL)setPowered:(BOOL)arg1;
- (BOOL)setEnabled:(BOOL)arg1;
@end

@interface SBRingerHUDController
+ (void)activate:(BOOL)fp8;
@end

@interface SBOrientationLockManager
+(id)sharedInstance;
-(void)lock;
-(void)unlock;
-(BOOL)isLocked;
@end

@interface CLLocationManager
+(BOOL)locationServicesEnabled;
+(void)setLocationServicesEnabled:(BOOL)fp8;
@end

@interface SBBrightnessController
+ (id)sharedBrightnessController;
- (void)_setBrightnessLevel:(float)fp8 showHUD:(BOOL)fp12;
@end

@interface SBTetherController
+ (id)sharedInstance;
- (void)_setTetherState:(int)fp8;
- (BOOL)isTethered;
@end

@interface BeeGlobalBasic : NSObject
{
    BOOL lockNC;
}
@end

@implementation BeeGlobalBasic
static BeeGlobalBasic* instance;

+(BeeGlobalBasic *)sharedInstance {
    if (instance==nil) {
        @synchronized(self) {
            if (instance==nil) {
                instance = [[self alloc] init];
                return instance;
            }   
        }    
    }
    return instance;
}
-(id)init
{
    self =[super init];
    if (self) {
        lockNC = NO;
    }
    return self;
}

-(void)unlockActivateNC
{
    lockNC = NO;
}
-(void)activateNC
{
    SBBulletinListController *blc = (SBBulletinListController *)[objc_getClass("SBBulletinListController") sharedInstance]; 
    BOOL islA = blc && [blc listViewIsActive]; //TODO:Support iOS4
    
    SBUIController *SBUI = (SBUIController *)[objc_getClass("SBUIController") sharedInstance];
    BOOL isA = [SBUI isSwitcherShowing];
    
    if (isA) {
        if ([SBUI respondsToSelector:@selector(dismissSwitcherAnimated:)]) {
            [SBUI dismissSwitcherAnimated:YES];
        } else {
            [SBUI dismissSwitcher];
        }
        [self performSelector:@selector(activateNC) withObject:nil afterDelay:0.05f];
        return;
    }
    
    if (blc && !lockNC) {
        lockNC = YES;
        if (islA) {
            [blc hideListViewAnimated:YES];
        }else {
            [blc showListViewAnimated:YES];
        }
        [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(unlockActivateNC) userInfo:nil repeats:NO];
    }
}


@end

static BOOL homePressing;

void homeButtonDown()
{
    struct GSEventRecord record;
    memset(&record, 0, sizeof(record));
    record.type = kGSEventMenuButtonDown;
    record.timestamp = GSCurrentEventTimestamp();
    GSSendSystemEvent(&record);
}

void homeButtonUp()
{
    struct GSEventRecord record;
    memset(&record, 0, sizeof(record));
    record.type = kGSEventMenuButtonUp;
    record.timestamp = GSCurrentEventTimestamp();
    GSSendSystemEvent(&record);
}
/*
void lockButtonDown()
{
    struct GSEventRecord record;
    memset(&record, 0, sizeof(record));
    record.type = kGSEventLockButtonDown;
    record.timestamp = GSCurrentEventTimestamp();
    GSSendSystemEvent(&record);
}

void lockButtonUp()
{
    struct GSEventRecord record;
    memset(&record, 0, sizeof(record));
    record.type = kGSEventLockButtonUp;
    record.timestamp = GSCurrentEventTimestamp();
    GSSendSystemEvent(&record);
}
*/

void activateSwitcher()
{
    SBUIController *SBUI = (SBUIController *)[objc_getClass("SBUIController") sharedInstance];
    BOOL isA = [SBUI isSwitcherShowing];
    
    if (isA) {
        if ([SBUI respondsToSelector:@selector(dismissSwitcherAnimated:)]) {
            [SBUI dismissSwitcherAnimated:YES];
            return;
        } else {
            [SBUI dismissSwitcher];
            return;
        }
    }else {
        [SBUI _toggleSwitcher];
        
        return;
    }
}

BOOL toggles(id _event)
{
    NSString* event = _event;
    if ([event isEqualToString:@"toggleWifi"]) {
        id wiMgr = [objc_getClass("SBWiFiManager") sharedInstance];
        BOOL cSet = [wiMgr wiFiEnabled];
        [wiMgr setWiFiEnabled:!cSet];
        
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%@ %@", LS(@"Wifi"),
                                                                                  !cSet ? LS(@"on") : LS(@"off")]);
    }else if ([event isEqualToString:@"toggleBluetooth"]) {
        BluetoothManager* btMgr = (BluetoothManager *)[objc_getClass("BluetoothManager") sharedInstance];
        BOOL cSet = [btMgr enabled];
        [btMgr setEnabled:!cSet];
        [btMgr setPowered:!cSet];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%@ %@", LS(@"Bluetooth"),
                                                                                  !cSet ? LS(@"on") : LS(@"off")]);
    }else if ([event isEqualToString:@"toggleMute"]) {
        id cSI = [objc_getClass("SBMediaController") sharedInstance];
        BOOL cSet = [cSI isRingerMuted]; //0 ring 1 mute
        [objc_getClass("SBRingerHUDController") activate:cSet]; // 0 mute 1 ring
        [cSI setRingerMuted:!cSet];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%@ %@", LS(@"Mute"),
                                                                                  !cSet ? LS(@"on") : LS(@"off")]);
    }else if ([event isEqualToString:@"toggleRotation"]) {
        id olMgr = [objc_getClass("SBOrientationLockManager") sharedInstance];
        BOOL cSet = [olMgr isLocked];
        if (cSet) [olMgr unlock];
        else [olMgr lock];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%@ %@", LS(@"Rotation"),
                                                                                  !cSet ? LS(@"on") : LS(@"off")]);
    }else if ([event isEqualToString:@"toggleAirplane"]) {
        id olMgr = [objc_getClass("SBTelephonyManager") sharedTelephonyManager];
        BOOL cSet = [olMgr isInAirplaneMode];
        [[objc_getClass("SBTelephonyManager") sharedTelephonyManager] setIsInAirplaneMode:!cSet];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%@ %@", LS(@"Airplain Mode"),
                                                                                  !cSet ? LS(@"on") : LS(@"off")]);
    }else if ([event isEqualToString:@"toggleLocation"]) {
        id Mgr = objc_getClass("CLLocationManager");
        BOOL cSet = [Mgr locationServicesEnabled];
        [Mgr setLocationServicesEnabled:!cSet];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%@ %@", LS(@"Location"),
                                                                                  !cSet ? LS(@"on") : LS(@"off")]);
    }
    
    return NO;
}

int globalKeyEvent(int keyCode, int modStat, int usagePage, BOOL keyDown)
{
    if (homePressing) {
        NSString* homeKey = [objc_getClass("BeeKeyboard") keyFromEvent:@"Home" AddonName:@"Basic" Global:YES];

        int hKeyCode = 0, hModStat = 0, hUsagePage = 0;
        if ([homeKey rangeOfString:@"."].length) {
            NSArray* keys = [homeKey componentsSeparatedByString:@"."];
            if ((int)[keys count] == 3) {
                hUsagePage = [[keys objectAtIndex:0] intValue];
                hModStat = [[keys objectAtIndex:1] intValue];
                hKeyCode = [[keys objectAtIndex:2] intValue];
                
            }
            
            if ((!keyDown && keyCode == hKeyCode) ||
                ((modStat & hModStat) != hModStat)) {
                homePressing = NO;
                homeButtonUp();
                
                return 2;
            }
        }
    }
    NSString* event = [objc_getClass("BeeKeyboard") eventFromKeyCode:keyCode Mod:modStat UsagePage:usagePage AddonName:@"Basic" Table:@"basic" Global:YES];

    if (keyDown) {
        if ([event isEqualToString:@"Home"]) {
            
            if (homePressing) {
                homeButtonUp();
            }
            homePressing = YES;
            homeButtonDown();
            
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, LS(@"HomeButton"));
            return 2;
        }else if ([event isEqualToString:@"Switcher"] || [event isEqualToString:@"Switcher2"]) {
            
            activateSwitcher();
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, LS(@"Switcher"));
            return 2;
        }else if ([event isEqualToString:@"NotiCenter"] || [event isEqualToString:@"NotiCenter2"]) {
            
            [[BeeGlobalBasic sharedInstance] activateNC];
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, LS(@"NotiCenter"));
            return 2;
        }else if ([event isEqualToString:@"AppLeft"]) {
            
            id uic = [objc_getClass("SBUIController") sharedInstance];
            if ([uic respondsToSelector:@selector(programmaticSwitchAppGestureMoveToLeft)])
                [uic programmaticSwitchAppGestureMoveToLeft];
            return 2;
        }else if ([event isEqualToString:@"AppRight"]) {
            
            id uic = [objc_getClass("SBUIController") sharedInstance];
            if ([uic respondsToSelector:@selector(programmaticSwitchAppGestureMoveToRight)])
                [uic programmaticSwitchAppGestureMoveToRight];
            return 2; 
        }else if ([event isEqualToString:@"BrightUp"]) {
            float cBright;
            float nBright;
            
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentBacklightLevel)]) {
                //iOS5. cannot on iOS6
                cBright = [[UIApplication sharedApplication] currentBacklightLevel];
            }else{
                //iOS6. cannot on iOS5 (I don't know why but freeze)
                cBright = [[UIScreen mainScreen] brightness];
            }
            
            nBright = cBright <= 0.9375f ? cBright + 0.0625f : 1.0f;
            [[objc_getClass("SBBrightnessController") sharedBrightnessController] _setBrightnessLevel:nBright showHUD:YES];
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, LS(@"Brightness Up"));
            return 2; 
        }else if ([event isEqualToString:@"BrightDown"]) {
            float cBright;
            float nBright;
            
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentBacklightLevel)]) {
                cBright = [[UIApplication sharedApplication] currentBacklightLevel];
            }else{
                cBright = [[UIScreen mainScreen] brightness];
            }
            
            nBright = cBright >= 0.0625f ? cBright - 0.0625f : 0.0f;
            [[objc_getClass("SBBrightnessController") sharedBrightnessController] _setBrightnessLevel:nBright showHUD:YES];
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, LS(@"Brightness Down"));
            return 2; 
        }else if ([event hasPrefix:@"toggle"]) {
            if (toggles(event)) return 2;
        }
    }
    
    
    return 0;
}