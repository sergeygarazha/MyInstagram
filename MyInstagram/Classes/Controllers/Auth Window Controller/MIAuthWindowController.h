//
//  MIAuthWindowController.h
//  MyInstagram
//
//  Created by Sergey Garazha on 23/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MIAuthWindowController : NSWindowController

@property (weak) IBOutlet WebView *webView;

- (IBAction)reload:(id)sender;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end
