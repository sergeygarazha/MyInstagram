//
//  MIAuthWindowController.m
//  MyInstagram
//
//  Created by Sergey Garazha on 23/04/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MIAuthWindowController.h"
#import "MINetworkManager.h"
#import "MIAppDelegate.h"

@interface MIAuthWindowController ()

@end

@implementation MIAuthWindowController 

#define CLIENT_ID       @"59643e138238464f81021b607ad0b820"
#define REDIRECT_URI    @"http://ya.ru/"

- (instancetype)init
{
    self = [super initWithWindowNibName:@"MIAuthWindowController"];
    if (self) {
    }
    return self;
}

- (void)loadWindow {
    [super loadWindow];
    
    [[self progressIndicator] startAnimation:self];
    [self reload:self];
}

- (void)dealloc {
    [self.webView setFrameLoadDelegate:nil];
    [self.webView setResourceLoadDelegate:nil];
}

#pragma mark - Mathods

- (IBAction)reload:(id)sender {
    // заствляем показать окно авторизации
//    WebPreferences *prefs = [self.webView preferences];
//    [prefs setPrivateBrowsingEnabled:YES];
    
//    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *each in [cookieStorage cookies]) {
//    	[cookieStorage deleteCookie:each];
//    }
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    NSString *authPath = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", CLIENT_ID, REDIRECT_URI];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:authPath]];
//    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    self.webView.frameLoadDelegate = self;
    self.webView.resourceLoadDelegate = self;
    
    [self.webView.mainFrame loadRequest:[request copy]];
}

#pragma mark - Web view delegeta methods

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    [[self progressIndicator] setHidden:NO];
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource {
    
    NSRange range = [response.URL.absoluteString rangeOfString:@"_token="];
    if (range.location != NSNotFound) {
        NSString *token = [response.URL.absoluteString substringFromIndex:range.location+range.length];
        [[MINetworkManager sharedInstance] setToken:token];
        
        id appDelegate = [NSApp delegate];
        if ([appDelegate respondsToSelector:@selector(showMainWindow)]) {
            [appDelegate performSelector:@selector(showMainWindow)];
        }
    }
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    if (error.code == -999) {
        NSLog(@"Failed to load");
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    [[self progressIndicator] setHidden:YES];
}

@end
