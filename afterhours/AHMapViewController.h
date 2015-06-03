//
//  AHMapViewController.h
//  afterhours
//
//  Created by Seth Cohen on 5/18/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AHMainViewController.h"

@interface AHMapViewController : UIViewController

// Needed so that we can slide the containing view out on button press
@property (weak, nonatomic) AHMainViewController *mainController;
@end
