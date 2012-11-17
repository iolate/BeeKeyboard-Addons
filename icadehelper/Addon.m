#import "BeeKeyboard.h"
#import <UIKit/UIKit.h>
#import "iCade.h"


@interface UIResponder (Private)
- (id)firstResponder;
@end

static BOOL Enable = TRUE;
static BOOL RunFirst = TRUE;

//Default(App) Mode Required
int keyEvent(int keyCode, int modStat, BOOL keyDown) 
{
    if (RunFirst)
    {
        NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        NSDictionary* filter = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/BeeKeyboard/iCADEHelper-filter.plist"];
        
        if (![[filter objectForKey:bundleIdentifier] boolValue]) {
            Enable = FALSE;
        }
        RunFirst = FALSE;
        
        [filter release];
    }
    
    id fResponder = [[[UIApplication sharedApplication] keyWindow] firstResponder];
    if (!fResponder || ![fResponder respondsToSelector:@selector(insertText:)]) return 0;
    
    NSString* event = [objc_getClass("BeeKeyboard") eventFromKeyCode:keyCode Mod:modStat UsagePage:7 AddonName:@"iCADEeHelper" Table:@"iCADEHelper" Global:NO];
    
    NSString* ch = nil;
    
    if ([event isEqualToString:@"iCadeToggle"]) {
        if (keyDown){
            Enable = !Enable;
        }
        return 1;
    }else if ([event isEqualToString:@"stickUp"]) {
        if (keyDown) ch = @"w";
        else ch = @"e";
    }else if ([event isEqualToString:@"stickRight"]) {
        NSLog(@"helper right");
        if (keyDown) ch = @"d";
        else ch = @"c";
    }else if ([event isEqualToString:@"stickDown"]) {
        NSLog(@"helper down");
        if (keyDown) ch = @"x";
        else ch = @"z";
    }else if ([event isEqualToString:@"stickLeft"]) {
        if (keyDown) ch = @"a";
        else ch = @"q";
    }else if ([event isEqualToString:@"buttonA"]) {
        if (keyDown) ch = @"y";
        else ch = @"t";
    }else if ([event isEqualToString:@"buttonB"]) {
        if (keyDown) ch = @"h";
        else ch = @"r";
    }else if ([event isEqualToString:@"buttonC"]) {
        if (keyDown) ch = @"u";
        else ch = @"f";
    }else if ([event isEqualToString:@"buttonD"]) {
        if (keyDown) ch = @"j";
        else ch = @"n";
    }else if ([event isEqualToString:@"buttonE"]) {
        if (keyDown) ch = @"i";
        else ch = @"m";
    }else if ([event isEqualToString:@"buttonF"]) {
        if (keyDown) ch = @"k";
        else ch = @"p";
    }else if ([event isEqualToString:@"buttonG"]) {
        if (keyDown) ch = @"o";
        else ch = @"g";
    }else if ([event isEqualToString:@"buttonH"]) {
        if (keyDown) ch = @"l";
        else ch = @"v";
    }else {
        return 0;
    }
    
    if (!Enable) return 0;
    
    [fResponder insertText:ch];
    return 1;
}
