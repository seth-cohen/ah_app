//
//  AHServiceManager.h
//  After Hours
//
//  Created by Seth Cohen on 5/5/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AHServiceResponseDelegate
@required
- (void) processResponse:(id)responseObject forRequestType:(NSNumber *)requestType;
@end

@interface AHServiceManager : NSObject

+ (AHServiceManager *) sharedInstance;

- (void) sendPostToEndpoint:(NSString *) endPoint withParameters:(NSDictionary *)params requestIdentifier:(NSNumber *)requestType delegate:(id<AHServiceResponseDelegate>)delegate;
- (void) sendGetToEndpoint:(NSString *) endPoint withParameters:(NSDictionary *)params requestIdentifier:(NSNumber *)requestType delegate:(id<AHServiceResponseDelegate>)delegate;

@end

static int const kResponseJSON = 1;
static int const kResponseXML = 2;