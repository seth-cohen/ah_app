//
//  AHUser.h
//  After Hours
//
//  Created by Seth Cohen on 5/3/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AHServiceManager.h"

@class AHGroup, AHGroupUser, AHLocation;

/*!
 @typedef UserCallback
 @abstract
 A block that is passed to User methods requiring callbacks.  This is mostly needed in methods where we
 will be using Facebook requests as a data store
 
 @param result The result of the method call.  Usually self.
 @param error  The `NSError` representing any error that occurred.
 */
typedef void (^UserCallback)(id result, NSError *error);

@interface AHUser : NSManagedObject <AHServiceResponseDelegate>

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * hasBusiness;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *publicGroups;
@property (nonatomic, retain) AHLocation *homeLocation;
@property (nonatomic, retain) NSSet *createdGroups;

/*!
 @abstract Populates a User NSManagedObject from a Facebook API request. To recieve notification that
 the request is done a delegate conforming to <UserDataDelegate> needs to be registered
 @return void
 */
- (void) populateFromFacebook;

/*!
 @abstract Populates a User NSManagedObject from a Facebook API request. To recieve notification that
 the request is done a delegate conforming to <UserDataDelegate> needs to be registered
 @return void
 */
- (void) populateFromFacebookWithFBID:(NSString *)fbid;

/*!
 @abstract Populates a USer NSManaged object from the webservice
 @return void
 */
- (void) populateFromService:(NSDictionary *)data;

/*!
 @abstract Whether or not this user is the current logged in user for whom we have an FB access token
 @return BOOL
 */
- (BOOL) isCurrentUser;

/*!
 @abstract Makes a call to the AH webservice to obtain data representation of a users friends that
 also have the application installed.
 */
- (void) getFriendsFromService;

- (AHGroup *)getDefaultGroup;

@end

@interface AHUser (CoreDataGeneratedAccessors)

- (void)addPublicGroupsObject:(AHGroupUser *)value;
- (void)removePublicGroupsObject:(AHGroupUser *)value;
- (void)addPublicGroups:(NSSet *)values;
- (void)removePublicGroups:(NSSet *)values;

- (void)addCreatedGroupsObject:(AHGroup *)value;
- (void)removeCreatedGroupsObject:(AHGroup *)value;
- (void)addCreatedGroups:(NSSet *)values;
- (void)removeCreatedGroups:(NSSet *)values;

@end

// API Action Types
static int const kUserRequestTypeMin = 1;
static int const kUserRequestPostAH = 1;
static int const kUserRequestGetFriendDataAH = 2;
static int const kUserRequestTypeMax = 2;
