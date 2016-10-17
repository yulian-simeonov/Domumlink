//
//  PersonalSettingsVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 3/19/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "PersonalSettingsVC.h"
#import "SettingsContactTimeframeVC.h"
#import "LangSettingViewController.h"

@interface PersonalSettingsVC (){
    IBOutlet UITableView *settingsTableView;
    
    IBOutlet UIButton *saveButton;
    
    IBOutlet UIButton *cancelButton;
    
    UIButton *notByMessageButton, *notByVibrationButton, *notByAudioButton;
    
    UISwitch *contactAnytimeSwitch, *easymodeSwitch;
    
    UILabel *notifyFromLabel, *notifyFromTitleLabel, *notifyToLabel, *notifyToTitleLabel;
    
    NSMutableDictionary *personalSettingDict;
    
    BOOL isEasyMode;
}

@end

enum SettingRows
{
//    Row_Password,
    Row_Language,
    Row_Email,
    Row_MobileNumber,
//    Row_Notifications,
//    Row_ContactMe,
//    Row_NotifyFrom,
//    Row_NotifyTo,
    Row_EasyMode,
    Row_TimeZone
};

NSArray *notButtonArray, *notByKeyArray, *notByImageNameArray;

NSMutableDictionary *notByDictionary;

NSMutableArray *notByTickImageArray;


