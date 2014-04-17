//
//  NSImageView+AFNetworking.h
//  MyInstagram
//
//  Created by Sergey Garazha on 16/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImageView (AFNetworking)

- (void)setImageFromURL:(NSURL *)url;
- (void)setImageFromURL:(NSURL *)url withThumbnail:(NSURL *)thumbnail;

@end
