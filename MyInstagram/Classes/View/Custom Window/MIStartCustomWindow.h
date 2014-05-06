//
//  MICustomWindow.h
//  MyInstagram
//
//  Created by Sergey Garazha on 18/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "INAppStoreWindow.h"

@class MICollectionView;
@class MITranslucentButton;

@interface MIStartCustomWindow : INAppStoreWindow

@property (weak) IBOutlet MICollectionView *collectionView;
@property (weak) IBOutlet MITranslucentButton *updateButton;

- (void)showProgressIndicator;
- (void)hideProgressIndicator;

@end