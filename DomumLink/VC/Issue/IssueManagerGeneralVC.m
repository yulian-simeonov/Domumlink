//
//  IssueManagerGeneralVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/30/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "IssueManagerGeneralVC.h"
#import "IssueManagerGeneralTabVC.h"
#import "IssueManagerTenantsTabVC.h"
#import "KGModal.h"
#import "IssueReadStatusVC.h"
#import "IssueManagerUpdatesTabVC.h"
#import "IssueChangeStatusVC.h"
#import "IssueManagerAssigneeTabVC.h"

@interface IssueManagerGeneralVC () <UIAlertViewDelegate> {
    IBOutlet UIButton *changeIssueStatusButton;
    
    IBOutlet UILabel *idLabel;
    
    IBOutlet UILabel *creatorNameLabel;
    
    IBOutlet UILabel *creatorTypeNameLabel;
    
    
    __weak IBOutlet UIButton *phonenumberButton;
    IBOutlet UILabel *createdDateLabel;
    
    IBOutlet UILabel *createdTimeLabel;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createdforlabelWidConstraint;

@property (strong, nonatomic) IBOutlet UIScrollView *tabScrollView;
@property (strong, nonatomic) IBOutlet UIView *tabBottomBarView;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UILabel *createdForLabel;
@property (weak, nonatomic) IBOutlet UIButton *tenantstabButton;
@property (weak, nonatomic) IBOutlet UIButton *assigneetabButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *assigneebtnCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressbarTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *jobtitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *updatesbtnCenterXConstraint;

@property (weak, nonatomic) IBOutlet UIButton *arrowButton;
@property (weak, nonatomic) IBOutlet UIButton *delayedButton;
@property (weak, nonatomic) IBOutlet UIButton *completedButton;

@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeiConstraint;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrlBtmConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrlTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *issueCategoryLabel;

// Localization
@property (weak, nonatomic) IBOutlet UILabel *createdbyLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdonLabel;
@property (weak, nonatomic) IBOutlet UIButton *generalTabButton;
@property (weak, nonatomic) IBOutlet UIButton *updateTabButton;


@end

@implementation IssueManagerGeneralVC

IssueManagerGeneralTabVC *generalTabController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Issue Name";
    
    self.delayedButton.userInteractionEnabled = NO;
    self.completedButton.userInteractionEnabled = NO;
    
    // Localization
    
    _createdbyLabel.text = LocalizedString(@"Createdby");
    _createdonLabel.text = LocalizedString(@"Createdon");
    [_generalTabButton setTitle:LocalizedString(@"General") forState:UIControlStateNormal];
    [_tenantstabButton setTitle:LocalizedString(@"Tenants") forState:UIControlStateNormal];
    [_assigneetabButton setTitle:LocalizedString(@"Assignees") forState:UIControlStateNormal];
    [_updateTabButton setTitle:LocalizedString(@"Updates") forState:UIControlStateNormal];
    [_delayedButton setTitle:LocalizedString(@"Delayed") forState:UIControlStateNormal];
    [_completedButton setTitle:LocalizedString(@"Completed") forState:UIControlStateNormal];
    
//    if ([GlobalVars sharedInstance].langCode == ELangFrench)
        _assigneetabButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    _assigneetabButton.titleLabel.
    
    [self updateIssueContent];
    //---------------------------------------------------- Building Tabbar --------------------------------------------------//
    [self buildTabbar];
    [self buildChangeStatusBar];
    
    if ([GlobalVars sharedInstance].isEasymode) {
        if ([_issueDictionary[@"SubStatus"] integerValue] == 5) { // Delayed Status
            [self disableDelayButton];
        } else {
            [self enableChangeStatusButton];
        }
    }
    
    // add the observer to textfield
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:nil];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserverForName:kNotiIssueDetailUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
//        
//    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiIssueDetailUpdated object:nil];
}

