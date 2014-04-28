//
//  MITranslucentButton.m
//  MyInstagram
//
//  Created by Sergey Garazha on 28/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MITranslucentButton.h"

@implementation MITranslucentButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) drawRect:(NSRect)dirtyRect
{
    [self setBordered:NO];
    
    //REMED since it has same effect as NSRectFill below
    //[[self cell] setBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.2]];
    
    NSColor* backgroundColor = [NSColor colorWithCalibratedRed:0.000 green:0.514 blue:0.735 alpha:0.250];
    [backgroundColor setFill];
//    NSRectFill(dirtyRect);
    NSRectFillUsingOperation(dirtyRect, NSCompositeSourceAtop);
    
    [super drawRect:dirtyRect];
}

@end