@implementation PersonalSettingsVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = LocalizedString(@"PersonalSettings");
    
    [saveButton setTitle:LocalizedString(@"SAVE") forState:UIControlStateNormal];
    [cancelButton setTitle:LocalizedString(@"CANCEL") forState:UIControlStateNormal];
    
    saveButton.layer.cornerRadius = 2;
    cancelButton.layer.cornerRadius = 2;
    
    _langCode = [GlobalVars sharedInstance].langCode;
    [settingsTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _langCode = [GlobalVars sharedInstance].langCode;
    isEasyMode = [GlobalVars sharedInstance].isEasymode;
    
    [SVProgressHUD show];
    [[APIController sharedInstance] getPersonalSettingsWithSuccessHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        personalSettingDict = [NSMutableDictionary dictionaryWithDictionary:jsonData];
        NSLog(@"%@", jsonData);
    
        [settingsTableView reloadData];
    } failureHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", [error description]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews{
    if ([settingsTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [settingsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([settingsTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [settingsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (IBAction)menuClicked:(UIButton *)sender{
    [self.sidePanelController showLeftPanelAnimated: YES];
}

- (IBAction)saveorcancelButtonClicked:(id)sender{
    if(sender == saveButton){
//        for(int i = 0; i < 3; i++){
//            if([notByDictionary objectForKey:notByKeyArray[i]]){
//                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:notByKeyArray[i]];
//            }
//            else{
//                [[NSUserDefaults standardUserDefaults] removeObjectForKey:notByKeyArray[i]];
//            }
//        }
        
//        if ([GlobalVars sharedInstance].langCode != _langCode) {
//            [GlobalVars sharedInstance].langCode = _langCode;
//            
//            [Utilities applyLanguageChange];
//        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i", [contactAnytimeSwitch isOn]] forKey:@"ContactMeAnytime"];
        
        if ([GlobalVars sharedInstance].isEasymode != isEasyMode) {
            [GlobalVars sharedInstance].isEasymode = isEasyMode;
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSideMenu" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupView" object:nil];
        }
        
//        if (personalSettingDict[@"data"] != nil) {
//            personalSettingDict = personalSettingDict[@"data"];
//        }
//        
//        [personalSettingDict setObject:@(_langCode) forKey:@"Language"];
////         Call Update api
//        if (personalSettingDict) {
//            [SVProgressHUD show];
//            
//            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
//            NSLog(@"%@", personalSettingDict);
//            
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"yyyy-M-dd h:m aa"];
//            
//            [dictionary setObject:GET_VALIDATED_STRING(personalSettingDict[@"MobileNumber"], @"") forKey:@"MobileNumber"];
//            
//            [dictionary setObject:GET_VALIDATED_STRING(personalSettingDict[@"Email"], @"") forKey:@"Email"];
//            
//            [dictionary setObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[GET_VALIDATED_STRING(personalSettingDict[@"NotifyFrom"], @"") integerValue]]] forKey:@"NotifyFrom"];
//            
//            [dictionary setObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[GET_VALIDATED_STRING(personalSettingDict[@"NotifyFrom"], @"") integerValue]]] forKey:@"NotifyTo"];
//            
//            [dictionary setObject:[self stringFromBool:[personalSettingDict[@"Contact24Hours"] boolValue]] forKey:@"Contact24Hours"];
//            
//            [dictionary setObject:GET_VALIDATED_STRING(personalSettingDict[@"TimeZoneName"], @"") forKey:@"TimeZoneName"];
//            
//            [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"EnableDaylightSavingTime"], @"") boolValue]] forKey:@"EnableDaylightSavingTime"];
//            
//            [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"HideAdminProfileFromNonAdmins"], @"") boolValue]] forKey:@"HideAdminProfileFromNonAdmins"];
//            
//            [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"IgnoreClosedOrResolvedIssues"], @"") boolValue]] forKey:@"IgnoreClosedOrResolvedIssues"];
//            
//            [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"NotificationOptions.Email"], @"") boolValue]] forKey:@"NotificationOptions.Email"];
//            
//            [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"NotificationOptions.Sms"], @"") boolValue]] forKey:@"NotificationOptions.Sms"];
//            
//            [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"NotificationOptions.Voice"], @"") boolValue]] forKey:@"NotificationOptions.Voice"];
//            
//            [dictionary setObject:@(_langCode) forKey:@"Language"];
//
//
//            NSLog(@"%@", dictionary);
//            [[APIController sharedInstance] updatePersonalSettingsWithSettingData:dictionary SuccessHandler:^(id jsonData) {
//                NSLog(@"%@", jsonData);
//                
//                [SVProgressHUD dismiss];
//            } failureHandler:^(NSError *error) {
//                NSLog(@"%@", [error description]);
//                [SVProgressHUD dismiss];
//            }];
//        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)stringFromBool:(BOOL)boolValue {
    return boolValue ? @"true" : @"false";
}

- (void)easyModeSwitchChanged:(UISwitch *)sender {
    isEasyMode = [sender isOn];
}

- (void)contactAnytimeSwitchChanged: (UISwitch *)sender{
    if([contactAnytimeSwitch isOn]){
        notifyFromTitleLabel.textColor = LIGHT_GRAY_COLOR1;
        notifyToTitleLabel.textColor = LIGHT_GRAY_COLOR1;
        notifyFromLabel.textColor = LIGHT_GRAY_COLOR1;
        notifyToLabel.textColor = LIGHT_GRAY_COLOR1;
    }
    else{
        notifyFromTitleLabel.textColor = GRAY_COLOR;
        notifyToTitleLabel.textColor = GRAY_COLOR;
        notifyFromLabel.textColor = GREEN_COLOR;
        notifyToLabel.textColor = GREEN_COLOR;
    }
}

- (void)initNotifyByButtons{
    notButtonArray = [NSArray arrayWithObjects:notByMessageButton, notByVibrationButton, notByAudioButton, nil];
    notByKeyArray = [NSArray arrayWithObjects:@"NotifyByMessage", @"NotifyByVibration", @"NotifyByAudio", nil];
    notByImageNameArray = [NSArray arrayWithObjects:@"notification_message_icon", @"notification_vibration_icon", @"notification_audio_icon", nil];
    notByTickImageArray = [[NSMutableArray alloc] init];
    notByDictionary = [[NSMutableDictionary alloc] init];
    
    for(int i = 0; i < 3; i++){
        if([[NSUserDefaults standardUserDefaults] objectForKey:notByKeyArray[i]])
            notByDictionary[notByKeyArray[i]] = @"1";
        
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee)
        return 5;
    else
        return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row == Row_Notifications){
//        return 104;
//    }
//    else
        return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    // Configure the cell
//    if (indexPath.row == Row_Password)
//    {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsPasswordCellID" forIndexPath:indexPath];
//    }
//    else
    
    if (indexPath.row == Row_Language)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsLanguageCellID" forIndexPath:indexPath];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:10];
        titleLabel.text = LocalizedString(@"Language");
        
        UILabel *LangLabel = (UILabel *)[cell viewWithTag:11];
        LangLabel.text = _langCode == ELangEnglish ? @"English" : @"Français";
    }
    else if (indexPath.row == Row_Email)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsEmailCellID" forIndexPath:indexPath];
        cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:10];
        titleLabel.text = LocalizedString(@"Email");
    }
    else if (indexPath.row == Row_MobileNumber)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsMobileCellID" forIndexPath:indexPath];
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:10];
        titleLabel.text = LocalizedString(@"MobileNumber");
        
        if (personalSettingDict)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", GET_VALIDATED_STRING(personalSettingDict[@"MobileNumber"], @"")];
    }
//    else if (indexPath.row == Row_Notifications)
//    {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsNotificationCellID" forIndexPath:indexPath];
//        notByMessageButton = (UIButton *)[cell viewWithTag:200];
//        notByVibrationButton = (UIButton *)[cell viewWithTag:201];
//        notByAudioButton = (UIButton *)[cell viewWithTag:202];
//        [self initNotifyByButtons];
//    }
//    else if (indexPath.row == Row_ContactMe)
//    {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsContactMeCellID" forIndexPath:indexPath];
//        contactAnytimeSwitch = (UISwitch *)[cell viewWithTag:200];
//        [contactAnytimeSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:@"ContactMeAnytime"] boolValue]];
//        [contactAnytimeSwitch addTarget:self action:@selector(contactAnytimeSwitchChanged:) forControlEvents: UIControlEventValueChanged];
//        [self contactAnytimeSwitchChanged: nil];
//    }
//    else if (indexPath.row == Row_NotifyFrom)
//    {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsNotifyFromCellID" forIndexPath:indexPath];
//        notifyFromTitleLabel = cell.textLabel;
//        notifyFromLabel = cell.detailTextLabel;
//        
//        NSDate *fromDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotifyFromTime"];
//        if(fromDate){
//            notifyFromLabel.text = [dateFormatter stringFromDate:fromDate];
//        }
//    } else if (indexPath.row == Row_NotifyTo)
//    {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsNotifyToCellID" forIndexPath:indexPath];
//        notifyToTitleLabel = cell.textLabel;
//        notifyToLabel = cell.detailTextLabel;
//        
//        NSDate *toDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotifyToTime"];
//        if(toDate){
//            notifyToLabel.text = [dateFormatter stringFromDate:toDate];
//        }
//    }
    else if (indexPath.row == Row_EasyMode)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EasymodeCell" forIndexPath:indexPath];
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:10];
        titleLabel.text = LocalizedString(@"EasyMode");
        
        easymodeSwitch = (UISwitch *)[cell viewWithTag:200];
        [easymodeSwitch setOn:isEasyMode];
        [easymodeSwitch addTarget:self action:@selector(easyModeSwitchChanged:) forControlEvents: UIControlEventValueChanged];
    }
    else if (indexPath.row == Row_TimeZone)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTimezoneCellID" forIndexPath:indexPath];
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:10];
        titleLabel.text = LocalizedString(@"TimeZone");
        
        if (personalSettingDict)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", GET_VALIDATED_STRING(personalSettingDict[@"TimeZoneName"], @"")];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.row == Row_NotifyFrom || indexPath.row == Row_NotifyTo){
//        if(![contactAnytimeSwitch isOn]){
//            [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SettingsContactTimeframePage"] animated:YES];
//        }
//        else{
//            ALERT(@"Error", @"You can select notification timeframe only after you disable Contact me anytime.");
//        }
//    }
    if (indexPath.row == Row_Language) {
        [self performSegueWithIdentifier:@"ShowLangSetting" sender:self];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([[segue identifier] isEqualToString:@"ShowLangSetting"]) {
         LangSettingViewController *langVC = (LangSettingViewController *)[segue destinationViewController];
         langVC.delegate = self;
         langVC.settingDict = personalSettingDict;
     }
 }

@end
