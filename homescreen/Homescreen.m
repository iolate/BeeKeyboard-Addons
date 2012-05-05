#import <UIKit/UIKit.h>

@interface SpringBoard
- (id)_accessibilityFrontMostApplication;
@end

@interface SBUIController
+(SBUIController *)sharedInstance;
-(BOOL)respondsToSelector:(SEL)fp8;
@end

@interface SBIconController
+ (id)sharedInstance;
- (void)scrollToIconListAtIndex:(int)fp8 animate:(BOOL)fp12;
- (int)currentIconListIndex;
- (id)scrollView;
@end

@interface BeeHomescreen

@end

@implementation BeeHomescreen

+(void)moveSBPage:(int)page
{
    BOOL onHome = NO;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(_accessibilityFrontMostApplication)]) {
        id MostApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
        onHome = MostApp == nil ? YES : NO;
    }else onHome = NO; 
    
    if (!onHome) return;
    
    SBIconController* SBIC = (SBIconController *)[objc_getClass("SBIconController") sharedInstance];
    
    UIScrollView* scroll = [SBIC scrollView];
    int numberOfPages = scroll.contentSize.width / scroll.bounds.size.width - 1;
    
    page = MIN(page, numberOfPages-1);
    [SBIC scrollToIconListAtIndex:page animate:YES];
}

+(void)movePageDirRight:(BOOL)right
{
    BOOL onHome = NO;
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(_accessibilityFrontMostApplication)]) {
        id MostApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
        onHome = MostApp == nil ? YES : NO;
    }else onHome = NO; 
    
    if (!onHome) return;
    
    SBIconController* SBIC = (SBIconController *)[objc_getClass("SBIconController") sharedInstance];
    
    UIScrollView* scroll = [SBIC scrollView];
    int numberOfPages = scroll.contentSize.width / scroll.bounds.size.width - 1;
    
    int index = [SBIC currentIconListIndex];
    
    if (right) index++;
    else index--;
    
    index = MIN(index, numberOfPages-1);
    
    if (index >= -1)
        [SBIC scrollToIconListAtIndex:index animate:YES];
}

@end

int keyEvent(int keyCode, int modStat, BOOL keyDown)
{
    if (keyDown) {
        int k = keyCode;
        
        if ((k>=30 && k<=39) && modStat == 0) {
            int num = k==39 ? -1 : k-30;
            [BeeHomescreen moveSBPage:num];
            
            return 1;
        }else if ((k == 79 || k == 80) && modStat == 0) {
            [BeeHomescreen movePageDirRight:k == 79 ? YES : NO];
            
            return 1;
        }
    }
    
    return 0;
}