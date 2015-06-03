//
//  AHUser.m
//  After Hours
//
//  Created by Seth Cohen on 5/3/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import "AHUser.h"
#import "AHGroup.h"
#import "AHGroupUser.h"
#import "AHLocation.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

// anonymous category
@interface AHUser ()

@property (strong, nonatomic) NSMutableData *responseData;

@end

@implementation AHUser

@dynamic dateCreated;
@dynamic emailAddress;
@dynamic facebookId;
@dynamic firstName;
@dynamic hasBusiness;
@dynamic id;
@dynamic lastName;
@dynamic password;
@dynamic username;
@dynamic publicGroups;
@dynamic homeLocation;
@dynamic createdGroups;

@synthesize responseData;


- (BOOL) isCurrentUser {
  return [self.facebookId isEqual:[[FBSDKAccessToken currentAccessToken] userID]];
}

- (void) populateFromFacebook {
  [self populateFromFacebookWithFBID:@"me"];
}

- (void) populateFromFacebookWithFBID:(NSString *) fbid {
  // Get the logged in user's details from FB and store them in the User model
  if ([FBSDKAccessToken currentAccessToken]) {
    [[[FBSDKGraphRequest alloc] initWithGraphPath:fbid parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
       if (!error) {
         NSLog(@"fetched user details:%@", result);
         
         // Map the dictonary details to the object properties
         self.dateCreated = [NSDate date];
         self.facebookId = [result objectForKey:@"id"];
         self.firstName = [result objectForKey:@"first_name"];
         self.lastName = [result objectForKey:@"last_name"];
         self.emailAddress = [result objectForKey:@"email"];
         self.username = [result objectForKey:@"first_name"];
         
         // Everything was OK.
         [self syncToWebService];
         NSError *saveError;
         if (![self.managedObjectContext save:&saveError]) {
           NSLog(@"Unfortunately we were not able to save. %@, %@", saveError, saveError.localizedDescription);
         }
       }
     }];
  }
}

- (void) syncToWebService {
  NSString *endpointString = @"users";
  NSDictionary *params = @{@"first_name" : self.firstName,
                           @"last_name" : self.lastName,
                           @"email_address" : self.emailAddress,
                           @"facebook_id" : self.facebookId,
                           @"username" : self.username};
  
  NSNumber *requestType = [NSNumber numberWithInt:kUserRequestPostAH];
  [[AHServiceManager sharedInstance] sendPostToEndpoint:endpointString withParameters:params requestIdentifier:requestType delegate:self];
}

- (void) getFriendsFromService {
  if (self.id) {
    NSString *endpointString = [NSString stringWithFormat:@"users/%@/friends", self.id];
    NSDictionary *params = @{@"token": [FBSDKAccessToken currentAccessToken].tokenString};
    
    NSNumber *requestType = [NSNumber numberWithInt:kUserRequestGetFriendDataAH];
    [[AHServiceManager sharedInstance] sendGetToEndpoint:endpointString withParameters:params requestIdentifier:requestType delegate:self];
  } else {
    NSLog(@"Can't request data from API because we don't have an ID yet to reference. Must first be synced to web service.");
  }
}

- (AHGroup *)getDefaultGroup {
  NSArray *groupArray = [self.createdGroups allObjects];
  NSUInteger idx = [groupArray indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
    return ([[(AHGroup *)obj type] intValue] == kAHGroupTypeAll);
  }];
  AHGroup *group;
  if (idx != NSNotFound) {
    group = [groupArray objectAtIndex:idx];
  } else {
    group = [NSEntityDescription
             insertNewObjectForEntityForName:@"AHGroup"
             inManagedObjectContext:self.managedObjectContext];
    group.creator = self;
    
    [self addCreatedGroupsObject:group];
    
  }
  return group;
}

