//
//  TenantDetailsVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/23/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "TenantDetailsVC.h"

#import "CreateIssue1VC.h"
#import "NSString+HTML.h"

@interface TenantDetailsVC () <UIAlertViewDelegate> {
    IBOutlet UILabel *fullnameLabel;
    
    IBOutlet UIButton *emailLabel;
    
    IBOutlet UIButton *mobileNumberLabel;
    
    IBOutlet UIButton *phoneNumberLabel;
    
    IBOutlet UIButton *genderLabel;
    
    IBOutlet UIButton *dateofbirthLabel;
    
    IBOutlet UILabel *leaseStartLabel;
    
    IBOutlet UILabel *moveInLabel;
    
    IBOutlet UILabel *leaseEndLabel;
    
    NSDictionary *unitDict;
    
    NSMutableDictionary *carDetailDict;

}
@property (weak, nonatomic) IBOutlet UILabel *apartmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildingnameLabel;
@property (weak, nonatomic) IBOutlet UITextView *emailTextView;
@property (weak, nonatomic) IBOutlet UIView *leaseInfoView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leaseinfoViewHeiConstraint;

// Localization
@property (weak, nonatomic) IBOutlet UILabel *leaseinfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildingDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *apartDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *leasestartDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaseendDescLabel;

@property (strong, nonatomic) IBOutlet UIView *tableContentView;
@property (weak, nonatomic) IBOutlet UIScrollView *detailScrollView;

// Car Details, Tenant Comments
@property (weak, nonatomic) IBOutlet UILabel *carMakeLabel;
@property (weak, nonatomic) IBOutlet UILabel *carModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenseLabel;
@property (weak, nonatomic) IBOutlet UILabel *carColorLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UIView *tenantCommentsView;

@property (weak, nonatomic) IBOutlet UIView *carDetailView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitBtnHeiConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *carDetailViewHeiConstraint;

@property (weak, nonatomic) IBOutlet UILabel *tenantCommentsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *carDetailsTitleLabel;
@end



NSDictionary *responseData, *buildingData;

@implementation TenantDetailsVC

