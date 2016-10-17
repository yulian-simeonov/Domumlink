//
//  TestViewController.m
//  DomumLink
//
//  Created by iOS Dev on 5/16/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "IssueManagerTenantsTabVC.h"
#import "IssueAddRecipientCell.h"
#import "SKSTableView.h"
#import "SelectTenantsCell.h"
#import "IssueManagerGeneralVC.h"

@interface IssueManagerTenantsTabVC ()  <SKSTableViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>{
    bool addRecipientsClicked;
    ERecipientType recipientType;
}


@property (nonatomic, weak) IBOutlet SKSTableView* tableView;
@property (weak, nonatomic) IBOutlet UITableView *buildingTenantsTable;

@property (nonatomic, retain) NSMutableArray *buildingTenantArray;
@property (nonatomic, retain) NSMutableArray *allTenantArray;

@property (nonatomic, retain) NSMutableDictionary *selectedTenants;

@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end


NSArray *notButtonArray, *notByKeyArray, *notByImageNameArray;

NSMutableDictionary *notByDictionary;

NSMutableArray *notByTickImageArray;

int selectedTenantsCount;

@implementation IssueManagerTenantsTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.SKSTableViewDelegate = self;
    //    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundView:nil];
    
    _selectedTenants = [NSMutableDictionary dictionary];
    
    _buildingTenantArray = [NSMutableArray array];
    [self loadTableData];
    
    NSString *buildingId = nil;
    if ([Utilities isValidString:self.issueDictionary[@"LocationInfo"][@"BuildingId"]]) {
        buildingId = self.issueDictionary[@"LocationInfo"][@"BuildingId"];
    }
    
    recipientType = [self.issueDictionary[@"RecipientType"] integerValue];
    if (recipientType == ERecipientTypeEmployee)
        [_editButton setTitle:LocalizedString(@"EditAssignees") forState:UIControlStateNormal];
    else {
        _editButton.hidden = ![[GlobalVars sharedInstance] hasEditRecipientPermission];
        [_editButton setTitle:LocalizedString(@"EditRecipients") forState:UIControlStateNormal];
    }
   [_editButton setTitle:LocalizedString(@"SaveChanges") forState:UIControlStateSelected];
    
    [[APIController sharedInstance] getPossibleTenantsWithRecipientType:[_issueDictionary[@"RecipientType"] integerValue] buildingId:buildingId successHandler:^(id jsonData) {
        if (jsonData == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            _allTenantArray = [NSMutableArray array];
            NSArray *keysArray = [jsonData allKeys];
            for (int i=0; i<keysArray.count; i++) {
                NSMutableArray *subArray = [NSMutableArray array];
                
                [subArray addObject:keysArray[i]];
                
                NSArray *tenants = jsonData[keysArray[i]];
                for (int j=0; j<[tenants count]; j++) {
                    NSMutableDictionary *dict = tenants[j];
                    
                    
                    BOOL isSelected = [self isSelected:[dict[@"UserId"] integerValue]];
                    [dict setObject:@(isSelected) forKey:@"isSelected"];
                    
                    if (isSelected) {
                        [_selectedTenants setObject:dict forKey:dict[@"UserId"]];
                    }
                    
                }
                [subArray addObjectsFromArray:tenants];
                
                [_allTenantArray addObject:subArray];
                [_buildingTenantsTable reloadData];
            }
        }
    } withFailureHandler:^(NSError *error) {
        NSLog(@"%@", error);
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTableData {
    [_buildingTenantArray removeAllObjects];
    [_buildingTenantArray addObjectsFromArray:self.issueDictionary[@"Recipients"]];
}

- (BOOL)isSelected:(NSInteger)tenantId {
    for (NSDictionary *tenant in _buildingTenantArray) {
        if ([tenant[@"UserId"] integerValue] == tenantId) {
            return YES;
        }
    }
    return NO;
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



- (IBAction)addRecipientsClicked:(id)sender{
    [sender setSelected:![sender isSelected]];
    addRecipientsClicked = [sender isSelected];
    if (addRecipientsClicked) {
        _buildingTenantsTable.hidden = YES;
    } else {
        [SVProgressHUD show];
        [[APIController sharedInstance] updateTenantWithIssueId:[_issueDictionary[@"IssueId"] integerValue] tenants:[_selectedTenants allValues] successHandler:^(id jsonData) {
            
            [SVProgressHUD dismiss];
            
            [self.issueDictionary setObject:jsonData[@"recipients"] forKey:@"Recipients"];
            [self loadTableData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiIssueUpdated object:_issueDictionary];
        } withFailureHandler:^(NSError *error) {
            NSLog(@"%@", error);
            [SVProgressHUD dismiss];
        }];
        
        _buildingTenantsTable.hidden = NO;
    }
    
    
    [self.tableView reloadData];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (addRecipientsClicked)
        return _buildingTenantArray ? 1 : 0;
    else
        return _allTenantArray ? 1 : 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableView == _buildingTenantsTable ? _buildingTenantArray.count : _allTenantArray.count;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [_allTenantArray[indexPath.row] count] - 1;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        return YES;
    }
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _buildingTenantsTable) {
        static NSString *CellIdentifier = @"SelectTenantsCell";

        SelectTenantsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
            cell = [[SelectTenantsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.tenantNameLabel.text = [NSString stringWithFormat:@"%@", _buildingTenantArray[indexPath.row][@"Name"]];
        
        // Apply Tenant Detail
        NSDictionary *tenantDict = _selectedTenants[_buildingTenantArray[indexPath.row][@"UserId"]];
        if (tenantDict) {
            if (recipientType == ERecipientTypeEmployee) { // In case of Internal issue
                cell.signedupView.hidden = YES;
            } else {
                cell.signedupView.hidden = NO;
                cell.signedupView.layer.cornerRadius = 3.5;
                if ([tenantDict[@"SignupStatus"] boolValue])
                    cell.signedupView.backgroundColor = [UIColor greenColor];
                else
                    cell.signedupView.backgroundColor = UNIT_RED_COLOR;
            }
            
            NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc] init];

            NSAttributedString *nameAtrStr = [[NSAttributedString alloc] initWithString:tenantDict[@"Name"] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f], NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
            
            [muAtrStr appendAttributedString:nameAtrStr];
            
            if ([Utilities isValidString:tenantDict[@"UnitName"]] &&
                recipientType != ERecipientTypeEmployee) {
                NSString *unitStr = [NSString stringWithFormat:@" - %@", tenantDict[@"UnitName"]];
                
                NSAttributedString *unitAtrStr = [[NSAttributedString alloc] initWithString:unitStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.0f], NSForegroundColorAttributeName : BLUE_COLOR}];
                

                [muAtrStr appendAttributedString:unitAtrStr];
            }
            
            cell.tenantNameLabel.attributedText = muAtrStr;
            
            NSString *homeNumber = tenantDict[@"HomeNumber"];
            NSString *mobileNumber = tenantDict[@"MobileNumber"];
            if (![Utilities isValidString:homeNumber] && ![Utilities isValidString:mobileNumber]) {
                cell.callButton.hidden = YES;
            } else {
                cell.callButton.hidden = NO;
                cell.callButton.tag = indexPath.row;
                [cell.callButton addTarget:self action:@selector(onClickCallButton:) forControlEvents:UIControlEventTouchUpInside];
            }
        } else {
            cell.signedupView.hidden = YES;
        }
        
        return cell;
        
    } else {
        static NSString *CellIdentifier = @"SelectTenantsBuildingCell";
        
        SelectTenantsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell)
            cell = [[SelectTenantsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.tenantNameLabel.text = [NSString stringWithFormat:@"%@", _allTenantArray[indexPath.row][0]];
        cell.expandable = YES;
        
        return cell;
    }
}

