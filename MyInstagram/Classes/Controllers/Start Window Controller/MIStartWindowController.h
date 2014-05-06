//
//  MIStartWindowController.h
//  MyInstagram
//
//  Created by Sergey Garazha on 26/03/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MIScrollView.h"
#import "MIDetailsWindowController.h"

@class MICollectionView;

@interface MIStartWindowController : NSWindowController <NSWindowDelegate, MIDetailsWindowControllerDelegate>

@property (weak) IBOutlet MICollectionView *collectionView;
@property (weak) IBOutlet NSView *tapView;
@property (strong) IBOutlet NSButton *updateButton;
@property BOOL loadingInProgress;

- (IBAction)getFeed:(id)sender;
- (IBAction)getNextPage:(id)sender;

@end
