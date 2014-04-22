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
#import "MIDetailsWindowController.h"
#import "Post.h"
#import "INAppStoreWindow.h"
#import "NSImageView+AFNetworking.h"
#import "RKObjectManager.h"

@interface MIStartWindowController () {
	NSArray *feed;
    MIDetailsWindowController *detailsWindowController;
    CGPoint windowOrigin;
    NSImageView *titleImage;
    NSArrayController *arrayController;
    BOOL loadingInProgress;
    NSTimer *timer;
    BOOL alignment;
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
        
        titleImage = [[NSImageView alloc] initWithFrame:CGRectMake(500.0, 0.0, 50.0, 70.0)];
        [titleImage setImage:[NSImage imageNamed:@"Instagram.png"]];
        [[(INAppStoreWindow *)self.window titleBarView] addSubview:titleImage];
	}
	return self;
}

- (void)dealloc {
	[arrayController removeObserver:self
	                     forKeyPath:@"selectedObjects"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Window controller lifecycle

- (void)windowWillLoad {
	[super windowWillLoad];
}

- (void)loadWindow {
	[super loadWindow];
    
    [self.check setHidden:YES];
    
    // extracting cache from DB
    [arrayController setContent:[[MIDatabaseManager sharedInstance] extractFeedFromDatabase]];
    
    // reconneciton
//    [self getFeed:self];
    
    NSScrollView *scrollView = (NSScrollView *)self.collectionView.superview.superview;
    scrollView.backgroundColor = [NSColor clearColor];
    [(MIScrollView *)scrollView setDelegate:self];
    
    // scrolling notification turning ON
//    [[self.collectionView superview] setPostsBoundsChangedNotifications:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(check:)
//                                                 name:NSViewBoundsDidChangeNotification object:[self.collectionView superview]];
    
    // selection handling
    [self.collectionView bind:NSContentBinding toObject:arrayController withKeyPath:@"arrangedObjects" options:nil];
	[self.collectionView addObserver:self forKeyPath:@"selectionIndexes"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
    
    // window apperience configuration
    INAppStoreWindow *window = (INAppStoreWindow *)self.window;
    window.delegate = self;
    window.titleBarHeight = 50.0f;
    
    window.titleBarDrawingBlock = ^(BOOL drawsAsMainWindow, CGRect drawingRect, CGPathRef clippingPath) {
		CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextAddPath(ctx, clippingPath);
		CGContextClip(ctx);
        
		NSGradient *gradient = nil;
		if (drawsAsMainWindow) {
			gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:36.0/256.0 green:98.0/256.0 blue:131.0/256.0 alpha:1.0]
													 endingColor:[NSColor colorWithCalibratedRed:71.0/256.0 green:129.0/256.0 blue:162.0/256.0 alpha:1.0]];
			[[NSColor darkGrayColor] setFill];
		} else {
			// set the default non-main window gradient colors
			gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.851f alpha:1]
													 endingColor:[NSColor colorWithCalibratedWhite:0.929f alpha:1]];
			[[NSColor colorWithCalibratedWhite:0.6f alpha:1] setFill];
		}
		[gradient drawInRect:drawingRect angle:90];
		NSRectFill(NSMakeRect(NSMinX(drawingRect), NSMinY(drawingRect), NSWidth(drawingRect), 1));
	};
    
    // title bar image positioning
    [self windowWillResize:self.window toSize:self.window.frame.size];
    // collection view items sizing
    [self windowDidEndLiveResize:nil];
    [self.collectionView setNeedsDisplay:YES];
}

- (void)close:(id)sender {
    [detailsWindowController.window close];
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

#pragma mark - Methods

- (IBAction)reconnect:(id)sender {
//	NSLog(@"Token request started");
//	[self.progressBar startAnimation:self];
//	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//	    BOOL result = [[MINetworkManager sharedInstance] performInstagramAuthorization];
//	    dispatch_async(dispatch_get_main_queue(), ^{
//	        if (result) {   //success
//	            NSLog(@"Token received");
//	            [self.progressBar setHidden:YES];
//	            [self.reconnectButton setHidden:YES];
//	            [self.getFeedButton setHidden:NO];
//			}
//	        else {          // failure
//	            NSLog(@"Failed to receive token");
//	            [self.reconnectButton setEnabled:YES];
//	            [self.reconnectButton setTitle:@"Retry to connect"];
//	            [self.reconnectButton sizeToFit];
//			}
//	        [self.progressBar stopAnimation:self];
//		});
//	});
    
    alignment = !alignment;
    if (alignment) {
        [self.collectionView setMinItemSize:CGSizeMake(100.0, 100.0)];
        [self.collectionView setMaxItemSize:CGSizeMake(200.0, 200.0)];
    } else {
        [self windowDidEndLiveResize:nil];
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
                        [arrayController setContent:resultArray];
                        [self.progressBar setHidden:YES];
                        [self.check setHidden:NO];
                        [timer invalidate];
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
- (IBAction)check:(id)sender {
    if (!loadingInProgress) {
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
    [self.check setAction:@selector(check:)];
    loadingInProgress = NO;
    NSMutableArray *ar = [NSMutableArray arrayWithArray:arrayController.content];
    [ar removeLastObject];
    [arrayController setContent:[ar copy]];
    [[RKObjectManager sharedManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny matchingPathPattern:@""];
}

#pragma mark - Window resizing

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    // положение изображения заголовка
    INAppStoreWindow *window = (INAppStoreWindow *)self.window;
    float height = 55.0;
    float width = 80.0;
    [titleImage setFrame:CGRectMake(frameSize.width/2.0-width/2.0, window.titleBarView.frame.size.height-height, width, height)];

    return frameSize;
}

- (void)windowDidEndLiveResize:(NSNotification *)notification {
    if (!alignment) {
        float collectionViewWidth = self.collectionView.superview.frame.size.width;
        
        int count = (int)(collectionViewWidth/100.0);
        float dif = collectionViewWidth - count*100.0;
        float width = 100.0 + dif/count - 1;
        
        [self.collectionView setMinItemSize:CGSizeMake(width, width)];
        [self.collectionView setMaxItemSize:CGSizeMake(width, width)];
    }
}

#pragma mark - Mouse handling

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint locationInView = [self.tapView convertPoint:[theEvent locationInWindow]
                                         fromView:[[self.tapView window] contentView]];
    if (locationInView.y > 0) {
//        windowOrigin = self.window.frame.origin;
        NSScrollView *scrollView = (NSScrollView *)self.collectionView.superview.superview;
        NSPoint pt = NSMakePoint(0.0, 0.0);
        [[scrollView documentView] scrollPoint:pt];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
//    if (windowOrigin.x != self.window.frame.origin.x || windowOrigin.y != self.window.frame.origin.y) {
//        NSScrollView *scrollView = (NSScrollView *)self.collectionView.superview.superview;
//        NSPoint pt = NSMakePoint(0.0, 0.0);
//        [[scrollView documentView] scrollPoint:pt];
//    } else {
//        windowOrigin = CGPointMake(100000.0, 100000.0);
//    }
}

- (void)didScrollToEnd {
    [self check:self];
}

@end
