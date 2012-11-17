#import "BeeKeyboard.h";
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface SpringBoard// (MouseSupport)

- (void)setMousePointerEnabled:(BOOL)enabled;
- (void)setMouseButtonsTwoThreeSwapped:(BOOL)swapped;
-(void)moveMousePointerToPoint:(CGPoint)point;
- (void)handleMouseEventAtPoint:(CGPoint)point buttons:(int)buttons;

// NOTE: Values of x and y are relative to the previous value, not absolute
- (CGPoint)handleMouseEventWithX:(float)x Y:(float)y buttons:(int)buttons;
@end

#define CSpring (SpringBoard *)[UIApplication sharedApplication]


BOOL MouseEnabled = NO;
BOOL Clicked = NO;

static int arrowPressed = 0;

void moveMouse()
{
    //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    //dispatch_get_main_queue();
    //dispatch_get_global_queue();
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (arrowPressed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                int x = 0, y = 0;
                
                if ((arrowPressed & 8)) x = x+5;
                if ((arrowPressed & 4)) x = x-5;
                if ((arrowPressed & 2)) y = y+5;
                if ((arrowPressed & 1)) y = y-5;
                
                [CSpring handleMouseEventWithX:x Y:y buttons:Clicked];
            });
            [NSThread sleepForTimeInterval:0.01f];
        }
        
    });
    
    
}


//Global Mode Required
int globalKeyEvent(int keyCode, int modStat, int usagePage, BOOL keyDown)
{
	NSString* event = [objc_getClass("BeeKeyboard") eventFromKeyCode:keyCode Mod:modStat UsagePage:7 AddonName:@"KeyboardMouse" Table:@"KeyboardMouse" Global:NO];

    if (keyDown && [event isEqualToString:@"Toggle"]) {

        [CSpring setMousePointerEnabled:!MouseEnabled];

        MouseEnabled = !MouseEnabled;

        if (MouseEnabled) {
            [CSpring handleMouseEventWithX:0 Y:0 buttons:0];
        }
    }
    
    if (!MouseEnabled) return 0;
    
    if (keyDown) {
        if ([event isEqualToString:@"MoveRight"]) {
            arrowPressed = (arrowPressed | 8);
            if ((arrowPressed ^ 8) == 0) moveMouse();
            return 2;
        }else if ([event isEqualToString:@"MoveLeft"]) {
            arrowPressed = (arrowPressed | 4);
            if ((arrowPressed ^ 4) == 0) moveMouse();
            return 2;
        }else if ([event isEqualToString:@"MoveDown"]) {
            arrowPressed = (arrowPressed | 2);
            if ((arrowPressed ^ 2) == 0) moveMouse();
            return 2;
        }else if ([event isEqualToString:@"MoveUp"]) {
            arrowPressed = (arrowPressed | 1);
            if ((arrowPressed ^ 1) == 0) moveMouse();
            return 2;
        }else if ([event isEqualToString:@"Click"]) {
            Clicked = YES;
            [CSpring handleMouseEventWithX:0 Y:0 buttons:1];
            //[CSpring handleMouseEventWithX:0 Y:0 buttons:2];
            return 2;
        }
    }else{
        if ([event isEqualToString:@"MoveRight"]) {
            arrowPressed = (arrowPressed ^ 8);
            return 2;
        }else if ([event isEqualToString:@"MoveLeft"]) {
            arrowPressed = (arrowPressed ^ 4);
            return 2;
        }else if ([event isEqualToString:@"MoveDown"]) {
            arrowPressed = (arrowPressed ^ 2);
            return 2;
        }else if ([event isEqualToString:@"MoveUp"]) {
            arrowPressed = (arrowPressed ^ 1);
            return 2;
        }
        
        if ([event isEqualToString:@"Click"]) {
            Clicked = NO;
            [CSpring handleMouseEventWithX:0 Y:0 buttons:0];
            return 2;
        } 
    }
    
	return 0;
}
