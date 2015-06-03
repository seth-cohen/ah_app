//
//  Location.h
//  After Hours
//
//  Created by Seth Cohen on 4/23/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AHUser;

@interface AHLocation : NSManagedObject

@property (nonatomic, retain) NSNumber * isVenue;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) AHUser *owner;

@end
