//
//  MIDetailsCustomWindow.h
//  MyInstagram
//
//  Created by Sergey Garazha on 28/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MITranslucentButton;

@interface MIDetailsCustomWindow : NSWindow

@property (weak) IBOutlet MITranslucentButton *leftTransitionView;
@property (weak) IBOutlet MITranslucentButton *rightTransitionView;
@property (weak) IBOutlet NSView *bottomView;
@property (weak) IBOutlet NSImageView *imageView;

@end
