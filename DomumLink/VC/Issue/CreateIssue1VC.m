//
//  CreateIssue1VC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 4/17/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "CreateIssue1VC.h"
#import "KGModal.h"
#import "SelectImageVC.h"
#import "ChooseIssueInfoViewController.h"
#import "PlaceholderTextView.h"
#import "SelectTenantsVC.h"

#define kRowCount 5

@interface CreateIssue1VC (){
    IBOutlet UITableView *createIssueTableView;
    
    PlaceholderTextView *descriptionTextView;
    
    NSInteger selectedIndex;
    
    NSDictionary *categoryDict;
    NSDictionary *locationTypeDict;
    NSDictionary *buildingDict;
    NSDictionary *locationDict;
    NSDictionary *floorDict;
    NSDictionary *unitDict;
    NSMutableDictionary *selectedIndexDict;
    
    NSInteger rowCount;
}
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

// Localization
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;


@end

enum CreateIssueRows{
    Row_General_Information,
    Row_Description,
    Row_Select_Images,
    Row_Select_Category,
    Row_Location,
    Row_Select_Building,
    Row_Select_Location,
    Row_Select_Floor
};

NSArray *cellIdArray;

#define DESCRIPTION_PLACEHOLDER @"Enter a Description here..."

@implementation CreateIssue1VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Localization
    self.title = _recipientType == ERecipientTypeEmployee ? LocalizedString(@"CreateEmployeeIssue") : LocalizedString(@"CreateTenantIssue");
    [_nextButton setTitle:[NSString stringWithFormat:@" %@", LocalizedString(@"NEXT")] forState:UIControlStateNormal];
    [_doneButton setTitle:LocalizedString(@"Done")];
    
    selectedIndexDict = [NSMutableDictionary dictionary];
    
    cellIdArray = @[@"generalInformationCell", @"descriptionCell", @"selectImagesCell", @"selectCategoryCell", @"locationCell", @"BuildingCell", @"BuildingLocationCell", @"FloorCell"];
    
    if (_tenantId) { // Issue Creation directly by selecting tenant in tenant list page
        locationTypeDict = @{@"Name":LocalizedString(@"Apartment"), @"Value":@2};
        if (_tenantBuildingInfo) {
            buildingDict = _tenantBuildingInfo;
            unitDict = _tenantBuildingInfo[@"UnitDict"];
        }
        [self updateRowCount];
        [createIssueTableView reloadData];
    } else {
        rowCount = kRowCount;
    }
    
    [SVProgressHUD show];
    [[APIController sharedInstance] getModelForNewIssueWithRecipientType:_recipientType successHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        [GlobalVars sharedInstance].toCreateIssue = [NSMutableDictionary dictionaryWithDictionary:jsonData];
    } failureHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        
        [Utilities showMsg:@"No permissions to create issue!"];
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"%@", [error description]);
    }];
}