-(void)viewDidLayoutSubviews{
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    UIColor *color = [[UIColor alloc] initWithRed:(90.0/255.0) green:(171.0/255.0) blue:(227.0/255.0) alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:color];
    for(UIBarButtonItem *button in self.navigationController.navigationBar.subviews){
        button.tintColor = [UIColor whiteColor];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewdidappear happened");
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Update UI
- (void)disableDelayButton {
    self.completedButton.userInteractionEnabled = YES;
    self.delayedButton.userInteractionEnabled = NO;
    self.delayedButton.highlighted = YES;
}

- (void)enableChangeStatusButton {
    self.delayedButton.userInteractionEnabled = YES;
    self.completedButton.userInteractionEnabled = YES;
}

#pragma mark - Update Issue Content
- (void)updateContentUponStatusChange {
    [generalTabController getIssueDetail];
}

- (void)updateContentWithIssueData:(NSDictionary *)issueDict {
    _issueDictionary = issueDict;
    [self updateIssueContent];
    [self buildChangeStatusBar];
}

- (void)updateIssueContent {
    if(self.issueDictionary){
        idLabel.text = [NSString stringWithFormat:@"%@ #: %@",
                        LocalizedString(@"ISSUE"),
                        [GET_VALIDATED_STRING(_issueDictionary[@"GeneratedId"], @"") stringByReplacingOccurrencesOfString:@"-" withString:@" "]];
        
        EUserType creatorType = EUserTypeNone;
        
        if(_issueDictionary[@"Creator"]){
            NSDictionary *creatorDict = _issueDictionary[@"Creator"];
            _jobtitleLabel.text = GET_VALIDATED_STRING(creatorDict[@"JobTitle"], @"");
            creatorNameLabel.text = GET_VALIDATED_STRING(creatorDict[@"Name"], @"");
            creatorTypeNameLabel.text = GET_VALIDATED_STRING(creatorDict[@"TypeName"], @"");
            
            
            [phonenumberButton setTitle: [NSString stringWithFormat:@"%@: %@", LocalizedString(@"Call"), GET_VALIDATED_STRING(creatorDict[@"MobileNumber"], @"")] forState:UIControlStateNormal];
            
            creatorType = [GET_VALIDATED_STRING(creatorDict[@"Type"], @"") integerValue];
        }
        
        double timestampvalto = GET_VALIDATED_DOUBLE(_issueDictionary[@"DateSubmitted"], 0);
        NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)timestampvalto];
        
        NSDateFormatter *dateFormatter = [GlobalVars sharedInstance].dateFormatterTime;
        if ([GlobalVars sharedInstance].langCode == ELangEnglish)
            [dateFormatter setDateFormat:@"MMM dd, yyyy"];
        else
            [dateFormatter setDateFormat:@"dd MMM yyyy"];
        
        createdDateLabel.text = LocalizedDateString([dateFormatter stringFromDate:createdDate]);
        
        if ([GlobalVars sharedInstance].langCode == ELangEnglish)
            [dateFormatter setDateFormat:@"h:mm a"];
        else
            [dateFormatter setDateFormat:@"H:mm"];
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-4*60*60]];
        createdTimeLabel.text = [dateFormatter stringFromDate:createdDate];
        
        NSString *category = [NSString stringWithFormat:@" %@", GET_VALIDATED_STRING(_issueDictionary[@"CategoryName"], @"")];
        _issueCategoryLabel.text = category;
        
        if ([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee) {
            self.createdForLabel.hidden = NO;
            
            if(self.issueDictionary[@"RecipientType"]){
                ERecipientType type = [self.issueDictionary[@"RecipientType"] integerValue];
                if (type == ERecipientTypeEmployee) {
                    self.createdForLabel.text = LocalizedString(@"Internal");
                    self.createdForLabel.backgroundColor = ORANGE_COLOR;
                } else if (type == ERecipientTypeTenant) {
                    self.createdForLabel.text = LocalizedString(@"Tenant");
                    self.createdForLabel.backgroundColor = NAV_BAR_COLOR;
                } else if (type == ERecipientTypeServiceSupport) {
                    self.createdForLabel.text = LocalizedString(@"Support");
                    self.createdForLabel.backgroundColor = [UIColor colorWithRed:209/255.0f green:240/255.0f blue:209/255.0f alpha:1.0f];
                }
            }
            
            // Show Phone number if employee has permission: hasViewEmployeeMobileNumberPermission
            
            if ([[GlobalVars sharedInstance] hasViewEmployeeMobileNumberPermission] &&
                creatorType == EUserTypeEmployee) {
                [self showPhoneNumber:YES];
            } else if ([[GlobalVars sharedInstance] hasViewTenantPhoneNumberEmailDOBPermission] &&
                       creatorType == EUserTypeTenant) {
                [self showPhoneNumber:YES];
            } else {
                [self showPhoneNumber:NO];
            }
        } else {
            _createdforlabelWidConstraint.constant = 0;
            self.createdForLabel.hidden = YES;
            
            [self showPhoneNumber:NO];
        }
    }
    
    // Priority
    if ([Utilities isValidString:_issueDictionary[@"PriorityLevel"]]) {
        NSInteger priorityCode = [_issueDictionary[@"PriorityLevel"] integerValue];
        NSString *priorityName = LocalizedString(GET_VALIDATED_STRING(_issueDictionary[@"PriorityLevelName"], @""));
        _priorityLabel.text = priorityName;
        if (priorityCode == 1) {
            _priorityLabel.backgroundColor = BLUE_COLOR;
        } else if(priorityCode == 2) {
            _priorityLabel.backgroundColor = ORANGE_COLOR;
        } else if(priorityCode == 3) {
            _priorityLabel.backgroundColor = UNIT_RED_COLOR;
        }
    } else {
        _priorityLabel.hidden = YES;
    }
    // Status
    NSString *issueStatus = [GET_VALIDATED_STRING(_issueDictionary[@"StatusName"], @"") uppercaseString];
    NSString *issueStatusDetail = GET_VALIDATED_STRING(_issueDictionary[@"SubStatusName"], @"");
    
    NSString *issueStatusString = [NSString stringWithFormat:@"%@ %@", issueStatus, [Utilities formatStringWithSpace:issueStatusDetail]];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:issueStatusString attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONTNAME_BOLD size:changeIssueStatusButton.titleLabel.font.pointSize] range:[issueStatusString rangeOfString:issueStatus]];
    [changeIssueStatusButton setAttributedTitle:attrStr forState:UIControlStateNormal];

    
    // Update status color according sub status
    NSInteger statusCode = [_issueDictionary[@"Status"] integerValue];
    NSInteger subStatusCode = [_issueDictionary[@"SubStatus"] integerValue];
    _statusBarView.backgroundColor = [[GlobalVars sharedInstance] getStatusColorWithStatus:statusCode SubStatusCode:subStatusCode];
}

