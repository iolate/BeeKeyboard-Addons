#import <UIKit/UIKit.h>
#import <UIkit/UIAccessibilityElement.h>

#define SETTING_FILE @"/var/mobile/Library/Preferences/BeeKeyboard/basic.plist"
#include <objc/runtime.h>
#import <QuartzCore/CAWindowServer.h>
#import <QuartzCore/CAWindowServerDisplay.h>
#import <CoreGraphics/CGGeometry.h>
#import <GraphicsServices/GraphicsServices.h>
#import "FakeTouch.h"

#define ADDON_BUNDLE [NSBundle bundleWithPath:@"/Library/Application Support/BeeKeyboard/Addons/Basic.bundle"]
#define LOCALIZED_TABLE_NAME @"Basic"
#define LS(a) [ADDON_BUNDLE localizedStringForKey:a value:a table: LOCALIZED_TABLE_NAME]

#pragma mark - interfaces
@interface BeeKeyboard
+(NSString *)keyFromEvent:(NSString *)event AddonName:(NSString *)addonName Global:(BOOL)global;
+(NSString *)eventFromKeyCode:(int)keyCode Mod:(int)modStat UsagePage:(int)uP AddonName:(NSString *)addonName Table:(NSString *)table Global:(BOOL)global;

+(void)performSelectorOnMainThread:(SEL)fp8 withObject:(id)fp12 waitUntilDone:(BOOL)fp16;
+(UIView *)framedView;
+(void)showElementFrame:(UIView *)view;
@end

@interface UIView (FixedApi)
// http://stackoverflow.com/a/2596519
- (UIViewController *)viewController;
@end

@implementation UIView (FixedApi)

- (UIViewController *)viewController;
{
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else {
        return nil;
    }
}
@end

#pragma mark - BeeBasicClass

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

@end


void makeFakeTouch(UIView* view)
{
    UITouch *touch = [[UITouch alloc] initInView:view];
    
    UIEvent *eventDown = [[UIEvent alloc] initWithTouch:touch];
    [[UIApplication sharedApplication] sendEvent:eventDown];
    
    [touch __setPhase:UITouchPhaseEnded];
    
    UIEvent *eventUp = [[UIEvent alloc] initWithTouch:touch];
    [[UIApplication sharedApplication] sendEvent:eventUp];
    
    [eventDown release];
    [eventUp release];
    [touch release];
}

void findControl(UIView *view, NSMutableArray *views) {
    //twitter - @devbug0
    
    if (view.hidden || !view.userInteractionEnabled) return;
    
	for (UIView *v in view.subviews) {
		findControl(v, views);
		
        if ([v isKindOfClass:[UISegmentedControl class]]) {
            continue;
        }else if ([[NSString stringWithFormat:@"%@", [v class]] isEqualToString:@"MacLionSafariScrollView"]) {
            //Swipe Safari gesture view
            continue;
        }
        
        if ([v isKindOfClass:[UIControl class]] ||
            [v isKindOfClass:[UITableViewCell class]] ||
            [v isKindOfClass:[UIScrollView class]] ||
            [[NSString stringWithFormat:@"%@", [v class]] isEqualToString:@"UISegment"]) {
            
            if (![views containsObject:v])
				[views insertObject:v atIndex:0];
        }
	}
}

id controlsInWindow()
{
    NSMutableArray* controls = [[NSMutableArray alloc] init];
    
    findControl([[UIApplication sharedApplication] keyWindow], controls);

    /*
    for (UIWindow* window in [[UIApplication sharedApplication] windows])
    {
        findControl(window, controls);
    }*/
    
    return controls;
}

static int tabCount = -1;
static id selectedControl = nil;
static BOOL keyOnDown = NO;
static unsigned int timestamp = 0;



