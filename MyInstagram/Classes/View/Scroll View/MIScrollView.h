//
//  MIScrollView.h
//  MyInstagram
//
//  Created by Sergey Garazha on 18/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RFOverlayScrollView.h"

@protocol MIScrollViewDelegate

- (void)didScrollToEnd;

@end

@interface MIScrollView : RFOverlayScrollView

@property (assign) id delegate;

@end
