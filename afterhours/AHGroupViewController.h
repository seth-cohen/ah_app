//
//  AHGroupViewController.h
//  afterhours
//
//  Created by Seth Cohen on 5/20/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AHGroupViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
