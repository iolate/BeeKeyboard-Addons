#import "BeeKeyboard.h"
#import <UIKit/UIKit.h>

#import "SimulateTouch.h"

#define SETTING_FILE_PATH @"/var/mobile/Library/Preferences/BeeKeyboard/SendMessages.plist"
#define LS(a) a


@interface UIKeyboard
//+ (BOOL)isOnScreen;
+ (id)activeKeyboard;
- (id)targetWindow;
@end

@interface UIControl (Private)
//UIControlEventTouchUpInside
- (void)sendActionsForControlEvents:(UIControlEvents)arg1;
//- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent;
@end

@interface UIBarButtonItem (Private)
- (SEL)action;
@end

@interface UIApplication (FirstResponder)
- (id)defaultFirstResponder;
@end

@interface UIWindow (Private)
- (id)firstResponder;
@end

@interface BeeKeyboard (SendMessages)
+(void)startMonitorTouch;
@end


int countSuperviews(UIView* view, int count)
{
    if (view.superview != nil) {
        return countSuperviews(view.superview, count+1);
    }else{
        return count;
    }
}

UIView* nSuperview(UIView* view, int superCount)
{
    if (superCount == 0) return view;
    if (superCount < 0) return nil;
    
    UIView* tmp = view.superview;
    for (int i = 1; i < superCount; i++) {
        tmp = tmp.superview;
        if (tmp == nil) {
            return nil;
        }
    }
    
    return tmp;
}

@interface SendMessagesClass : NSObject
{
    UIButton* buttonView;
    UIView* inputView;
}
+(SendMessagesClass *)sharedInstance;
@end

@implementation SendMessagesClass
static SendMessagesClass* instance;

+(SendMessagesClass *)sharedInstance {
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
    if ((self = [super init])) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchedView:) name:@"SendMessages_ViewTouched" object:nil];
    }
    
    return self;
}

-(void)setInputView:(UIView *)iv
{
    inputView = iv;
}

-(UIView *)getCommonSuperView
{
    UIView* a = (UIView *)buttonView;
    UIView* b = inputView;
    
    int aSCount = countSuperviews(a, 0);
    int bSCount = countSuperviews(b, 0);
    
    int sameCount = 0;
    if (aSCount > bSCount) {
        sameCount = bSCount;
    }else {
        //aSCount =< bSCount
        sameCount = aSCount;
    }
    a = nSuperview(a, aSCount-sameCount);
    b = nSuperview(b, bSCount-sameCount);
    
    UIView* commonView = nil;
    //int commonCount = 0;
    
    for (int i = 0; i < sameCount+1; i++) {
        if (nSuperview(a, i) == nSuperview(b, i)) {
            commonView = nSuperview(a, i);
            //commonCount = sameCount-i;
            break;
        }
    }
    
    return commonView;
}

-(BOOL)newButtonDefined:(int)simulateType
{
    if (buttonView == nil || inputView == nil) return FALSE;
    if (buttonView.window != inputView.window) return FALSE;

    int inputSCount = countSuperviews(inputView, 0);
    int buttonSCount = countSuperviews(buttonView, 0);
    
    NSString* targetClass = nil;
    NSString* buttonSelector = nil;
    
    for (id target in [buttonView allTargets]) {
        NSArray *actions = [buttonView actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
        
        if ([actions count]) {
            targetClass = [NSString stringWithFormat:@"%@", [target class]];
            if ([target isKindOfClass:[UIBarButtonItem class]]) {
                buttonSelector = NSStringFromSelector([target action]);
            }else{
                buttonSelector = [actions objectAtIndex:0];
            }
        }
    }
    
    NSString* className = [NSString stringWithFormat:@"%@", [inputView class]];
    NSString* superClassName = inputView.superview != nil ? [NSString stringWithFormat:@"%@", [inputView.superview class]] : @"";
    NSString* textViewKey = [NSString stringWithFormat:@"%@-%@-%d", className, superClassName, inputSCount];
    NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:SETTING_FILE_PATH] ?: [NSMutableDictionary dictionary];
    NSMutableDictionary* bdic = [dic objectForKey:bundleIdentifier] ? [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:bundleIdentifier]] : [NSMutableDictionary dictionary];
    
    UIView* commonView = [self getCommonSuperView];
    if (commonView == nil) return FALSE;

    int commonSCount = countSuperviews(commonView, 0);
    
    NSMutableDictionary* buttonData = [NSMutableDictionary dictionary];
    [buttonData setObject:[NSNumber numberWithInt:buttonSCount] forKey:@"buttonSCount"];
    [buttonData setObject:[NSNumber numberWithInt:commonSCount] forKey:@"commonSCount"];
    [buttonData setObject:[NSString stringWithFormat:@"%@", [buttonView class]] forKey:@"buttonClass"];
    [buttonData setObject:[NSNumber numberWithInt:buttonView.tag] forKey:@"buttonTag"];
    [buttonData setObject:[NSNumber numberWithInt:simulateType] forKey:@"simulateType"];
    if (targetClass != nil) {
        [buttonData setObject:targetClass forKey:@"targetClass"];
        [buttonData setObject:buttonSelector forKey:@"buttonSelector"];
    }
    
    [bdic setObject:buttonData forKey:textViewKey];
    [dic setObject:bdic forKey:bundleIdentifier];
    [dic writeToFile:SETTING_FILE_PATH atomically:NO];
    
    return TRUE;
    
}

