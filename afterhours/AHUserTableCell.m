//
//  AHUserTableCell.m
//  afterhours
//
//  Created by Seth Cohen on 5/27/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import "AHUserTableCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation AHUserTableCell

- (void)awakeFromNib {
    // Initialization code
  
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {
  // force the autoconstraint solver to, well...solve.
  [self.profileImage setNeedsLayout];
  [self.profileImage layoutIfNeeded];
  self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2.0f;
  self.profileImage.clipsToBounds = YES;
}

@end
