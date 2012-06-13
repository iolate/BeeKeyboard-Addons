#import <UIKit/UIKit.h>
#import "BeeKeyboard.h";

@class SBIconListView;

@interface SBIconController
+ (id)sharedInstance;
- (void)scrollToIconListAtIndex:(int)fp8 animate:(BOOL)fp12;
- (int)currentIconListIndex;
- (id)scrollView;
- (id)currentRootIconList;
- (id)currentFolderIconList;
- (id)dock;
- (BOOL)hasOpenFolder;
@end

@interface SBIconListView
- (unsigned int)iconRowsForCurrentOrientation;
- (unsigned int)iconColumnsForCurrentOrientation;
- (NSArray *)visibleIcons;
-(BOOL)isEqual:(id)fp8;
@end

@interface SBIconView
- (void)setHighlighted:(BOOL)fp8;
- (void)setIsJittering:(BOOL)fp8;
@end

@interface SBIcon
- (void)launch;
@end

@interface SBIconViewMap
+ (id)homescreenMap;
- (id)mappedIconViewForIcon:(id)fp8; //SBIconView
@end

@interface SBAwayController
+ (id)sharedAwayController;
- (BOOL)isLocked; //just Locked
@end

static int jitterIndex = -1;
static BOOL inDock = FALSE;
static id oListView = nil;

BOOL moveSBPage(id _event)
{
    int page = 0;
    
    NSString* event = _event;
    if ([event isEqualToString:@"Spotlight"]) {
        page = 0;
    }else if ([event isEqualToString:@"Page1"]) {
        page = 1;
    }else if ([event isEqualToString:@"Page2"]) {
        page = 2;
    }else if ([event isEqualToString:@"Page3"]) {
        page = 3;
    }else if ([event isEqualToString:@"Page4"]) {
        page = 4;
    }else if ([event isEqualToString:@"Page5"]) {
        page = 5;
    }else if ([event isEqualToString:@"Page6"]) {
        page = 6;
    }else if ([event isEqualToString:@"Page7"]) {
        page = 7;
    }else if ([event isEqualToString:@"Page8"]) {
        page = 8;
    }else if ([event isEqualToString:@"Page9"]) {
        page = 9;
    }else return NO;
    
    
    SBAwayController* SBAC = (SBAwayController *)[objc_getClass("SBAwayController") sharedAwayController];
    if ([SBAC isLocked]) return NO;
    
    SBIconController* SBIC = (SBIconController *)[objc_getClass("SBIconController") sharedInstance];
    
    UIScrollView* scroll = [SBIC scrollView];
    int numberOfPages = scroll.contentSize.width / scroll.bounds.size.width - 1;
    
    page = MIN(page-1, numberOfPages-1);
    [SBIC scrollToIconListAtIndex:page animate:YES];
    
    return YES;
}

