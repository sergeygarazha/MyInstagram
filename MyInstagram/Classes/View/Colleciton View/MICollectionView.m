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
    if ([object isKindOfClass:[Post class]]) {
        [item.imageView setImageFromURL:[NSURL URLWithString:[(Post *)object thumbnail]]];
    }
    return item;
}

@end
