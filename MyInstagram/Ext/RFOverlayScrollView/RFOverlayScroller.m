//
//  RFTransparentScroller.m
//  RFOverlayScrollView
//
//  Created by Tim Brückmann on 30.12.12.
//  Copyright (c) 2012 Rheinfabrik. All rights reserved.
//

#import "RFOverlayScroller.h"

#define FRAME_COUNT 10

@interface RFOverlayScroller () {
    int _animationStep;
}

@end

@implementation RFOverlayScroller

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self == nil) {
        return nil;
    }
    [self commonInitializer];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInitializer];
}

- (void)commonInitializer
{
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                options:(
                                                                         NSTrackingMouseEnteredAndExited
                                                                         | NSTrackingActiveInActiveApp
                                                                         | NSTrackingMouseMoved
                                                                         )
                                                                  owner:self
                                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Only draw the knob. drawRect: should only be invoked when overlay scrollers are not used
    [self drawKnob];
}

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag
{
    // Don't draw the background. Should only be invoked when using overlay scrollers
}

- (void)setFloatValue:(float)aFloat
{
    [super setFloatValue:aFloat];
    [self.animator setAlphaValue:1.0f];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOut) object:nil];
    [self performSelector:@selector(fadeOut) withObject:nil afterDelay:1.5f];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [super mouseExited:theEvent];
    [self fadeOut];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [super mouseEntered:theEvent];
    [self setControlTint:1];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.1f;
        [self.animator setAlphaValue:1.0f];
    } completionHandler:^{
    }];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOut) object:nil];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
	[super mouseMoved:theEvent];
    self.alphaValue = 1.0f;
}

- (void)fadeOut
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.3f;
        [self.animator setAlphaValue:0.0f];
    } completionHandler:^{
    }];
}

+ (BOOL)isCompatibleWithOverlayScrollers
{
    return self == [RFOverlayScroller class];
}

+ (CGFloat)zeroWidth
{
    return 0.0f;
}

- (void)drawKnob
{
	CGFloat alphaValue;
	
	alphaValue = 0.5 * (float)10 / (float) FRAME_COUNT;
    if ([self bounds].size.width < [self bounds].size.height) {
        [[NSColor colorWithRed:71.0/256.0 green:129.0/256.0 blue:162.0/256.0 alpha:1.0] setFill];
        NSRect rect = [self rectForPart:NSScrollerKnob];
        rect.size.width = 6;
        rect.origin.x += 0;
        rect.origin.x += 6.0;
        MMFillRoundedRect(rect, 4, 4);
    }
    else {
        // horiz scrollbar
        [[NSColor colorWithCalibratedWhite:0.0 alpha:alphaValue] setFill];
        NSRect rect = [self rectForPart:NSScrollerKnob];
        rect.size.height = 6;
        rect.origin.y += 0;
        rect.origin.y += 6.0;
        MMFillRoundedRect(rect, 4, 4);
    }
}

- (void) _updateKnob
{
	[self setNeedsDisplay:YES];
	
	if (_animationStep > 0) {
//		if (!_disableFade) {
//			if (!_scheduled) {
//				_scheduled = YES;
				[self performSelector:@selector(_updateKnobAfterDelay) withObject:nil afterDelay:0.3 / FRAME_COUNT];
				_animationStep --;
			}
//		}
//	}
}

- (void) _updateKnobAfterDelay
{
//	_scheduled = NO;
	[self _updateKnob];
}

void MMFillRoundedRect(NSRect rect, CGFloat x, CGFloat y)
{
    NSBezierPath* thePath = [NSBezierPath bezierPath];
	
    [thePath appendBezierPathWithRoundedRect:rect xRadius:x yRadius:y];
    [thePath fill];
}

@end
