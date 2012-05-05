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
@end

@interface SBBulletinListController
+(SBBulletinListController *)sharedInstance;
-(BOOL)listViewIsActive;
-(void)hideListViewAnimated:(BOOL)fp8;
-(void)showListViewAnimated:(BOOL)fp8;
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
-(void)_activateSwitcher
{
    SBUIController *SBUI = (SBUIController *)[objc_getClass("SBUIController") sharedInstance];
    [SBUI _toggleSwitcher];
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
        [self performSelectorOnMainThread:@selector(_activateSwitcher) withObject:nil waitUntilDone:YES];
        
        return;
        //if (!isA) [self performSelector:@selector(activateSwitcher) withObject:nil afterDelay:0.05f];
    }
}



@end


static BOOL homePressing;

int globalKeyEvent(int keyCode, int modStat, int usagePage, BOOL keyDown)
{
    if (usagePage == 65281) {
        if (keyCode == 16 && keyDown) { //expose
            [[BeeGlobalBasic sharedInstance] activateSwitcher];
            
            return 2;
        }else if (keyCode == 2 && keyDown) { //dash board
            [[BeeGlobalBasic sharedInstance] activateNC];
            
            return 2;
        }
        
    }else if (usagePage == 7) {
        if (homePressing && ((keyCode == 26 && !keyDown) || modStat%2 == 0)) {
            homePressing = NO;
            [[BeeGlobalBasic sharedInstance] homeButtonUp];
            
            return 2;
        }
        
        if (keyCode == 26 && modStat%2 && keyDown) {
            homePressing = YES;
            [[BeeGlobalBasic sharedInstance] homeButtonDown];
            
            return 2;
        }else if ((keyCode == 81 || keyCode == 82) && modStat%2 && keyDown) {
#pragma mark NC & Switcher
            SBBulletinListController *blc = (SBBulletinListController *)[objc_getClass("SBBulletinListController") sharedInstance];
            BOOL islA = blc && [blc listViewIsActive]; //TODO:Support iOS4
            
            SBUIController *SBUI = (SBUIController *)[objc_getClass("SBUIController") sharedInstance];
            BOOL isA = [SBUI isSwitcherShowing];
            
            if (keyCode == 81) { if (isA) [[BeeGlobalBasic sharedInstance] activateSwitcher]; else [[BeeGlobalBasic sharedInstance] activateNC]; }
            else if (keyCode == 82) { if (islA) [[BeeGlobalBasic sharedInstance] activateNC]; else [[BeeGlobalBasic sharedInstance] activateSwitcher]; }
            
            return 2;
        }else if ((keyCode == 79 || keyCode == 80) && modStat%2 && keyDown) {
#pragma mark App Switch
            
            id uic = [objc_getClass("SBUIController") sharedInstance];
            
            BOOL right = keyCode==79 ? YES : NO;
            //TODO: invert option
            right = !right;
            
            if (!right){
                if ([uic respondsToSelector:@selector(programmaticSwitchAppGestureMoveToLeft)])
                    [uic programmaticSwitchAppGestureMoveToLeft];
                
            }else if (right){
                if ([uic respondsToSelector:@selector(programmaticSwitchAppGestureMoveToRight)])
                    [uic programmaticSwitchAppGestureMoveToRight];
            }
            
            return 2;
        }
    }
    
    return 0;
}