void movePageDirRight(BOOL right)
{
    
    SBAwayController* SBAC = (SBAwayController *)[objc_getClass("SBAwayController") sharedAwayController];
    if ([SBAC isLocked]) return;
    
    
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

BOOL moveIcons(id _event)
{
#define IndexCheck jitterIndex >= 0 && (jitterIndex < (int)[iconList count])
#define jitterNO SBIconView* oIconView = [[objc_getClass("SBIconViewMap") homescreenMap] mappedIconViewForIcon:[iconList objectAtIndex:jitterIndex]]; \
[oIconView setIsJittering:NO];\
[oIconView setHighlighted:NO];
#define jitterYES SBIconView* iconView = [[objc_getClass("SBIconViewMap") homescreenMap] mappedIconViewForIcon:[iconList objectAtIndex:jitterIndex]]; \
[iconView setIsJittering:YES];\
[iconView setHighlighted:YES];
#define dockJitterNO inDock = NO; \
oListView = nil; \
SBIconListView* dockView = [SBIC dock]; \
NSArray* iconList = [dockView visibleIcons]; \
if (IndexCheck) { jitterNO }
    
    
    NSString* event = _event;
    if ([event isEqualToString:@"IconMoveRight"]) {
        SBIconController* SBIC = (SBIconController *)[objc_getClass("SBIconController") sharedInstance];
        SBIconListView* listView = [SBIC hasOpenFolder] ? [SBIC currentFolderIconList] : inDock ? [SBIC dock] : [SBIC currentRootIconList];
        
        if ([SBIC hasOpenFolder] && inDock) {
            dockJitterNO
        }
        
        if (![listView isEqual:oListView]) { jitterIndex = -1; oListView = listView; }
        NSArray* iconList = [listView visibleIcons];
        
        if (IndexCheck) {
            jitterNO
        }else jitterIndex = -1;
        
        jitterIndex++;
        if (IndexCheck) {
            jitterYES
        }
        
        return YES;
    }else if ([event isEqualToString:@"IconMoveLeft"]) {
        SBIconController* SBIC = (SBIconController *)[objc_getClass("SBIconController") sharedInstance];
        
        SBIconListView* listView = [SBIC hasOpenFolder] ? [SBIC currentFolderIconList] : inDock ? [SBIC dock] : [SBIC currentRootIconList];
        
        if ([SBIC hasOpenFolder] && inDock) {
            dockJitterNO
        }
        
        if (![listView isEqual:oListView]) { jitterIndex = -1; oListView = listView; }
        NSArray* iconList = [listView visibleIcons];
        
        if (IndexCheck) {
            jitterNO
        }else jitterIndex = -1;
        
        jitterIndex--;
        if (IndexCheck) {
            jitterYES
        }
        
        return YES;
    }else if ([event isEqualToString:@"IconMoveDown"]) {
        SBIconController* SBIC = (SBIconController *)[objc_getClass("SBIconController") sharedInstance];
        if (!inDock || [SBIC hasOpenFolder]) {
            if (inDock) {
                dockJitterNO
            }
            
            SBIconListView* listView = [SBIC hasOpenFolder] ? [SBIC currentFolderIconList] : [SBIC currentRootIconList];
            if (![listView isEqual:oListView]) { jitterIndex = -1; oListView = listView; }
            NSArray* iconList = [listView visibleIcons];
            unsigned int columns = [listView iconColumnsForCurrentOrientation];
            
            if (IndexCheck) {
                jitterNO
            }else jitterIndex = -1;
            
            if (jitterIndex == -1) {
                if (![SBIC hasOpenFolder]) {
                    inDock = YES;
                    
                    SBIconListView* dockView = [SBIC dock];
                    oListView = dockView;
                    
                    NSArray* iconList = [dockView visibleIcons];
                    
                    jitterIndex = 0;
                    
                    if (IndexCheck) {
                        jitterYES
                    }
                }
                return NO;
            }else{
                jitterIndex = jitterIndex + columns;
                if (IndexCheck) {
                    jitterYES
                }else if (![SBIC hasOpenFolder]) {
                    inDock = YES;
                    
                    SBIconListView* dockView = [SBIC dock];
                    oListView = dockView;
                    
                    NSArray* iconList = [dockView visibleIcons];
                    unsigned int columns = [listView iconColumnsForCurrentOrientation];
                    
                    jitterIndex = jitterIndex%columns;
                    
                    if (IndexCheck) {
                        jitterYES
                    }else {
                        jitterIndex = 0;
                        
                        if (IndexCheck) {
                            jitterYES
                        }
                    }
                }
            }
            
        }else {
            return NO;
        }
        
        return YES;
    }else if ([event isEqualToString:@"IconMoveUp"]) {
        SBIconController* SBIC = (SBIconController *)[objc_getClass("SBIconController") sharedInstance];
        
        if (!inDock || [SBIC hasOpenFolder]) {
            if (inDock) {
                dockJitterNO
            }
            
            SBIconListView* listView = [SBIC hasOpenFolder] ? [SBIC currentFolderIconList] : [SBIC currentRootIconList];
            if (![listView isEqual:oListView]) { jitterIndex = -1; oListView = listView; }
            NSArray* iconList = [listView visibleIcons];
            unsigned int columns = [listView iconColumnsForCurrentOrientation];
            
            if (IndexCheck) {
                jitterNO
            }else jitterIndex = -1;
            
            jitterIndex = jitterIndex - columns;
            if (IndexCheck) {
                jitterYES
            }
            
        } else {
            SBIconListView* dockView = [SBIC dock];
            NSArray* iconList = [dockView visibleIcons];
            
            if (IndexCheck) {
                jitterNO
            }
            
            inDock = NO;
            
            SBIconListView* listView = [SBIC currentRootIconList];
            oListView = listView;
            iconList = [listView visibleIcons];
            
            jitterIndex = [iconList count]-1;
            if (IndexCheck) {
                jitterYES
            }else jitterIndex = -1;
            
        }
        
        return YES;
    }     
    return NO;
}

int keyEvent(int keyCode, int modStat, BOOL keyDown)
{
    if (keyDown) {
        NSString* event = [objc_getClass("BeeKeyboard") eventFromKeyCode:keyCode Mod:modStat UsagePage:7 AddonName:@"Homescreen" Table:@"homescreen" Global:NO];
        
        if ([event isEqualToString:@"MoveLeft"]) {
            movePageDirRight(NO);
            return 1;
        }else if ([event isEqualToString:@"MoveRight"]) {
            movePageDirRight(YES);
            return 1;
        }else if ([event isEqualToString:@"LaunchApp"]) {
            SBIconController* SBIC = (SBIconController *)[objc_getClass("SBIconController") sharedInstance];
            
            SBIconListView* listView = [SBIC hasOpenFolder] ? [SBIC currentFolderIconList] : inDock ? [SBIC dock] : [SBIC currentRootIconList];
            if (![listView isEqual:oListView]) {
                jitterIndex = -1;
                return 0;
            }
            
            NSArray* iconList = [listView visibleIcons];
            
            if (IndexCheck) {
                oListView = nil;
                jitterNO
                
                SBIcon* icon = [iconList objectAtIndex:jitterIndex];
                [icon launch];
            }
            return 1;
        }else if ([event isEqualToString:@"Spotlight"]) {
            moveSBPage(event);
            return 1;
        }else if ([event hasPrefix:@"IconMove"]) {
            if (moveIcons(event)) return 1;
        }else if ([event hasPrefix:@"Page"]) {
            if (moveSBPage(event)) return 1;
        }
        
    }
    
    return 0;
}