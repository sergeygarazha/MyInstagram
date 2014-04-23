//
//  MIAppDelegate.h
//  MyInstagram
//
//  Created by Sergey Garazha on 26/03/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MIStartWindowController;
@class MIAuthWindowController;

@interface MIAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSWindowController *currentWindowController;

- (IBAction)saveAction:(id)sender;
- (void)showMainWindow;
- (IBAction)logout:(id)sender;

@end
