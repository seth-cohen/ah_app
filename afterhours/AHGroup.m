//
//  AHGroup.m
//  After Hours
//
//  Created by Seth Cohen on 5/3/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import "AHGroup.h"
#import "AHGroupUser.h"
#import "AHUser.h"

@implementation AHGroup

@dynamic id;
@dynamic isPrivate;
@dynamic name;
@dynamic type;
@dynamic users;
@dynamic creator;

+ (NSMutableArray *)groupTypes {
  static NSMutableArray *types;
  if (types == nil) {
    types = [[NSMutableArray alloc] initWithArray: @[@"Friends", @"Coworkers", @"Mix", @"Almost Friends"]];
  }
  return types;
}

- (void)syncToWebService {
  NSString *endpointString = @"groups";
  
  NSMutableArray *usersArray = [[NSMutableArray alloc] init];
  for (AHGroupUser *groupUser in self.users) {
    NSString* formattedMilliseconds = [NSString stringWithFormat:@"%.0f", [groupUser.joinDate timeIntervalSince1970]];
    [usersArray addObject:@{@"user_id" : groupUser.user.id,
                            @"join_date" : formattedMilliseconds,
                            @"is_admin" : [NSNumber numberWithBool:groupUser.isAdmin]}];
  }
  
  NSError *error;
  NSData *jsonUsers = [NSJSONSerialization dataWithJSONObject:usersArray options:0 error:&error];
  NSString *jsonString = [[NSString alloc] initWithData:jsonUsers encoding:NSUTF8StringEncoding];
  NSLog(@"JSONify = %@", jsonString);
  
  NSDictionary *params = @{@"is_private" : [NSNumber numberWithBool:self.isPrivate],
                           @"name" : self.name,
                           @"type" : self.type,
                           @"creator_id" : self.creator.id,
                           @"users" :  jsonString};
  
  NSNumber *requestType = [NSNumber numberWithInt:kGroupRequestPostAH];
  [[AHServiceManager sharedInstance] sendPostToEndpoint:endpointString withParameters:params requestIdentifier:requestType delegate:self];
}

#pragma mark - AHServiceResponseDelegate

- (void) processResponse:(id)responseObject forRequestType:(NSNumber *)requestType {
  NSLog(@"API Response Data: %@", responseObject);
  
  switch ([requestType integerValue]) {
    case kGroupRequestPostAH:
      [self handleResponseFromPost:responseObject];
      break;
    default:
      NSLog(@"No handler for request type %@", requestType);
      break;
  }
}

- (void) handleResponseFromPost:(id) object {
  NSString *objectId = [object valueForKey:@"id"];
  if (objectId && ![self.objectID isTemporaryID]) {
    // convert the NSString that is objectID from the JSON data object into a number
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    self.id = [f numberFromString:objectId];
    
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]) {
      NSLog(@"Unable to save managed object context.");
      NSLog(@"%@, %@", saveError, saveError.localizedDescription);
    }
  }
}
@end


