//
//  MIScrollView.m
//  MyInstagram
//
//  Created by Sergey Garazha on 18/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIScrollView.h"

@implementation MIScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)reflectScrolledClipView:(NSClipView *)cView {
    [super reflectScrolledClipView:cView];
    
    CGRect rect = [self documentVisibleRect];
    
    NSCollectionView *cv = (NSCollectionView *)self.documentView;
    CGRect ds = cv.frame;
    
    if (ds.size.height == rect.origin.y+rect.size.height) {
        if ([self.delegate respondsToSelector:@selector(didScrollToEnd)]) {
            [self.delegate didScrollToEnd];
        }
    }
}

@end
