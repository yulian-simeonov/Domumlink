//
//  SelectTenantsVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 4/17/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "SelectTenantsVC.h"
#import "SelectTenantsCell.h"
#import "AssignEmployeesVC.h"

@interface SelectTenantsVC (){
    IBOutlet UILabel *stepLabel;
    
    IBOutlet UILabel *selectTenantsLabel;
    
    IBOutlet UIView *legendNotSignedUpView;
    
    IBOutlet UIView *legendSignedUpView;
    
    IBOutlet UIButton *notByMessageButton;
    
    IBOutlet UIButton *notByVibrationButton;
    
    IBOutlet UIButton *notByAudioButton;
    
    BOOL isSearched;
    
}


@property (nonatomic, retain) NSMutableArray *allTenantArray;
@property (nonatomic, retain) NSMutableArray *filteredArray;

@property (nonatomic, retain) NSMutableDictionary *selectedTenants;

@property (nonatomic, retain) NSMutableDictionary *selectedDict;

// Localization
@property (weak, nonatomic) IBOutlet UISearchBar *searchController;
@property (weak, nonatomic) IBOutlet UILabel *notSignupLabel;
@property (weak, nonatomic) IBOutlet UILabel *signedUpLabel;
@property (weak, nonatomic) IBOutlet UILabel *notifyTenantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *emaildescLabel;
@property (weak, nonatomic) IBOutlet UILabel *smsdescLabel;
@property (weak, nonatomic) IBOutlet UILabel *calldescLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *searchCancelButton;

@end


NSArray *notButtonArray, *notByKeyArray, *notByImageNameArray;

NSMutableDictionary *notByDictionary;

NSMutableArray *notByTickImageArray;

int selectedTenantsCount;

@implementation SelectTenantsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Localization
    self.title = LocalizedString(@"CreateIssue");
    _searchController.placeholder = LocalizedString(@"Search");
    _notSignupLabel.text = LocalizedString(@"NotSignedUpToDomumLink");
    _signedUpLabel.text = LocalizedString(@"SignedUptoDomumLink");
    _notifyTenantsLabel.text = LocalizedString(@"NOTIFYTENANTSBY");
    _emaildescLabel.text = LocalizedString(@"Email");
    _smsdescLabel.text = LocalizedString(@"SMS");
    _calldescLabel.text = LocalizedString(@"Call");
    [_backButton setTitle:LocalizedString(@"BACK") forState:UIControlStateNormal];
    [_nextButton setTitle:LocalizedString(@"NEXT") forState:UIControlStateNormal];
    selectTenantsLabel.text = [NSString stringWithFormat:@"%@ (0)", LocalizedString(@"SelectTenants")];
    [_searchCancelButton setTitle:LocalizedString(@"Cancel") forState:UIControlStateNormal];
    
    
    
    self.navigationItem.hidesBackButton = YES;
    
    selectedTenantsCount = 0;
    _selectedTenants = [NSMutableDictionary dictionary];
    _selectedDict = [NSMutableDictionary dictionary];
    
    stepLabel.layer.cornerRadius = 3;
    stepLabel.clipsToBounds = YES;
    
    legendNotSignedUpView.layer.cornerRadius = legendNotSignedUpView.frame.size.width/2;
    legendSignedUpView.layer.cornerRadius = legendSignedUpView.frame.size.width/2;
    
    notByMessageButton.layer.cornerRadius = notByMessageButton.frame.size.width/2;
    notByVibrationButton.layer.cornerRadius = notByVibrationButton.frame.size.width/2;
    notByAudioButton.layer.cornerRadius = notByAudioButton.frame.size.width/2;
    [self initNotifyByButtons];
    
    self.tableView.SKSTableViewDelegate = self;
    //    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    
    NSString *buildingId = nil;
    if ([Utilities isValidString:[GlobalVars sharedInstance].toCreateIssue[@"LocationBuildingId"]])
        buildingId = [NSString stringWithFormat:@"%@", [GlobalVars sharedInstance].toCreateIssue[@"LocationBuildingId"]];
    
    [[APIController sharedInstance] getPossibleTenantsWithRecipientType:[[GlobalVars sharedInstance].toCreateIssue[@"RecipientType"] integerValue] buildingId:buildingId successHandler:^(id jsonData) {
        NSLog(@"%@", jsonData);
        
        if (jsonData == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            _allTenantArray = [NSMutableArray array];
            _filteredArray = [NSMutableArray array];
            NSArray *keysArray = [jsonData allKeys];
            for (int i=0; i<keysArray.count; i++) {
                if (![keysArray[i] isEqualToString:@"All"]) {
                    NSMutableArray *subArray = [NSMutableArray array];
                    
                    [subArray addObject:keysArray[i]];
                    
                    NSArray *tenants = jsonData[keysArray[i]];
                    
                    [subArray addObjectsFromArray:tenants];
                    
                    [_allTenantArray addObject:subArray];
                    [_filteredArray addObject:subArray];
                }
            }
            
            if (_tenantId) {
//                [_filteredArray removeAllObjects];
//                isSearched = YES;
//                for (NSArray *array in _allTenantArray) {
//                    if (array.count > 0) {
//                        NSMutableArray *subArray = [[NSMutableArray alloc] init];
//                        [subArray addObject:array[0]];
//                        for (int i=1; i<array.count; i++) {
//                            NSString *userId = array[i][@"UserId"];
//                            
//                            if ([userId integerValue] == _tenantId) {
//                                [subArray addObject:array[i]];
//                            }
//                        }
//                        [_filteredArray addObject:subArray];
//                    }
//                }
                [_selectedTenants setObject:@{@"UserId" : @(_tenantId)} forKey:@(_tenantId)];
                selectedTenantsCount = 1;
                
                selectTenantsLabel.text = [NSString stringWithFormat:@"%@ (1)", LocalizedString(@"SelectTenants")];
            }
            
            [self.tableView refreshData];
        }
    } withFailureHandler:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (BOOL)isSelected:(NSString*)tenantName {
//    for (NSString *tenant in _buildingTenantArray) {
//        if ([tenant isEqualToString:tenantName]) {
//            return YES;
//        }
//    }
    return NO;
}

- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextClicked:(id)sender{
    NSLog(@"%@", _filteredArray);
    
    NSMutableArray *userIds = [NSMutableArray array];
    for (NSDictionary *dict in [_selectedTenants allValues]) {
        [userIds addObject:[NSString stringWithFormat:@"%@", dict[@"UserId"]]];
    }
    if (userIds.count > 0)
        [[GlobalVars sharedInstance].toCreateIssue setObject:userIds forKey:@"RecipientIds"];
    else {
        [Utilities showMsg:LocalizedString(@"PleaseSelectAtLeastOneTenant")];
        return;
    }
    
    NSString * updateByEmail = [notByDictionary objectForKey:notByKeyArray[0]] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:updateByEmail forKey:@"NotifyRecipientsEmail"];

    NSString * updateBySms = [notByDictionary objectForKey:notByKeyArray[1]] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:updateBySms forKey:@"NotifyRecipientsSms"];

    NSString * updateByVoice = [notByDictionary objectForKey:notByKeyArray[2]] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:updateByVoice forKey:@"NotifyRecipientsVoice"];
    
    if ([[GlobalVars sharedInstance].toCreateIssue[@"RecipientType"] integerValue] == ERecipientTypeTenant) {
        [self performSegueWithIdentifier:@"assignEmployeesSegue" sender:nil];
    }
    else
        [self performSegueWithIdentifier:@"GoStep4VC" sender:nil];
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

