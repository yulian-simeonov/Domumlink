//
//  BuildingInfoVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/17/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "BuildingInfoVC.h"
#import "EmergencyContactCell.h"
#import "BuildingScheduleCell.h"

@interface BuildingInfoVC (){
    IBOutlet UITableView *emergencyTableView;
    
    IBOutlet UIView *emergencyHeaderView;
    
    IBOutlet UITableView *scheduleTableView;
}
@property (weak, nonatomic) IBOutlet UILabel *buildingaddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextView *buildingnameTextView;
@property (weak, nonatomic) IBOutlet UIImageView *buildingImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoviewHeiConstraint;

@property (weak, nonatomic) IBOutlet UILabel *emergencyContactsLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildingScheduleLabel;
@property (weak, nonatomic) IBOutlet UILabel *buildingNameLabel;

@end

BOOL isLoading;

NSMutableData *responseData;

NSArray *scheduleTitleArray;
NSArray *scheduleKeyArray;
NSMutableDictionary *scheduleDataDict;

NSArray *emergencyContacts;

@implementation BuildingInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = LocalizedString(@"BuildingInfo");
    _emergencyContactsLabel.text = LocalizedString(@"EmergencyContacts");
    _buildingScheduleLabel.text = LocalizedString(@"BuildingSchedule");
    
    responseData = [[NSMutableData alloc] init];
    scheduleDataDict = [NSMutableDictionary dictionary];
    
    [SVProgressHUD show];
    [[APIController sharedInstance] feedBuildingInfoWithSuccessHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        emergencyContacts = [NSArray arrayWithArray:jsonData[@"EmergencyContacts"]];
        [emergencyTableView reloadData];
        
//        scheduleTitleArray = [NSArray arrayWithArray:jsonData[@""]]
        
        _buildingNameLabel.text = jsonData[@"BuildingName"];
        NSDictionary *addressDict= jsonData[@"Address"];
        NSString *addressLine1Str = GET_VALIDATED_STRING(addressDict[@"AddressLine1"], @"");
        NSString *cityStr = GET_VALIDATED_STRING(addressDict[@"City"], @"");
        NSString *provinceStr = GET_VALIDATED_STRING(addressDict[@"ProvinceName"], @"");
        NSString *zipcodeStr = GET_VALIDATED_STRING(addressDict[@"ZipCode"], @"");
        NSString *countryStr = GET_VALIDATED_STRING(addressDict[@"CountryName"], @"");

        NSString *addr = [NSString stringWithFormat:@"%@, %@, %@, %@, %@", addressLine1Str, cityStr, provinceStr, zipcodeStr, countryStr];
        
        _buildingaddressLabel.text = addr;
        
        NSURL *buildingImageUrl = [NSURL URLWithString:[jsonData[@"Image"][@"Url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [_buildingImage sd_setImageWithURL:buildingImageUrl];
        
        [self parseScheduleData:jsonData];
        
    } failureHandler:^(NSError *error) {
        NSLog(@"%@", [error description]);
        [SVProgressHUD dismiss];
    }];
    
}

- (void)parseScheduleData:(NSDictionary *)buildlingDict {
    scheduleKeyArray = @[@"GarbageDays", @"RecyclingDays", @"SwimmingPoolDays", @"GymDays"];
    scheduleTitleArray = @[@"Garbage Hours", @"Recycling Hours", @"Swimming Pool Hours", @"Gym Hours"];
    
    NSArray *keyArray = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    NSArray *dayArray = LocalizedArray(keyArray);
    
    for (int i=0; i<scheduleKeyArray.count; i++) {
        NSDictionary *data = buildlingDict[scheduleKeyArray[i]];
        if (data && ![data isKindOfClass:[NSNull class]]) {
            NSMutableArray *scheduleArray = [NSMutableArray array];
            
            for (int j=0; j<keyArray.count; j++) {
                NSString *keyFrom = [NSString stringWithFormat:@"%@From", keyArray[j]];
                NSString *keyTo = [NSString stringWithFormat:@"%@To", keyArray[j]];
                if ([Utilities isValidString:data[keyFrom]] && [Utilities isValidString:data[keyTo]]) {
                    NSDictionary *dict = @{@"Name":dayArray[j], @"From":data[keyFrom], @"To":data[keyTo]};
                    [scheduleArray addObject:dict];
                }
            }
            if (scheduleArray.count > 0)
                [scheduleDataDict setObject:scheduleArray forKey:scheduleTitleArray[i]];
        }
    }
    [scheduleTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // iOS 7
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // iOS 8
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)viewDidLayoutSubviews
{
    // iOS 7
    if ([emergencyTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [emergencyTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    // iOS 8
    if ([emergencyTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [emergencyTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // iOS 7
    if ([scheduleTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [scheduleTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    // iOS 8
    if ([scheduleTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [scheduleTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == emergencyTableView)
        return 1;
    else if (tableView == scheduleTableView)
        return scheduleDataDict.allKeys.count;
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == emergencyTableView)
        return emergencyContacts.count;
    else if(tableView == scheduleTableView) {
        return [scheduleDataDict[scheduleDataDict.allKeys[section]] count];
    }
    else
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(tableView == scheduleTableView) {
        // KeysArray: @[@"Garbage Hours", @"Recycling Hours", @"Swimming Pool Hours", @"Gym Hours"];
        NSString *key = [scheduleDataDict.allKeys[section] stringByReplacingOccurrencesOfString:@" " withString:@""];
        return LocalizedString(key);
    }
    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == emergencyTableView)
        return 35;
    else if(tableView == scheduleTableView)
        return 35;
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == emergencyTableView){
        EmergencyContactCell *cell = (EmergencyContactCell *)[tableView dequeueReusableCellWithIdentifier:@"emergencyContactCell"];
        if(cell == nil){
            cell = [[EmergencyContactCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"emergencyContactCell"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        NSDictionary *contact = emergencyContacts[indexPath.row];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", contact[@"FullName"], contact[@"Title"]]];
        
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[contact[@"FullName"] length])];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange([contact[@"FullName"] length], [contact[@"Title"] length]+3)];

        cell.phoneNumberLabel.attributedText = string; //[Utilities formatPhoneNumber:contact[@"PhoneNumber"] deleteLastChar:NO];
        
    //    [cell.phoneNumberLabel setText:@"aofajwofjawe"];
        return cell;
    }
    else if(tableView == scheduleTableView){
        BuildingScheduleCell *cell = (BuildingScheduleCell *)[tableView dequeueReusableCellWithIdentifier:@"buildingScheduleCell"];
        if(cell == nil){
            cell = [[BuildingScheduleCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"buildingScheduleCell"];
        }
        
        NSString *title = scheduleDataDict.allKeys[indexPath.section];
        NSArray *dataArray = scheduleDataDict[title];
        NSDictionary *dict = dataArray[indexPath.row];
        if(dict){
            cell.titleLabel.text = title;
            cell.weekdayLabel.text = dict[@"Name"];
            double timestampvalfrom =  GET_VALIDATED_DOUBLE(dict[@"From"], 0);
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)timestampvalfrom];
            
            double timestampvalto = GET_VALIDATED_DOUBLE(dict[@"To"], 0);
            NSDate *dateTo = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)timestampvalto];
            
            NSDateFormatter *formatter = [GlobalVars sharedInstance].dateFormatterTime;
            if ([GlobalVars sharedInstance].langCode == ELangEnglish)
                [formatter setDateFormat:@"haa"];
            else
                [formatter setDateFormat:@"H:ss"];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            cell.timeLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:dateFrom], [formatter stringFromDate:dateTo]];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == emergencyTableView) {
        NSString *phNo = emergencyContacts[indexPath.row][@"PhoneNumber"];
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
        } else
        {
            [[[UIAlertView alloc]initWithTitle:@"DomumLink" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
        }
    }
}

#pragma mark - UITableView Scroll Event
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == scheduleTableView) {
        if (scrollView.contentSize.height < scrollView.frame.size.height)
            return;
        
        if (scrollView.contentOffset.y > 5 && _infoviewHeiConstraint.constant == 220) {
            [UIView animateWithDuration:0.3 animations:^{
                _infoviewHeiConstraint.constant = 141;
                [self.view layoutIfNeeded];
            }];
        } else if  (scrollView.contentOffset.y < 5 && _infoviewHeiConstraint.constant == 141) {
            [UIView animateWithDuration:0.3 animations:^{
                _infoviewHeiConstraint.constant = 220;
                [self.view layoutIfNeeded];
            }];
        }
    }
}
@end