- (void)onClickCallButton:(UIButton *)sender {
    NSInteger index = [sender tag];
    NSDictionary *tenantDict = _selectedTenants[_buildingTenantArray[index][@"UserId"]];
    
    NSMutableArray *numberArray = [NSMutableArray array];
    
    NSString *mobileNumber = tenantDict[@"MobileNumber"];
    NSString *homeNumber = tenantDict[@"HomeNumber"];
    
    if ([Utilities isValidString:mobileNumber])
        [numberArray addObject:[NSString stringWithFormat:@"%@: %@", LocalizedString(@"Mobile"), mobileNumber]];
    if ([Utilities isValidString:homeNumber])
        [numberArray addObject:[NSString stringWithFormat:@"%@: %@", LocalizedString(@"Home"), homeNumber]];
    
    UIAlertView *alert;
    if (numberArray.count == 1) {
        alert = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:numberArray[0], nil];
    } else if (numberArray.count == 2) {
        alert = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:numberArray[0], numberArray[1], nil];
    }
    if (alert)
        [alert show];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectTenantsCell";
    
    SelectTenantsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SelectTenantsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (addRecipientsClicked) {
    
        cell.expandable = NO;
        NSMutableDictionary *tenant = _allTenantArray[indexPath.row][indexPath.subRow];
        

        NSString *name = tenant[@"Name"];

        if (tenant[@"UnitName"] && [Utilities isValidString:tenant[@"UnitName"]]) {
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@", name, tenant[@"UnitName"]]];
            [attrString addAttributes:@{NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(name.length, attrString.length - name.length)];
            
            [cell.tenantNameLabel setAttributedText:attrString];
        }
        else
            cell.tenantNameLabel.text = [NSString stringWithFormat:@"%@", name];

        NSString *imageName = [tenant[@"isSelected"] boolValue] ? @"add_tenant_checked" : @"add_tenant_unchecked";
        
        cell.selectionImageView.image = [UIImage imageNamed:imageName];

        if (recipientType == ERecipientTypeEmployee) { // In case of Internal issue
            cell.signedupView.hidden = YES;
        } else {
            cell.signedupView.hidden = NO;
            cell.signedupView.layer.cornerRadius = cell.signedupView.frame.size.width/2;
            if ([tenant[@"SignupStatus"] boolValue]) {
                cell.signedupView.backgroundColor = [UIColor greenColor];
            } else {
                cell.signedupView.backgroundColor = UNIT_RED_COLOR;
            }
        }
    }
    
    
    return cell;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView == _buildingTenantsTable ? 44.0f : 30.0f;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* tenant = _allTenantArray[indexPath.row][indexPath.subRow];
    [tenant setObject:@(![tenant[@"isSelected"] boolValue]) forKey:@"isSelected"];
    
    if([tenant[@"isSelected"] boolValue]){
        selectedTenantsCount++;
        [_selectedTenants setObject:tenant forKey:tenant[@"UserId"]];
    }
    else
    {
        selectedTenantsCount--;
        [_selectedTenants removeObjectForKey:tenant[@"UserId"]];
    }
    
    [tableView reloadData];
//    selectTenantsLabel.text = [NSString stringWithFormat:@"Select Tenants (%i)", selectedTenantsCount];
}

-(void)tableView:(SKSTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex > 0) {
        NSString *number = [[alertView buttonTitleAtIndex:buttonIndex] componentsSeparatedByString:@":"][1];
        
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",[number stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
        } else {
            [[[UIAlertView alloc]initWithTitle:@"DomumLink" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
        }
    }
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
