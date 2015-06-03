//
//  AHNewGroupViewController.m
//  afterhours
//
//  Created by Seth Cohen on 5/23/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import "AHNewGroupViewController.h"
#import "AHGroup.h"
#import "AHUser.h"
#import "AHGroupUser.h"
#import "DownPicker/DownPicker.h"
#import "AHDataStore.h"
#import <QuartzCore/QuartzCore.h>

@interface AHNewGroupViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *isPrivateSwitch;
@property (weak, nonatomic) IBOutlet UITextField *groupNameText;
@property (strong, nonatomic) AHGroup *editingGroup;

@property (weak, nonatomic) IBOutlet UITableView *allUsersTable;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) DownPicker *pickerView;
@property (weak, nonatomic) IBOutlet UITextField *groupTypeInput;

@property (strong, nonatomic) NSMutableSet *selectedUsers;

- (IBAction)saveGroup:(id)sender;
@end

@implementation AHNewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  // bind yourTextField to DownPicker
  self.groupTypeInput.text = [[AHGroup groupTypes]objectAtIndex:0];
  self.pickerView = [[DownPicker alloc] initWithTextField:self.groupTypeInput withData:[AHGroup groupTypes]];
  [self.pickerView setPlaceholder:@"Select Group Type:"];
  
  // initialize the array to keep track of the indexPaths that have been selected by the user.
  self.selectedUsers = [[NSMutableSet alloc] init];
  
  self.managedObjectContext = [[AHDataStore getInstance] managedObjectContext];
  
  self.editingGroup = [NSEntityDescription
                       insertNewObjectForEntityForName:@"AHGroup"
                       inManagedObjectContext:self.managedObjectContext];
  self.editingGroup.creator = [[AHDataStore getInstance] currentUser];
  
  [self.allUsersTable setEditing:YES];
  NSError *error;
  if (![[self fetchedResultsController] performFetch:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    abort();
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  // we need to determine if we are being popped off of the navgigation stack so we can reset or undo the
  // managed context... we only want to save if the user presses the save button.
  if ([self isMovingFromParentViewController]) {
    [self.managedObjectContext undo];
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return @"Add Users To Group";
}

// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  
  // Configure the cell to show the user's name and email address
  AHUser *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = [NSString stringWithFormat: @"%@ %@", user.firstName, user.lastName];
  cell.editingAccessoryType = UITableViewCellAccessoryNone;
  cell.accessoryView = UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
  
  // Configure the cell.
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //[tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  //the below code will allow multiple selection
  if ([self.selectedUsers containsObject:indexPath]) {
    [self.selectedUsers removeObject:indexPath];
  } else {
    [self.selectedUsers addObject:indexPath];
  }
  //[tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
  
  return [sectionInfo numberOfObjects];
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
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"AHUser" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];

  // Create the sort descriptors array.
  NSSortDescriptor *addressDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
  NSArray *sortDescriptors = @[addressDescriptor];
  [fetchRequest setSortDescriptors:sortDescriptors];
  
  // Create the predicate so we don't select the current user since it is their group, no need to add them to it
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id != %@",[[AHDataStore getInstance] currentUser].id];
  [fetchRequest setPredicate:predicate];
  
  // Create and initialize the fetch results controller.
  _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
  _fetchedResultsController.delegate = self;

  
  return _fetchedResultsController;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

- (IBAction)saveGroup:(id)sender {
  // make sure that we have enough information to create a new group and at least one user is added.
  NSString *name = [self.groupNameText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  if (name.length == 0) {
    // highlight the input field to show the error
    // TODO determine a way to remove focus
    self.groupNameText.layer.borderColor = [[UIColor redColor] CGColor];
    self.groupNameText.layer.borderWidth = 1.0f;
    self.groupNameText.layer.cornerRadius = 5.0f;
    [self.groupNameText resignFirstResponder]; // remove focus from the text field so that it has to be selected again and will remove error highlighting
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Save Group" message:@"Every Group requires a name to be saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    return;
  } else {
    self.editingGroup.name = name;
  }
  
  NSString *groupType = [self.groupTypeInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  if (groupType.length == 0) {
    self.groupTypeInput.layer.borderColor = [[UIColor redColor] CGColor];
    self.groupTypeInput.layer.borderWidth = 1.0f;
    self.groupTypeInput.layer.cornerRadius = 5.0f;
    [self.groupTypeInput resignFirstResponder]; // remove focus from the text field so that it has to be selected again and will remove error highlighting
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Save Group" message:@"Every Group should have a Group Type set." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    return;
  } else {
    // NSArrays are zero indexed.
    self.editingGroup.type = [NSNumber numberWithInteger:(2 + [[AHGroup groupTypes] indexOfObject:groupType])];
  }
  
  if ([self.selectedUsers count] == 0) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Save Group" message:@"Must add at least one contact to the group in order to save." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    return;
  } else {
    for (NSIndexPath *indexPath in self.selectedUsers) {
      AHGroupUser *groupUser = [NSEntityDescription
                                insertNewObjectForEntityForName:@"AHGroupUser"
                                inManagedObjectContext:self.managedObjectContext];
      groupUser.user = [self.fetchedResultsController objectAtIndexPath:indexPath];
      groupUser.group = self.editingGroup;
      groupUser.joinDate = [NSDate date];
      groupUser.isAdmin = NO;
      
      // TODO see if it is more efficient to add these to set/array and then add them with addUsers:
      [self.editingGroup addUsersObject:groupUser];
    }
  }
  
  self.editingGroup.isPrivate = self.isPrivateSwitch.on;
  NSError *error;
  if (![self.editingGroup.managedObjectContext save:&error]) {
    [self.editingGroup.managedObjectContext undo];
    NSLog(@"Unfortunately we were not able to save. %@, %@", error, error.localizedDescription);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem Saving Group" message:@"Sorry, there was a problem saving the Group. Please try again, won't you?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    return;
  } else {
    [self.editingGroup syncToWebService];
    [self.navigationController popViewControllerAnimated:YES];
  }
}

#pragma mark - Text Field Delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
  self.groupNameText.layer.borderWidth = 0;
  self.groupNameText.layer.borderColor = [[UIColor blackColor] CGColor];
}
@end
