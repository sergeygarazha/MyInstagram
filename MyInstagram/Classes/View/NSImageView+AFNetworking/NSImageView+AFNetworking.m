//
//  NSImageView+AFNetworking.m
//  MyInstagram
//
//  Created by Sergey Garazha on 16/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "NSImageView+AFNetworking.h"
#import <AFNetworking/AFImageRequestOperation.h>
#import "ITProgressIndicator.h"

#import "MIImage.h"

@implementation NSImageView (AFNetworking)

#pragma mark - Ivars
AFImageRequestOperation *currentOperation = nil;
ITProgressIndicator *progressIndicator;
BOOL showIndicator;
NSTimer *timer;

#pragma mark - Publick methods

- (void)setImageFromURL:(NSURL *)url withThumbnailURL:(NSURL *)thumbnail {
    if (self.image && [currentOperation isExecuting]) {
        [currentOperation cancel];
    }
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showProgressIndicator) userInfo:nil repeats:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:thumbnail];
    currentOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                         success:^(NSImage *image) {
                                                                             [self setImageFromURL:url withThumbnail:image];
                                                                         }];
    [currentOperation start];
}

- (void)setImageFromURL:(NSURL *)url withThumbnail:(NSImage *)image {
    self.image = image;
    [self setImageFromURL:url];
}

- (void)setImageFromURL:(NSURL *)url {
    if (self.image && [currentOperation isExecuting]) {
        [currentOperation cancel];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    currentOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(NSImage *image) {
        self.image = image;
        [self.image setSize:CGSizeMake(200.0, 200.0)];
        [progressIndicator removeFromSuperview];
        progressIndicator = nil;
        [timer invalidate];
    }];
    [currentOperation start];
}

#pragma mark - Progress Indicator handling

- (void)showProgressIndicator {
    [progressIndicator removeFromSuperview];
    progressIndicator = nil;
    progressIndicator = [[ITProgressIndicator alloc] initWithFrame:self.frame];
    progressIndicator.color = [NSColor colorWithCalibratedRed:36.0/256.0 green:98.0/256.0 blue:131.0/256.0 alpha:1.0];
    [progressIndicator setAlphaValue:0.5];
    progressIndicator.widthOfLine = 20.0;
    progressIndicator.innerMargin = 30.0;
    progressIndicator.animationDuration = 1.0;
    progressIndicator.numberOfLines = 8;
    progressIndicator.steppedAnimation = NO;
    [self addSubview:progressIndicator];
    
    [progressIndicator setLengthOfLine:self.frame.size.width/3.0];
    [progressIndicator setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    if (progressIndicator) {
        [self showProgressIndicator];
    }
}

- (void)dealloc {
    [timer invalidate];
}

@end
