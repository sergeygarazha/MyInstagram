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

@interface MIStartWindowController () {
	NSArray *feed;
    MIDetailsWindowController *detailsWindowController;
    CGPoint windowOrigin;
    NSArrayController *arrayController;
    BOOL loadingInProgress;
    NSTimer *timer;
}

@end

@implementation MIStartWindowController

- (instancetype)init {
	self = [super initWithWindowNibName:@"MIStartWindowController"];
	if (self) {
		feed = [NSArray array];
        loadingInProgress = NO;
        windowOrigin = CGPointMake(100000.0, 100000.0);
        
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
//    [arrayController setContent:[[MIDatabaseManager sharedInstance] extractFeedFromDatabase]];
    
    // reconneciton
    [self getFeed:self];
    
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
    detailsWindowController = nil;
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    
    if (detailsWindowController) {
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
        NSCollectionViewItem *item = [self.collectionView itemAtIndex:index];
        Post *selectedPost = arrayController.content[index];
        
        //!!: обнуляем индексы
        [self.collectionView setSelectionIndexes:[NSIndexSet indexSet]];
        
        // проверяем, нету ли уже готового окна с таким постом
        if (detailsWindowController && detailsWindowController.post == selectedPost) {
            if (![detailsWindowController.window isVisible]) {
                [detailsWindowController showWindow:self];
                [detailsWindowController.window becomeKeyWindow];
            }
            return;
        }
        
        if (!item.imageView.image) {
            [item.imageView setImageFromURL:[NSURL URLWithString:selectedPost.thumbnail]];
        }
        
        if ([detailsWindowController.window isVisible]) {
            [detailsWindowController updateWithPost:selectedPost];
        } else {
            detailsWindowController = [[MIDetailsWindowController alloc] initWithPost:selectedPost];
            detailsWindowController.delegate = self;
            // indicators of the next and privious triggers visibility
            NSUInteger currentIndex = [arrayController.content indexOfObject:detailsWindowController.post];
            NSArray *ar = arrayController.arrangedObjects;
            NSUInteger count = [ar count];
            [(MIDetailsCustomWindow *)detailsWindowController.window setNextPageAvailable:!(currentIndex+1 == count)];
            [(MIDetailsCustomWindow *)detailsWindowController.window setPreviousPageAvailable:!(currentIndex-1 == 0)];
            
            NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"detailsWindow"];
            if (str) {
                [detailsWindowController.window setFrame:NSRectFromString(str) display:YES animate:NO];
            }
            [detailsWindowController showWindow:self];
        }
        [detailsWindowController.window makeKeyAndOrderFront:self];
        [detailsWindowController.window setOrderedIndex:0];
	}
	else {
        // ничего не выбрано
//		NSLog(@"Observer called but no objects where selected.");
	}
}

#pragma mark - Initial feed receiving

- (IBAction)getFeed:(id)sender {
    [[MIDatabaseManager sharedInstance] deleteOldEntries];
    
    if (!loadingInProgress) {
        [self.progressBar setHidden:NO];
        [self.progressBar startAnimation:self];
        [self.getFeedButton setEnabled:NO];
        loadingInProgress = YES;
        
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showCancelForGetFeed) userInfo:nil repeats:NO];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[MINetworkManager sharedInstance] getFeedAndExecute: ^(BOOL success, NSArray *resultArray) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        loadingInProgress = NO;
                        [arrayController setContent:resultArray];
                        [self.progressBar setHidden:YES];
                        [self.check setHidden:NO];
                        [timer invalidate];
                        
                        [self checkIfWeNeedToContinueLoading];
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    loadingInProgress = NO;
                    [self.progressBar stopAnimation:self];
                    [self.getFeedButton setEnabled:YES];
                });
            }];
        });
    }
}

- (void)checkIfWeNeedToContinueLoading {
    // проверяем, не нужно ли загрузить следующую страницу
    NSUInteger itemsCount = [self.collectionView.content count];
    if (itemsCount != 0) {
        int countOfItemsInRaw = (int)(self.collectionView.frame.size.width/self.collectionView.maxItemSize.width);
        int numberOfRaws = (int)itemsCount/countOfItemsInRaw;
        float contentHeight = self.collectionView.maxItemSize.height*numberOfRaws;
        if (self.collectionView.superview.frame.size.height > contentHeight) {
            [self getNextPage:self];
        }
    }
}