- (void)showPhoneNumber:(BOOL)isShow {
    if (isShow) {
        phonenumberButton.hidden = NO;
        _progressbarTopConstraint.constant = 1;
    } else {
        phonenumberButton.hidden = YES;
        _progressbarTopConstraint.constant = 1;
    }
}

#pragma mark - Tabbar

- (void)buildTabbar {
    
    generalTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"IssueGeneralViewPage"];
    generalTabController.issueDictionary = _issueDictionary;
    generalTabController.delegate = self;
    generalTabController.view.frame = CGRectMake(0, 0, _tabScrollView.frame.size.width, _tabScrollView.frame.size.height);
    generalTabController.messageTextField.delegate = self;
    
    [_tabScrollView addSubview:generalTabController.view];
    [self addChildViewController: generalTabController];
    
    
    IssueManagerUpdatesTabVC *updatesTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"IssueUpdatesTabViewPage"];
    updatesTabController.issueDictionary = _issueDictionary;
    [updatesTabController.view setFrame:CGRectMake(960, 0, _tabScrollView.frame.size.width, _tabScrollView.frame.size.height)];
    [_tabScrollView addSubview:updatesTabController.view];
    [self addChildViewController:updatesTabController];
    
    
    if(self.issueDictionary[@"RecipientType"]){
        ERecipientType type = [self.issueDictionary[@"RecipientType"] integerValue];
        
        if ([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee ) {
            if (type == ERecipientTypeTenant) {
                IssueManagerTenantsTabVC *tenantsTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"IssueTenantsTabViewPage"];
                tenantsTabController.issueDictionary = [NSMutableDictionary dictionaryWithDictionary:_issueDictionary];
                [tenantsTabController.view setFrame:CGRectMake(320, 0, _tabScrollView.frame.size.width, _tabScrollView.frame.size.height)];
                [_tabScrollView addSubview:tenantsTabController.view];
                [self addChildViewController: tenantsTabController];
                
                
                IssueManagerAssigneeTabVC *assigneeTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"IssueAssigneeTabViewPage"];
                [assigneeTabController.view setFrame:CGRectMake(640, 0, _tabScrollView.frame.size.width, _tabScrollView.frame.size.height)];
                assigneeTabController.issueDictionary = [NSMutableDictionary dictionaryWithDictionary:_issueDictionary];
                //    assigneeTabController.isTenants = NO;
                [_tabScrollView addSubview: assigneeTabController.view];
                [self addChildViewController: assigneeTabController];
            } else if (type == ERecipientTypeServiceSupport) {
                _tenantstabButton.hidden = YES;
                _assigneetabButton.hidden = YES;
                _updatesbtnCenterXConstraint.constant = 40;
            } else {
                _tenantstabButton.hidden = YES;
                _assigneebtnCenterXConstraint.constant = 0;
                
                IssueManagerTenantsTabVC *tenantsTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"IssueTenantsTabViewPage"];
                tenantsTabController.issueDictionary = [NSMutableDictionary dictionaryWithDictionary:_issueDictionary];
                [tenantsTabController.view setFrame:CGRectMake(640, 0, _tabScrollView.frame.size.width, _tabScrollView.frame.size.height)];
                [_tabScrollView addSubview:tenantsTabController.view];
                [self addChildViewController: tenantsTabController];
            }
            
        } else {
            [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                _tenantstabButton.hidden = YES;
                _assigneetabButton.hidden = YES;
                _assigneebtnCenterXConstraint.constant = 0;
                _updatesbtnCenterXConstraint.constant = 40;
            }];
        }
    }
}