-(void)touchedView:(NSNotification *)info
{
    buttonView = info.object;
    if (buttonView == nil) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"SendMessages") message:LS(@"Cannot get button.\nTry again?") delegate:[SendMessagesClass sharedInstance] cancelButtonTitle:LS(@"Cancel") otherButtonTitles:LS(@"OK"), nil];
        [alert setTag:1];
        [alert show];
        [alert release];
    }else if ([buttonView isKindOfClass:[UIButton class]]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"SendMessages") message:LS(@"Select simulate type\nIf only iPhone app on iPad, plz use Default") delegate:[SendMessagesClass sharedInstance] cancelButtonTitle:LS(@"Default") otherButtonTitles:LS(@"Simulate Touch"), nil];
        [alert setTag:3];
        [alert show];
        [alert release];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"SendMessages") message:LS(@"This is not a button.\nTry again?") delegate:[SendMessagesClass sharedInstance] cancelButtonTitle:LS(@"Cancel") otherButtonTitles:LS(@"OK"), nil];
        [alert setTag:1];
        [alert show];
        [alert release];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        [objc_getClass("BeeKeyboard") startMonitorTouch];
    }else if (alertView.tag == 2 && buttonIndex == 1) {
        [[NSFileManager defaultManager] removeItemAtPath:SETTING_FILE_PATH error:nil];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"SendMessages") message:@"All settings are removed." delegate:[SendMessagesClass sharedInstance] cancelButtonTitle:LS(@"OK") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else if (alertView.tag == 3) {
        if ([self newButtonDefined:buttonIndex]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"SendMessages") message:LS(@"Complete") delegate:nil cancelButtonTitle:LS(@"OK") otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"SendMessages") message:LS(@"Error") delegate:nil cancelButtonTitle:LS(@"OK") otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

@end

NSMutableArray* buttonsArray = nil;

void findButtons(UIView* view, int subCount, NSString* buttonClass, int buttonTag, NSString* targetClass, NSString* buttonSelector, int count)
{
    if (subCount > count) {
        for (UIView* v in view.subviews) {
            findButtons(v, subCount, buttonClass, buttonTag, targetClass, buttonSelector, count+1);
        }
    }else if (subCount == count) {
        for (UIView* v in view.subviews) {
        	
            if ([v isKindOfClass:[UIButton class]] && [buttonClass isEqualToString:[NSString stringWithFormat:@"%@", [v class]]]) {
                if (targetClass != nil || ![targetClass isEqualToString:@""]) {
                    for (id target in [(UIButton *)v allTargets]) {
        				NSArray *actions = [(UIButton *)v actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
        
        				if ([actions count]) {
            				if ([targetClass isEqualToString:[NSString stringWithFormat:@"%@", [target class]]]) {
                                if ([target isKindOfClass:[UIBarButtonItem class]]) {
                                    if ([buttonSelector isEqualToString:NSStringFromSelector([target action])]) {
                                        [buttonsArray addObject:v];
                                        break;
                                    }
                                }else{
                                    if ([buttonSelector isEqualToString:[actions objectAtIndex:0]]) {
                                        [buttonsArray addObject:v];
                                        break;
                                    }
                                }
            					
            				}
        				}
    				}
                }else{
                	[buttonsArray addObject:v];
                }
            }
        }
    }
}

CGPoint ConvertWindowLocation(CGPoint point)
{
    //UIWindow is always portrait even device is landscaped
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGSize screen = [[UIScreen mainScreen] bounds].size;
    
    if (orientation == UIInterfaceOrientationPortrait) {
        return point;
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGPointMake(screen.width - point.x, screen.height - point.y);
    }else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        //Homebutton is left
        return CGPointMake(screen.height - point.y, point.x);
    }else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGPointMake(point.y, screen.width - point.x);
    }else return point;
    
}


