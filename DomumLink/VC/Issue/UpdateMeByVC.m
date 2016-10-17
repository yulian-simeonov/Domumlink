//
//  UpdateMeByVC.m
//  DomumLink
//
//  Created by iOS Dev on 6/1/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "UpdateMeByVC.h"
#import "TenantDetailsVC.h"
#import "IssuesVC.h"

@interface UpdateMeByVC() {
    IBOutlet UIButton *notByMessageButton;
    
    IBOutlet UIButton *notByVibrationButton;
    
    IBOutlet UIButton *notByAudioButton;
}
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

// Localization
@property (weak, nonatomic) IBOutlet UILabel *updatemebyLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *smsLabel;
@property (weak, nonatomic) IBOutlet UILabel *callLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UILabel *updatesLabel;

@end


@implementation UpdateMeByVC


NSArray *notButtonArray, *notByKeyArray, *notByImageNameArray;

NSMutableDictionary *notByDictionary;

NSMutableArray *notByTickImageArray;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Localization
    self.title = LocalizedString(@"CreateIssue");
    _updatemebyLabel.text = LocalizedString(@"UpdateMeBy");
    _emailLabel.text = LocalizedString(@"Email");
    _smsLabel.text = LocalizedString(@"SMS");
    _callLabel.text = LocalizedString(@"Call");
    [_backButton setTitle:[NSString stringWithFormat:@" %@", LocalizedString(@"BACK")] forState:UIControlStateNormal];
    [_finishButton setTitle:[NSString stringWithFormat:@" %@", LocalizedString(@"FINISH")] forState:UIControlStateNormal];
    _updatesLabel.text = LocalizedString(@"Updates");
    
    self.navigationItem.hidesBackButton = YES;
    
    notByMessageButton.layer.cornerRadius = notByMessageButton.frame.size.width/2;
    notByVibrationButton.layer.cornerRadius = notByVibrationButton.frame.size.width/2;
    notByAudioButton.layer.cornerRadius = notByAudioButton.frame.size.width/2;
    [self initNotifyByButtons];
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) {
        _stepLabel.text = @"2";
    } else {
        if ([[GlobalVars sharedInstance].toCreateIssue[@"RecipientType"] integerValue] == ERecipientTypeTenant) {
            _stepLabel.text = @"4";
        } else {
            _stepLabel.text = @"3";
        }
    }
}

- (void)initNotifyByButtons{
    notButtonArray = [NSArray arrayWithObjects:notByMessageButton, notByVibrationButton, notByAudioButton, nil];
    notByKeyArray = [NSArray arrayWithObjects:@"NotifyByMessage", @"NotifyByVibration", @"NotifyByAudio", nil];
    notByImageNameArray = [NSArray arrayWithObjects:@"notification_message_icon", @"notification_vibration_icon", @"notification_audio_icon", nil];
    notByTickImageArray = [[NSMutableArray alloc] init];
    notByDictionary = [[NSMutableDictionary alloc] init];
    
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
    NSString *updateByEmail = [notByDictionary objectForKey:notByKeyArray[0]] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:updateByEmail forKey:@"UpdateMeByEmail"];
    
    NSString *updateBySms = [notByDictionary objectForKey:notByKeyArray[1]] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:updateBySms forKey:@"UpdateMeBySms"];
    
    NSString *updateByVoice = [notByDictionary objectForKey:notByKeyArray[2]] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:updateByVoice forKey:@"UpdateMeByVoice"];
    

    NSString *notifyByEmail = [[[GlobalVars sharedInstance].toCreateIssue objectForKey:@"NotifyAssigneesEmail"] boolValue] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:notifyByEmail forKey:@"NotifyAssigneesEmail"];
    
    NSString *notifyBySms = [[[GlobalVars sharedInstance].toCreateIssue objectForKey:@"NotifyAssigneesSms"] boolValue] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:notifyBySms forKey:@"NotifyAssigneesSms"];

    NSString *notifyByVoice = [[[GlobalVars sharedInstance].toCreateIssue objectForKey:@"NotifyAssigneesVoice"] boolValue] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:notifyByVoice forKey:@"NotifyAssigneesVoice"];
    
    
    NSString *notifyReciByEmail = [[[GlobalVars sharedInstance].toCreateIssue objectForKey:@"NotifyRecipientsEmail"] boolValue] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:notifyReciByEmail forKey:@"NotifyRecipientsEmail"];
    
    NSString *notifyReciBySms = [[[GlobalVars sharedInstance].toCreateIssue objectForKey:@"NotifyRecipientsSms"] boolValue] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:notifyReciBySms forKey:@"NotifyRecipientsSms"];
    
    NSString *notifyReciByVoice = [[[GlobalVars sharedInstance].toCreateIssue objectForKey:@"NotifyRecipientsVoice"] boolValue] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:notifyReciByVoice forKey:@"NotifyRecipientsVoice"];
    
    
    NSString *showAssignees = [[GlobalVars sharedInstance].toCreateIssue[@"ShowAssignees"] boolValue] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:showAssignees forKey:@"ShowAssignees"];

    NSString *showRecipients = [[GlobalVars sharedInstance].toCreateIssue[@"ShowRecipients"] boolValue] ? @"true" : @"false";
    [[GlobalVars sharedInstance].toCreateIssue setObject:showRecipients forKey:@"ShowRecipients"];
    
    NSArray *array = [GlobalVars sharedInstance].toCreateIssue[@"RecipientIds"];
    for (int i=0; i<array.count; i++) {
        NSString *keyStr = [NSString stringWithFormat:@"RecipientIds[%d]", i];
        [[GlobalVars sharedInstance].toCreateIssue setObject:array[i] forKey:keyStr];
    }
    
    [[GlobalVars sharedInstance].toCreateIssue removeObjectForKey:@"RecipientIds"];

    
    NSArray *array1 = [GlobalVars sharedInstance].toCreateIssue[@"AssigneeIds"];
    for (int i=0; i<array1.count; i++) {
        NSString *keyStr = [NSString stringWithFormat:@"AssigneeIds[%d]", i];
        [[GlobalVars sharedInstance].toCreateIssue setObject:array1[i] forKey:keyStr];
    }
    
    [[GlobalVars sharedInstance].toCreateIssue removeObjectForKey:@"AssigneeIds"];

    
    NSArray *array2 = [GlobalVars sharedInstance].toCreateIssue[@"ImageIds"];
    for (int i=0; i<array2.count; i++) {
        NSString *keyStr = [NSString stringWithFormat:@"ImageIds[%d]", i];
        [[GlobalVars sharedInstance].toCreateIssue setObject:array2[i] forKey:keyStr];
    }
    
    [[GlobalVars sharedInstance].toCreateIssue removeObjectForKey:@"ImageIds"];
    
    NSLog(@"%@", [GlobalVars sharedInstance].toCreateIssue);
    
    [SVProgressHUD show];
    [[APIController sharedInstance] createNewIssue:[GlobalVars sharedInstance].toCreateIssue successHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        
        IssuesVC *issuesVC = nil;
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[IssuesVC class]]) {
                issuesVC = (IssuesVC *)vc;
                break;
            }
        }
        if (issuesVC) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiIssueRefresh object:nil];
            [self.navigationController popToViewController:issuesVC animated:YES];
        }
        else {
//            [self.navigationController popToRootViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowIssues" object:nil];
        }
    } failureHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", [error description]);
    }];
}


@end
