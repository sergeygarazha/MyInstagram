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
#import "MIDetailsCustomWindow.h"

@implementation MIDetailsWindowController

@synthesize post;

- (instancetype)initWithPost:(Post *)post_ {
	self = [super initWithWindowNibName:@"MIDetailsWindowController"];
	if (self) {
		self.post = post_;
	}
	return self;
}

- (void)loadWindow {
	[super loadWindow];

	[[(MIDetailsCustomWindow *)self.window imageView] setImageFromURL:[NSURL URLWithString:post.standard] withThumbnailURL:[NSURL URLWithString:post.thumbnail]];
	self.window.delegate = self;
}

- (void)updateWithPost:(Post *)post_ {
	self.post = post_;
	[[(MIDetailsCustomWindow *)self.window imageView] setImageFromURL:[NSURL URLWithString:post.standard] withThumbnailURL:[NSURL URLWithString:post.thumbnail]];
}

#pragma mark - Actions

- (IBAction)transitionLeft:(id)sender {
    if ([self.delegate respondsToSelector:@selector(showPreviousPost)]) {
        [self.delegate performSelector:@selector(showPreviousPost)];
    }
}

- (IBAction)transitionRight:(id)sender {
    if ([self.delegate respondsToSelector:@selector(showNextPost)]) {
        [self.delegate performSelector:@selector(showNextPost)];
    }
}

@end