void tabControls (BOOL rightDir)
{
    if (keyOnDown) {
        keyOnDown = NO;
        return;
    }
    
    NSArray* controls = controlsInWindow();
    
    if ([controls count] == 0) {
        [controls release];
        return;
    }
    
    keyOnDown = YES;
    
    if (rightDir) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL firstCheck = NO;
            unsigned int ts = arc4random(); //[[NSDate date] timeIntervalSince1970]
            timestamp = ts;
            while (keyOnDown) {
                if (ts != timestamp) break;
                
                if (tabCount >= [controls count]-1) {
                    tabCount = -1;
                }
                
                tabCount++;
                
                UIView* con = [controls objectAtIndex:tabCount];
                
                [objc_getClass("BeeKeyboard") performSelectorOnMainThread:@selector(showElementFrame:) withObject:con waitUntilDone:YES];
                selectedControl = con;
                if (firstCheck)
                    [NSThread sleepForTimeInterval:0.1f];
                else {
                    firstCheck = YES;
                    [NSThread sleepForTimeInterval:0.3f];
                }
            }
        });
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL firstCheck = NO;
            unsigned int ts = arc4random(); //[[NSDate date] timeIntervalSince1970]
            timestamp = ts;
            while (keyOnDown) {
                if (ts != timestamp) break;
                
                if (tabCount <= 0 || tabCount > [controls count]) {
                    tabCount = [controls count];
                }
                
                tabCount--;
                
                UIView* con = [controls objectAtIndex:tabCount];
                
                [objc_getClass("BeeKeyboard") performSelectorOnMainThread:@selector(showElementFrame:) withObject:con waitUntilDone:YES];
                selectedControl = con;
                if (firstCheck)
                    [NSThread sleepForTimeInterval:0.1f];
                else {
                    firstCheck = YES;
                    [NSThread sleepForTimeInterval:0.3f];
                }
            }
        });
    }
    
    [controls release];
}

void controlValue(id view, int dir)
{
    //right left down up
 
    if (keyOnDown) {
        keyOnDown = NO;
        return;
    }
    
    keyOnDown = YES;
    
    if ([view isKindOfClass:[UISlider class]]) {
        UISlider* slider = view;
        if ([slider isEnabled]) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL firstCheck = NO;
                unsigned int ts = arc4random(); //[[NSDate date] timeIntervalSince1970]
                timestamp = ts;
                while (keyOnDown) {
                    if (ts != timestamp) break;
                    
                    if (dir == 1 || dir == 4) {
                        [slider setValue:slider.value + slider.maximumValue*0.1f <= slider.maximumValue ? slider.value + slider.maximumValue*0.1f : slider.maximumValue animated:YES];
                    }else if (dir == 2 || dir == 3) {
                        [slider setValue:slider.value - slider.maximumValue*0.1f >= 0 ? slider.value - slider.maximumValue*0.1f : 0 animated:YES];
                    }
                    [slider sendActionsForControlEvents:UIControlEventValueChanged];
                    
                    if (firstCheck)
                        [NSThread sleepForTimeInterval:0.1f];
                    else {
                        firstCheck = YES;
                        [NSThread sleepForTimeInterval:0.3f];
                    }
                }
            });
                    
            
        }
    } else if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView* scroll = view;
        
#define SCROLL_VALUE 100
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL firstCheck = NO;
            unsigned int ts = arc4random(); //[[NSDate date] timeIntervalSince1970]
            timestamp = ts;
            while (keyOnDown) {
                if (ts != timestamp) break;
                
                if (dir == 1){
                    CGFloat currentOffset = scroll.contentOffset.x;
                    CGFloat newOffset = currentOffset + SCROLL_VALUE;
                    
                    float right = scroll.contentSize.width - scroll.bounds.size.width;
                    if (right < 0) right = 0;
                    
                    if (newOffset > right) newOffset = right;
                    
                    [scroll setContentOffset:CGPointMake(newOffset,scroll.contentOffset.y) animated:YES];
                }else if (dir == 2) {
                    CGFloat currentOffset = scroll.contentOffset.x;
                    CGFloat newOffset = currentOffset - SCROLL_VALUE;
                    if (newOffset < 0) newOffset = 0;
                    
                    [scroll setContentOffset:CGPointMake(newOffset,scroll.contentOffset.y) animated:YES];
                }else if (dir == 3) {
                    CGFloat currentOffset = scroll.contentOffset.y;
                    CGFloat newOffset = currentOffset + SCROLL_VALUE;
                    
                    float bottom = scroll.contentSize.height - scroll.bounds.size.height;
                    if (bottom < 0) bottom = 0;
                    
                    if (newOffset > bottom) newOffset = bottom;
                    
                    [scroll setContentOffset:CGPointMake(scroll.contentOffset.x, newOffset) animated:YES];
                }else if (dir == 4) {
                    CGFloat currentOffset = scroll.contentOffset.y;
                    CGFloat newOffset = currentOffset - SCROLL_VALUE;
                    if (newOffset < 0) newOffset = 0;
                    
                    [scroll setContentOffset:CGPointMake(scroll.contentOffset.x, newOffset) animated:YES];
                }
                
                if (firstCheck)
                    [NSThread sleepForTimeInterval:0.1f];
                else {
                    firstCheck = YES;
                    [NSThread sleepForTimeInterval:0.3f];
                }
            }
        });
        
    } else {
        
    }
    

}

#pragma mark - process key event

