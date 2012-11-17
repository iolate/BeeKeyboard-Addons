//FakeTouch
//http://cocoawithlove.com/2008/10/synthesizing-touch-event-on-iphone.html

#import <UIKit/UIKit.h>

@interface GSEventProxy : NSObject
{
@public
    unsigned int flags;
    unsigned int type;
    unsigned int ignored1;
    float x1;
    float y1;
    float x2;
    float y2;
    unsigned int ignored2[10];
    unsigned int ignored3[7];
    float sizeX;
    float sizeY;
    float x3;
    float y3;
    unsigned int ignored4[3];
}
@end


@interface UIEvent (Creation)
- (id)_initWithEvent:(GSEventProxy *)fp8 touches:(id)fp12;
@end

@interface UIEvent (Synthesize)
- (id)initWithTouch:(UITouch *)touch;
@end

@interface UITouch (Synthesize)
- (id)initInView:(UIView *)view;
- (void)__setPhase:(UITouchPhase)phase;
- (void)setLocationInWindow:(CGPoint)location;
@end
