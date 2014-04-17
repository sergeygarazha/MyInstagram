//
//  MIDatabaseManager.h
//  MyInstagram
//
//  Created by Sergey Garazha on 27/03/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKManagedObjectStore;
@class NSManagedObjectModel;
@class NSPersistentStore;

@interface MIDatabaseManager : NSObject

@property (nonatomic, strong) NSPersistentStore *persistentStore;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) RKManagedObjectStore *managedObjectStore;

+ (MIDatabaseManager *)sharedInstance;
- (NSArray *)extractFeedFromDatabase;
- (void)deleteOldEntries;

@end
