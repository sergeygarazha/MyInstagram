//
//  NSImageView+AFNetworking.m
//  MyInstagram
//
//  Created by Sergey Garazha on 16/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "NSImageView+AFNetworking.h"
#import <AFNetworking/AFImageRequestOperation.h>

#import "MIImage.h"

@implementation NSImageView (AFNetworking)

AFImageRequestOperation *currentOperation = nil;


- (void)setImageFromURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    
    if (self.image && [currentOperation isExecuting]) {
        [currentOperation cancel];
    }
    
    currentOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(NSImage *image) {
        self.image = image;
        [self.image setSize:self.frame.size];
    }];
    [currentOperation start];
}

- (void)setImageFromURL:(NSURL *)url withThumbnailURL:(NSURL *)thumbnail {
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

@end
