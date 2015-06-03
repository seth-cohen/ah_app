//
//  AHDataStore.h
//  After Hours
//
//  Created by Seth Cohen on 5/3/15.
//  Copyright (c) 2015 Seth Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AHUser;

@interface AHDataStore : NSObject

@property (strong, nonatomic) AHUser *mainUser;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (AHDataStore *)getInstance;
- (NSManagedObjectContext *)editingObjectContext;
- (void)saveContext;
- (AHUser *)currentUser;
@end