- (void)showCancelForGetFeed {
    [self.getFeedButton setEnabled:YES];
    [self.getFeedButton setTitle:@"Cancel"];
    [self.getFeedButton setAction:@selector(cancelGetFeedOperation)];
    timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(cancelGetFeedOperation) userInfo:nil repeats:NO];
}

- (void)cancelGetFeedOperation {
    [timer invalidate];
    [self.progressBar stopAnimation:self];
    [self.getFeedButton setEnabled:YES];
    [self.getFeedButton setTitle:@"Get feed"];
    [self.getFeedButton setAction:@selector(getFeed:)];
    loadingInProgress = NO;
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:@""];
}

#pragma mark - Next Page Receiving

// load next page
- (IBAction)getNextPage:(id)sender {
    if (!loadingInProgress && [[MINetworkManager sharedInstance] nextPageURL]) {
        loadingInProgress = YES;
        NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:CGRectZero];
        [indicator setStyle:NSProgressIndicatorSpinningStyle];
        NSMutableArray *ar = [NSMutableArray arrayWithArray:arrayController.content];
        [ar addObject:indicator];
        [arrayController setContent:[ar copy]];
        [self.check setEnabled:NO];
        [self.check setTitle:@"Cancel"];
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showCancelLable) userInfo:nil repeats:NO];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[MINetworkManager sharedInstance] getNextPageAndExecute:^(BOOL success, NSArray *resultArray) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (resultArray.count) {
                            NSMutableArray *ar = [NSMutableArray array];
                            [ar addObjectsFromArray:[arrayController content]];
                            [ar removeLastObject];
                            [ar addObjectsFromArray:resultArray];
                            [arrayController setContent:[ar copy]];
                            loadingInProgress = NO;
                            [self.check setEnabled:YES];
                            [self.check setTitle:@"Get next page"];
                            [timer invalidate];
                            
                            [self checkIfWeNeedToContinueLoading];
                        }
                    });
                } else {
                    [self cancelNextPageReceiving];
                    if (resultArray) {
                        [self.check setEnabled:NO];
                    }
                }
                
            }];
        });
    }
}

- (void)showCancelLable {
    [self.check setEnabled:YES];
    [self.check setTitle:@"Cancel"];
    [self.check setAction:@selector(cancelNextPageReceiving)];
    timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(cancelNextPageReceiving) userInfo:nil repeats:NO];
}

- (void)cancelNextPageReceiving {
    [timer invalidate];
    [self.check setEnabled:YES];
    [self.check setTitle:@"Get next page"];
    [self.check setAction:@selector(getNextPage:)];
    loadingInProgress = NO;
    NSMutableArray *ar = [NSMutableArray arrayWithArray:arrayController.content];
    [ar removeLastObject];
    [arrayController setContent:[ar copy]];
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:@""];
}

#pragma mark - MIDetailsWindowController Delegate

- (void)showPreviousPost
{
    NSUInteger currentIndex = [arrayController.content indexOfObject:detailsWindowController.post];
    if (currentIndex > 0) {
        [detailsWindowController updateWithPost:arrayController.content[--currentIndex]];
        // indicators of the next and privious triggers visibility
        [(MIDetailsCustomWindow *)detailsWindowController.window setNextPageAvailable:YES];
        [(MIDetailsCustomWindow *)detailsWindowController.window setPreviousPageAvailable:!(currentIndex-1 == 0)];
    }
}

- (void)showNextPost
{
    NSUInteger currentIndex = [arrayController.content indexOfObject:detailsWindowController.post];
    NSArray *ar = arrayController.arrangedObjects;
    NSUInteger count = [ar count];
    if (count > ++currentIndex) {
        [detailsWindowController updateWithPost:arrayController.content[currentIndex]];
        // indicators of the next and privious triggers visibility
        [(MIDetailsCustomWindow *)detailsWindowController.window setNextPageAvailable:!(currentIndex+1 == count)];
        [(MIDetailsCustomWindow *)detailsWindowController.window setPreviousPageAvailable:YES];
    }
}

#pragma mark - Window resizing

- (void)windowDidEndLiveResize:(NSNotification *)notification
{
    float collectionViewWidth = self.collectionView.superview.frame.size.width;
    
    int count = (int)(collectionViewWidth/100.0);
    float dif = collectionViewWidth - count*100.0;
    float width = 100.0 + dif/count - 1;
    
    [self.collectionView setMinItemSize:CGSizeMake(width, width)];
    [self.collectionView setMaxItemSize:CGSizeMake(width, width)];
}

- (void)didScrollToEnd {
    [self getNextPage:self];
}

@end
