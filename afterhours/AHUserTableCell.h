//
//  AHUserTableCell.h
//  afterhours
//
//  Created by Seth Cohen on 5/27/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBSDKProfilePictureView;

@interface AHUserTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *profileImage;

@end