- (void)buildChangeStatusBar {
    EIssueStatusType issueStatus = [self.issueDictionary[@"Status"] integerValue];
    if (issueStatus == EIssueStatusCanceled || issueStatus == EIssueStatusResolved) {
        
        // About resolved issue, the employeer can force it opened if they have permission: hasForceResolveAndReOpenIssue and Issue has CanReopen possibilities.
        if (issueStatus == EIssueStatusResolved &&
            [GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee &&
            [[GlobalVars sharedInstance] hasForceResolveAndReOpenIssue] &&
            self.issueDictionary[@"WorkflowPossibilities"] && [self.issueDictionary[@"WorkflowPossibilities"][@"CanReopen"] boolValue]) {
            
            _arrowButton.hidden = NO;
            changeIssueStatusButton.userInteractionEnabled = YES;
        } else {
            _arrowButton.hidden = YES;
            changeIssueStatusButton.userInteractionEnabled = NO;
        }
        
        _delayedButton.hidden = YES;
        _completedButton.hidden = YES;
        
        if ([GlobalVars sharedInstance].isEasymode) {
            _toolbarHeiConstraint.constant = 0;
            _toolbarView.hidden = YES;
            _arrowButton.hidden = YES;
            changeIssueStatusButton.userInteractionEnabled = NO;
        } else {
            _toolbarHeiConstraint.constant = 36;
            _toolbarView.hidden = NO;
        }
    } else {
        
        if ([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee) {
            if ([GlobalVars sharedInstance].isEasymode) {
                _arrowButton.hidden = YES;
                _delayedButton.hidden = NO;
                _completedButton.hidden = NO;
                changeIssueStatusButton.userInteractionEnabled = NO;
                
                _generalTabButton.userInteractionEnabled = NO;
                _tenantstabButton.userInteractionEnabled = NO;
                _assigneetabButton.userInteractionEnabled = NO;
                _updateTabButton.userInteractionEnabled = NO;
            }
            else {
                _delayedButton.hidden = YES;
                _completedButton.hidden = YES;
                
                EUserType createUser;
                ERecipientType reciType;
                if ([self.issueDictionary[@"Creator"][@"IsGeneratedBySystem"] boolValue]) {
                    createUser = EUserTypeEmployee;
                } else {
                    createUser = [self.issueDictionary[@"Creator"][@"Type"] integerValue];
                }
                
                reciType = [self.issueDictionary[@"RecipientType"] integerValue];
                
                if (createUser == EUserTypeEmployee && reciType == ERecipientTypeTenant) {
                    if ([[GlobalVars sharedInstance] hasChangeStatusOfEmployeeCreatedIssue]) {
                        _arrowButton.hidden = NO;
                        changeIssueStatusButton.userInteractionEnabled = YES;
                    } else {
                        _arrowButton.hidden = YES;
                        changeIssueStatusButton.userInteractionEnabled = NO;
                    }
                } else if (createUser == EUserTypeTenant && reciType == ERecipientTypeTenant) {
                    if ([[GlobalVars sharedInstance] hasChangeStatusOfTenantCreatedIssue]) {
                        _arrowButton.hidden = NO;
                        changeIssueStatusButton.userInteractionEnabled = YES;
                    } else {
                        _arrowButton.hidden = YES;
                        changeIssueStatusButton.userInteractionEnabled = NO;
                    }
                } else  {
                    _arrowButton.hidden = NO;
                    changeIssueStatusButton.userInteractionEnabled = YES;
                }
            }
        } else if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) {
            _delayedButton.hidden = YES;
            _completedButton.hidden = YES;
            
            if (issueStatus == EIssueStatusResolved) {
                _arrowButton.hidden = YES;
                changeIssueStatusButton.userInteractionEnabled = NO;
            } else {
                NSString *creatorId = [NSString stringWithFormat:@"%@", self.issueDictionary[@"Creator"][@"UserId"]];
                if ([creatorId isEqualToString:[GlobalVars sharedInstance].currentUser.userId]) {
                    _arrowButton.hidden = NO;
                    changeIssueStatusButton.userInteractionEnabled = YES;
                } else {
                    _arrowButton.hidden = YES;
                    changeIssueStatusButton.userInteractionEnabled = NO;
                }
            }
        }
    }
}

//----------------------------- IssueManagerGeneralTabVC textfield delegate ----------------------------------//
- (void)openTabScrollView:(CGFloat)keyboardHei {
    if (_scrlBtmConstraint.constant != keyboardHei) {
        _scrlTopConstraint.constant = -1 * 253;
        _scrlBtmConstraint.constant = keyboardHei;
    }
}

- (void)closeTabScrollView {
    if (_scrlTopConstraint.constant != 0) {
        _scrlTopConstraint.constant = 0;
        _scrlBtmConstraint.constant = 0;
    }
}

#pragma mark Text Field Delegate, This is from IssueManagerGeneralTabVC class
- (void)textFieldDidChange:(UITextField *)textField {
    if ([generalTabController.messageTextField.text isEqualToString:@""]) {
        if (!generalTabController.isImageSendDisabled) {
            generalTabController.msgsendButton.hidden = YES;
            generalTabController.imgsendButton.hidden = NO;
        }
    } else {
        generalTabController.msgsendButton.hidden = NO;
        generalTabController.imgsendButton.hidden = YES;
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CGFloat endOffset = generalTabController.messageTable.contentSize.height - generalTabController.messageTable.frame.size.height - 5;
            if (generalTabController.messageTable.contentOffset.y < endOffset) {
                if (generalTabController.messageArray.count > 0) {
                    [generalTabController.messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:generalTabController.messageArray.count+1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    [generalTabController.messageTable beginUpdates];
                    [generalTabController.messageTable endUpdates];
                }
            }
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self closeTabScrollView];
    return [textField resignFirstResponder];
}

-(void)keyboardDidShow:(NSNotification*)notification
{
    if(!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //        [_tabScrollView setContentOffset:CGPointMake(0, keyboardFrameBeginRect.size.height) animated:YES];
        [self openTabScrollView:keyboardFrameBeginRect.size.height];
        
        //        [self.navigationController setNavigationBarHidden:YES animated:YES];
        //        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        //            // iOS 7
        //            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        //        }
    }
}
//-----------------------------------------------------------------------------------------------------------//

#pragma mark - UIButton Action

- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (IBAction)readStatusButtonClicked:(UIButton *)sender{
//    [KGModal sharedInstance].closeButtonType = KGModalCloseButtonTypeNone;
//
//    IssueReadStatusViewController *popupController = [self.storyboard instantiateViewControllerWithIdentifier:@"issueReadStatusPopupPage"];
//    popupController.view.frame = CGRectMake(0, 0, 300, MIN(popupController.statusArray.count * 65, 300));
////    [[KGModal sharedInstance] showWithContentView:popupController.view andAnimated:YES];
//    [[KGModal sharedInstance] showWithContentViewc:popupController andAnimated:YES];
//}

- (IBAction)tabClicked:(UIButton *)sender{
    [UIView animateWithDuration:0.3 animations:^{
        _tabBottomBarView.center = CGPointMake(sender.center.x, _tabBottomBarView.center.y);
    }];
    
    [_tabScrollView setContentOffset:CGPointMake(sender.tag * 320, 0) animated:YES];
}
- (IBAction)onClickChangeStatus:(id)sender {
    [self performSegueWithIdentifier:@"GoChangeStatusVC" sender:self];
}

- (IBAction)onOpen:(id)sender {
    IssueChangeStatusVC *controller = (IssueChangeStatusVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"issueChangeStatus"];
    [self.navigationController pushViewController:controller animated:YES];
    //    [self performSegueWithIdentifier:@"aaa" sender:nil];
}

- (IBAction)onClickDelay:(id)sender {
    [SVProgressHUD show];
    [[APIController sharedInstance] changeStatusToDelayWithIssueId:[_issueDictionary[@"IssueId"] integerValue] successHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        if ([jsonData[@"Successful"] boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
            [generalTabController getIssueDetail];
        }
        
    } failureHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", [error description]);
    }];
}

- (IBAction)onClickPhone:(id)sender {
    if (!phonenumberButton.isHidden) {
        NSString *phoneNum = [[phonenumberButton titleForState:UIControlStateNormal] componentsSeparatedByString:LocalizedString(@": ")][1];
        
        if ([phoneNum isEqualToString:LocalizedString(@"Unknown")]) {
            return;
        }
        
        [[[UIAlertView alloc] initWithTitle:@"" message:phoneNum delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil] show];
    }
}

- (IBAction)onClickComplete:(id)sender {
    [SVProgressHUD show];
    [[APIController sharedInstance] changeStatusToCompleteWithIssueId:[_issueDictionary[@"IssueId"] integerValue] successHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        if ([jsonData[@"Successful"] boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
            [generalTabController getIssueDetail];
        }
    } failureHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", [error description]);
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [phonenumberButton titleColorForState:UIControlStateNormal]]];
        [[UIApplication sharedApplication] openURL:telURL];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"GoChangeStatusVC"]) {
        IssueChangeStatusVC *destVC = (IssueChangeStatusVC *) [segue destinationViewController];
        destVC.issueStatus = [self.issueDictionary[@"Status"] integerValue];
        
        NSString *creatorId = [NSString stringWithFormat:@"%@", self.issueDictionary[@"Creator"][@"UserId"]];
        destVC.isIssueCreator = [creatorId isEqualToString:[GlobalVars sharedInstance].currentUser.userId];
    }
}

@end
