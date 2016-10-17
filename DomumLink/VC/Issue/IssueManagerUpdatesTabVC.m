//
//  IssueManagerUpdatesTabVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 2/5/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "IssueManagerUpdatesTabVC.h"

#import "IssueManagerGeneralVC.h"

@interface IssueManagerUpdatesTabVC () {
    IBOutlet UIButton *notByMessageButton;
    
    IBOutlet UIButton *notByVibrationButton;
    
    IBOutlet UIButton *notByAudioButton;
}

// Localization
@property (weak, nonatomic) IBOutlet UILabel *updatemebyLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *smsLabel;
@property (weak, nonatomic) IBOutlet UILabel *callLabel;

@end

@implementation IssueManagerUpdatesTabVC

NSArray *notButtonArray, *notByKeyArray, *notByImageNameArray;

NSMutableDictionary *notByDictionary;

NSMutableArray *notByTickImageArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Localization
    _updatemebyLabel.text = LocalizedString(@"UpdateMeBy");
    _emailLabel.text = LocalizedString(@"Email");
    _smsLabel.text = LocalizedString(@"SMS");
    _callLabel.text = LocalizedString(@"Call");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    notByMessageButton.layer.cornerRadius = notByMessageButton.frame.size.width/2;
    notByVibrationButton.layer.cornerRadius = notByVibrationButton.frame.size.width/2;
    notByAudioButton.layer.cornerRadius = notByAudioButton.frame.size.width/2;
    
    
    notByTickImageArray = [[NSMutableArray alloc] init];
    notByDictionary = [[NSMutableDictionary alloc] init];
    
    notButtonArray = [NSArray arrayWithObjects:notByMessageButton, notByVibrationButton, notByAudioButton, nil];
    notByKeyArray = [NSArray arrayWithObjects:@"NotifyByMessage", @"NotifyByVibration", @"NotifyByAudio", nil];
    notByImageNameArray = [NSArray arrayWithObjects:@"notification_message_icon", @"notification_vibration_icon", @"notification_audio_icon", nil];
    

    NSDictionary *notifyMe = _issueDictionary[@"NotifyMe"];
    if (notifyMe && ![notifyMe isKindOfClass:[NSNull class]]) {
        [notByDictionary setObject:notifyMe[@"Email"] forKey:notByKeyArray[0]];
        [notByDictionary setObject:notifyMe[@"Sms"] forKey:notByKeyArray[1]];
        [notByDictionary setObject:notifyMe[@"Voice"] forKey:notByKeyArray[2]];
    }
    
    [self initNotifyByButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNotifyByButtons{
    
//    NSLog(@"%@", _issueDictionary);
    
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
        if([[notByDictionary objectForKey:notByKey] boolValue]){
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
            if([[notByDictionary objectForKey:notByKey] boolValue]){
                [notByDictionary setObject:@"0" forKey:notByKey];
            }
            else{
                [notByDictionary setObject:@"1" forKey:notByKey];
            }
            break;
        }
    }
    
    [self setNotifyByButtonsStyle];
    
    BOOL email = [notByDictionary objectForKey:notByKeyArray[0]] ? [[notByDictionary objectForKey:notByKeyArray[0]] boolValue] : NO;
    BOOL sms = [notByDictionary objectForKey:notByKeyArray[1]] ? [[notByDictionary objectForKey:notByKeyArray[1]] boolValue] : NO;
    BOOL voice = [notByDictionary objectForKey:notByKeyArray[2]] ? [[notByDictionary objectForKey:notByKeyArray[2]] boolValue] : NO;
    
    [SVProgressHUD show];
    [[APIController sharedInstance] updateNotifyMeOptionWithIssueId:[_issueDictionary[@"IssueId"] integerValue] Email:email Sms:sms Voice:voice SuccessHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", jsonData);
        
        NSMutableDictionary *notifyMe = [NSMutableDictionary dictionaryWithDictionary:_issueDictionary[@"NotifyMe"]];
        
        if ([notifyMe isKindOfClass:[NSMutableDictionary class]]) {
            [notifyMe setObject:[notByDictionary objectForKey:notByKeyArray[0]] forKey:@"Email"];
            [notifyMe setObject:[notByDictionary objectForKey:notByKeyArray[1]] forKey:@"Sms"];
            [notifyMe setObject:[notByDictionary objectForKey:notByKeyArray[2]] forKey:@"Voice"];
            NSMutableDictionary *issueDict = [NSMutableDictionary dictionaryWithDictionary:_issueDictionary];
            [issueDict setObject:notifyMe forKey:@"NotifyMe"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiIssueUpdated object:issueDict];
        }
    } failureHandler:^(NSError *error) {
        NSLog(@"%@", [error description]);
        [SVProgressHUD dismiss];
    }];
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