NSString *phoneToCall;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Localization
    self.title = LocalizedString(@"Tenant");
    [_submitButton setTitle:LocalizedString(@"SubmitAnIssue") forState:UIControlStateNormal];
    _leaseinfoLabel.text = LocalizedString(@"LeaseInformation");
    _buildingDescLabel.text = LocalizedString(@"Building");
    _apartDescLabel.text = LocalizedString(@"Apartment");
    _leasestartDescLabel.text = LocalizedString(@"LeaseStart");
    _leaseendDescLabel.text = LocalizedString(@"LeaseEnd");
    _carDetailsTitleLabel.text = LocalizedString(@"CarDetails");
    _tenantCommentsTitleLabel.text = LocalizedString(@"TenantComments");
    
    emailLabel.hidden = YES;
    mobileNumberLabel.hidden = YES;
    phoneNumberLabel.hidden = YES;
    genderLabel.hidden = YES;
    dateofbirthLabel.hidden = YES;
    _leaseInfoView.hidden = YES;
    _submitButton.hidden = YES;
    _leaseinfoViewHeiConstraint.constant = 0;
    
    
    [SVProgressHUD show];
    
    [[APIController sharedInstance] getTenantDetailWithTenantId:[_tenantId integerValue] successHandler:^(id jsonData) {
        if (jsonData == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            
            responseData = (NSDictionary *)jsonData;
            NSDictionary *dictionary = (NSDictionary*)jsonData;
            NSDictionary *tenantDict = dictionary[@"Tenant"];
            fullnameLabel.text = tenantDict[@"Name"];
            
            NSDateFormatter *formatter = [GlobalVars sharedInstance].dateFormatterTime;
            
            if ([GlobalVars sharedInstance].langCode == ELangEnglish)
                [formatter setDateFormat:@"MMM dd, yyyy"];
            else
                [formatter setDateFormat:@"dd MMM yyyy"];
            
            NSString *email = GET_VALIDATED_STRING(tenantDict[@"Email"], LocalizedString(@"Unknown"));
            
            NSString *mobileNumber = [NSString stringWithFormat:@"%@: %@", LocalizedString(@"Call"), GET_VALIDATED_STRING(tenantDict[@"MobileNumber"], LocalizedString(@"Unknown"))];
            
            NSString *homeNumber = [NSString stringWithFormat:@"%@: %@", LocalizedString(@"Call"), GET_VALIDATED_STRING(tenantDict[@"HomeNumber"], LocalizedString(@"Unknown"))];
            
            NSDecimalNumber *gender = tenantDict[@"Sex"];
            
            NSString *dateOfBirth;
            
            if (![tenantDict[@"DateOfBirth"] isKindOfClass:[NSNull class]]) {
                NSInteger interval = [tenantDict[@"DateOfBirth"] integerValue];
                dateOfBirth = LocalizedDateString([formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]]);
            } else {
                dateOfBirth = LocalizedString(@"Unknown");
            }
            
            gender = gender == (id)[NSNull null] ? [[NSDecimalNumber alloc] initWithInt:0] : gender;
            
            _emailTextView.text = email;
            [mobileNumberLabel setTitle:mobileNumber forState:UIControlStateNormal];
            [phoneNumberLabel setTitle:homeNumber forState:UIControlStateNormal];
            
            if ([gender integerValue] == 0)
                [genderLabel setTitle:LocalizedString(@"Unknown") forState:UIControlStateNormal];
            if ([gender integerValue] == 1)
                [genderLabel setTitle:LocalizedString(@"Male") forState:UIControlStateNormal];
            if ([gender integerValue] == 2)
                [genderLabel setTitle:LocalizedString(@"Female") forState:UIControlStateNormal];
//            [genderLabel setImage:[UIImage imageNamed:[gender boolValue]  ? @"tenant_male_icon" : @"tenant_female_icon"] forState:UIControlStateNormal];
            
            if ([Utilities isValidString: tenantDict[@"DateOfBirth"]]) {
                [dateofbirthLabel setTitle:dateOfBirth forState:UIControlStateNormal];
            } else {
                [dateofbirthLabel setTitle:LocalizedString(@"Unknown") forState:UIControlStateNormal];
            }
            
            // Show/Hide Submit Button based on IsActive field
            if ([[GlobalVars sharedInstance] hasSendIssueToTenantPermission] &&
                [[GlobalVars sharedInstance] hasRespondToTenantCreatedIssuePermission] &&
                [[GlobalVars sharedInstance] hasWriteMsgOnTenantIssuePermission]) {
                
                if ([GlobalVars sharedInstance].currentUser.accountType == 0 &&
                    [dictionary[@"CurrentLease"] isKindOfClass:[NSNull class]]) {
                    
                    _submitBtnHeiConstraint.constant = -10;
                    _submitButton.hidden = YES;
                }
                else if ([GlobalVars sharedInstance].currentUser.accountType == 1 &&
                         (tenantDict[@"IsActive"] && ![tenantDict[@"IsActive"] boolValue]) ) {
                    
                    _submitBtnHeiConstraint.constant = -10;
                    _submitButton.hidden = YES;
                } else {
                    _submitButton.hidden = NO;
                }
            } else {
                _submitBtnHeiConstraint.constant = -10;
                _submitButton.hidden = YES;
            }
            
            NSLog(@"%d, %d, %d, %@", [[GlobalVars sharedInstance] hasSendIssueToTenantPermission], [[GlobalVars sharedInstance] hasRespondToTenantCreatedIssuePermission], [[GlobalVars sharedInstance] hasWriteMsgOnTenantIssuePermission], dictionary );
            
//------------------------------ Car Details ----------------------------------------//
            if (dictionary[@"Tenant"] && dictionary[@"Tenant"][@"CarDetails"]) {
                NSArray *carDetailKeyArray = @[@"CarMake", @"CarModel", @"CarColor", @"LicensePlateNumber", @"CarType", @"ParkingStickerNumber"];
                NSDictionary *carDetails = dictionary[@"Tenant"][@"CarDetails"];
                carDetailDict = [NSMutableDictionary dictionary];
                for (NSString *key in carDetailKeyArray) {
                    NSString *detail = carDetails[key];
                    if ([Utilities isValidString:detail])
                        [carDetailDict setObject:detail forKey:key];
                }
            }
            
           [self updateCarDetails];
            
            
//------------------------------ Update Lease Information ---------------------------------//
            
            if (dictionary[@"Tenant"] && ![dictionary[@"CurrentLease"] isKindOfClass:[NSNull class]]) {
                NSDictionary* leaseDict = dictionary[@"CurrentLease"];
                if ([GlobalVars sharedInstance].currentUser.accountType == 0) {
                    NSInteger interval = [leaseDict[@"LeaseStart"] integerValue];
                    leaseStartLabel.text = LocalizedDateString([formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]]);
                    interval = [leaseDict[@"LeaseEnd"] integerValue];
                    
                    leaseEndLabel.text = LocalizedDateString([formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]]);
                } else if ([GlobalVars sharedInstance].currentUser.accountType == 1) {
                    leaseEndLabel.hidden = YES;
                    leaseStartLabel.hidden = YES;
                }
                
                //Update Lease Unit
                if (leaseDict[@"LeaseUnits"]) {
                    NSArray *leaseUnits = leaseDict[@"LeaseUnits"];
                    if (leaseUnits.count > 0) {
                        _apartmentLabel.text = leaseUnits[0][@"UnitName"];
                        
                        unitDict = @{@"Value" : leaseUnits[0][@"UnitId"], @"Name" : leaseUnits[0][@"UnitName"]};
                    }
                }
                _buildingnameLabel.text = leaseDict[@"BuildingName"];
                
                _leaseinfoViewHeiConstraint.constant = 195;
                _leaseInfoView.hidden = NO;
            } else {
                _leaseinfoViewHeiConstraint.constant = 120.0f;
                _leaseInfoView.hidden = NO;
                [SVProgressHUD show];
                if ([Utilities isValidString:tenantDict[@"ApartmentId"]]) {
                    [[APIController sharedInstance] getBuildingUnitsDetailWithUnitId:[tenantDict[@"ApartmentId"] integerValue] successHandler:^(id jsonData) {
                        if (jsonData == nil) {
                            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        } else {
                            NSDictionary *dictionary = (NSDictionary*)jsonData;
                            NSLog(@"%@", dictionary);
                            if (dictionary[@"Unit"]) {
                                buildingData = dictionary;
                                
                                _leaseInfoView.hidden = NO;
                                _leaseinfoViewHeiConstraint.constant = 120;
                                
                                _buildingnameLabel.text = GET_VALIDATED_STRING(dictionary[@"Unit"][@"BuildingName"], @"Unknown") ;
                                _apartmentLabel.text = GET_VALIDATED_STRING(dictionary[@"Unit"][@"UnitName"], @"Unknown");
                                
                                unitDict = @{@"Value" : buildingData[@"Unit"][@"UnitId"], @"Name" : buildingData[@"Unit"][@"UnitName"]};
                            }
                        }
                        [SVProgressHUD dismiss];
                    } failureHandler:^(NSError *error) {
                        NSLog(@"%@", [error description]);
                        [SVProgressHUD dismiss];
                    }];
                }
                
                leaseEndLabel.hidden = YES;
                leaseStartLabel.hidden = YES;
                
            }
            
            emailLabel.hidden = NO;
            mobileNumberLabel.hidden = NO;
            phoneNumberLabel.hidden = NO;
            genderLabel.hidden = NO;
            dateofbirthLabel.hidden = NO;
            
