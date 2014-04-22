//
//  MICustomWindow.m
//  MyInstagram
//
//  Created by Sergey Garazha on 18/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MICustomWindow.h"

@implementation MICustomWindow

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)close {
    [self.windowController close:self];
    
    [super close];
}

@end
