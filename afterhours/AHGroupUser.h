//
//  GroupUser.h
//  After Hours
//
//  Created by Seth Cohen on 4/28/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AHGroup, AHUser;

@interface AHGroupUser : NSManagedObject

@property BOOL isAdmin;
@property (nonatomic, retain) NSDate *joinDate;
@property (nonatomic, retain) AHGroup *group;
@property (nonatomic, retain) AHUser *user;

@end
