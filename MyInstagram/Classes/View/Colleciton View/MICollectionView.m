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

@implementation MICollectionView

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

@end
