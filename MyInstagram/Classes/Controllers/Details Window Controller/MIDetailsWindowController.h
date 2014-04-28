//
//  MIDetailsWindowController.h
//  MyInstagram
//
//  Created by Sergey Garazha on 17/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Post;

@protocol MIDetailsWindowControllerDelegate <NSObject>

@required
- (void)showNextPost;
- (void)showPreviousPost;

@end

@interface MIDetailsWindowController : NSWindowController <NSWindowDelegate>

@property (strong) Post *post;
@property (weak) id<MIDetailsWindowControllerDelegate> delegate;

- (instancetype)initWithPost:(Post *)post_;
- (void)updateWithPost:(Post *)post;
- (IBAction)transitionLeft:(id)sender;
- (IBAction)transitionRight:(id)sender;

@end