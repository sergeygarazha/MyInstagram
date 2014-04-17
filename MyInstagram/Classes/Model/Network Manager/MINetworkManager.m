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
    manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"https://api.instagram.com/v1/users/"]];
    manager.managedObjectStore = [MIDatabaseManager sharedInstance].managedObjectStore;
    
    [RKObjectManager setSharedManager:manager];
    
    return manager;
}

#pragma mark - Methods

- (NSArray *)getFeedAndExecute:(feedReturnBlockType)block {
	RKEntityMapping *articleMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:[MIDatabaseManager sharedInstance].managedObjectStore];
	[articleMapping addAttributeMappingsFromDictionary:@{ @"images.thumbnail.url":          @"thumbnail",
                                                          @"images.standard_resolution.url":    @"standard"
                                                          }];

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

	[self.manager addResponseDescriptorsFromArray:@[articleDescriptor, errorDescriptor]];

	__block NSArray *resultArray = [NSArray array];

    [[MIDatabaseManager sharedInstance] deleteOldEntries];
    
	[manager getObjectsAtPath:[NSString stringWithFormat:@"self/feed?access_token=%@", [[MINetworkManager sharedInstance] token]]
	               parameters:nil
	                  success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
	    resultArray = mappingResult.array;
	    block(YES, resultArray);
	}
                      failure: ^(RKObjectRequestOperation *operation, NSError *error) {
	    block(NO, resultArray);
	    NSLog(@"Failed to receive feed array");
	}];

	return resultArray;
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

#pragma mark - User Defaults

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
