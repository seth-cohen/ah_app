//
//  AHLocationSearchController.m
//  afterhours
//
//  Created by Seth Cohen on 5/29/15.
//  Copyright (c) 2015 After Hours. All rights reserved.
//

#import "AHLocationSearchController.h"

@interface AHLocationSearchController ()

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation AHLocationSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
  self.searchController.searchResultsUpdater = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
