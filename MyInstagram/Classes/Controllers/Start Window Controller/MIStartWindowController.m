//
//  MIStartWindowController.m
//  MyInstagram
//
//  Created by Sergey Garazha on 26/03/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIStartWindowController.h"
#import "MINetworkManager.h"
#import "MICollectionView.h"
#import "MIDatabaseManager.h"
#import "Post.h"
#import "INAppStoreWindow.h"
#import "NSImageView+AFNetworking.h"
#import "RKObjectManager.h"
#import "MIDetailsCustomWindow.h"
#import "MIStartCustomWindow.h"
#import "MITranslucentButton.h"

#import "MIDetailsView.h"
#import "MAAttachedWindow.h"

@interface MIStartWindowController () {
    MIDetailsWindowController *detailsWindowController;
    NSArrayController *arrayController;
    NSTimer *timer;
}

@property (nonatomic) MAAttachedWindow *detailsWindow;

@end

@implementation MIStartWindowController

- (instancetype)init {
	self = [super initWithWindowNibName:@"MIStartWindowController"];
	if (self) {
        self.loadingInProgress = NO;
        
        arrayController = [[NSArrayController alloc] initWithContent:[NSArray array]];
	}
	return self;
}

- (void)dealloc {
	[self.collectionView removeObserver:self
                             forKeyPath:@"selectionIndexes"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Window controller lifecycle

- (void)loadWindow {
	[super loadWindow];
    
    // extracting cache from DB
    [arrayController setContent:[[MIDatabaseManager sharedInstance] extractFeedFromDatabase]];
    
    // reconneciton
//    [self getFeed:self];
    
    // selection handling
    [self.collectionView bind:NSContentBinding toObject:arrayController withKeyPath:@"arrangedObjects" options:nil];
	[self.collectionView addObserver:self forKeyPath:@"selectionIndexes"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
    
    // window apperience configuration
    INAppStoreWindow *window = (INAppStoreWindow *)self.window;
    window.delegate = self;
    
    // scroll view
    NSScrollView *scrollView = (NSScrollView *)self.collectionView.superview.superview;
    scrollView.backgroundColor = [NSColor clearColor];
    [(MIScrollView *)scrollView setDelegate:self];
}

- (void)close:(id)sender {
    [detailsWindowController.window close];
    detailsWindowController.windowIsLoaded = NO;
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    
    if (detailsWindowController.windowIsLoaded) {
        [detailsWindowController showWindow:self];
    }
}

- (void)windowWillMiniaturize:(NSNotification *)notification {
    if ([[detailsWindowController window] isVisible]) {
        [detailsWindowController close];
    } else {
        detailsWindowController = nil;
    }
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
	if ([[self.collectionView selectionIndexes] count] > 0) {
        NSUInteger index = [[self.collectionView selectionIndexes] lastIndex];
////        NSCollectionViewItem *item = [self.collectionView itemAtIndex:index];
        Post *selectedPost = arrayController.content[index];
//
//        //!!: resetting indexes
//        [self.collectionView setSelectionIndexes:[NSIndexSet indexSet]];
//        
////        // check if there is existen window with such post
////        if (detailsWindowController && detailsWindowController.post == selectedPost) {
////            if (![detailsWindowController.window isVisible]) {
////                [detailsWindowController showWindow:self];
////                [detailsWindowController.window becomeKeyWindow];
////            }
////            return;
////        }
////        
////        if (!item.imageView.image) {
////            [item.imageView setImageFromURL:[NSURL URLWithString:selectedPost.thumbnail]];
////        }
////        
////        if ([detailsWindowController.window isVisible]) {
////            [detailsWindowController updateWithPost:selectedPost];
////        } else {
//            // creating new details window
//            detailsWindowController = [[MIDetailsWindowController alloc] initWithPost:selectedPost];
//            detailsWindowController.delegate = self;
//
//            // loading saved from old session frame for window
////            NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"detailsWindow"];
////            if (str) {
////                [detailsWindowController.window setFrame:NSRectFromString(str) display:YES animate:NO];
////            }
////            [detailsWindowController showWindow:self];

        
        
        
			[self.window removeChildWindow:self.detailsWindow];
			self.detailsWindow = nil;

			NSRect rect = [self.collectionView frameForItemAtIndex:index];
			NSPoint point = rect.origin;

			point.y = self.window.frame.origin.y + self.window.frame.size.height - point.y - rect.size.height - 10.0;
			point.x += self.window.frame.origin.x + rect.size.width + 15.0;

			MIDetailsView *detailsView = [[MIDetailsView alloc] initWithFrame:CGRectMake(0.0, 0.0, 500.0, 500.0)];
			self.detailsWindow = [[MAAttachedWindow alloc] initWithView:detailsView attachedToPoint:point onSide:MAPositionAutomatic];
			[self.detailsWindow setViewMargin:10.0];
			[self.detailsWindow setCornerRadius:23.0];

			[detailsView.imageView setImageFromURL:[NSURL URLWithString:selectedPost.standard] withThumbnailURL:[NSURL URLWithString:selectedPost.thumbnail]];

			[[self window] addChildWindow:self.detailsWindow ordered:NSWindowAbove];
        
        
        
        
        
        
//            detailsWindowController.attachingPoint = point;
//            
//            [[self window] addChildWindow:detailsWindowController.window ordered:NSWindowAbove];
//        }
//        
//        // indicators of the next and privious triggers visibility
//        NSUInteger currentIndex = [arrayController.content indexOfObject:detailsWindowController.post];
//        [(MIDetailsCustomWindow *)detailsWindowController.window setPreviousPageAvailable:!(currentIndex == 0)];
//        [(MIDetailsCustomWindow *)detailsWindowController.window setNextPageAvailable:YES];
//        [detailsWindowController.window makeKeyAndOrderFront:self];
//        [detailsWindowController.window setOrderedIndex:0];
	}
	else {
        
	}
}

#pragma mark - Initial feed receiving

- (IBAction)getFeed:(id)sender {
    [[MIDatabaseManager sharedInstance] deleteOldEntries];
    
    if (!self.loadingInProgress) {
        // UI behaviour
        [self.updateButton setEnabled:NO];
        [(MIStartCustomWindow *)self.window showProgressIndicator];
        self.loadingInProgress = YES;
        
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showCancelForGetFeed) userInfo:nil repeats:NO];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[MINetworkManager sharedInstance] getFeedAndExecute: ^(BOOL success, NSArray *resultArray) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        self.loadingInProgress = NO;
                        [arrayController setContent:resultArray];
                        [timer invalidate];
                        [self checkIfWeNeedToContinueLoading];
                    }
                    self.loadingInProgress = NO;
                    [self.updateButton setEnabled:YES];
                    [self.updateButton setHidden:YES];
                    [(MIStartCustomWindow *)self.window hideProgressIndicator];
                });
            }];
        });
    }
}

