//
//  MIDetailsView.m
//  MyInstagram
//
//  Created by Sergey Garazha on 26/05/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIDetailsView.h"

@implementation MIDetailsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self configure];
    }
    return self;
}

- (void)configure
{
    self.imageView = [[NSImageView alloc] initWithFrame:self.frame];
//    [self.imageView setImage:[NSImage imageNamed:@"Reload1.png"]];
    [self.imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
    
    self.imageView.wantsLayer = YES;
    self.imageView.layer.masksToBounds = YES;
    [self.imageView.layer setCornerRadius:25.0];

    [self addSubview:self.imageView];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
