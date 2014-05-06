//
//  MIButtonCell.m
//  MyInstagram
//
//  Created by Sergey Garazha on 06/05/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIButtonCell.h"

@implementation MIButtonCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    
////    [self setBackgroundColor:[NSColor clearColor]];
//    
//    
//}
//
- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//    if (flag) {
        controlView.layer.backgroundColor = (__bridge CGColorRef)([NSColor clearColor]);
//    }
}

@end
