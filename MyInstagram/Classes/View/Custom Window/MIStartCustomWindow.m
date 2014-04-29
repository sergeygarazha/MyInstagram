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

@interface MIStartCustomWindow () {
    NSImageView *titleImage;
}

@end

@implementation MIStartCustomWindow

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.getNextPage setHidden:YES];
    
    // title bar
    titleImage = [[NSImageView alloc] initWithFrame:CGRectMake(500.0, 0.0, 50.0, 70.0)];
    [titleImage setImage:[NSImage imageNamed:@"Instagram.png"]];
    [[self titleBarView] addSubview:titleImage];
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
}

- (void)setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animateFlag
{
    [super setFrame:frameRect display:displayFlag animate:animateFlag];
    
    
}

@end
