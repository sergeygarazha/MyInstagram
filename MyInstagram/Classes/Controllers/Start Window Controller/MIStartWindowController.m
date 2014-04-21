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

@interface MIStartWindowController () {
	NSArray *feed;
    MIDetailsWindowController *detailsWindowController;
    BOOL tapTrigger;
    NSImageView *titleImage;
    NSArrayController *arrayController;
}

@end

@implementation MIStartWindowController

- (instancetype)init {
	self = [super initWithWindowNibName:@"MIStartWindowController"];
	if (self) {
		feed = [NSArray array];
        tapTrigger = NO;
        
        arrayController = [[NSArrayController alloc] initWithContent:[NSArray array]];
        
        titleImage = [[NSImageView alloc] initWithFrame:CGRectMake(500.0, 0.0, 50.0, 70.0)];
        [titleImage setImage:[NSImage imageNamed:@"Instagram.png"]];
        [[(INAppStoreWindow *)self.window titleBarView] addSubview:titleImage];
	}
	return self;
}

- (id)initWithWindow:(NSWindow *)window {
	self = [super initWithWindow:window];
	if (self) {
		// Initialization code here.
	}
	return self;
}

- (void)dealloc {
	[arrayController removeObserver:self
	                     forKeyPath:@"selectedObjects"];
}

#pragma mark - Window controller lifecycle

- (void)windowWillLoad {
	[super windowWillLoad];
}

- (void)loadWindow {
	[super loadWindow];
    
    // extracting cache from DB
    [arrayController setContent:[[MIDatabaseManager sharedInstance] extractFeedFromDatabase]];
    
    // reconneciton
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getFeed:self];
    });
    
    MIScrollView *scrollView = (MIScrollView *)self.collectionView.superview.superview;
    scrollView.backgroundColor = [NSColor clearColor];
    [scrollView setDelegate:self];
    
    // selection handling
    [self.collectionView bind:NSContentBinding toObject:arrayController withKeyPath:@"arrangedObjects" options:nil];
	[self.collectionView addObserver:self forKeyPath:@"selectionIndexes"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
    
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
    
    [self.collectionView setMinItemSize:CGSizeMake(100.0, 100.0)];
    [self.collectionView setMaxItemSize:CGSizeMake(200.0, 200.0)];
}

- (void)windowDidLoad {
	[super windowDidLoad];
    
}

- (void)showWindow:(id)sender {
	[super showWindow:sender];
}

- (NSWindow *)window {
	return [super window];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	// do whatever necessary here
	if ([[self.collectionView selectionIndexes] count] > 0) {
        Post *selectedPost = arrayController.content[[[self.collectionView selectionIndexes] lastIndex]];
        
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
	}
	else {
		NSLog(@"Observer called but no objects where selected.");
	}
}

#pragma mark - Methods

- (IBAction)reconnect:(id)sender {
	NSLog(@"Token request started");
	[self.progressBar startAnimation:self];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
	    BOOL result = [MINetworkManager performInstagramAuthorization];
	    dispatch_async(dispatch_get_main_queue(), ^{
	        if (result) {   //success
	            NSLog(@"Token received");
	            [self.progressBar setHidden:YES];
	            [self.reconnectButton setHidden:YES];
	            [self.getFeedButton setHidden:NO];
			}
	        else {          // failure
	            NSLog(@"Failed to receive token");
	            [self.reconnectButton setEnabled:YES];
	            [self.reconnectButton setTitle:@"Retry to connect"];
	            [self.reconnectButton sizeToFit];
			}
	        [self.progressBar stopAnimation:self];
		});
	});
}

- (IBAction)getFeed:(id)sender {
    [self.progressBar setHidden:NO];
    [self.progressBar startAnimation:self];
	[[MINetworkManager sharedInstance] getFeedAndExecute: ^(BOOL success, NSArray *resultArray) {
        if (success) {
            [arrayController setContent:resultArray];
            [self.progressBar stopAnimation:self];
            [self.progressBar setHidden:YES];
        }
	}];
}

- (IBAction)check:(id)sender {
    [[MINetworkManager sharedInstance] getNextPageAndExecute:^(BOOL success, NSArray *resultArray) {
        if (success) {
            NSMutableArray *ar = [NSMutableArray array];
            [ar addObjectsFromArray:[arrayController content]];
            [ar addObjectsFromArray:resultArray];
            [arrayController setContent:ar];
        }
    }];
}

#define MIN_ITEM_WIDTH  100

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    // положение изображения заголовка
    INAppStoreWindow *window = (INAppStoreWindow *)self.window;
    float height = 55.0;
    float width = 80.0;
    [titleImage setFrame:CGRectMake(frameSize.width/2.0-width/2.0, window.titleBarView.frame.size.height-height, width, height)];
    
//    float collectionViewFrameWidth = self.collectionView.frame.size.width;
//    float minItemWidth = 100.0;
//    int count = (int)(collectionViewFrameWidth/minItemWidth);
//    float difference = collectionViewFrameWidth - count*minItemWidth;
//    float resultItemWidth = minItemWidth+difference/count;
//    [self.collectionView setMinItemSize:CGSizeMake(resultItemWidth, resultItemWidth)];
//    [self.collectionView setMaxItemSize:CGSizeMake(resultItemWidth, resultItemWidth)];
    
    return frameSize;
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint locationInView = [self.tapView convertPoint:[theEvent locationInWindow]
                                         fromView:[[self.tapView window] contentView]];
    if (locationInView.y > 0) {
            NSScrollView *scrollView = (NSScrollView *)self.collectionView.superview.superview;
            NSPoint pt = NSMakePoint(0.0, 0.0);
            [[scrollView documentView] scrollPoint:pt];
    }
}

- (void)didScrollToEnd {
//    [self check:self];
}

@end
