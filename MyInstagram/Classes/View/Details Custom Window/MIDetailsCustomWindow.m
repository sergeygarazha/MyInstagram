//
//  MIDetailsCustomWindow.m
//  MyInstagram
//
//  Created by Sergey Garazha on 28/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIDetailsCustomWindow.h"
#import "MITranslucentButton.h"

@interface MIDetailsCustomWindow () {
    NSTrackingArea *leftTrackingArea;
	NSTrackingArea *rightTrackingArea;
	NSTrackingArea *bottomTrackingArea;
    BOOL windowClosingTrigger;
    CGPoint mouseLocation;
}

@end

@implementation MIDetailsCustomWindow

- (void)awakeFromNib
{
    windowClosingTrigger = NO;
    
    [self setAspectRatio:self.imageView.frame.size];
    
    // titles
	NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[centredStyle setAlignment:NSCenterTextAlignment];
	NSDictionary *attributes = @{ NSForegroundColorAttributeName: [NSColor whiteColor],
		                          NSParagraphStyleAttributeName: centredStyle };
	[self.leftTransitionView setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Назад" attributes:attributes]];
	[self.rightTransitionView setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Вперед" attributes:attributes]];
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)flag
{
    [super setFrame:frameRect display:flag];
    
    [self updateTrackingAreas];
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animateFlag
{
    [super setFrame:frameRect display:displayFlag animate:animateFlag];
    
    [self updateTrackingAreas];
}

- (void)close
{
    CGPoint origin = self.frame.origin;
    CGSize size = self.frame.size;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f,%f,%f,%f",
                                                      origin.x,     origin.y,
                                                      size.width,   size.height]
                                              forKey:@"detailsWindow"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    [super close];
}

#pragma mark - Mouse handling

- (void)mouseDown:(NSEvent *)theEvent
{
    windowClosingTrigger = YES;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	mouseLocation = CGPointMake(theEvent.deltaX, theEvent.deltaY);
	windowClosingTrigger = NO;
    
	CGRect rect = self.frame;
	rect.origin.x += theEvent.deltaX;
	rect.origin.y -= theEvent.deltaY;
    
	[self setFrame:rect display:YES animate:NO];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (windowClosingTrigger) {
        [self close];
    }
	windowClosingTrigger = NO;
}

#pragma mark - Tracking areas

- (void)updateTrackingAreas
{
    [self.contentView removeTrackingArea:leftTrackingArea];
	leftTrackingArea = [[NSTrackingArea alloc] initWithRect:self.leftTransitionView.frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self.contentView addTrackingArea:leftTrackingArea];
	[self.contentView removeTrackingArea:rightTrackingArea];
	rightTrackingArea = [[NSTrackingArea alloc] initWithRect:self.rightTransitionView.frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self.contentView addTrackingArea:rightTrackingArea];
	[self.contentView removeTrackingArea:bottomTrackingArea];
	bottomTrackingArea = [[NSTrackingArea alloc] initWithRect:self.bottomView.frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
	[self.contentView addTrackingArea:bottomTrackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	if (theEvent.trackingArea == leftTrackingArea) {
		[self.leftTransitionView setHidden:NO];
	}
	if (theEvent.trackingArea == rightTrackingArea) {
		[self.rightTransitionView setHidden:NO];
	}
	if (theEvent.trackingArea == bottomTrackingArea) {
		[self.bottomView setHidden:NO];
	}
}

- (void)mouseExited:(NSEvent *)theEvent
{
	if (theEvent.trackingArea == leftTrackingArea && theEvent.type == NSMouseExited) {
		[self.leftTransitionView setHidden:YES];
	}
	if (theEvent.trackingArea == rightTrackingArea && theEvent.type == NSMouseExited) {
		[self.rightTransitionView setHidden:YES];
	}
	if (theEvent.trackingArea == bottomTrackingArea && theEvent.type == NSMouseExited) {
		[self.bottomView setHidden:YES];
	}
}

@end
