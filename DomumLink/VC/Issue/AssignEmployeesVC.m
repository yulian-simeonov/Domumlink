//
//  AssignEmployeesVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 4/17/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "AssignEmployeesVC.h"
#import "SelectTenantsCell.h"
#import "TenantDetailsVC.h"

@interface AssignEmployeesVC (){
    IBOutlet UILabel *stepLabel;
    
    IBOutlet UILabel *assignEmployeesLabel;
    
    IBOutlet UIButton *notByMessageButton;
    
    IBOutlet UIButton *notByVibrationButton;
    
    IBOutlet UIButton *notByAudioButton;
    
    BOOL isSearched;
}

@property (nonatomic, retain) NSMutableArray *allTenantArray;

@property (nonatomic, retain) NSMutableDictionary *selectedTenants;

// Localization
@property (weak, nonatomic) IBOutlet UILabel *notifyEmployeesLabel;
@property (weak, nonatomic) IBOutlet UILabel *emaildescLabel;
@property (weak, nonatomic) IBOutlet UILabel *smsdescLabel;
@property (weak, nonatomic) IBOutlet UILabel *calldescLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

NSMutableArray *buildingEmployeeArray;

int selectedEmployeesCount;

NSArray *notButtonArray, *notByKeyArray, *notByImageNameArray;

NSMutableDictionary *notByDictionary;

NSMutableArray *notByTickImageArray;