//-------------------------- Update Tenant Comment ----------------------------//
            if (dictionary[@"Tenant"] && dictionary[@"Tenant"][@"Comments"]) {
                CGRect frame = _tableContentView.frame;
                
                if (![[GlobalVars sharedInstance] hasViewTenantCommentPermission]) {
                    _tenantCommentsView.hidden = YES;
                    frame.size.height = _leaseinfoViewHeiConstraint.constant + 30 + _carDetailViewHeiConstraint.constant;
                } else {
                    _tenantCommentsView.hidden = NO;
                    
                    NSString *comment = [[dictionary[@"Tenant"][@"Comments"] stringByDecodingHTMLEntities] stringByConvertingHTMLToPlainText];

                    _commentsLabel.text = comment;
                    
                    if ([Utilities isValidString:comment]) {
                        CGSize textSize = [comment                                                          sizeWithFont:[UIFont fontWithName:@"OpenSans" size:15] constrainedToSize:CGSizeMake(270, 20000) lineBreakMode: NSLineBreakByWordWrapping]; //Assuming your width is 240
                        
                        CGFloat height = _leaseinfoViewHeiConstraint.constant + 30 + _carDetailViewHeiConstraint.constant + (textSize.height + 10 + 45 + 16);
                        frame.size.height = height;
                        
                        [_leaseInfoView layoutIfNeeded];
                        [_leaseInfoView updateConstraints];
                    } else {
                        CGFloat height = _leaseinfoViewHeiConstraint.constant + 30 + _carDetailViewHeiConstraint.constant;
                        frame.size.height = height;
                        _tenantCommentsView.hidden = YES;
                    }
                }
                
                _tableContentView.frame = frame;
            }
