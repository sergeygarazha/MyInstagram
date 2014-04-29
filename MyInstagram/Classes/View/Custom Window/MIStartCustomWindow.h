//
//  MICustomWindow.h
//  MyInstagram
//
//  Created by Sergey Garazha on 18/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "INAppStoreWindow.h"

@class MICollectionView;

@interface MIStartCustomWindow : INAppStoreWindow

@property (weak) IBOutlet NSButton *getNextPage;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *getFeed;
@property (weak) IBOutlet MICollectionView *collectionView;

@end