- (void)checkIfWeNeedToContinueLoading {
    // check if we need to load next page
    NSUInteger itemsCount = [self.collectionView.content count];
    if (itemsCount != 0) {
        int countOfItemsInRaw = (int)(self.collectionView.frame.size.width/self.collectionView.maxItemSize.width);
        int numberOfRaws = (int)itemsCount/countOfItemsInRaw;
        float contentHeight = self.collectionView.maxItemSize.height*numberOfRaws;
        if (self.collectionView.superview.frame.size.height > contentHeight) {
            [self getNextBatchOfPosts:self andExecute:nil];
        }
    }
}

- (void)showCancelForGetFeed {
    [self.updateButton setEnabled:YES];
    [self.updateButton setAction:@selector(cancelGetFeedOperation)];
    timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(cancelGetFeedOperation) userInfo:nil repeats:NO];
}

- (void)cancelGetFeedOperation {
    [timer invalidate];
    [self.updateButton setEnabled:YES];
    [self.updateButton setAction:@selector(getFeed:)];
    self.loadingInProgress = NO;
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:@""];
}

#pragma mark - Next Batch Receiving

- (IBAction)getNextBatchOfPosts:(id)sender andExecute:(completionBlock)block {
    if (!self.loadingInProgress && [[MINetworkManager sharedInstance] nextPageURL]) {
        self.loadingInProgress = YES;
        NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:CGRectZero];
        [indicator setStyle:NSProgressIndicatorSpinningStyle];
        NSMutableArray *ar = [NSMutableArray arrayWithArray:arrayController.content];
        [ar addObject:indicator];
        [arrayController setContent:[ar copy]];
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showCancelLable) userInfo:nil repeats:NO];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[MINetworkManager sharedInstance] getNextPageAndExecute:^(BOOL success, NSArray *resultArray) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (resultArray.count) {
                            NSMutableArray *ar = [NSMutableArray array];
                            [ar addObjectsFromArray:[arrayController content]];
                            [ar removeLastObject];
                            [ar addObjectsFromArray:resultArray];
                            [arrayController setContent:[ar copy]];
                            self.loadingInProgress = NO;
                            [timer invalidate];
                            
                            [self checkIfWeNeedToContinueLoading];
                        }
                    });
                } else {
                    [self cancelNextBatchReceiving];
                }
                
                if (block) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(success);
                    });
                }
            }];
        });
    }
}

- (void)showCancelLable {
    timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(cancelNextBatchReceiving) userInfo:nil repeats:NO];
}

- (void)cancelNextBatchReceiving {
    [timer invalidate];
    self.loadingInProgress = NO;
    NSMutableArray *ar = [NSMutableArray arrayWithArray:arrayController.content];
    [ar removeLastObject];
    [arrayController setContent:[ar copy]];
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:@""];
}

#pragma mark - MIDetailsWindowController Delegate

- (void)showPreviousPost
{
    NSUInteger currentIndex = [arrayController.content indexOfObject:detailsWindowController.post];
    
    BOOL condition = (currentIndex == 1);
    [(MIDetailsCustomWindow *)detailsWindowController.window setPreviousPageAvailable:!condition];
    if (condition) {
        [[(MIDetailsCustomWindow *)detailsWindowController.window leftTransitionView] setHidden:YES];
    }
    
    [detailsWindowController updateWithPost:arrayController.content[--currentIndex]];
    [(MIDetailsCustomWindow *)detailsWindowController.window setNextPageAvailable:YES];
}

- (void)showNextPost
{
    NSUInteger currentIndex = [arrayController.content indexOfObject:detailsWindowController.post];
    NSArray *ar = arrayController.arrangedObjects;
    NSUInteger count = [ar count];
    
    BOOL nextPostAvailable = (currentIndex+1 < count);
    [(MIDetailsCustomWindow *)detailsWindowController.window setPreviousPageAvailable:count>1];
    if (nextPostAvailable) {
        if ([[arrayController.content lastObject] isKindOfClass:[Post class]]) {
            [detailsWindowController updateWithPost:arrayController.content[currentIndex+1]];
        }
    } else {
        [self getNextBatchOfPosts:self andExecute:^(BOOL result) {
            if (result && [detailsWindowController windowIsLoaded]) {
                [detailsWindowController updateWithPost:arrayController.content[currentIndex+1]];
            }
        }];
    }
}

#pragma mark - Window resizing

- (void)windowDidEndLiveResize:(NSNotification *)notification
{
    [(MICollectionView *)self.collectionView adjustItemsSize];
}

- (void)didScrollToEnd {
    [self getNextBatchOfPosts:self andExecute:nil];
}

@end