//            _leaseinfoViewHeiConstraint.constant = 120;
            [self.detailScrollView addSubview:_tableContentView];
            self.detailScrollView.contentSize = _tableContentView.frame.size;
            //            [_tableContentView layoutIfNeeded];
        }
        
        [SVProgressHUD dismiss];
    } failureHandler:^(NSError *error) {
        NSLog(@"%@", [error description]);
        [SVProgressHUD dismiss];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 
- (IBAction)onClickCellPhone:(id)sender {
//    NSString *phNo = @"+919876543210";
//    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
//        [[UIApplication sharedApplication] openURL:phoneUrl];
//    } else
//    {
//        [[[UIAlertView alloc]initWithTitle:@"DomumLink" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
//    }
    
    NSString *phoneNum = [[sender titleForState:UIControlStateNormal] componentsSeparatedByString:LocalizedString(@": ")][1];
    
    if ([phoneNum isEqualToString:LocalizedString(@"Unknown")]) {
        return;
    }
    
    NSString *cleanedString = [[[sender titleForState:UIControlStateNormal] componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
    
    [[[UIAlertView alloc] initWithTitle:@"" message:cleanedString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil] show];
    
    phoneToCall = cleanedString;
}

- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onClickSubmit:(id)sender {
    NSString *buildingId, *unitId;
    if (responseData[@"Tenant"] && ![responseData[@"CurrentLease"] isKindOfClass:[NSNull class]]) {
        buildingId = responseData[@"CurrentLease"][@"BuildingId"];
        
    } else if (buildingData != nil) {
        if ([Utilities isValidString:buildingData[@"Unit"][@"BuildingName"]]) {
            buildingId = responseData[@"Tenant"][@"ApartmentId"];
        }
    }
    
    unitId = responseData[@"Tenant"][@"ApartmentId"];
    

    [SVProgressHUD show];
    [[APIController sharedInstance] getIssueLocationApartmentsWithLocationBuildingId:[buildingId integerValue] SuccessHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        
        [jsonData insertObject:@{@"Name" : LocalizedString(@"SelectUnit")} atIndex:0];
        
        NSLog(@"%@", jsonData);
        for (NSDictionary *dict in jsonData) {
            if ([dict[@"Value"] integerValue] == [unitId integerValue]) {
                unitDict = dict;
                break;
            }
        }
        
        [self performSegueWithIdentifier:@"GoCreateIssue" sender:self];
        
    } failureHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", [error description]);
    }];
    
//    [self performSegueWithIdentifier:@"GoCreateIssue" sender:self];
}

#pragma mark - Car Detail Function
- (void)updateCarDetails {
//    [_carDetailView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (carDetailDict) {
        NSArray *keyArray = [carDetailDict allKeys];
        if (keyArray.count > 0) {
            int margin = 50;
            CGFloat cellHei = 40;
            _carDetailView.hidden = NO;
            _carDetailViewHeiConstraint.constant = cellHei * keyArray.count + margin;
            int i = 0;
            for (NSString *key in keyArray) {
                int index = i++;
                
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, cellHei * index + margin, 100, cellHei)];
                titleLabel.text = LocalizedString(key);
                titleLabel.font = [UIFont fontWithName:FONTNAME_REGULAR size:15.0f];
                titleLabel.textColor = [UIColor colorWithRed:67/255.0f green:67/255.0f blue:67/255.0f alpha:1.0];
//                titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                titleLabel.numberOfLines = 1;
                titleLabel.minimumFontSize = 10;
                titleLabel.adjustsFontSizeToFitWidth = YES;
                [_carDetailView addSubview:titleLabel];
                
                UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(124, cellHei * index + margin, 172, cellHei)];
                descLabel.text = [NSString stringWithFormat:@"%@", carDetailDict[key]];
                descLabel.font = [UIFont fontWithName:FONTNAME_SEMIBOLD size:13.0f];
                descLabel.textColor = [UIColor colorWithRed:67/255.0f green:67/255.0f blue:67/255.0f alpha:1.0];
                [_carDetailView addSubview:descLabel];
            }
            
            return;
        }
    }
    
    _carDetailView.hidden = YES;
    _carDetailViewHeiConstraint.constant = 0;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneToCall]];
        [[UIApplication sharedApplication] openURL:telURL];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue destinationViewController] isKindOfClass:[CreateIssue1VC class]]) {
        CreateIssue1VC *destVC = (CreateIssue1VC *)[segue destinationViewController];
        destVC.recipientType = ERecipientTypeTenant;
        destVC.tenantId = [responseData[@"Tenant"][@"UserId"] integerValue];
        if (responseData[@"Tenant"] && ![responseData[@"CurrentLease"] isKindOfClass:[NSNull class]]) {
            destVC.tenantBuildingInfo = @{@"Name":responseData[@"CurrentLease"][@"BuildingName"], @"Value":responseData[@"CurrentLease"][@"BuildingId"], @"UnitDict":unitDict};
        } else if (buildingData != nil) {
            if ([Utilities isValidString:buildingData[@"Unit"][@"BuildingName"]]) {
                NSLog(@"%@, %@", buildingData[@"Unit"][@"BuildingName"], unitDict);
                if (unitDict)
                    destVC.tenantBuildingInfo = @{@"Name":buildingData[@"Unit"][@"BuildingName"], @"Value":buildingData[@"Unit"][@"BuildingId"], @"UnitDict":unitDict};
                else
                    destVC.tenantBuildingInfo = @{@"Name":buildingData[@"Unit"][@"BuildingName"], @"Value":buildingData[@"Unit"][@"BuildingId"]};
            }
        }
    }
}
@end
