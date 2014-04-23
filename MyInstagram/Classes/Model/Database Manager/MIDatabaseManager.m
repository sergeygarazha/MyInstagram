//
//  MIDatabaseManager.m
//  MyInstagram
//
//  Created by Sergey Garazha on 27/03/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIDatabaseManager.h"
#import <RKManagedObjectStore.h>
#import <RKPathUtilities.h>
#import <RKLog.h>

@implementation MIDatabaseManager

@synthesize persistentStore, managedObjectStore, managedObjectModel;

+ (MIDatabaseManager *)sharedInstance {
	static dispatch_once_t pred;
	static MIDatabaseManager *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[MIDatabaseManager alloc] init]; });
	return sharedInstance;
}

- (id)init {
	self = [super init];
	if (self) {
        [self persistentStore];
	}
	return self;
}

#pragma mark - Properties initialization
// вызываем при первичной инициализации
- (NSPersistentStore *)persistentStore {
    if (!persistentStore) {
        NSError *error = nil;
        BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
        if (!success) {
            RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
        }
        NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Store.sqlite"];
        persistentStore = [self.managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
        if (!persistentStore) {
            RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
        }
        [self.managedObjectStore createManagedObjectContexts];
    }
    
	return persistentStore;
}
//==>
- (RKManagedObjectStore *)managedObjectStore {
    if (!managedObjectStore) {
        managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
    }
    
	return managedObjectStore;
}
//==>
- (NSManagedObjectModel *)managedObjectModel {
    if (!managedObjectModel) {
        managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    
	return managedObjectModel;
}

#pragma mark - Methods

- (NSArray *)extractFeedFromDatabase {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
	NSArray *matches = [self.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:nil];
    
	return matches;
}

- (void)deleteOldEntries {
    for (NSManagedObject *object in [self extractFeedFromDatabase]) {
        [self.managedObjectStore.mainQueueManagedObjectContext deleteObject:object];
    }
    NSError *error = nil;
    [self.managedObjectStore.mainQueueManagedObjectContext save:&error];
    if (error) {
        NSLog(@"Failed to save context: %@", error.userInfo);
    }
}

@end
