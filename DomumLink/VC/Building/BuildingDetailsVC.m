//
//  BuildingDetailsVC.m
//  
//
//  Created by Yulian Simeonov on 1/24/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "BuildingDetailsVC.h"
#import "Building.h"
#import "Floor.h"
#import "Room.h"
#import "KGModal.h"
#import "BuildingBasicInfoModalVC.h"
#import "TenantDetailsVC.h"
#import "EmergencyContactCell.h"

@interface BuildingDetailsVC (){
    
    IBOutlet UILabel *buildingNameLabel;
    
    IBOutlet UILabel *buildingAddressLabel;
    
    IBOutlet UIImageView *buildingImageView;

    IBOutlet UITableView *floorTableView;
    
    IBOutlet UIView *helpView;
    
    IBOutlet UIView *basicInfoView;
    
    BOOL isLoaded;
    
    NSArray *emergencyContacts;
}

@property (nonatomic) id gotenantdetailObserver;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buildinginfoViewHeiConstraint;

// Localization
@property (weak, nonatomic) IBOutlet UIImageView *helpImage;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (weak, nonatomic) IBOutlet UITableView *emergencyTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emerTableHeiConstraint;

@property (weak, nonatomic) IBOutlet UIView *emerTableContainerView;
@end

NSURLConnection *detailsRequest, *unitsRequest;

NSMutableData *detailsResponseData, *unitsResponseData;

NSMutableArray *floorArray;

@implementation BuildingDetailsVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_gotenantdetailObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GoTenantDetail" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _gotenantdetailObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"GoTenantDetail" object:nil queue:nil usingBlock:^(NSNotification* note) {
        TenantDetailsVC *tenantVC = [self.storyboard instantiateViewControllerWithIdentifier:@"tenantDetailsViewPage"];
        tenantVC.tenantId = [NSString stringWithFormat:@"%@", note.object[@"TenantID"]];
        [self.navigationController pushViewController:tenantVC animated:YES];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Localization
    self.title = LocalizedString(@"BuildingStatus");
    [_dismissButton setTitle:LocalizedString(@"Dismiss") forState:UIControlStateNormal];
    _helpImage.image = [GlobalVars sharedInstance].langCode == ELangEnglish ? [UIImage imageNamed:@"img_unitHelp.png"] : [UIImage imageNamed:@"img_unitHelp_fr.png"];
    

    floorTableView.hidden = YES;
    _emerTableContainerView.hidden = YES;
    // Start Connection...
    
    buildingNameLabel.text = _buildingDict[@"BuildingName"];
    buildingAddressLabel.text = @"";
    
    
    if (_buildingDict[@"BuildingImage"] && ![_buildingDict[@"BuildingImage"] isKindOfClass:[NSNull class]]) {
        [buildingImageView sd_setImageWithURL:[NSURL URLWithString:_buildingDict[@"BuildingImage"][@"Url"]] placeholderImage:[UIImage imageNamed:@"img_nobuilding"]];
    }
    
    isLoaded = NO;
    
    [SVProgressHUD show];
    [[APIController sharedInstance] getBuildingDetailsWithBuildingId:_buildingDict[@"BuildingId"] withSuccessHandler:^(id jsonData) {
        if (jsonData == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            NSDictionary *dictionary = (NSDictionary*)jsonData;
            if(dictionary[@"Building"] && ![dictionary[@"Building"] isKindOfClass:[NSNull class]]){
                if (dictionary[@"Building"][@"EmergencyContacts"] &&
                    ![dictionary[@"Building"][@"EmergencyContacts"] isKindOfClass:[NSNull class]] &&
                    [dictionary[@"Building"][@"EmergencyContacts"] count] > 0) {
                    
                    _emerTableContainerView.hidden = NO;
                    _emerTableHeiConstraint.constant = 122;
                    
                    emergencyContacts = dictionary[@"Building"][@"EmergencyContacts"];
//                    [floorTableView addSubview:_emerTableContainerView];
                    [floorTableView reloadData];
                    
                } else {
                    _emerTableContainerView.hidden = YES;
                    _emerTableHeiConstraint.constant = 0;
//                    [_emerTableContainerView removeFromSuperview];
                }
                
                NSDictionary *addressDict = dictionary[@"Building"][@"Address"];
                if(addressDict && ![addressDict isKindOfClass:[NSNull class]]){
                    NSString *addressLine1Str = GET_VALIDATED_STRING(addressDict[@"AddressLine1"], @"");
                    NSString *cityStr = GET_VALIDATED_STRING(addressDict[@"City"], @"");
                    NSString *countryStr = GET_VALIDATED_STRING(addressDict[@"CountryName"], @"");
                    NSString *zipcodeStr = GET_VALIDATED_STRING(addressDict[@"ZipCode"], @"");
                    buildingAddressLabel.text = [NSString stringWithFormat:@"%@, %@, %@ %@", addressLine1Str, cityStr, countryStr, zipcodeStr];
                }
            }
        }
                
        if (isLoaded) {
            [SVProgressHUD dismiss];
        } else {
            isLoaded = YES;
        }
    } failureHandler:^(NSError *error) {
        NSLog(@"%@", [error description]);
        if (isLoaded) {
            [SVProgressHUD dismiss];
        } else {
            isLoaded = YES;
        }
    }];
    
    [[APIController sharedInstance] getBuildingUnitsWithUnitType:@"Apartment" andBuildingId:_buildingDict[@"BuildingId"] successHandler:^(id jsonData) {
        if (jsonData == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            NSDictionary *dictionary = (NSDictionary*)jsonData;
            floorTableView.hidden = NO;
            floorArray = dictionary[@"Floors"];
            [floorTableView reloadData];
        }
        if (isLoaded) {
            [SVProgressHUD dismiss];
        } else {
            isLoaded = YES;
        }
    } failureHandler:^(NSError *error) {
        NSLog(@"%@", [error description]);
        if (isLoaded) {
            [SVProgressHUD dismiss];
        } else {
            isLoaded = YES;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Scroll Event
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentSize.height < scrollView.frame.size.height)
        return;
    
    if (scrollView.contentOffset.y > 5 && _buildinginfoViewHeiConstraint.constant == 190) {
        [UIView animateWithDuration:0.3 animations:^{
            _buildinginfoViewHeiConstraint.constant = 141;
            [self.view layoutIfNeeded];            
        }];
    } else if  (scrollView.contentOffset.y < 5 && _buildinginfoViewHeiConstraint.constant == 141) {
        [UIView animateWithDuration:0.3 animations:^{
            _buildinginfoViewHeiConstraint.constant = 190;
            [self.view layoutIfNeeded];
        }];
    }
}
- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)helpClicked:(UIButton *)sender{
    helpView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        helpView.alpha = 1.0;
    }];
}

