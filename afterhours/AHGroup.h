//
//  AHGroup.h
//  After Hours
//
//  Created by Seth Cohen on 5/3/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AHServiceManager.h"


@class AHGroupUser, AHUser;

@interface AHGroup : NSManagedObject <AHServiceResponseDelegate>

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) AHUser *creator;

+ (NSMutableArray *)groupTypes;
- (void) syncToWebService;
@end

@interface AHGroup (CoreDataGeneratedAccessors)

- (void)addUsersObject:(AHGroupUser *)value;
- (void)removeUsersObject:(AHGroupUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end

static int const kAHGroupTypeAll = 1;
static int const kAHGroupTypeFriends = 2;
static int const kAHGroupTypeCoworkers = 3;
static int const kAHGroupTypeMix = 4;
static int const kAHGroupTypeAlmostFriends = 5;

// API Action Types
static int const kGroupRequestTypeMin = 1;
static int const kGroupRequestPostAH = 1;
static int const kGroupRequestTypeMax = 1;