#pragma mark - UISearchBarDelegate


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    
}
- (IBAction)onClickCancel:(id)sender {
    [_searchController resignFirstResponder];
    _searchController.text = @"";
    isSearched = NO;
    _filteredArray = [NSMutableArray arrayWithArray:_allTenantArray];
    [self.tableView refreshData];
    _searchCancelButton.enabled = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchCancelButton.enabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [_filteredArray removeAllObjects];
    isSearched = YES;
    for (NSArray *array in _allTenantArray) {
        if (array.count > 0) {
            NSMutableArray *subArray = [[NSMutableArray alloc] init];
            [subArray addObject:array[0]];
            for (int i=1; i<array.count; i++) {
                NSString *name = array[i][@"Name"];
                
                if ([name rangeOfString:searchBar.text options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [subArray addObject:array[i]];
                }
            }
            [_filteredArray addObject:subArray];
        }
    }
    [self.tableView refreshData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   
    return _filteredArray.count > 0 ? 1 : 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _filteredArray.count;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%lu", [_filteredArray[indexPath.row] count] - 1);
    return [_filteredArray[indexPath.row] count] - 1;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearched)
        return YES;
    
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        return YES;
    }
    
    if (_tenantId)
        return YES;
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectTenantsBuildingCell";
    
    SelectTenantsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SelectTenantsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.tenantNameLabel.text = _filteredArray[indexPath.row][0];
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
    NSMutableDictionary *tenant = _filteredArray[indexPath.row][indexPath.subRow];
    
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
    NSMutableDictionary* tenant = _filteredArray[indexPath.row][indexPath.subRow];
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
    selectTenantsLabel.text = [NSString stringWithFormat:@"%@ (%lu)", LocalizedString(@"SelectTenants"), (unsigned long)[[_selectedTenants allKeys] count]];
}

-(void)tableView:(SKSTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"assignEmployeesSegue"]) {
        NSMutableArray *selectedBulidings = [NSMutableArray array];
        for (NSArray *array in _filteredArray) {
            for (int i=1; i<array.count; i++) {
                NSDictionary *dict = array[i];
                if ([dict[@"isSelected"] boolValue]) {
                    [selectedBulidings addObject:array[0]];
                    break;
                }
            }
        }
        
        AssignEmployeesVC *destVC = (AssignEmployeesVC *)[segue destinationViewController];
        destVC.selectedBuildinArray = selectedBulidings;
    }
}

@end
