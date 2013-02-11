//http://cocoawithlove.com/2008/10/synthesizing-touch-event-on-iphone.html

#import "FakeTouch.h"
#import <UIKit/UITouch.h>

@interface UIApplication (Private)
-(id)_touchesEvent;
@end

@interface UITouchesEvent
-(id)allTouches;
@end

@implementation GSEventProxy
@end

@implementation UITouch (Synthesize)

- (id)initInView:(UIView *)view
{
    self = [super init];
    if (self != nil)
    {
        CGRect frameInWindow;
        if ([view isKindOfClass:[UIWindow class]])
        {
            frameInWindow = view.frame;
        }
        else
        {
            frameInWindow = [view.window convertRect:view.frame fromView:view.superview];
            // [view.superview convertRect:view.frame toView:nil];
        }
        
        _tapCount = 1;
        _locationInWindow =
        CGPointMake(
                    frameInWindow.origin.x + 0.5 * frameInWindow.size.width,
                    frameInWindow.origin.y + 0.5 * frameInWindow.size.height);
        _previousLocationInWindow = _locationInWindow;
        
        UIView *target = [view.window hitTest:_locationInWindow withEvent:nil];
        _view = [target retain];
        _window = [view.window retain];
        _phase = UITouchPhaseBegan;
        _touchFlags._firstTouchForView = 1;
        _touchFlags._isTap = 1;
        _timestamp = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

//
// setPhase:
//
// Setter to allow access to the _phase member.
//
- (void)__setPhase:(UITouchPhase)phase
{
	_phase = phase;
	_timestamp = [NSDate timeIntervalSinceReferenceDate];
}



- (void)setLocationInWindow:(CGPoint)location
{
	_previousLocationInWindow = _locationInWindow;
	_locationInWindow = location;
	_timestamp = [NSDate timeIntervalSinceReferenceDate];
}

@end

@implementation UIEvent (Synthesize)

- (id)initWithTouch:(UITouch *)touch
{
    
    CGPoint location = [touch locationInView:touch.window];
    GSEventProxy *gsEventProxy = [[GSEventProxy alloc] init];
    gsEventProxy->x1 = location.x;
    gsEventProxy->y1 = location.y;
    gsEventProxy->x2 = location.x;
    gsEventProxy->y2 = location.y;
    gsEventProxy->x3 = location.x;
    gsEventProxy->y3 = location.y;
    gsEventProxy->sizeX = 1.0;
    gsEventProxy->sizeY = 1.0;
    gsEventProxy->flags = ([touch phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    gsEventProxy->type = 3001;
    
    //GSEventRecord* record = ;
    //GSSendSystemEvent(_GSEventGetGSEventRecord((GSEventRef)gsEventProxy));
    
    Class touchesEventClass = objc_getClass("UITouchesEvent");
    if (touchesEventClass && ![[self class] isEqual:touchesEventClass])
    {
        [self release];
        self = [touchesEventClass alloc];
    }
    
    NSSet* touches = [[[UIApplication sharedApplication] _touchesEvent] allTouches];
    NSSet* newTouches = [touches setByAddingObject:touch];

    self = [self _initWithEvent:gsEventProxy touches:newTouches];
    if (self != nil)
    {
    }
    return self;
}

@end
