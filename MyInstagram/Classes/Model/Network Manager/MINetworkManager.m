//
//  MINetworkManager.m
//  MyInstagram
//
//  Created by Sergey Garazha on 27/03/14.
//  Copyright (c) 2014 self. All rights reserved.
//

#import "MINetworkManager.h"
#import <RKObjectManager.h>
#import "Post.h"
#import "MIDatabaseManager.h"
#import <RKEntityMapping.h>
#import <RKErrorMessage.h>

@interface MINetworkManager () {
    NSURL *nextPageURL;
}

@end

@implementation MINetworkManager

@synthesize token, manager;

+ (MINetworkManager *)sharedInstance {
	static dispatch_once_t pred;
	static MINetworkManager *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[MINetworkManager alloc] init]; });
	return sharedInstance;
}

- (id)init {
	self = [super init];
	if (self) {
        [self manager];
	}
	return self;
}

- (RKObjectManager *)manager {
    if (!manager) {
        manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
        manager.managedObjectStore = [MIDatabaseManager sharedInstance].managedObjectStore;
        
        [RKObjectManager setSharedManager:manager];
        
        // mapping for posts
        RKEntityMapping *articleMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:[MIDatabaseManager sharedInstance].managedObjectStore];
        [articleMapping addAttributeMappingsFromDictionary:@{ @"images.thumbnail.url":              @"thumbnail",
                                                              @"images.standard_resolution.url":    @"standard"
                                                              }];
        // mapping for next page string
        RKObjectMapping *nextPageMapping = [RKObjectMapping mappingForClass:[NSMutableDictionary class]];
        [nextPageMapping addAttributeMappingsFromDictionary:@{@"next_url": @"next_url"}];
        RKResponseDescriptor *nextPageDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:nextPageMapping
                                                                                                method:RKRequestMethodAny
                                                                                           pathPattern:nil
                                                                                               keyPath:@"pagination"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
        
        //!!!: обработка истекшего срока годности токена
        RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
        // The entire value at the source key path containing the errors maps to the message
        [errorMapping addAttributeMappingsFromDictionary:@{ @"error_message":   @"errorMessage",
                                                            @"error_type":      @"userInfo"
                                                            }];
        NSIndexSet *errorStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);
        // Any response in the 4xx status code range with an "errors" key path uses this mapping
        RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:errorStatusCodes];
        
        NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // Anything in 2xx
        RKResponseDescriptor *articleDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:articleMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"data" statusCodes:statusCodes];
        
        [manager addResponseDescriptorsFromArray:@[articleDescriptor, errorDescriptor, nextPageDescriptor]];
    }
    
    return manager;
}

#pragma mark - Methods

- (void)getFeedAndExecute:(feedReturnBlockType)block {
    __block NSMutableArray *resultArray = [NSMutableArray array];

//    [[MIDatabaseManager sharedInstance] deleteOldEntries];
    
	[manager getObjectsAtPath:[NSString stringWithFormat:@"self/feed?access_token=%@", [[MINetworkManager sharedInstance] token]]
	               parameters:nil
	                  success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//                          @autoreleasepool {
                              for (id element in mappingResult.array) {
                                if ([element isKindOfClass:[NSDictionary class]]) {
                                    nextPageURL = [NSURL URLWithString:element[@"next_url"]];
                                }
                                
                                if ([element isKindOfClass:[RKErrorMessage class]]) {
                                    NSLog(@"error!: %@", [(RKErrorMessage *)element errorMessage]);
                                }
                                
                                if ([element isKindOfClass:[Post class]]) {
                                    [resultArray addObject:element];
                                }
//                            }
                      }
     
	    block(YES, [resultArray copy]);
	}
                      failure: ^(RKObjectRequestOperation *operation, NSError *error) {
	    block(NO, nil);
	    NSLog(@"Failed to receive feed array");
	}];
}

- (void)getNextPageAndExecute:(feedReturnBlockType)block {
    if (nextPageURL) {
        [self.manager getObjectsAtPath:nextPageURL.absoluteString
                            parameters:nil
                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                   // success
                                   NSMutableArray *resultArray = [NSMutableArray array];
                                   
                                   @autoreleasepool {
                                       for (id element in mappingResult.array) {
                                           if ([element isKindOfClass:[NSDictionary class]]) {
                                               nextPageURL = [NSURL URLWithString:element[@"next_url"]];
                                           }
                                           
                                           if ([element isKindOfClass:[RKErrorMessage class]]) {
                                               NSLog(@"error!: %@", [(RKErrorMessage *)element errorMessage]);
                                           }
                                           
                                           if ([element isKindOfClass:[Post class]]) {
                                               [resultArray addObject:element];
                                           }
                                       }
                                   }
                                   block(YES, resultArray);
                            }
                               failure:^(RKObjectRequestOperation *operation, NSError *error) {
                // failure
                                   block(NO, nil);
                                   NSLog(@"Failed to receive next page");
        }];
    } else {
        NSLog(@"next page string is nil");
    }
}

+ (BOOL)performInstagramAuthorization {
	NSURL *url = [NSURL URLWithString:@"https://instagram.com/oauth/authorize/?client_id=59643e138238464f81021b607ad0b820&redirect_uri=http://ya.ru/&response_type=token"];
	NSError *error = nil;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	NSURLResponse *response = nil;
	[request setTimeoutInterval:5];
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

	if (response) {
		url = response.URL;
		NSString *str = url.absoluteString;
		NSRange start = [str rangeOfString:@"_token="];
		[[MINetworkManager sharedInstance] setToken:[str substringFromIndex:start.location + 7]];
		return YES;
	}

	NSLog(@"Failed to receive token");
	return NO;
}

#pragma mark - Token

- (NSString *)token {
    if (!token) {
        token = [[NSUserDefaults standardUserDefaults] stringForKey:TOKEN];
    }
    
    if (!token) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [MINetworkManager performInstagramAuthorization];
        });
    }
    
    return token;
}

- (void)setToken:(NSString *)token_ {
    token = token_;
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