- (void) populateFromService:(NSDictionary *)data {
  NSLog(@"populating user details:%@", data);
  
  // Map the dictonary details to the object properties
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  
  NSLog(@"%@", [NSDate date]);
  self.dateCreated = [dateFormatter dateFromString:[data objectForKey:@"created_date"]];
  self.facebookId = [data objectForKey:@"facebook_id"];
  self.firstName = [data objectForKey:@"first_name"];
  self.lastName = [data objectForKey:@"last_name"];
  self.emailAddress = [data objectForKey:@"email_address"];
  self.username = [data objectForKey:@"first_name"];
  
  NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
  f.numberStyle = NSNumberFormatterDecimalStyle;
  self.id = [f numberFromString:[data valueForKey:@"id"]];
  
  // Everything was OK.
  [self syncToWebService];
  NSError *saveError;
  if (![self.managedObjectContext save:&saveError]) {
    NSLog(@"Unfortunately we were not able to save. %@, %@", saveError, saveError.localizedDescription);
  }
}

#pragma mark - AHServiceResponseDelegate

- (void) processResponse:(id)responseObject forRequestType:(NSNumber *)requestType {
  NSLog(@"API Response Data: %@", responseObject);
  
  switch ([requestType integerValue]) {
    case kUserRequestPostAH:
      [self handleResponseFromPost:responseObject];
      break;
    case kUserRequestGetFriendDataAH:
      [self handleResponseGetFriends:responseObject];
      break;
    default:
      NSLog(@"No handler for request type %@", requestType);
      break;
  }
}

- (void) handleResponseFromPost:(id) object {
  NSString *objectId = [[object valueForKey:@"user"] valueForKey:@"id"];
  if (objectId && ![self.objectID isTemporaryID]) {
    // convert the NSString that is objectID from the JSON data object into a number
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    self.id = [f numberFromString:objectId];
    if (self.id > 0 && [self isCurrentUser]) {
      [self getFriendsFromService];
    }
    
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]) {
      NSLog(@"Unable to save managed object context.");
      NSLog(@"%@, %@", saveError, saveError.localizedDescription);
    }
  }
}

- (void) handleResponseGetFriends:(id)object {
  NSLog(@"Got Friend Data:%@", object);
  NSDictionary *data = [object valueForKey:@"data"];
  
  // Check to see if we already have the Group that the friends have been added to in CoreData
  // we will just use that one instead of creating a new one.
  AHGroup *groupAll = [self getDefaultGroup];
  if ([groupAll.id intValue] == 0) {
    NSDictionary *groupData = [data valueForKey:@"group"];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    groupAll.id = [f numberFromString:[groupData valueForKey:@"group_id"]];
    groupAll.name = [groupData valueForKey:@"name"];
  }
  
  // Get an array of friend IDs to fetch users
  NSArray *friends = [data valueForKey:@"users"];
  NSArray *friendIds = [friends valueForKey:@"id"];
  
  // See if these friends are already in this data store.  Only if multiple people on the same
  // phone are using this app will they already be in the
  NSFetchRequest *requestExistingFriends = [[NSFetchRequest alloc] initWithEntityName:@"AHUser"];
  requestExistingFriends.predicate = [NSPredicate predicateWithFormat:@"id IN %@", friendIds];
  
  NSError *fetchExistingError;
  NSArray *existingFriends = [self.managedObjectContext executeFetchRequest:requestExistingFriends error:&fetchExistingError];
  
  if (existingFriends != nil && [existingFriends count] > 0) {
    for (AHUser *existingFriend in existingFriends) {
      if (![groupAll.users containsObject:existingFriend]) {
        
      }
    }
  } else {
    for (NSDictionary *friend in friends) {
      // for each friend returned see if they are already in the group, if not add them.
      
      AHUser *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"AHUser"
                                                      inManagedObjectContext:self.managedObjectContext];
      [newUser populateFromService:friend];
      
      AHGroupUser *newGroupUser = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"AHGroupUser"
                                   inManagedObjectContext:self.managedObjectContext];
      newGroupUser.group = groupAll;
      newGroupUser.user = newUser;
      newGroupUser.isAdmin = [NSNumber numberWithBool:NO];
      newGroupUser.joinDate = [NSDate date];
      
      [groupAll addUsersObject:newGroupUser];
    }
  }
  
  NSError *saveError;
  if (![self.managedObjectContext save:&saveError]) {
    NSLog(@"Unable to save managed object context.");
    NSLog(@"%@, %@", saveError, saveError.localizedDescription);
  }
}

@end
