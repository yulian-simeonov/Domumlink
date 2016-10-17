//
//  HomeVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/14/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "HomeVC.h"
#import "UIViewController+JASidePanel.h"
#import "IssuesVC.h"
#import "BuildingInfoVC.h"

@interface HomeVC (){
    IBOutlet UIButton *unreadIssuesButton;
    
    IBOutlet UIButton *openIssuesButton;
}
@property (weak, nonatomic) IBOutlet UIButton *issuesButton;
@property (weak, nonatomic) IBOutlet UIButton *buildinginfoButton;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    [SVProgressHUD show];
    
    [[APIController sharedInstance] loginWithEmail:[GlobalVars sharedInstance].currentUser.email andPassword:[GlobalVars sharedInstance].currentUser.password withSuccessHandler:^(id jsonData){
        NSLog(@"%@", jsonData);
        [SVProgressHUD dismiss];
        
        
        NSString *unreadString = [NSString stringWithFormat:@"%i %@", [GlobalVars sharedInstance].unreadIssuesCount, LocalizedString(@"UNREAD")];
        NSMutableAttributedString *unreadAttrString = [[NSMutableAttributedString alloc] initWithString:unreadString attributes:@{NSForegroundColorAttributeName: NAV_BAR_COLOR}];
        [unreadAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONTNAME_REGULAR size:15] range:[unreadString rangeOfString:LocalizedString(@"UNREAD")]];
        [unreadAttrString addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR1 range:[unreadString rangeOfString:LocalizedString(@"UNREAD")]];
        [unreadIssuesButton setAttributedTitle:unreadAttrString forState:UIControlStateNormal];
        
        NSString *openString = [NSString stringWithFormat:@"%i %@", [GlobalVars sharedInstance].openIssuesCount, LocalizedString(@"OPEN")];
        NSMutableAttributedString *openAttrString = [[NSMutableAttributedString alloc] initWithString:openString attributes:@{NSForegroundColorAttributeName: NAV_BAR_COLOR}];
        [openAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONTNAME_REGULAR size:15] range:[openString rangeOfString:LocalizedString(@"OPEN")]];
        [openAttrString addAttribute:NSForegroundColorAttributeName value:DARK_GRAY_COLOR1 range:[openString rangeOfString:LocalizedString(@"OPEN")]];
        [openIssuesButton setAttributedTitle:openAttrString forState:UIControlStateNormal];
        
        openIssuesButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        
    } withFailureHandler:^(NSError *error){
        [SVProgressHUD dismiss];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    // Localization
    self.title = LocalizedString(@"Home");
    [_issuesButton setTitle:LocalizedString(@"Issues") forState:UIControlStateNormal];
    [_buildinginfoButton setTitle:[NSString stringWithFormat:@" %@", LocalizedString(@"BuildingInfo")] forState:UIControlStateNormal];
    if ([GlobalVars sharedInstance].langCode == ELangEnglish) {
        [_buildinginfoButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:27.0f]];
    } else {
        [_buildinginfoButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:17.0f]];
    }
    
    int i = 0;
    i++;
    [self.sidePanelController showCenterPanelAnimated:YES];
}

-(void)viewDidLayoutSubviews{
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    UIColor *color = [[UIColor alloc] initWithRed:(90.0/255.0) green:(171.0/255.0) blue:(227.0/255.0) alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:color];
    for(UIBarButtonItem *button in self.navigationController.navigationBar.subviews){
        button.tintColor = [UIColor whiteColor];
    }
}
- (IBAction)onClickBuildingInfo:(id)sender {
    BuildingInfoVC *buildingInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"buildingInfoViewPage"];
    [self.navigationController pushViewController:buildingInfoVC animated:YES];
}

- (IBAction)menuClicked:(id)sender{
    [self.sidePanelController showLeftPanelAnimated: YES];
}

- (IBAction)issuesClicked:(UIButton *)sender{
    NSString *filterStr = @"";
    if(sender == unreadIssuesButton){
        filterStr = @"Unread";
    }
    else if(sender == unreadIssuesButton){
        filterStr = @"Open";
    }
    
    IssuesVC *issuesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"issuesViewPage"];
    issuesVC.filterString = filterStr;
    [self.navigationController pushViewController:issuesVC animated:YES];
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