int keyEvent(int keyCode, int modStat, BOOL keyDown) 
{
    NSString* event = [objc_getClass("BeeKeyboard") eventFromKeyCode:keyCode Mod:modStat UsagePage:7 AddonName:@"Basic" Table:@"basic" Global:NO];
    BOOL isApp = ![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"];
         
    if (keyDown) {
        if ([event isEqualToString:@"QuitApp"]) {
            [[BeeBasic sharedInstance] quitApp];
            return 1;
        }else if ([event isEqualToString:@"TabControl"] && isApp) {
            tabControls(YES);
            
            return 1;
        }else if ([event isEqualToString:@"TabControlPrev"] && isApp) {
            tabControls(NO);
            
            return 1;
        }else if ([event isEqualToString:@"ControlClick"] && isApp) {
            NSArray* controls = controlsInWindow();
            
            if (tabCount != -1 && tabCount < [controls count]) {
                UIView* con = [controls objectAtIndex:tabCount];
                //CGRect frameInWindow = [con.superview convertRect:[con frame] toView:nil];
                
                if ([con isEqual:selectedControl] && [objc_getClass("BeeKeyboard") framedView] != nil && [con isEqual:[objc_getClass("BeeKeyboard") framedView]]) {
                    if ([con isKindOfClass:[UISwitch class]]) {
                        UISwitch* swit = (UISwitch *)con;
                        
                        if ([swit isEnabled]) {
                            [swit setOn:![swit isOn] animated:YES];
                            [swit sendActionsForControlEvents:UIControlEventValueChanged];
                        }
                        
                    }else {
                        [objc_getClass("BeeKeyboard") showElementFrame:nil];
                        makeFakeTouch(con);
                    }
                    
                }else if (![con isEqual:selectedControl]){
                    tabCount = -1;
                    [objc_getClass("BeeKeyboard") showElementFrame:nil];
                }else {
                    [objc_getClass("BeeKeyboard") showElementFrame:nil];
                }
                
                [controls release];
                return 1;
            }
            [controls release];
            return 0;
        }else if ([event isEqualToString:@"Control_RIGHT"] && isApp) {
            NSArray* controls = controlsInWindow();
            
            if (tabCount != -1 && tabCount < [controls count]) {
                UIView* con = [controls objectAtIndex:tabCount];
                if ([objc_getClass("BeeKeyboard") framedView] == nil || ![con isEqual:selectedControl] || ![con isEqual:[objc_getClass("BeeKeyboard") framedView]]) return 0;
                
                controlValue(con, 1);
                
                [controls release];
                return 1;
            }else {
                [controls release];
                return 0;
            }
        }else if ([event isEqualToString:@"Control_LEFT"] && isApp) {
            NSArray* controls = controlsInWindow();
            
            if (tabCount != -1 && tabCount < [controls count]) {
                UIView* con = [controls objectAtIndex:tabCount];
                if ([objc_getClass("BeeKeyboard") framedView] == nil || ![con isEqual:selectedControl] || ![con isEqual:[objc_getClass("BeeKeyboard") framedView]]) return 0;
                
                controlValue(con, 2);
                
                [controls release];
                return 1;
            }else {
                [controls release];
                return 0;
            }
        }else if ([event isEqualToString:@"Control_DOWN"] && isApp) {
            NSArray* controls = controlsInWindow();
            
            if (tabCount != -1 && tabCount < [controls count]) {
                UIView* con = [controls objectAtIndex:tabCount];
                if ([objc_getClass("BeeKeyboard") framedView] == nil || ![con isEqual:selectedControl] || ![con isEqual:[objc_getClass("BeeKeyboard") framedView]]) return 0;
                
                controlValue(con, 3);
                
                [controls release];
                return 1;
            }else {
                [controls release];
                return 0;
            }
        }else if ([event isEqualToString:@"Control_UP"] && isApp) {
            NSArray* controls = controlsInWindow();
            
            if (tabCount != -1 && tabCount < [controls count]) {
                UIView* con = [controls objectAtIndex:tabCount];
                if ([objc_getClass("BeeKeyboard") framedView] == nil || ![con isEqual:selectedControl] || ![con isEqual:[objc_getClass("BeeKeyboard") framedView]]) return 0;
                
                controlValue(con, 4);
                
                [controls release];
                return 1;
            }else {
                [controls release];
                return 0;
            }
        }else if ([event isEqualToString:@"RemoveControlFrame"] && isApp) {
            tabCount = -1;
            [objc_getClass("BeeKeyboard") showElementFrame:nil];
            return 1;
        }
    }else{
        if (([event hasPrefix:@"TabControl"] || [event hasPrefix:@"Control_"]) && isApp) {
            keyOnDown = NO;
            timestamp = 0;
        }
    }
    
    return 0;
}