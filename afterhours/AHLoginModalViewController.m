//
//  AHLoginModalViewController.m
//  afterhours
//
//  Created by Seth Cohen on 5/19/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import "AHLoginModalViewController.h"
#import "AHDataStore.h"
#import "AHUser.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AHLoginModalViewController () <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@end

@implementation AHLoginModalViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Let's load the FB login button before anything else, no reason to wait for map to load
  self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
  self.managedObjectContext = [[AHDataStore getInstance] managedObjectContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBSDKLoginButtonDelegate
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
  [FBSDKAccessToken setCurrentAccessToken:nil];
  [FBSDKProfile setCurrentProfile:nil];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
  
  AHUser *currentUser = [AHDataStore getInstance].currentUser;
  
  if (currentUser == nil) {
    // If not well, then let's save him and store him for later use.
    if ([result.declinedPermissions count] == 0) {
      // First make sure that we don't already have a user with this ID
      // this is the most convenient way to create and configure a new entity.
      AHUser *newUser = [NSEntityDescription
                         insertNewObjectForEntityForName:@"AHUser"
                         inManagedObjectContext:self.managedObjectContext];
      
      [newUser populateFromFacebook];
    }
  }
  
  [self willMoveToParentViewController:nil];
  [self.view removeFromSuperview];
  [self removeFromParentViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