- (void)viewDidLayoutSubviews{
    if ([createIssueTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [createIssueTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([createIssueTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [createIssueTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Issue Info Handler
- (void)handleIssueInfo:(NSDictionary *)info Type:(NSInteger)type Index:(NSInteger)index delegate:(id)delegate {
    switch (type) {
        case 1: {
            categoryDict = info;
        }
            break;
        case 2: {
//            if (index > 1) // Ignore index 0, 1. There are Select building and None.
                locationTypeDict = info;
        }
            break;
        case 3: {
            buildingDict = info;
            unitDict = nil;
            floorDict = nil;
            [selectedIndexDict setObject:@0 forKey:@5];
            [selectedIndexDict setObject:@0 forKey:@6];
        }
            break;
        case 4: {
            locationDict = info;
            if (info == nil) {
                floorDict = nil;
                [selectedIndexDict setObject:@0 forKey:@5];
            }
        }
            break;
        case 5: {
            floorDict = info;
        }
            break;
        case 6: {  // Building Unit
            unitDict = info;
        }
            break;
        default:
            break;
    }
    
    [self updateRowCount];
    
    [createIssueTableView reloadData];
    [createIssueTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowCount-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [selectedIndexDict setObject:@(index) forKey:@(type)];
    
}

- (void)updateRowCount {
    rowCount = kRowCount;
    if (locationTypeDict) {
        if ([locationTypeDict[@"Value"] integerValue] == 2) { // Apartment Selected
            if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) { // My Apartment Selected
                // No needs to set building.
                rowCount = kRowCount;
            } else {
                if (_tenantId) { // Tenant Issue creation directly by selecting tenant in tenant list page
                    ++rowCount;
                    if (buildingDict) {
                        rowCount = rowCount+1; // Value:1 Common Area, Value:2 Apartment
                    }
                } else {
                    ++rowCount;
                    if (buildingDict) {
                        rowCount = rowCount+1; // Value:1 Common Area, Value:2 Apartment
                    }
                }
            }
        } else if ([locationTypeDict[@"Value"] integerValue] == 1) { // Common Area
            ++rowCount;
            if (buildingDict) {
                rowCount = rowCount + 2;
            }
        }
    }
}

#pragma mark - UIButton Action

- (IBAction)backClicked:(id)sender{
    [[GlobalVars sharedInstance].toCreateIssue setObject:@[] forKey:@"ImageIds"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextClicked:(id)sender{
    
    if (![Utilities isValidString:descriptionTextView.text]) {
        [Utilities showMsg:LocalizedString(@"IssueDescriptionIsARequiredField")];
        return;
    }
    
    if (!categoryDict) {
        [Utilities showMsg:LocalizedString(@"CategoryIsARequiredField")];
        return;
    }
    
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) {
        // No needs to select building or aparment for Tenant user.
    } else {
        if (locationTypeDict && [locationTypeDict[@"Value"] integerValue] > 0 && !buildingDict) {
            [Utilities showMsg:LocalizedString(@"PleaseSelectBuilding")];
            return;
        }
        
        if ([locationTypeDict[@"Value"] integerValue] == 2) { // Location type is Apartment
            if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant || _tenantId) {
                // My apartment selected
            } else {
                if (buildingDict && !unitDict) {
                    [Utilities showMsg:LocalizedString(@"PleaseSelectApartment")];
                    return;
                }
            }
        }
    }
    
    if (descriptionTextView.text.length < 10) {
        [Utilities showMsg:LocalizedString(@"DescMustBe10")];
        return;
    }
    
    [[GlobalVars sharedInstance].toCreateIssue setObject:descriptionTextView.text forKey:@"Description"];
    
    if (locationTypeDict == nil) {
        [[GlobalVars sharedInstance].toCreateIssue setObject:categoryDict[@"Value"] forKey:@"CategoryId"];
        
        [[GlobalVars sharedInstance].toCreateIssue setObject:[NSNull null] forKey:@"LocationBuildingId"];
        [[GlobalVars sharedInstance].toCreateIssue setObject:[NSNull null] forKey:@"LocationId"];
        [[GlobalVars sharedInstance].toCreateIssue setObject:[NSNull null] forKey:@"LocationFloorId"];
        [[GlobalVars sharedInstance].toCreateIssue setObject:[NSNull null] forKey:@"LocationApartmentId"];
        
    } else {
        [[GlobalVars sharedInstance].toCreateIssue setObject:categoryDict[@"Value"] forKey:@"CategoryId"];
        
        if ([locationTypeDict[@"Value"] integerValue] == 0) { // Location type is None
            [[GlobalVars sharedInstance].toCreateIssue setObject:[NSNull null] forKey:@"LocationBuildingId"];
            [[GlobalVars sharedInstance].toCreateIssue setObject:[NSNull null] forKey:@"LocationId"];
            [[GlobalVars sharedInstance].toCreateIssue setObject:[NSNull null] forKey:@"LocationFloorId"];
            [[GlobalVars sharedInstance].toCreateIssue setObject:[NSNull null] forKey:@"LocationApartmentId"];
        } else if ([locationTypeDict[@"Value"] integerValue] == 1) { // Location type is Common Area
            
            if (locationTypeDict)
                [[GlobalVars sharedInstance].toCreateIssue setObject:locationTypeDict[@"Value"] forKey:@"LocationType"];
            if (buildingDict)
                [[GlobalVars sharedInstance].toCreateIssue setObject:buildingDict[@"Value"] forKey:@"LocationBuildingId"];
            
            if (locationDict)
                [[GlobalVars sharedInstance].toCreateIssue setObject:locationDict[@"Value"] forKey:@"LocationId"];

            if (floorDict)
                [[GlobalVars sharedInstance].toCreateIssue setObject:floorDict[@"Value"] forKey:@"LocationFloorId"];
        } else if ([locationTypeDict[@"Value"] integerValue] == 2) {
            if (locationTypeDict)
                [[GlobalVars sharedInstance].toCreateIssue setObject:locationTypeDict[@"Value"] forKey:@"LocationType"];
            if (buildingDict)
                [[GlobalVars sharedInstance].toCreateIssue setObject:buildingDict[@"Value"] forKey:@"LocationBuildingId"];
            if (unitDict)
                [[GlobalVars sharedInstance].toCreateIssue setObject:unitDict[@"Value"] forKey:@"LocationApartmentId"];
        }
    }
    
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) {
        [self performSegueWithIdentifier:@"ShowUpdateMeBy" sender:nil];
    } else {
        if ([[GlobalVars sharedInstance].toCreateIssue[@"RecipientType"] integerValue] == ERecipientTypeTenant) {
            if (self.tenantId) {
                [[GlobalVars sharedInstance].toCreateIssue setObject:@[@(self.tenantId)] forKey:@"RecipientIds"];
                
                [self performSegueWithIdentifier:@"selectTenantsSegue" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"selectTenantsSegue" sender:nil];
            }
        } else {
            [self performSegueWithIdentifier:@"selectAssigneesSegue" sender:nil];
        }
    }
}

- (IBAction)selectImagesClicked:(id)sender{
    if ([[GlobalVars sharedInstance].toCreateIssue[@"ImageIds"] count] > kPictureUploadLimit-1) {
        [Utilities showMsg:LocalizedString(@"YouHaveReachedPictureUploadLimit")];
    } else {
        [KGModal sharedInstance].closeButtonType = KGModalCloseButtonTypeNone;
        
        SelectImageVC *popupController = [self.storyboard instantiateViewControllerWithIdentifier:@"selectImagesPopupPage"];
        popupController.delegate = self;
        popupController.view.frame = CGRectMake(0, 0, 300, 80);
        //    [[KGModal sharedInstance] showWithContentView:popupController.view andAnimated:YES];
        [[KGModal sharedInstance] showWithContentViewc:popupController andAnimated:YES];
    }
}

- (IBAction)onClickDone:(id)sender {
    _toolbar.hidden = YES;
    [descriptionTextView resignFirstResponder];
}

#pragma mark - SelectImageVC Delegate
- (void)handleUploadedImage:(NSDictionary *)imageInfo {
    NSLog(@"%@", imageInfo);
    if (imageInfo[@"ImageId"] && ![imageInfo[@"ImageId"] isKindOfClass:[NSNull class]]) {
        [[KGModal sharedInstance] hideAnimated:YES];
        
        [[GlobalVars sharedInstance].toCreateIssue[@"ImageIds"] addObject:imageInfo[@"ImageId"]];
        
        [createIssueTableView reloadData];
    }
}

#pragma mark - UITextViewDelegate


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    _toolbar.hidden = NO;
//    descriptionTextView.text = @"";
//    descriptionTextView.textColor = RGB(102, 102, 102);
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
//    if(descriptionTextView.text.length == 0){
//        descriptionTextView.textColor = LIGHT_GRAY_COLOR1;
//        descriptionTextView.text = DESCRIPTION_PLACEHOLDER;
//        [descriptionTextView resignFirstResponder];
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if ([text isEqualToString:@"\n"])
//    {
//        [textView resignFirstResponder];
//    }
    return YES;
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    NSInteger rowCount = kRowCount;
    //    if (locationTypeDict) {
    //        rowCount++;
    //        if (buildingDict) {
    //            rowCount = [locationTypeDict[@"Value"] integerValue] == 1 ? rowCount+2 : rowCount+1; // Value:1 Common Area, Value:2 Apartment
    //        }
    //    }
    //
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == Row_General_Information || indexPath.row == Row_Select_Images)
        return 80;
    else if(indexPath.row == Row_Description)
        return 160;
    else
        return 44;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdArray[indexPath.row]];
    
    if(indexPath.row == Row_General_Information) {
        UILabel *generalinfoLabel = (UILabel *)[cell viewWithTag:10];
        generalinfoLabel.text = LocalizedString(@"GeneralInformation");
        
        UILabel *descLabel = (UILabel *)[cell viewWithTag:11];
        descLabel.text = LocalizedString(@"T50");
    } else if (indexPath.row == Row_Select_Images) {
        UIButton *button = (UIButton *)[cell viewWithTag:200];
        [button setTitle:[NSString stringWithFormat:@" %@", LocalizedString(@"SelectImages")] forState:UIControlStateNormal];
        button.layer.cornerRadius = 3;
        button.clipsToBounds = YES;
        
        UILabel *noteLabel = (UILabel *)[cell viewWithTag:10];
        if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) {
            noteLabel.text = LocalizedDateString(@"EmergencyCall");
            [noteLabel setTextColor:[UIColor redColor]];
        } else {
            noteLabel.text = LocalizedString(@"Note");
            [noteLabel setTextColor:[UIColor colorWithRed:90/255.0f green:171/255.0f blue:227/255.0f alpha:1.0f]];
        }
        
        if (_recipientType == ERecipientTypeEmployee)
            noteLabel.hidden = YES;
    }
    else if(indexPath.row == Row_Description){
        descriptionTextView = (PlaceholderTextView *)[cell viewWithTag:200];
        descriptionTextView.delegate = self;
        descriptionTextView.placeholder = LocalizedString(@"EnterDescriptionHere");
        descriptionTextView.placeholderColor = [UIColor lightGrayColor];
    }
    
    if (indexPath.row == Row_Select_Images) {
        UILabel *imageLabel = (UILabel *)[cell viewWithTag:1];
        imageLabel.text = [NSString stringWithFormat:@"(%lu/%d)", (unsigned long)[[GlobalVars sharedInstance].toCreateIssue[@"ImageIds"] count], kPictureUploadLimit];
        ;
    }
    
    if(indexPath.row < Row_Select_Category){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else{
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    if (indexPath.row == Row_Select_Category) {
        cell.textLabel.text = categoryDict ? categoryDict[@"Name"] : LocalizedString(@"SelectCategory");
    } else if (indexPath.row == Row_Location) {
        cell.textLabel.text = locationTypeDict ? locationTypeDict[@"Name"] : LocalizedString(@"SelectLocation");
    } else if (indexPath.row == Row_Select_Building) {
        cell.textLabel.text = buildingDict ? buildingDict[@"Name"] : LocalizedString(@"SelectBuilding");
    } else if (indexPath.row == Row_Select_Location) {
        if ([locationTypeDict[@"Value"] integerValue] == 1) // Common Area
            cell.textLabel.text = locationDict ? locationDict[@"Name"] : LocalizedString(@"UnspecifiedLocation");
        else if ([locationTypeDict[@"Value"] integerValue] == 2) { // Apartment
            cell.textLabel.text = unitDict ? unitDict[@"Name"] : LocalizedString(@"SelectUnit");
        }
    } else if (indexPath.row == Row_Select_Floor) {
        cell.textLabel.textColor = locationDict ? [UIColor darkGrayColor] : [UIColor lightGrayColor];
        
        cell.textLabel.text = floorDict ? floorDict[@"Name"] : LocalizedString(@"DoesNotApplyToAFloor");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row > 2) {
        if (indexPath.row == Row_Select_Floor) {
            if (locationDict == nil)
                return;
        }
        
        selectedIndex = indexPath.row - 2;
        if (indexPath.row == Row_Select_Location && [locationTypeDict[@"Value"] integerValue] == ELocationApartment)
            selectedIndex = 6;
        [self performSegueWithIdentifier:@"GoChooseIssueInfo" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"GoChooseIssueInfo"]) {
        ChooseIssueInfoViewController *destVC = (ChooseIssueInfoViewController *)[segue destinationViewController];
        destVC.infoType = selectedIndex;
        if (locationDict)
            destVC.locationId = [locationDict[@"Value"] integerValue];
        if (buildingDict)
            destVC.locationBuildingId = [buildingDict[@"Value"] integerValue];
        destVC.selIndex = selectedIndexDict[@(selectedIndex)] ? [selectedIndexDict[@(selectedIndex)] integerValue] : 0;
        destVC.delegate = self;
    } else if ([[segue identifier] isEqualToString:@"selectTenantsSegue"]) {
        SelectTenantsVC *destVC = (SelectTenantsVC *)[segue destinationViewController];
        destVC.tenantId = _tenantId;
    }
}


@end