- (IBAction)dismissHelpClicked:(id)sender{
    helpView.alpha = 0;
    helpView.hidden = YES;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *phNo = emergencyContacts[indexPath.row][@"PhoneNumber"];
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",[phNo stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
        } else
        {
            [[[UIAlertView alloc]initWithTitle:@"DomumLink" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _emergencyTable) {
        return 1;
    }
//    if (tableView == floorTableView && section == 0)
//        return _emerTableContainerView.frame.size.height;
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
//    if (tableView ==  floorTableView && section == 0) {
//        UIView *transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, floorTableView.frame.size.width, _emerTableContainerView.frame.size.height)];
//        [transparentView setBackgroundColor:[UIColor clearColor]];
//        return transparentView;
//    }
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, floorTableView.frame.size.width, 25)];
    [footerView setBackgroundColor:self.view.backgroundColor];
    
    return footerView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    if (tableView == _emergencyTable) {
//        return 1;
//    }
//    return floorArray.count;
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? emergencyContacts.count : floorArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return indexPath.row == 0 ? 75 : 35;
    } else {
        NSArray *unitArray = floorArray[indexPath.row][@"Units"];
        if (unitArray.count == 0)
            return 50;
        return 102+((unitArray.count-1)/4)*45 + 10;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        EmergencyContactCell *cell = (EmergencyContactCell *)[tableView dequeueReusableCellWithIdentifier:@"emergencyContactCell"];
        if(cell == nil){
            cell = [[EmergencyContactCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"emergencyContactCell"];
        }
        
        if (indexPath.row > 0)
            cell.headerViewHeiConstraint.constant = 0;
        else
            cell.headerViewHeiConstraint.constant = 40;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSDictionary *contact = emergencyContacts[indexPath.row];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", contact[@"FullName"], contact[@"Title"]]];
        
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[contact[@"FullName"] length])];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange([contact[@"FullName"] length], [contact[@"Title"] length]+3)];
        
        cell.phoneNumberLabel.attributedText = string; //[Utilities formatPhoneNumber:contact[@"PhoneNumber"] deleteLastChar:NO];
        cell.titleLabel.text = LocalizedString(@"EmergencyContacts");
        
        return cell;
    } else {
        
        NSDictionary *floor = floorArray[indexPath.row];
        
        BuildingDetailsCell *cell = (BuildingDetailsCell *)[tableView dequeueReusableCellWithIdentifier:@"buildingDetailsCell"];
        if(cell == nil){
            cell = [[BuildingDetailsCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"buildingDetailsCell"];
        }
        
        // Localization
        cell.floorNoLabel.text = [NSString stringWithFormat:@"%@ %@", LocalizedString(@"FLOOR"), floor[@"FloorName"]];
        cell.roomInfoDelegate = self;
        
    //    if(indexPath.section == 0)
    //        cell.helpButton.hidden = NO;
    //    else
    //        cell.helpButton.hidden = YES;
        
        cell.unitArray = floor[@"Units"];
        
        [cell.unitCollectionView reloadData];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void)onRoomClicked:(NSString *)unitId {
    [KGModal sharedInstance].closeButtonType = KGModalCloseButtonTypeRight;
    
    
    BuildingBasicInfoModalVC *popupController = (BuildingBasicInfoModalVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"PopupView"];
    popupController.providesPresentationContextTransitionStyle = YES;
    popupController.definesPresentationContext = YES;
    popupController.modalPresentationStyle = UIModalPresentationCustom;
    popupController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    popupController.unitId = unitId;
    [self presentViewController:popupController animated:YES completion:nil];
//    [[KGModal sharedInstance] showWithContentView:popupController.view andAnimated:YES];    
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