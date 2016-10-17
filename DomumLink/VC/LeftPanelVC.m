//
//  LeftPanelVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/15/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "LeftPanelVC.h"
#import "TenantsVC.h"
#import "UIViewController+JASidePanel.h"

@interface LeftPanelVC () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UILabel *userFullnameLabel;
    IBOutlet UILabel *userPositionLabel;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *issueviewTopConstraint;

//iPhone outlets
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic) id updateSideMenuObserver;
@property (weak, nonatomic) IBOutlet UITableView *menuTable;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation UILabel (Additions)

- (void)sizeToFitWithAlignmentRight {
    CGRect beforeFrame = self.frame;
    [self sizeToFit];
    CGRect afterFrame = self.frame;
    self.frame = CGRectMake(beforeFrame.origin.x + beforeFrame.size.width - afterFrame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

@end

@implementation LeftPanelVC

@synthesize  menuView;

NSInteger menuCount;
NSArray *identifiers, *cellTitles;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateSideMenu];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _updateSideMenuObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"UpdateSideMenu" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self updateSideMenu];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"ShowIssues" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self issuesButtonPressed:nil];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateSideMenu" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowIssues" object:nil];
}

- (void)updateSideMenu {
    
    [_logoutButton setTitle:[NSString stringWithFormat:@"  %@", LocalizedString(@"LogOut")] forState:UIControlStateNormal];
    
    UIImage *settingsImage = [[UIImage imageNamed:@"settings_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [settingsButton setImage:settingsImage forState:UIControlStateNormal];
    settingsButton.tintColor = GREEN_COLOR;
    

    menuCount = 0;
    if([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee){
        
        if ([GlobalVars sharedInstance].isEasymode) {
            _issueviewTopConstraint.constant = -40;
            
            menuCount = 1;
            identifiers = @[@"IssuesCell"];
            cellTitles = @[LocalizedString(@"Issues")];
        } else {
            _issueviewTopConstraint.constant = 2;
            
            if ([[GlobalVars sharedInstance] hasBuildingStatusPermission]) {
                menuCount = 3;
                identifiers = @[@"TenantsCell", @"IssuesCell", @"BuildingStatusCell"];
                cellTitles = @[LocalizedString(@"Tenants"), LocalizedString(@"Issues"), LocalizedString(@"BuildingStatus")];
            }
            else {
                menuCount = 2;
                identifiers = @[@"TenantsCell", @"IssuesCell", @"BuildingStatusCell"];
                cellTitles = @[LocalizedString(@"Tenants"), LocalizedString(@"Issues"), LocalizedString(@"BuildingStatus")];
            }
            
            if ([[GlobalVars sharedInstance] hasTenantsPermission]) {
                menuCount = menuCount;
                identifiers = @[@"TenantsCell", @"IssuesCell", @"BuildingStatusCell"];
                cellTitles = @[LocalizedString(@"Tenants"), LocalizedString(@"Issues"), LocalizedString(@"BuildingStatus")];
                
            }
            else {
                menuCount = menuCount - 1;
                identifiers = @[@"IssuesCell", @"BuildingStatusCell"];
                cellTitles = @[LocalizedString(@"Issues"), LocalizedString(@"BuildingStatus")];
                
            }
        }
    }
    else if([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant){
        _issueviewTopConstraint.constant = 2;
        
        
        menuCount = 3;
        identifiers = @[@"HomeCell", @"IssuesCell", @"BuildingInfoCell"];
        cellTitles = @[LocalizedString(@"Home"), LocalizedString(@"Issues"), LocalizedString(@"BuildingInfo")];

    }
    
    
    
    
    userFullnameLabel.text = [NSString stringWithFormat:@"%@ %@", [GlobalVars sharedInstance].currentUser.firstName, [GlobalVars sharedInstance].currentUser.lastName];
    userFullnameLabel.adjustsFontSizeToFitWidth = YES;
    
    userPositionLabel.text = LocalizedString([GlobalVars sharedInstance].currentUser.jobTitle);
    
    [_menuTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)settingsClicked:(id)sender{   
    UINavigationController *navController = (UINavigationController *)self.sidePanelController.centerPanel;
    [navController popToRootViewControllerAnimated:NO];
    [navController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"PersonalSettingsPage"] animated:YES];
    
    self.sidePanelController.centerPanel = navController;
}

- (IBAction)onLogout:(id)sender{
//    [[GlobalVars sharedInstance] removeUserSetting];
    [[GlobalVars sharedInstance] setIsLoggedIn:NO];
    
    [GlobalVars sharedInstance].currentUser = nil;
    [SharedAppDelegate showLogin];
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    
//    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"LoginVC"] animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiers[indexPath.row]];
    UILabel *issuesLabel = nil;
    if([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee) {
        NSInteger issueRow = [[GlobalVars sharedInstance] hasTenantsPermission] ? 1 : 0;
        if ([GlobalVars sharedInstance].isEasymode) {
            issueRow = 0;
            if (indexPath.row == issueRow) {
                issuesLabel = (UILabel *)[cell.contentView viewWithTag:3];
            }
        } else {
            if (indexPath.row == issueRow) {
                issuesLabel = (UILabel *)[cell.contentView viewWithTag:3];
            }

        }
    } else if([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) {
        if (indexPath.row == 1) {
            issuesLabel = (UILabel *)[cell.contentView viewWithTag:3];
        }
    }
    
    if (issuesLabel) {
        issuesLabel.layer.cornerRadius = 10;
        issuesLabel.clipsToBounds = YES;
        issuesLabel.text = [NSString stringWithFormat:@"%i", [GlobalVars sharedInstance].unreadIssuesCount];
//        [issuesLabel sizeToFitWithAlignmentRight];
        
    }
    
    UIButton *titleButton = (UIButton *)[cell viewWithTag:10];
    if ([titleButton isKindOfClass:[UIButton class]]) {
        [titleButton setTitle:cellTitles[indexPath.row] forState:UIControlStateNormal];
        if ([identifiers[indexPath.row] isEqualToString:@"BuildingInfoCell"]) {
            if ([GlobalVars sharedInstance].langCode == ELangEnglish)
                titleButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            else
                titleButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        }
    }
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)issuesButtonPressed:(id)sender {
    UINavigationController *navController = (UINavigationController *)self.sidePanelController.centerPanel;
    [navController popToRootViewControllerAnimated:NO];
    [navController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"issuesViewPage"] animated:YES];
    
    self.sidePanelController.centerPanel = navController;
}

- (IBAction)tenantsButtonPressed:(id)sender {
    UINavigationController *navController = (UINavigationController *)self.sidePanelController.centerPanel;
    [navController popToRootViewControllerAnimated:NO];
    
    NSString *vcId;
    if([GlobalVars sharedInstance].currentUser.type == 1){
        vcId = @"tenantsViewPage";
    }
    else if([GlobalVars sharedInstance].currentUser.type == 2){
        vcId = @"homeViewPage";
    }
    [navController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:vcId] animated:YES];
    
    self.sidePanelController.centerPanel = navController;
}

- (IBAction)buildingButtonPressed:(id)sender {
    UINavigationController *navController = (UINavigationController *)self.sidePanelController.centerPanel;
    [navController popToRootViewControllerAnimated:NO];
    NSString *vcId;
    if([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee){
        vcId = @"buildingsViewPage";
    }
    else if([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant){
        vcId = @"buildingInfoViewPage";
    }
    [navController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:vcId] animated:YES];
    
    self.sidePanelController.centerPanel = navController;
    
//    [self selectActiveButton:TenantsButton withActual:actualActiveButton];
}

@end
