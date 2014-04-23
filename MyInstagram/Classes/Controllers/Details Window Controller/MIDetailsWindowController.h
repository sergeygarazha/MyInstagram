//
//  MIDetailsWindowController.h
//  MyInstagram
//
//  Created by Sergey Garazha on 17/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Post;

@interface MIDetailsWindowController : NSWindowController <NSWindowDelegate>

@property (weak) IBOutlet NSImageView *image;
@property (strong) Post *post;

- (instancetype)initWithPost:(Post *)post_;
- (void)updateWithPost:(Post *)post;

@end
