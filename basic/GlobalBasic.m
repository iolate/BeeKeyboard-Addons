#import <UIKit/UIKit.h>
#import <GraphicsServices/GSEvent.h>

@interface SBUIController
+(SBUIController *)sharedInstance;
-(BOOL)isSwitcherShowing;
-(void)dismissSwitcherAnimated:(BOOL)fp8;
-(void)dismissSwitcher;
-(void)_toggleSwitcher;
- (BOOL)activateSwitcher;
- (void)programmaticSwitchAppGestureMoveToLeft;
- (void)programmaticSwitchAppGestureMoveToRight;
-(BOOL)respondsToSelector:(SEL)fp8;
-(void)performSelectorOnMainThread:(SEL)fp8 withObject:(id)fp12 waitUntilDone:(BOOL)fp16;
@end

@interface SBBulletinListController
+(SBBulletinListController *)sharedInstance;
-(BOOL)listViewIsActive;
-(void)hideListViewAnimated:(BOOL)fp8;
-(void)showListViewAnimated:(BOOL)fp8;
@end


@interface BeeKeyboard
+(NSString *)keyFromEvent:(NSString *)event AddonName:(NSString *)addonName Global:(BOOL)global;
+(NSString *)eventFromKeyCode:(int)keyCode Mod:(int)modStat UsagePage:(int)uP AddonName:(NSString *)addonName Table:(NSString *)table Global:(BOOL)global;
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

-(void)homeButtonDown
{
    struct GSEventRecord record;
	memset(&record, 0, sizeof(record));
	record.type = kGSEventMenuButtonDown;
	record.timestamp = GSCurrentEventTimestamp();
	GSSendSystemEvent(&record);
}

-(void)homeButtonUp
{
    struct GSEventRecord record;
	memset(&record, 0, sizeof(record));
	record.type = kGSEventMenuButtonUp;
    //record.timestamp = GSCurrentEventTimestamp();
	GSSendSystemEvent(&record);
}

-(void)lockButtonDown
{
    struct GSEventRecord record;
	memset(&record, 0, sizeof(record));
	record.type = kGSEventLockButtonDown;
	record.timestamp = GSCurrentEventTimestamp();
	GSSendSystemEvent(&record);
}

-(void)lockButtonUp
{
    struct GSEventRecord record;
	memset(&record, 0, sizeof(record));
	record.type = kGSEventLockButtonUp;
    //record.timestamp = GSCurrentEventTimestamp();
	GSSendSystemEvent(&record);
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

-(void)activateSwitcher
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
        //[SBUI _toggleSwitcher];
        [SBUI performSelectorOnMainThread:@selector(_toggleSwitcher) withObject:nil waitUntilDone:YES];
        
        return;
    }
}



@end


static BOOL homePressing;

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
                [[BeeGlobalBasic sharedInstance] homeButtonUp];
                
                return 2;
            }
        }
    }
    //NSString* keyString = [NSString stringWithFormat:@"%d.%d.%d", usagePage, modStat, keyCode];
    NSString* event = [objc_getClass("BeeKeyboard") eventFromKeyCode:keyCode Mod:modStat UsagePage:usagePage AddonName:@"Basic" Table:@"basic" Global:YES];

    if ([event isEqualToString:@"Home"]) {
        if (keyDown) {
            if (homePressing) {
                [[BeeGlobalBasic sharedInstance] homeButtonUp];
            }
            homePressing = YES;
            [[BeeGlobalBasic sharedInstance] homeButtonDown];
        }
        return 2;
    }else if ([event isEqualToString:@"Switcher"] || [event isEqualToString:@"Switcher2"]) {
        if (keyDown) {
            [[BeeGlobalBasic sharedInstance] activateSwitcher];
        }
        return 2;
    }else if ([event isEqualToString:@"NotiCenter"] || [event isEqualToString:@"NotiCenter2"]) {
        if (keyDown) {
            [[BeeGlobalBasic sharedInstance] activateNC];
        }
        return 2;
    }else if ([event isEqualToString:@"AppLeft"]) {
        if (keyDown) {
            id uic = [objc_getClass("SBUIController") sharedInstance];
            if ([uic respondsToSelector:@selector(programmaticSwitchAppGestureMoveToLeft)])
                [uic programmaticSwitchAppGestureMoveToLeft];
        }
        return 2;
    }else if ([event isEqualToString:@"AppRight"]) {
        if (keyDown) {
            id uic = [objc_getClass("SBUIController") sharedInstance];
            if ([uic respondsToSelector:@selector(programmaticSwitchAppGestureMoveToRight)])
                [uic programmaticSwitchAppGestureMoveToRight];
        }
        return 2; 
    }
    
    return 0;
}