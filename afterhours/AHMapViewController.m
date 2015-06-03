//
//  AHMapViewController.m
//  afterhours
//
//  Created by Seth Cohen on 5/18/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import "AHMapViewController.h"
#import "DownPicker/DownPicker.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AHMapViewController ()

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@property (strong, nonatomic) DownPicker *pickerView;
@property (weak, nonatomic) IBOutlet UITextField *groupSelectInput;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
- (IBAction)handleSettingButton:(id)sender;

@end

@implementation AHMapViewController

NSMutableArray *groupNames;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  groupNames = [[NSMutableArray  alloc]initWithArray: @[@"test1", @"test2", @"test3", @"test4"]];
  
  // bind yourTextField to DownPicker
  self.pickerView = [[DownPicker alloc] initWithTextField:self.groupSelectInput withData:groupNames];
  [self.pickerView setPlaceholder:@"Tap to Select Group:"];
  [self registerForKeyboardNotifications];
  
  // Do any additional setup after loading the view, typically from a nib.
  
  self.mapView.camera = [GMSCameraPosition cameraWithLatitude:42.347403
                                                    longitude:-71.077767
                                                         zoom:16];
  self.mapView.myLocationEnabled = YES;
  self.mapView.mapType = kGMSTypeNormal;
  self.mapView.settings.compassButton = NO;
  self.mapView.settings.myLocationButton = YES;
  
  // Creates a marker in the center of the map.
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.position = self.mapView.camera.target;
  marker.title = @"Home";
  marker.map = self.mapView;
  
}

#pragma mark - Keyboard response and notifications
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];
  
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification {
  NSDictionary* info = [aNotification userInfo];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  [self.view layoutIfNeeded];
  
  self.bottomConstraint.constant = kbSize.height + 20;
  // regardless of duration this animation seems to occur at speed of keyboard animation
  [UIView animateWithDuration:0 animations:^{
    [self.view layoutIfNeeded];
  }];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
  [self.view layoutIfNeeded];
  self.bottomConstraint.constant = 80;
  // regardless of duration this animation seems to occur at speed of keyboard animation
  [UIView animateWithDuration:0 animations:^{
    [self.view layoutIfNeeded];
  }];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)handleSettingButton:(id)sender {
  [self.mainController handleMenuSlide];
}

@end
