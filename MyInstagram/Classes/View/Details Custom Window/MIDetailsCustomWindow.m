//
//  MIDetailsCustomWindow.m
//  MyInstagram
//
//  Created by Sergey Garazha on 28/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIDetailsCustomWindow.h"
#import "MITranslucentButton.h"
#import "MIDetailsWindowController.h"

#define MAATTACHEDWINDOW_SCALE_FACTOR [[NSScreen mainScreen] userSpaceScaleFactor]

@interface MIDetailsCustomWindow () {
    NSTrackingArea *leftTrackingArea;
	NSTrackingArea *rightTrackingArea;
	NSTrackingArea *bottomTrackingArea;
    BOOL windowClosingTrigger;
    CGPoint mouseLocation;
    NSPoint _point;
    float _distance;
    
    NSColor *borderColor;
    float borderWidth;
    float arrowBaseWidth;
    float arrowHeight;
    BOOL hasArrow;
    float cornerRadius;
    BOOL drawsRoundCornerBesideArrow;
    
@private
    NSColor *_MABackgroundColor;
    __weak NSView *_view;
    __weak NSWindow *_window;
    MAWindowPosition _side;
    NSRect _viewFrame;
    BOOL _resizing;
}

@end

@implementation MIDetailsCustomWindow

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    MIDetailsWindowController *controller = (MIDetailsWindowController *)self.windowController;
    
    [self setAspectRatio:self.imageView.frame.size];
    _view = self.imageView;
    [self setAspectRatio:self.imageView.frame.size];
    
    // MAAttachedWindow configurartion
    _point = [controller attachingPoint];
    _distance = 10.0;
    borderWidth = 0.0;
    windowClosingTrigger = NO;
    self.viewMargin = 10.0f;
    arrowBaseWidth = 20.0;
    arrowHeight = 16.0;
    arrowBaseWidth = 10.0;
    hasArrow = YES;
    drawsRoundCornerBesideArrow = YES;
    self.styleMask = NSBorderlessWindowMask;
    self.backingType = NSBackingStoreBuffered;
    [self setExcludedFromWindowsMenu:YES];
    [self setMovableByWindowBackground:YES];
    [self useOptimizedDrawing:YES];
    [self setCornerRadius:8.0];
    [self setBackgroundColor:[NSColor whiteColor]];
    
//    // Configure our initial geometry.
//    [self _updateGeometry];
//    
//    // Update the background.
//    [super _updateBackground];
    
    // titles
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [NSColor whiteColor],
                                  NSParagraphStyleAttributeName: centredStyle };
    [self.leftTransitionView setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Back" attributes:attributes]];
    [self.rightTransitionView setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Forward" attributes:attributes]];
    
    // rounded corners
//    self.imageView.wantsLayer = YES;
//    self.imageView.layer.masksToBounds = YES;
//    [self.imageView.layer setCornerRadius:25.0];
    
//    [self.contentView setWantsLayer:YES];
//    [self.contentView layer].masksToBounds = YES;
//    [[self.contentView layer] setCornerRadius:25.0];
    
    // end of new implementation
    windowClosingTrigger = NO;
    
    // titles
	centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[centredStyle setAlignment:NSCenterTextAlignment];
	attributes = @{ NSForegroundColorAttributeName: [NSColor whiteColor],
                    NSParagraphStyleAttributeName: centredStyle };
	[self.leftTransitionView setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Back" attributes:attributes]];
	[self.rightTransitionView setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Forward" attributes:attributes]];
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
    [(MIDetailsWindowController *)self.windowController setWindowIsLoaded:NO];
    
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
	if (theEvent.trackingArea == leftTrackingArea && self.previousPageAvailable) {
		[self.leftTransitionView setHidden:NO];
	}
	if (theEvent.trackingArea == rightTrackingArea && self.nextPageAvailable) {
		[self.rightTransitionView setHidden:NO];
	}
	if (theEvent.trackingArea == bottomTrackingArea) {
		[self.bottomView setHidden:NO];
	}
}

- (void)mouseExited:(NSEvent *)theEvent
{
	if (theEvent.trackingArea == leftTrackingArea) {
		[self.leftTransitionView setHidden:YES];
	}
	if (theEvent.trackingArea == rightTrackingArea) {
		[self.rightTransitionView setHidden:YES];
	}
	if (theEvent.trackingArea == bottomTrackingArea) {
		[self.bottomView setHidden:YES];
	}
}

@end
