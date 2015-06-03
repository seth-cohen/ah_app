//
//  AHServiceManager.m
//  After Hours
//
//  Created by Seth Cohen on 5/5/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import "AHServiceManager.h"
#import "AFNetworking/AFNetworking.h"

@implementation AHServiceManager

#pragma mark - Singleton
static AHServiceManager *singletonInstance;

static NSString *const kRestBaseURL = @"https://www.agenda.com/api/v1/";

+ (AHServiceManager *) sharedInstance{
  if (singletonInstance == nil) {
    singletonInstance = [[super alloc] init];
  }
  return singletonInstance;
}

#pragma mark - Service REST Request
- (void) sendPostToEndpoint:(NSString *) endPoint withParameters:(NSDictionary *)params requestIdentifier:(NSNumber *)requestId delegate:(id)delegate {
  NSURL *baseURL = [NSURL URLWithString:kRestBaseURL];
  AFHTTPRequestOperationManager *operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
  
  // TODO since currently my Webservice uses self signed certs we need to accept invalid certs
  AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
  [policy setAllowInvalidCertificates:YES];
  [operationManager setSecurityPolicy:policy];
  
  // We must anticipate the fact that we may receive a 303 for See Other if the resources has already been
  // created 
  AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
  NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
  [indexSet addIndexes:serializer.acceptableStatusCodes];
  [indexSet addIndex:303];
  serializer.acceptableStatusCodes = indexSet;
  operationManager.responseSerializer = serializer;
  
  [operationManager POST:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"JSON: %@", [responseObject description]);
    [delegate processResponse:responseObject forRequestType:requestId];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"BAD Error: %@", [error description]);
  }];
}

- (void) sendGetToEndpoint:(NSString *)endPoint withParameters:(NSString *)params requestIdentifier:(NSNumber *)requestId delegate:(id)delegate {
  AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
  [policy setAllowInvalidCertificates:YES];
  
  NSURL *baseURL = [NSURL URLWithString:kRestBaseURL];
  AFHTTPRequestOperationManager *operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
  
  // TODO since currently my Webservice uses self signed certs we need to accept ainvalid certs
  [operationManager setSecurityPolicy:policy];
  operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
  
  [operationManager GET:endPoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"JSON: %@", [responseObject description]);
    [delegate processResponse:responseObject forRequestType:requestId];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", [error description]);
  }];
}

@end
