//
//  SelectIssueTypeVC.m
//  DomumLink
//
//  Created by iOS Dev on 6/1/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "SelectIssueTypeVC.h"

#import "CreateIssue1VC.h"

@interface SelectIssueTypeVC ()
@property (weak, nonatomic) IBOutlet UILabel *reporttenantLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportemployeeLabel;

@end

@implementation SelectIssueTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Localization
    _reporttenantLabel.text = LocalizedString(@"ReportTenantIssue");
    _reportemployeeLabel.text = LocalizedString(@"ReportEmployeeIssue");
}

- (IBAction)onClickReportTenant:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiIssueCreate object:@{@"IssueType":@(ERecipientTypeTenant)}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickReportEmployee:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiIssueCreate object:@{@"IssueType":@(ERecipientTypeEmployee)}];
    [self dismissViewControllerAnimated:YES completion:nil];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
