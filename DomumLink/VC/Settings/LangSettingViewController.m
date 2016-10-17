//
//  LangSettingViewController.m
//  DomumLink
//
//  Created by iOS Dev on 8/14/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "LangSettingViewController.h"

#import "PersonalSettingsVC.h"

@interface LangSettingViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSInteger selIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *langTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation LangSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selIndex = [GlobalVars sharedInstance].langCode;
    
    self.title = LocalizedString(@"Language");
    _doneButton.title = LocalizedString(_doneButton.title);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selIndex = indexPath.row;
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    // Configure the cell
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"EnglishCell" forIndexPath:indexPath];
        cell.accessoryType = selIndex == ELangEnglish ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else if (indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FrenchCell" forIndexPath:indexPath];
        cell.textLabel.text = cell.textLabel.text;
        cell.accessoryType = selIndex == ELangFrench ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)stringFromBool:(BOOL)boolValue {
    return boolValue ? @"true" : @"false";
}

- (IBAction)doneButtonClicked:(id)sender{
    
    NSMutableDictionary *personalSettingDict = [NSMutableDictionary dictionaryWithDictionary:_settingDict];
    
    self.delegate.langCode = selIndex;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"ContactMeAnytime"];
    
    if (personalSettingDict[@"data"] != nil) {
        personalSettingDict = personalSettingDict[@"data"];
    }
    
    [personalSettingDict setObject:@(selIndex) forKey:@"Language"];
    //         Call Update api
    if (_settingDict) {
        [SVProgressHUD show];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        NSLog(@"%@", personalSettingDict);
        
        NSDateFormatter *formatter = [GlobalVars sharedInstance].dateFormatterTime;
        [formatter setDateFormat:@"yyyy-M-dd h:m aa"];
        
        [dictionary setObject:GET_VALIDATED_STRING(personalSettingDict[@"MobileNumber"], @"") forKey:@"MobileNumber"];
        
        [dictionary setObject:GET_VALIDATED_STRING(personalSettingDict[@"Email"], @"") forKey:@"Email"];
        
        [dictionary setObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[GET_VALIDATED_STRING(personalSettingDict[@"NotifyFrom"], @"") integerValue]]] forKey:@"NotifyFrom"];
        
        [dictionary setObject:[formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[GET_VALIDATED_STRING(personalSettingDict[@"NotifyFrom"], @"") integerValue]]] forKey:@"NotifyTo"];
        
        [dictionary setObject:[self stringFromBool:[personalSettingDict[@"Contact24Hours"] boolValue]] forKey:@"Contact24Hours"];
        
        [dictionary setObject:GET_VALIDATED_STRING(personalSettingDict[@"TimeZoneName"], @"") forKey:@"TimeZoneName"];
        
        [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"EnableDaylightSavingTime"], @"") boolValue]] forKey:@"EnableDaylightSavingTime"];
        
        [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"HideAdminProfileFromNonAdmins"], @"") boolValue]] forKey:@"HideAdminProfileFromNonAdmins"];
        
        [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"IgnoreClosedOrResolvedIssues"], @"") boolValue]] forKey:@"IgnoreClosedOrResolvedIssues"];
        
        [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"NotificationOptions.Email"], @"") boolValue]] forKey:@"NotificationOptions.Email"];
        
        [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"NotificationOptions.Sms"], @"") boolValue]] forKey:@"NotificationOptions.Sms"];
        
        [dictionary setObject:[self stringFromBool:[GET_VALIDATED_STRING(personalSettingDict[@"NotificationOptions.Voice"], @"") boolValue]] forKey:@"NotificationOptions.Voice"];
        
        [dictionary setObject:@(selIndex) forKey:@"Language"];
        
        
        NSLog(@"%@", dictionary);
        [[APIController sharedInstance] updatePersonalSettingsWithSettingData:dictionary SuccessHandler:^(id jsonData) {
            NSLog(@"%@", jsonData);
            
            if ([GlobalVars sharedInstance].langCode != selIndex) {
                [GlobalVars sharedInstance].langCode = selIndex;
                
                [Utilities applyLanguageChange];
            }
            
            [SVProgressHUD dismiss];
            
            [self.navigationController popViewControllerAnimated:YES];
        } failureHandler:^(NSError *error) {
            NSLog(@"%@", [error description]);
            [SVProgressHUD dismiss];
        }];
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
