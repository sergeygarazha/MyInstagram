//
//  MIDetailsWindowController.m
//  MyInstagram
//
//  Created by Sergey Garazha on 17/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIDetailsWindowController.h"
#import "Post.h"
#import "NSImageView+AFNetworking.h"

@interface MIDetailsWindowController () {
    Post *post;
    BOOL trigger;
    CGPoint mouseLocationChanged;
}

@end

@implementation MIDetailsWindowController

- (instancetype)initWithPost:(Post *)post_ {
	self = [super initWithWindowNibName:@"MIDetailsWindowController"];
	if (self) {
        post = post_;
        trigger = NO;
	}
	return self;
}

- (id)initWithWindow:(NSWindow *)window {
	self = [super initWithWindow:window];
	if (self) {
		// Initialization code here.
	}
	return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (theEvent.window == self.window) {
        trigger = YES;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    mouseLocationChanged = CGPointMake(theEvent.deltaX, theEvent.deltaY);
    trigger = NO;
    
    CGRect rect = self.window.frame;
    rect.origin.x += theEvent.deltaX;
    rect.origin.y -= theEvent.deltaY;
    
    [self.window setFrame:rect display:YES animate:NO];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (trigger && theEvent.window == self.window) {
        [self.window close];
    }
    trigger = NO;
}

- (void)loadWindow {
    [super loadWindow];
    
    [self.window setAspectRatio: self.image.frame.size];
    [self.image setImageFromURL:[NSURL URLWithString:post.standard] withThumbnail:[NSURL URLWithString:post.thumbnail]];
    
    self.window.delegate = self;
}

- (void)windowDidLoad {
	[super windowDidLoad];

	// Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowDidEndLiveResize:(NSNotification *)notification {
//    CGPoint origin = self.window.frame.origin;
//    CGSize size = self.image.frame.size;
//    [self.window setFrame:CGRectMake(origin.x, origin.y, size.width, size.height) display:YES];
    
//    NSLog(@"%f, %f", self.window.frame.size.width, self.window.frame.size.height);
}

//- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
//}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    NSLog(@"%f", frameSize.height);
    
    return frameSize;
}

@end
