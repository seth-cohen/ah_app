//
//  Business.h
//  After Hours
//
//  Created by Seth Cohen on 4/23/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AHBusiness : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * capacity;
@property (nonatomic, retain) NSNumber * occupancy;

@end
