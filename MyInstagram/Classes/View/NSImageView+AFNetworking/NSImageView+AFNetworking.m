//
//  NSImageView+AFNetworking.m
//  MyInstagram
//
//  Created by Sergey Garazha on 16/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "NSImageView+AFNetworking.h"
#import <AFNetworking/AFImageRequestOperation.h>

@implementation NSImageView (AFNetworking)

- (void)setImageFromURL:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(NSImage *image) {
        self.image = image;
        
        [self.image setSize:self.frame.size];
    }];
    [operation start];
}

- (void)setImageFromURL:(NSURL *)url withThumbnail:(NSURL *)thumbnail {
    [self setImageFromURL:thumbnail];
    [self setImageFromURL:url];
}

@end
