//
//  MICollectionView.m
//  MyInstagram
//
//  Created by Sergey Garazha on 16/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MICollectionView.h"
#import "Post.h"
#import "NSImageView+AFNetworking.h"
#import <AFNetworking/AFImageRequestOperation.h>

@interface MICollectionView ()
{
    BOOL firstStart;
}

@end

@implementation MICollectionView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    firstStart = YES;
}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object {
    NSCollectionViewItem *item = [super newItemForRepresentedObject:object];
    
    // ячейка для картинки
    if ([object isKindOfClass:[Post class]]) {
        [item.imageView setImageFromURL:[NSURL URLWithString:[(Post *)object thumbnail]]];
    }
    
    // ячейка для анимации загрузки
    if ([object isKindOfClass:[NSProgressIndicator class]]) {
        [item.view addSubview:object];
        [object setFrame:item.view.frame];
        [object startAnimation:self];
    }
    
    return item;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    if (firstStart) {
        [self adjustItemsSize];
        firstStart = NO;
    }
}

- (void)adjustItemsSize {
    float collectionViewWidth = self.superview.frame.size.width;
    
    int count = (int)(collectionViewWidth/100.0);
    float dif = collectionViewWidth - count*100.0;
    float width = 100.0 + dif/count - 1;
    
    [self setMinItemSize:CGSizeMake(width, width)];
    [self setMaxItemSize:CGSizeMake(width, width)];
}

@end