BOOL simulateButtonEvent(UIView* inputView, NSDictionary* buttonData)
{
    int inputSCount = countSuperviews(inputView, 0);
    int buttonSCount = [[buttonData objectForKey:@"buttonSCount"] intValue];
    int commonSCount = [[buttonData objectForKey:@"commonSCount"] intValue];
    int buttonTag = [[buttonData objectForKey:@"buttonTag"] intValue];
    int simulateType = [[buttonData objectForKey:@"simulateType"] intValue] ?: 0;

    NSString* buttonClass = [buttonData objectForKey:@"buttonClass"];
    NSString* targetClass = [buttonData objectForKey:@"targetClass"];
    NSString* buttonSelector = [buttonData objectForKey:@"buttonSelector"];
    
    if (inputSCount < commonSCount) return FALSE;
    
    UIView* commonView = nSuperview(inputView, inputSCount-commonSCount);
    buttonsArray = [NSMutableArray array];
    findButtons(commonView, buttonSCount - commonSCount, buttonClass, buttonTag, targetClass, buttonSelector, 1);
    if ([buttonsArray count] == 1) {
    	UIButton* b = (UIButton *)[buttonsArray objectAtIndex:0];
        
        if (simulateType == 0) {
            [b sendActionsForControlEvents:UIControlEventTouchUpInside];
        }else {
            CGRect frameInWindow = [b.window convertRect:b.frame fromView:b.superview];
            CGPoint locationInWindow = ConvertWindowLocation(CGPointMake(
                                                                         frameInWindow.origin.x + 0.5 * frameInWindow.size.width,
                                                                         frameInWindow.origin.y + 0.5 * frameInWindow.size.height));
            
            int pIndex = [[UIApplication sharedApplication] simulateTouch:0 atPoint:locationInWindow withType:STTouchDown];
            [[UIApplication sharedApplication] simulateTouch:pIndex atPoint:locationInWindow withType:STTouchUp];
        }
        
        
        
    	return TRUE;
    }else {
    	return FALSE;
    }
}

int keyEvent(int keyCode, int modStat, BOOL keyDown)
{
    NSString* event = [objc_getClass("BeeKeyboard") eventFromKeyCode:keyCode Mod:modStat UsagePage:7 AddonName:@"SendMessages" Table:@"SendMessages" Global:NO];
    
    if ([event isEqualToString:@"Send"]) {
        if (keyDown){
            
            if ([[UIKeyboard activeKeyboard] targetWindow] != nil) {
                UIView* textInput = [[[UIApplication sharedApplication] defaultFirstResponder] firstResponder];
                
                if (textInput == nil) {
                    return 0;
                }
                
                [[SendMessagesClass sharedInstance] setInputView:textInput];
                
                NSString* className = [NSString stringWithFormat:@"%@", [textInput class]];
                NSString* superClassName = textInput.superview != nil ? [NSString stringWithFormat:@"%@", [textInput.superview class]] : @"";
                int inputSCount = countSuperviews(textInput, 0);
                NSString* textViewKey = [NSString stringWithFormat:@"%@-%@-%d", className, superClassName, inputSCount];
                
                NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithContentsOfFile:SETTING_FILE_PATH];
                NSMutableDictionary* bdic = [dic objectForKey:bundleIdentifier] ?: nil;
                
                BOOL definedTextView = NO;
                if (bdic != nil) {
                    NSDictionary* targetDic = [bdic objectForKey:textViewKey] ?: nil;
                    
                    if (targetDic != nil) {
                        if (simulateButtonEvent(textInput, targetDic)) {
                            return 1;
                        }
                        
                        definedTextView = YES;
                    }
                }
                
                NSString* message = nil;
                if (definedTextView) {
                    message = LS(@"Defined but has error.\nDo you want set send button again?\nIf has error again, plz send mail with app name to me via cydia.");
                }else {
                    message = LS(@"Not defined.\nPlease touch send button");
                }
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"SendMessages") message:message delegate:[SendMessagesClass sharedInstance] cancelButtonTitle:LS(@"Cancel") otherButtonTitles:LS(@"OK"), nil];
                    [alert setTag:1];
                    [alert show];
                    [alert release];
                    
                
                
                return 1;
            }
            
        }
    }else if ([event isEqualToString:@"RemoveAll"]) {
        if (keyDown) {
            NSString* message = nil;
            if ([[NSFileManager defaultManager] fileExistsAtPath:SETTING_FILE_PATH]) {
                message = @"Do you want to remove all SendMessages' settings?";
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"SendMessages") message:message delegate:[SendMessagesClass sharedInstance] cancelButtonTitle:LS(@"Cancel") otherButtonTitles:LS(@"OK"), nil];
                [alert setTag:2];
                [alert show];
                [alert release];
            }else{
                message = @"No settings.";
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:LS(@"SendMessages") message:message delegate:nil cancelButtonTitle:LS(@"OK") otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
        
    }
    return 0;
}