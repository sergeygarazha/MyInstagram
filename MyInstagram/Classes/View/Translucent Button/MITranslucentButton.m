//
//  MITranslucentButton.m
//  MyInstagram
//
//  Created by Sergey Garazha on 28/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MITranslucentButton.h"

@implementation MITranslucentButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.color = [NSColor colorWithCalibratedRed:0.000 green:0.514 blue:0.735 alpha:0.250];
}

- (void) drawRect:(NSRect)dirtyRect
{
    [self setBordered:NO];
    [self.color setFill];
    NSRectFillUsingOperation(dirtyRect, NSCompositeSourceAtop);
    [super drawRect:dirtyRect];
}

@end
