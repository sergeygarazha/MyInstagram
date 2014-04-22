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

AFImageRequestOperation *currentOperation = nil;
ITProgressIndicator *progressIndicator;

- (void)setImageFromURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    
    if (self.image && [currentOperation isExecuting]) {
        [currentOperation cancel];
    }
    
    currentOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(NSImage *image) {
        self.image = image;
        [self.image setSize:CGSizeMake(200.0, 200.0)];
        [progressIndicator removeFromSuperview];
        progressIndicator = nil;
    }];
    [currentOperation start];
}

- (void)setImageFromURL:(NSURL *)url withThumbnailURL:(NSURL *)thumbnail {
    [self showProgressIndicator];
    NSURLRequest *request = [NSURLRequest requestWithURL:thumbnail];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                      success:^(NSImage *image) {
                                                          [self setImageFromURL:url withThumbnail:image];
                                                      }];
    [operation start];
}

- (void)setImageFromURL:(NSURL *)url withThumbnail:(NSImage *)image {
    self.image = image;
    [self setImageFromURL:url];
}

- (void)showProgressIndicator {
    [progressIndicator removeFromSuperview];
    progressIndicator = nil;
    progressIndicator = [[ITProgressIndicator alloc] initWithFrame:self.frame];
    progressIndicator.color = [NSColor colorWithCalibratedRed:36.0/256.0 green:98.0/256.0 blue:131.0/256.0 alpha:0.1];
    progressIndicator.widthOfLine = 5.0;
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

@end
