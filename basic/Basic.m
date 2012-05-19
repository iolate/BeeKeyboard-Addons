 #import <UIKit/UIKit.h>

#define LS(a) a
#define SETTING_FILE @"/var/mobile/Library/Preferences/blueteeth/basic.plist"

@interface BeeKeyboard
+(BeeKeyboard *)sharedInstance;
-(NSString *)eventFromKey:(NSString *)keyString AddonName:(NSString *)addonName Table:(NSString *)table Global:(BOOL)global;
-(NSString *)keyFromEvent:(NSString *)event AddonName:(NSString *)addonName Table:(NSString *)table Global:(BOOL)global;
@end

@interface BeeBasic : NSObject
{
    BOOL showAlert;
    
    UIAlertView* alert;
}

@end

@implementation BeeBasic
static BeeBasic* instance;

+(BeeBasic *)sharedInstance {
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
        showAlert = NO;
    }
    return self;
}


-(void)_quitApp {
    showAlert = NO;
    exit(0);
}
-(void)quitApp
{
    if (showAlert) {
        [alert dismissWithClickedButtonIndex:0 animated:YES];
        showAlert = NO;
        [self _quitApp];
    }else{
        showAlert = YES;
        
        if (alert) [alert release];
        
        NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        BOOL onSpringboard = [bundleIdentifier isEqualToString:@"com.apple.springboard"] ? YES : NO;
        NSString* message = onSpringboard ? LS(@"Respring?") : LS(@"Quit?");
        NSString* otherButton = onSpringboard ? LS(@"Restart") : LS(@"Quit");
        
        alert = [[UIAlertView alloc] initWithTitle:LS(@"") message:message delegate:self cancelButtonTitle:LS(@"Cancel") otherButtonTitles:otherButton, nil];
        [alert setTag:1];
        [alert show];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        showAlert = NO;
        if (buttonIndex == 0) {
            
        }else {
            [self _quitApp];
        }
    }
}

-(UIAlertView *)topAlertView
{
    for (UIWindow* tW in [[UIApplication sharedApplication] windows]) {
        if ([tW isKindOfClass:objc_getClass("_UIAlertNormalizingOverlayWindow")]) {
            //_UIAlertNormalizingOverlayWindow
            for (int i = [[tW subviews] count]-1; i>=0; i--) {
                id sW = [[tW subviews] objectAtIndex:i];
                if ([sW isKindOfClass:[UIAlertView class]]) {
                    return (UIAlertView *)sW;
                }else{
                    continue;
                }
            }
        }/*else if ([tW isKindOfClass:objc_getClass("_UIAlertOverlayWindow")]) {
          //ActionSheet
          }*/
    }
    
    return nil;
}
-(void)Escape {
    
#pragma mark Close AlertView
    UIAlertView* rAlert = [self topAlertView];
    
    id cButton = [rAlert buttonAtIndex:[rAlert cancelButtonIndex]];
    [rAlert _buttonClicked:cButton];
    
}

@end


int keyEvent(int keyCode, int modStat, BOOL keyDown) 
{
    if (keyDown) {
        NSString* keyString = [NSString stringWithFormat:@"7.%d.%d", modStat, keyCode];
        NSString* event = [[objc_getClass("BeeKeyboard") sharedInstance] eventFromKey:keyString AddonName:@"Basic" Table:@"basic" Global:NO];
        
        if ([event isEqualToString:@"QuitApp"]) {
            [[BeeBasic sharedInstance] quitApp];
            return 1;
        }else {
            
            if (keyCode == 41) {
                [[BeeBasic sharedInstance] Escape];
                
                if ([[BeeBasic sharedInstance] topAlertView] != nil) return 1;
                else return 0;
            }   
        }
    }
    
    
    return 0;
}