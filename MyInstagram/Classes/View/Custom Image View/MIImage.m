//
//  MIImage.m
//  MyInstagram
//
//  Created by Sergey Garazha on 4/20/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIImage.h"

@implementation MIImage

- (NSImageRep *)bestRepresentationForRect:(NSRect)rect context:(NSGraphicsContext *)referenceContext hints:(NSDictionary *)hints {
    NSImageRep *representation = [[NSImageRep alloc] init];
    float width = rect.size.width > rect.size.height ? rect.size.width : rect.size.height;
    [representation setSize:CGSizeMake(width, width)];
    return representation;
}

@end
