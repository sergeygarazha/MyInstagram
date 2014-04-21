//
//  MIStartWindowController.h
//  MyInstagram
//
//  Created by Sergey Garazha on 26/03/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MIScrollView.h"

@class MICollectionView;

@interface MIStartWindowController : NSWindowController <NSWindowDelegate>

@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSButton *reconnectButton;
@property (weak) IBOutlet NSButton *getFeedButton;
@property (weak) IBOutlet MICollectionView *collectionView;
@property (weak) IBOutlet NSView *tapView;
@property (weak) IBOutlet NSButton *check;

- (IBAction)reconnect:(id)sender;
- (IBAction)getFeed:(id)sender;
- (IBAction)check:(id)sender;

@end
