//
//  AHMainViewController.m
//  afterhours
//
//  Created by Seth Cohen on 5/18/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import "AHMainViewController.h"
#import "AHSimpleSettingTableCell.h"
#import "AHCompoundSettingTableCell.h"
#import "AHGroupViewController.h"
#import "AHMapViewController.h"
#import "AHDataStore.h"
#import "AHUser.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AHMainViewController () <UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITableView *settingsView;

// The embedded navigation controller
@property (weak, nonatomic) UINavigationController *navController;

// Pull our settings tray and animations
@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer *leftEdgePanGesture;
@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer *rightEdgePanGesture;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehaviour;
@property (nonatomic, strong) UIPushBehavior* pushBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *panAttachmentBehaviour;

@property (nonatomic, assign, getter = isSettingsOpen) BOOL settingsOpen;

@end

@implementation AHMainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.leftEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePan:)];
  self.leftEdgePanGesture.edges = UIRectEdgeLeft;
  self.leftEdgePanGesture.delegate = self;
  [self.view addGestureRecognizer:self.leftEdgePanGesture];
  
  self.rightEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScreenEdgePan:)];
  self.rightEdgePanGesture.edges = UIRectEdgeRight;
  self.rightEdgePanGesture.delegate = self;
  [self.view addGestureRecognizer:self.rightEdgePanGesture];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // Important to call this only after our view is on screen (ie: we can trust the view geometry).
  [self setupContentViewControllerAnimatorProperties];
  
  self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.containerView.layer.shadowOpacity = 1.0f;
  self.containerView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.containerView.bounds] CGPath];
  self.containerView.layer.shadowOffset = CGSizeZero;
  self.containerView.layer.shadowRadius = 5.0f;
  
  if ([FBSDKAccessToken currentAccessToken] == nil) {
    // we need to show the login modal
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"loginController"];
    
    controller.view.frame = self.view.frame;
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Setting tray Animation

-(void)setupContentViewControllerAnimatorProperties {
  NSAssert(self.animator == nil, @"Animator is not nil – setupContentViewControllerAnimatorProperties likely called twice.");
  
  // for some reason view did load is called twice when the navigation controller is embedded in a container
  // TODO figure out why
  NSLog(@"%@", [self.view class]);
  self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
  
  UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.containerView]];
  // Need to create a boundary that lies to the left off of the right edge of the screen.
  [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, 0, 0, 50 - self.view.frame.size.width)];
  [self.animator addBehavior:collisionBehaviour];
  self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.containerView]];
  self.gravityBehaviour.gravityDirection = CGVectorMake(-1, 0);
  [self.animator addBehavior:self.gravityBehaviour];
  
  self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.containerView] mode:UIPushBehaviorModeInstantaneous];
  self.pushBehavior.magnitude = 0.0f;
  self.pushBehavior.angle = 0.0f;
  [self.animator addBehavior:self.pushBehavior];
  
  UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.containerView]];
  itemBehaviour.elasticity = 0.15f;
  [self.animator addBehavior:itemBehaviour];
}

#pragma mark - UIGestureRecognizerDelegate Methods

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if (gestureRecognizer == self.leftEdgePanGesture && self.isSettingsOpen == NO) {
    return YES;
  }
  else if (gestureRecognizer == self.rightEdgePanGesture && self.isSettingsOpen == YES) {
    return YES;
  }
  
  return NO;
}

#pragma mark - Gesture Recognizer Methods

-(void)handleScreenEdgePan:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
  if (self.containerView != nil) {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    location.y = CGRectGetMidY(self.containerView.bounds);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
      [self.animator removeBehavior:self.gravityBehaviour];
      
      self.panAttachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:self.containerView attachedToAnchor:location];
      [self.animator addBehavior:self.panAttachmentBehaviour];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
      self.panAttachmentBehaviour.anchorPoint = location;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
      [self.animator removeBehavior:self.panAttachmentBehaviour], self.panAttachmentBehaviour = nil;
      
      CGPoint velocity = [gestureRecognizer velocityInView:self.view];
      
      if (velocity.x > 0) {
        // Open menu
        self.settingsOpen = YES;
        
        self.gravityBehaviour.gravityDirection = CGVectorMake(1, 0);
      }
      else {
        // Close menu
        self.settingsOpen = NO;
        
        self.gravityBehaviour.gravityDirection = CGVectorMake(-1, 0);
      }
      
      [self.animator addBehavior:self.gravityBehaviour];
      
      self.pushBehavior.pushDirection = CGVectorMake(velocity.x / 10.0f, 0);
      self.pushBehavior.active = YES;
    }
  }
}

#pragma mark - UIDynamicAnimatorDelegate Methods
- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator {
  
}

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
  
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return @"My Account";
}

// Customize the appearance of table view cells.

- (void)configureCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row != 0) {
    cell.textLabel.text = @"My Groups";
  } else {
    AHCompoundSettingTableCell *cellCast = (AHCompoundSettingTableCell *) cell;
    cellCast.settingLabelView.text = [[AHDataStore getInstance] currentUser].username;
  }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  // Configure the cell.
  NSString *cellIdentifier = @"Cell";
  
  if (indexPath.row == 0) {
    cellIdentifier = @"compoundSettingCell";
  } else {
    cellIdentifier = @"simpleSettingCell";
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
  [self configureCell:cell AtIndexPath:indexPath];
  
  return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(indexPath.row == 0)
  {
    return 80.0f;
  } else {
    return 44.0f;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 1 && [[self.navController.viewControllers lastObject] isKindOfClass:[AHGroupViewController class]] == NO) {
    [self.navController.viewControllers[0] performSegueWithIdentifier:@"showMyGroups" sender:self];
    [self handleMenuSlide];
  }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"embedNavigator"]) {
    self.navController = segue.destinationViewController;
    AHMapViewController *mapController = self.navController.viewControllers[0];
    mapController.mainController = self;
  }
}

- (void) handleMenuSlide {
  if (self.settingsOpen == YES) {
    self.gravityBehaviour.gravityDirection = CGVectorMake(-5, 0);
    self.settingsOpen = NO;
  }
  else {
    // Close menu
    self.settingsOpen = YES;
    
    self.gravityBehaviour.gravityDirection = CGVectorMake(5, 0);
  }
  
  [self.animator addBehavior:self.gravityBehaviour];
  
  //self.pushBehavior.pushDirection = CGVectorMake(velocity.x / 10.0f, 0);
  //self.pushBehavior.active = YES;
}
@end

