//
//  AHGroupViewController.m
//  afterhours
//
//  Created by Seth Cohen on 5/20/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import "AHGroupViewController.h"
#import "AHDataStore.h"
#import "AHGroupUser.h"
#import "AHUser.h"
#import "AHGroup.h"
#import "AHUserTableCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AHGroupViewController ()

@property (strong, nonatomic) NSMutableSet *collapsedSections;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *groupTableView;

@end

@implementation AHGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.managedObjectContext = [[AHDataStore getInstance] managedObjectContext];
  
  self.collapsedSections = [[NSMutableSet alloc] init];
  
  NSError *error;
  if (![[self fetchedResultsController] performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
  CGPoint origin = self.groupTableView.frame.origin;
  CGSize size = self.groupTableView.frame.size;
  NSLog(@"%f, %f, %f, %f", origin.x, origin.y, size.height, size.width);
}

#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 44.0f; // Same as each custom section view height
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIButton* result = [UIButton buttonWithType:UIButtonTypeCustom];
  result.backgroundColor = [UIColor colorWithRed:0.91f green:0.91f blue:0.91f alpha:1.0f];
  
  [result addTarget:self action:@selector(sectionButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
  
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
  [result setTitle:sectionInfo.name forState:UIControlStateNormal];
  
  result.tag = section;
  return result;
}

// Customize the appearance of table view cells.
- (void)configureCell:(AHUserTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  
  // Configure the cell to show the user's name and email address
  AHGroupUser *usergroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
  AHUser *user = usergroup.user;
  cell.nameLabel.text = [NSString stringWithFormat: @"%@ - %@", user.firstName, user.emailAddress];
  cell.profileImage.profileID = user.facebookId;
  
  NSLog(@"group: %@", usergroup.group.name);
  NSLog(@"users: %@", usergroup.user.firstName);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  AHUserTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
  
  // Configure the cell.
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger numRows = 0;
  if ([self.collapsedSections containsObject:@(section)] == NO) {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    numRows = [sectionInfo numberOfObjects];
  }
  
  return numRows;
}

#pragma mark - Collapsible section headers

-(NSArray*) indexPathsForSection:(NSInteger)section withNumberOfRows:(NSInteger)numberOfRows {
  NSMutableArray* indexPaths = [NSMutableArray new];
  for (int i = 0; i < numberOfRows; i++) {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
    [indexPaths addObject:indexPath];
  }
  return indexPaths;
}

-(void)sectionButtonTouchUpInside:(UIButton*)sender {
  [self.groupTableView beginUpdates];
  NSInteger section = sender.tag;
  bool shouldCollapse = ![self.collapsedSections containsObject:@(section)];
  if (shouldCollapse) {
    NSInteger numRows = [self.groupTableView numberOfRowsInSection:section];
    NSArray* indexPaths = [self indexPathsForSection:section withNumberOfRows:numRows];
    [self.groupTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [self.collapsedSections addObject:@(section)];
  }
  else {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger numRows = [sectionInfo numberOfObjects];
    NSArray* indexPaths = [self indexPathsForSection:section withNumberOfRows:numRows];
    [self.groupTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [self.collapsedSections removeObject:@(section)];
  }
  [self.groupTableView endUpdates];
}

#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
  
  if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
  }
  
  // Create and configure a fetch request with the User entity.
  // this is the long winded way to configure a fetch request.
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"AHGroupUser" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];
  
  // Create the sort descriptors array.
  NSSortDescriptor *groupDescriptor = [[NSSortDescriptor alloc] initWithKey:@"group.name" ascending:YES];
  NSSortDescriptor *addressDescriptor = [[NSSortDescriptor alloc] initWithKey:@"user.firstName" ascending:YES];
  NSArray *sortDescriptors = @[groupDescriptor, addressDescriptor];
  [fetchRequest setSortDescriptors:sortDescriptors];
  //[fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"user.createdGroups", nil]];
  
  // Create and initialize the fetch results controller.
  _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"group.name" cacheName:nil];
  _fetchedResultsController.delegate = self;
  
  return _fetchedResultsController;
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [self.groupTableView reloadData];
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
