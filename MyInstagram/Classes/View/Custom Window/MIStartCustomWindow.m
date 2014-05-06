//
//  MICustomWindow.m
//  MyInstagram
//
//  Created by Sergey Garazha on 18/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIStartCustomWindow.h"
#import "MIScrollView.h"
#import "MICollectionView.h"
#import "MIStartWindowController.h"
#import "ITProgressIndicator.h"
#import "MITranslucentButton.h"

@interface MIStartCustomWindow () {
    NSImageView *titleImage;
    NSTrackingArea *updateButtonTrackingArea;
}

@end

@implementation MIStartCustomWindow

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // title bar
    titleImage = [[NSImageView alloc] initWithFrame:CGRectMake(500.0, 0.0, 50.0, 70.0)];
    [titleImage setImage:[NSImage imageNamed:@"Instagram.png"]];
    [[self titleBarView] addSubview:titleImage];
    [[self titleBarView] addSubview:self.updateButton];
    self.titleBarHeight = 50.0f;
    self.titleBarDrawingBlock = ^(BOOL drawsAsMainWindow, CGRect drawingRect, CGPathRef clippingPath) {
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextAddPath(ctx, clippingPath);
		CGContextClip(ctx);
        
		NSGradient *gradient = nil;
		if (drawsAsMainWindow) {
			gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:36.0/256.0 green:98.0/256.0 blue:131.0/256.0 alpha:1.0]
													 endingColor:[NSColor colorWithCalibratedRed:71.0/256.0 green:129.0/256.0 blue:162.0/256.0 alpha:1.0]];
			[[NSColor darkGrayColor] setFill];
		} else {
			// set the default non-main window gradient colors
			gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.851f alpha:1]
													 endingColor:[NSColor colorWithCalibratedWhite:0.929f alpha:1]];
			[[NSColor colorWithCalibratedWhite:0.6f alpha:1] setFill];
		}
		[gradient drawInRect:drawingRect angle:90];
		NSRectFill(NSMakeRect(NSMinX(drawingRect), NSMinY(drawingRect), NSWidth(drawingRect), 1));
	};
    
    [self setFrame:self.frame display:YES animate:YES];
    [self hideProgressIndicator];
}

- (void)close
{
    [self.windowController close:self];
    
    [super close];
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)flag
{
    [super setFrame:frameRect display:flag];
    
    float height = 55.0;
    float width = 80.0;
    [titleImage setFrame:CGRectMake(frameRect.size.width/2.0-width/2.0, self.titleBarView.frame.size.height-height, width, height)];
    [self.updateButton setFrame:CGRectMake(self.titleBarView.frame.size.width-55.0, 0.0, 50.0, 43.0)];
    [self.updateButton setColor:[NSColor clearColor]];
    
    [self updateTrackingArea];
}

#pragma mark - Mouse detecting

- (void)updateTrackingArea
{
    [[self titleBarView] removeTrackingArea:updateButtonTrackingArea];
	updateButtonTrackingArea = [[NSTrackingArea alloc] initWithRect:[self titleBarView].frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:nil];
    [[self titleBarView] addTrackingArea:updateButtonTrackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	if (theEvent.trackingArea == updateButtonTrackingArea) {
		[self.updateButton setHidden:NO];
	}
}

- (void)mouseExited:(NSEvent *)theEvent
{
	if (theEvent.trackingArea == updateButtonTrackingArea && ![(MIStartWindowController *)self.windowController loadingInProgress]) {
		[self.updateButton setHidden:YES];
	}
}

#pragma mark - Progress Indicator

- (void)showProgressIndicator
{
    for (NSView *subview in [self.updateButton subviews]) {
        if ([subview isKindOfClass:[NSImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    CGSize size = self.updateButton.frame.size;
    ITProgressIndicator *indicator = [[ITProgressIndicator alloc] initWithFrame:CGRectMake(0.0, -3.0, size.width, size.height)];
    [self.updateButton addSubview:indicator];
}

- (void)hideProgressIndicator
{
    for (NSView *subview in [self.updateButton subviews]) {
        if ([subview isKindOfClass:[ITProgressIndicator class]]) {
            [subview removeFromSuperview];
        }
    }
    
    NSImageView *image = [[NSImageView alloc] initWithFrame:CGRectMake(12.0, 8.0, self.updateButton.frame.size.width-23.0, self.updateButton.frame.size.height-23.0)];
    [image setImage:[NSImage imageNamed:@"Reload1.png"]];
    [self.updateButton addSubview:image];
}

@end
