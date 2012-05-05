#import <UIKit/UIKit.h>

#define LS(a) a

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
        
        alert = [[UIAlertView alloc] initWithTitle:LS(@"") message:LS(@"종료하시겠습니까?") delegate:self cancelButtonTitle:LS(@"Cancel") otherButtonTitles:LS(@"Quit"), nil];
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
        if (keyCode == 20 && modStat%2) {
            [[BeeBasic sharedInstance] quitApp];
            return 1;
        }else if (keyCode == 41) {
            [[BeeBasic sharedInstance] Escape];
            
            if ([[BeeBasic sharedInstance] topAlertView] != nil) return 1;
            else return 0;
        }
    }
    
    return 0;
}