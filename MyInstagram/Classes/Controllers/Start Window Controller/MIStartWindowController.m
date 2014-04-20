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

@interface MIStartWindowController () {
	NSArray *feed;
	NSArrayController *arrayController;
    MIDetailsWindowController *detailsWindowController;
    BOOL tapTrigger;
}

@end

@implementation MIStartWindowController

- (instancetype)init {
	self = [super initWithWindowNibName:@"MIStartWindowController"];
	if (self) {
		feed = [NSArray array];
        arrayController = [[NSArrayController alloc] init];
        
        // extracting cache from DB
        [arrayController setContent:[[MIDatabaseManager sharedInstance] extractFeedFromDatabase]];
        
        tapTrigger = NO;
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
    
    // reconneciton
//	[self reconnect:self];
    
    // selection handling
    [self.collectionView bind:NSContentBinding toObject:arrayController withKeyPath:@"arrangedObjects" options:nil];
	[self.collectionView addObserver:self forKeyPath:@"selectionIndexes"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
    
    self.window.delegate = self;
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
        
        CGRect rect = detailsWindowController.window.frame;
        
        detailsWindowController = [[MIDetailsWindowController alloc] initWithPost:selectedPost];
        [detailsWindowController showWindow:self];
        
        if (rect.size.width != 0) {
            [detailsWindowController.window setFrame:rect display:YES animate:NO];
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
		} else {
            
        }
	}];
}

- (IBAction)check:(id)sender {
    [[MINetworkManager sharedInstance] getFeedAndExecute:^(BOOL success, NSArray *resultArray) {
        if (success) {
            [arrayController setContent:resultArray];
        }
    }];
}

//- (void)windowDidEndLiveResize:(NSNotification *)notification {
//    CGFloat spacing = self.window.frame.size.width-self.collectionView.frame.size.width;
//    NSSize size = self.window.frame.size;
//    CGFloat itemWidth = self.collectionView.itemPrototype.view.frame.size.width;
//    float x = (size.width-spacing)/itemWidth;
//    
//    CGRect rect = self.window.frame;
//    rect.size.width = itemWidth*floor(x)+spacing;
//    [self.window setFrame:rect display:YES animate:YES];
//}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
    CGFloat spacing = self.window.frame.size.width-self.collectionView.frame.size.width;
    
//    CGFloat scrollerWidth = self.window.scr
    
    CGFloat itemWidth = self.collectionView.itemPrototype.view.frame.size.width;
    float x = (frameSize.width-spacing)/itemWidth;
    
    CGRect rect = CGRectMake(sender.frame.origin.x, sender.frame.origin.y, itemWidth*floor(x)+spacing, frameSize.height);
    
    float minWindowWidth = itemWidth+spacing;
    
    if (rect.size.width < minWindowWidth) {
        rect.size.width = minWindowWidth;
        NSLog(@"Yep");
    }
    
    NSLog(@"%f", rect.size.width);
    
    return rect.size;
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

@end