@implementation AssignEmployeesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Localization
    self.title = LocalizedString(@"CreateIssue");
    _notifyEmployeesLabel.text = LocalizedString(@"NOTIFYEMPLOYEESBY");
    _emaildescLabel.text = LocalizedString(@"Email");
    _smsdescLabel.text = LocalizedString(@"SMS");
    _calldescLabel.text = LocalizedString(@"Call");
    [_backButton setTitle:LocalizedString(@"BACK") forState:UIControlStateNormal];
    [_nextButton setTitle:LocalizedString(@"NEXT") forState:UIControlStateNormal];
    assignEmployeesLabel.text = [NSString stringWithFormat:@"%@ (0)", LocalizedString(@"AssignEmployees")];
    
    
    self.navigationItem.hidesBackButton = YES;
    
    selectedEmployeesCount = 0;
    _selectedTenants = [NSMutableDictionary dictionary];

    stepLabel.layer.cornerRadius = 3;
    stepLabel.clipsToBounds = YES;
    
    notByMessageButton.layer.cornerRadius = notByMessageButton.frame.size.width/2;
    notByVibrationButton.layer.cornerRadius = notByVibrationButton.frame.size.width/2;
    notByAudioButton.layer.cornerRadius = notByAudioButton.frame.size.width/2;
    [self initNotifyByButtons];
    
    self.tableView.SKSTableViewDelegate = self;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    
    NSString *buildingId = nil;
    if ([Utilities isValidString:[GlobalVars sharedInstance].toCreateIssue[@"LocationBuildingId"]])
        buildingId = [NSString stringWithFormat:@"%@", [GlobalVars sharedInstance].toCreateIssue[@"LocationBuildingId"]];
    
    if ([[GlobalVars sharedInstance].toCreateIssue[@"RecipientType"] integerValue] == ERecipientTypeTenant) {
        [[APIController sharedInstance] getPossibleAssigneesWithRecipientType:[[GlobalVars sharedInstance].toCreateIssue[@"RecipientType"] integerValue] buildingId:buildingId successHandler:^(id jsonData) {
            NSLog(@"%@", jsonData);
            
            if (jsonData == nil) {
                [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                
                NSInteger locationType = [[GlobalVars sharedInstance].toCreateIssue[@"LocationType"] integerValue];
                if (locationType == 0 && self.selectedBuildinArray.count == 1) {
                    _allTenantArray = [NSMutableArray array];
                    
                    if (jsonData[self.selectedBuildinArray[0]]) {
                        NSMutableArray *subArray = [NSMutableArray array];
                        
                        [subArray addObject:self.selectedBuildinArray[0]];
                        [subArray addObjectsFromArray:jsonData[self.selectedBuildinArray[0]]];
                        
                        [_allTenantArray addObject:subArray];
                    }
                    
                    if (jsonData[@"All"]) {
                        NSMutableArray *subArray = [NSMutableArray array];
                        
                        [subArray addObject:@"All"];
                        [subArray addObjectsFromArray:jsonData[@"All"]];
                        
                        [_allTenantArray insertObject:subArray atIndex:0];
                    }
                } else {
                
                    _allTenantArray = [NSMutableArray array];
                    NSArray *keysArray = [jsonData allKeys];
                    for (int i=0; i<keysArray.count; i++) {
                        NSMutableArray *subArray = [NSMutableArray array];
                        
                        [subArray addObject:keysArray[i]];
                        
                        NSArray *tenants = jsonData[keysArray[i]];
                        [subArray addObjectsFromArray:tenants];
                        
                        if ([keysArray[i] isEqualToString:@"All"]) {
                            [_allTenantArray insertObject:subArray atIndex:0];
                        } else {
                            [_allTenantArray addObject:subArray];
                        }
                    }
                    
                }
                [self.tableView reloadData];
            }
        } withFailureHandler:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    } else {
        [[APIController sharedInstance] getPossibleTenantsWithRecipientType:[[GlobalVars sharedInstance].toCreateIssue[@"RecipientType"] integerValue] buildingId:buildingId successHandler:^(id jsonData) {
            NSLog(@"%@", jsonData);
            
            if (jsonData == nil) {
                [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                _allTenantArray = [NSMutableArray array];
                NSArray *keysArray = [jsonData allKeys];
                for (int i=0; i<keysArray.count; i++) {
                    NSMutableArray *subArray = [NSMutableArray array];
                    
                    [subArray addObject:keysArray[i]];
                    
                    NSArray *tenants = jsonData[keysArray[i]];
                    
                    [subArray addObjectsFromArray:tenants];
                    
                    if ([keysArray[i] isEqualToString:@"All"]) {
                        [_allTenantArray insertObject:subArray atIndex:0];
                    } else {
                        [_allTenantArray addObject:subArray];
                    }
                }
                [self.tableView refreshData];
            }
        } withFailureHandler:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    
}

- (void)initNotifyByButtons{
    notButtonArray = [NSArray arrayWithObjects:notByMessageButton, notByVibrationButton, notByAudioButton, nil];
    notByKeyArray = [NSArray arrayWithObjects:@"NotifyByMessage", @"NotifyByVibration", @"NotifyByAudio", nil];
    notByImageNameArray = [NSArray arrayWithObjects:@"notification_message_icon", @"notification_vibration_icon", @"notification_audio_icon", nil];
    notByTickImageArray = [[NSMutableArray alloc] init];
    notByDictionary = [[NSMutableDictionary alloc] init];
    
    [notByDictionary setObject:@"1" forKey:@"NotifyByMessage"];
    
    for(int i = 0; i < 3; i++){
        
        UIButton *notButton = notButtonArray[i];
        notButton.layer.cornerRadius = notByMessageButton.frame.size.width / 2;
        notButton.layer.borderColor = LIGHT_GRAY_COLOR2.CGColor;
        [notButton addTarget:self action:@selector(notifyByButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *notByImage = [[UIImage imageNamed:notByImageNameArray[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [notButton setImage:notByImage forState:UIControlStateNormal];
        
        UIImageView *tickImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_notification_tick_icon"]];
        [tickImageView sizeToFit];
        tickImageView.center = CGPointMake(50, 50);
        [notButton addSubview:tickImageView];
        [notByTickImageArray addObject:tickImageView];
    }
    
    [self setNotifyByButtonsStyle];
}

- (void)setNotifyByButtonsStyle{
    for(int i = 0; i < 3; i++){
        UIButton *notButton = notButtonArray[i];
        NSString *notByKey = notByKeyArray[i];
        if([notByDictionary objectForKey:notByKey]){
            notButton.backgroundColor = GREEN_COLOR;
            notButton.layer.borderWidth = 0;
            notButton.tintColor = [UIColor whiteColor];
            ((UIImageView *)notByTickImageArray[i]).hidden = NO;
        }
        else{
            notButton.backgroundColor = [UIColor whiteColor];
            notButton.layer.borderWidth = 2;
            notButton.tintColor = NAV_BAR_COLOR;
            ((UIImageView *)notByTickImageArray[i]).hidden = YES;
        }
    }
}

#pragma mark - UIButton Action

- (IBAction)notifyByButtonClicked:(id)sender{
    for(int i = 0; i < 3; i++){
        UIButton *notButton = notButtonArray[i];
        NSString *notByKey = notByKeyArray[i];
        if(sender == notButton){
            if([notByDictionary objectForKey:notByKey]){
                [notByDictionary removeObjectForKey:notByKey];
            }
            else{
                [notByDictionary setObject:@"1" forKey:notByKey];
            }
            break;
        }
    }
    
    [self setNotifyByButtonsStyle];
}


- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)finishClicked:(id)sender{
    NSMutableArray *userIds = [NSMutableArray array];
    for (NSDictionary *dict in [_selectedTenants allValues]) {
        [userIds addObject:[NSString stringWithFormat:@"%@", dict[@"UserId"]]];
    }
    if ([[GlobalVars sharedInstance].toCreateIssue[@"RecipientType"] integerValue] == ERecipientTypeEmployee) {
        if (userIds.count > 0)
            [[GlobalVars sharedInstance].toCreateIssue setObject:userIds forKey:@"RecipientIds"];
        else {
            [Utilities showMsg:LocalizedString(@"PleaseSelectAtLeastOneEmployee")];
            return;
        }
    } else {
        if (userIds.count > 0)
            [[GlobalVars sharedInstance].toCreateIssue setObject:userIds forKey:@"AssigneeIds"];
    }
    
    NSString *updateByEmail = [notByDictionary objectForKey:notByKeyArray[0]] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:updateByEmail forKey:@"NotifyAssigneesEmail"];
    
    NSString * updateBySms = [notByDictionary objectForKey:notByKeyArray[1]] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:updateBySms forKey:@"NotifyAssigneesSms"];
    
    NSString * updateByVoice = [notByDictionary objectForKey:notByKeyArray[2]] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:updateByVoice forKey:@"NotifyAssigneesVoice"];
    
    NSLog(@"%@", [GlobalVars sharedInstance].toCreateIssue);
    
    [self performSegueWithIdentifier:@"ShowUpdateMeBy" sender:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return _allTenantArray.count > 0 ? 1 : 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _allTenantArray.count;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [_allTenantArray[indexPath.row] count] - 1;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearched)
        return YES;
    
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        return YES;
    }
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectTenantsBuildingCell";
    
    SelectTenantsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SelectTenantsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.tenantNameLabel.text = _allTenantArray[indexPath.row][0];
    cell.expandable = YES;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectTenantsCell";
    
    SelectTenantsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SelectTenantsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    cell.expandable = NO;
    NSMutableDictionary *tenant = _allTenantArray[indexPath.row][indexPath.subRow];
    
    if (tenant[@"Apartment"])
        cell.tenantNameLabel.text = [NSString stringWithFormat:@"%@ - Apt %@", tenant[@"Name"], tenant[@"Apartment"]];
    else
        cell.tenantNameLabel.text = [NSString stringWithFormat:@"%@", tenant[@"Name"]];
    
    NSString *imageName = _selectedTenants[tenant[@"UserId"]] ? @"add_tenant_checked" : @"add_tenant_unchecked";
    
    cell.selectionImageView.image = [UIImage imageNamed:imageName];
    
    cell.signedupView.layer.cornerRadius = cell.signedupView.frame.size.width/2;
    if ([tenant[@"SignupStatus"] boolValue]) {
        cell.signedupView.backgroundColor = [UIColor greenColor];
    } else {
        cell.signedupView.backgroundColor = [UIColor colorWithRed:206/255.0f green:92/255.0f blue:92/255.0f alpha:1.0f];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* tenant = _allTenantArray[indexPath.row][indexPath.subRow];
    [tenant setObject:@(![tenant[@"isSelected"] boolValue]) forKey:@"isSelected"];
    
    if (_selectedTenants[tenant[@"UserId"]])
        [_selectedTenants removeObjectForKey:tenant[@"UserId"]];
    else
        [_selectedTenants setObject:tenant forKey:tenant[@"UserId"]];
    
    //    if([tenant[@"isSelected"] boolValue]){
    //        selectedTenantsCount++;
    //        [_selectedTenants setObject:tenant forKey:tenant[@"UserId"]];
    //    }
    //    else
    //    {
    //        selectedTenantsCount--;
    //        [_selectedTenants removeObjectForKey:tenant[@"UserId"]];
    //    }
    
    [tableView reloadData];
    assignEmployeesLabel.text = [NSString stringWithFormat:@"%@ (%lu)", LocalizedString(@"AssignEmployees"), (unsigned long)[[_selectedTenants allKeys] count]];
}

-(void)tableView:(SKSTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


@end
