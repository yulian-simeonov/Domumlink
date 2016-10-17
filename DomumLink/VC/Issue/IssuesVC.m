//
//  IssuesVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/23/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "IssuesVC.h"
#import "UIViewController+JASidePanel.h"
#import "IssuesListCell.h"
#import "ActivityIndicator.h"
#import "JSON.h"
#import "IssueManagerGeneralVC.h"
#import "NSString+HTML.h"
#import "UIScrollView+BottomRefreshControl.h"
#import "KGModal.h"
#import "SelectIssueTypeVC.h"
#import "CreateIssue1VC.h"

@interface IssuesVC (){
    IBOutlet UIButton *listViewButton;
    
    IBOutlet UIButton *cardsViewButton;
    
    IBOutlet UILabel *viewModeLabel;
    
    IBOutlet UITableView *issuesTableView;
    
    NSInteger pageId;
}
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *submitbtnRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menubarHeiConstraint;

@property (nonatomic) id issueupdateObserver;
@property (nonatomic) id issueCreateObserver;

@property (weak, nonatomic) IBOutlet UILabel *noIssuesLabel;

@end

BOOL isLoading;
NSMutableData *responseData;
UIImage *cardsViewImage, *listViewImage;
bool viewMode;
NSInteger selectedIndex;
UIRefreshControl *topRefreshControl;

@implementation IssuesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _noIssuesLabel.text = LocalizedString(@"YouHaveNoOpenIssues");
    
    // Add bottom refresh to Tableview
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    refreshControl.triggerVerticalOffset = 100.;
    [refreshControl addTarget:self action:@selector(bottomRefreshHandler) forControlEvents:UIControlEventValueChanged];
    issuesTableView.bottomRefreshControl = refreshControl;

    topRefreshControl = [UIRefreshControl new];
    topRefreshControl.triggerVerticalOffset = 100.;
    [topRefreshControl addTarget:self action:@selector(topRefreshHandler) forControlEvents:UIControlEventValueChanged];
    [issuesTableView addSubview:topRefreshControl];
    
    // Initializer
    viewMode = 1;
    pageId = 1;
    issuesTableView.hidden = YES;
    _issueArray = [[NSMutableArray alloc] init];

    
    // Update UI
    [self updateUIContents];
    
    // Call Feed API
    [self getFeeds:YES];
    
    // Create local notifications
    _issueCreateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotiIssueCreate object:nil queue:nil usingBlock:^(NSNotification *note) {
        [[KGModal sharedInstance] hideAnimated:YES];
        ERecipientType reciType = [[note.object objectForKey:@"IssueType"] integerValue];
        
        CreateIssue1VC *createIssue = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateIssueVC"];
        createIssue.recipientType = reciType;
        [self.navigationController pushViewController:createIssue animated:YES];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotiIssueRefresh object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self performSelector:@selector(topRefreshHandler) withObject:nil afterDelay:1];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiIssueUpdated object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotiIssueCreate object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([GlobalVars sharedInstance].isEasymode) {
        _menubarHeiConstraint.constant = 0;
    } else {
        _menubarHeiConstraint.constant = 50;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Localization
    self.title = LocalizedString(@"Issues");
    [_submitButton setTitle:LocalizedString(@"SubmitAnIssue") forState:UIControlStateNormal];
    
    // Notification for update issue
    _issueupdateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kNotiIssueUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        if (selectedIndex < _issueArray.count) {
            NSDictionary *issueDict = note.object;
            [_issueArray replaceObjectAtIndex:selectedIndex withObject:issueDict];
            [issuesTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:selectedIndex]] withRowAnimation:UITableViewRowAnimationTop];
            [issuesTableView reloadInputViews];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews{
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    UIColor *color = [[UIColor alloc] initWithRed:(90.0/255.0) green:(171.0/255.0) blue:(227.0/255.0) alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:color];
    for(UIBarButtonItem *button in self.navigationController.navigationBar.subviews){
        button.tintColor = [UIColor whiteColor];
    }
}

- (void)topRefreshHandler {
    pageId = 1;
    [self getFeeds:YES];
}

- (void)bottomRefreshHandler {
    pageId = pageId + 1;
    [self getFeeds:NO];
}

#pragma mark - Function for UI Control
- (void)updateUIContents {
    // ---------------------------------------------------------------------//
    cardsViewImage = [[UIImage imageNamed:@"issues_list_large_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cardsViewButton setImage:cardsViewImage forState:UIControlStateNormal];
    cardsViewButton.tintColor = [UIColor whiteColor];
    
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) {
        listViewButton.hidden = YES;
        cardsViewButton.hidden = YES;
        _submitbtnRightConstraint.constant = -76;
    } else {
        listViewButton.hidden = NO;
        _submitbtnRightConstraint.constant = 8;
        listViewImage = [[UIImage imageNamed:@"issues_list_small_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [listViewButton setImage:listViewImage forState:UIControlStateNormal];
        listViewButton.tintColor = GRAY_COLOR;
    }
    
    if (![GlobalVars sharedInstance].isEasymode) {
        // Check if the user can submit issue
        [SVProgressHUD show];
        [[APIController sharedInstance] getModelForNewIssueWithRecipientType:ERecipientTypeTenant successHandler:^(id jsonData) {
            _submitButton.hidden = NO;
            _menubarHeiConstraint.constant = 50;
        } failureHandler:^(NSError *error) {
            _submitButton.hidden = YES;
            _menubarHeiConstraint.constant = 0;
        }];
    }
    
    // --------------------------------------------------------------------//
}

#pragma mark - Function for API call

- (void)getFeeds:(BOOL)isTopRefresh {
    // Do refresh stuff here
    // Start Connection...

    [SVProgressHUD show];
    [[APIController sharedInstance] feedIssuesWithPageId:pageId successHandler:^(id jsonData) {
        if (jsonData == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            if (topRefreshControl.isRefreshing)
                [topRefreshControl endRefreshing];
            if (isTopRefresh)
                [_issueArray removeAllObjects];
            
            issuesTableView.hidden = NO;
            NSDictionary *dictionary = (NSDictionary*)jsonData;
//            for(NSDictionary *issueDict in dictionary[@"Issues"]){
//                if(![self.filterString isEqualToString:@""]){
//                    if([self.filterString isEqualToString:@"Unread"] && ![issueDict[@"IsUnread"] boolValue]){
//                        continue;
//                    }
//                    else if([self.filterString isEqualToString:@"Open"] && ![GET_VALIDATED_STRING(issueDict[@"StatusName"], @"") isEqualToString:@"Open"]){
//                        continue;
//                    }
//                }
//                [_issueArray addObject:issueDict];
//            }
            [_issueArray addObjectsFromArray:dictionary[@"Issues"]];
            
            if (_issueArray.count > 0) {                
                _noIssuesLabel.hidden = YES;
                issuesTableView.hidden = NO;
            } else {
                _noIssuesLabel.hidden = NO;
                issuesTableView.hidden = YES;
            }
            
            [issuesTableView reloadData];
        }
        [issuesTableView.bottomRefreshControl endRefreshing];
        [SVProgressHUD dismiss];
    } withFailureHandler:^(NSError *error) {
        NSLog(@"%@", error);
        [issuesTableView.bottomRefreshControl endRefreshing];
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - UIButton Action

- (IBAction)viewSwitchButtonClicked:(UIButton *)sender{
    if(sender == cardsViewButton){
        listViewButton.backgroundColor = [UIColor whiteColor];
        listViewButton.tintColor = GRAY_COLOR;
        
        cardsViewButton.backgroundColor = NAV_BAR_COLOR;
        cardsViewButton.tintColor = [UIColor whiteColor];
        
        viewModeLabel.text = @"Cards";
        
        viewMode = 1;
    }
    else if(sender == listViewButton){
        listViewButton.backgroundColor = NAV_BAR_COLOR;
        listViewButton.tintColor = [UIColor whiteColor];
        
        cardsViewButton.backgroundColor = [UIColor whiteColor];
        cardsViewButton.tintColor = GRAY_COLOR;
        
        viewModeLabel.text = @"List";
        
        viewMode = 0;
    }
    
    [issuesTableView reloadData];
}

- (IBAction)onClickSubmit:(id)sender {
    
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) {
        CreateIssue1VC *createIssue = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateIssueVC"];
        createIssue.recipientType = ERecipientTypeTenant;
        [self.navigationController pushViewController:createIssue animated:YES];
    } else if ([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee) {
        if ([[GlobalVars sharedInstance] hasSendIssueToTenantPermission]) {
            [KGModal sharedInstance].closeButtonType = KGModalCloseButtonTypeNone;
            
            SelectIssueTypeVC *popupController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectIssueTypeVC"];
            popupController.view.frame = CGRectMake(0, 0, 300, 80);
            //    [[KGModal sharedInstance] showWithContentView:popupController.view andAnimated:YES];
            [[KGModal sharedInstance] showWithContentViewc:popupController andAnimated:YES];
        } else {
            CreateIssue1VC *createIssue = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateIssueVC"];
            createIssue.recipientType = ERecipientTypeEmployee;
            [self.navigationController pushViewController:createIssue animated:YES];
        }
    }
}

- (IBAction)menuClicked:(id)sender{
    [self.sidePanelController showLeftPanelAnimated: YES];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return 0;
    
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return nil;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, issuesTableView.frame.size.width, 25)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    return footerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, issuesTableView.frame.size.width, 5)];
    [bottomBorderView setBackgroundColor:RGB(211, 222, 235)];
    
    return bottomBorderView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _issueArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(viewMode == 0)
        return 116.0f;
    else {
        CGFloat height;
        NSDictionary *issue = _issueArray[indexPath.section];
        if ([issue[@"Images"] count] == 0) {
            height = 297;
        } else {
            height = 322.0f;
        }
        
        if ([GlobalVars sharedInstance].currentUser.type != EUserTypeTenant)
            return height;
        else
            return height - 26;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellPrototypeName = @"";
    
    if(viewMode == 0)
    {
        cellPrototypeName = @"issuesListCell";
    }
    else
    {
        cellPrototypeName = @"issuesCardsCell";
    }
    
    IssuesListCell *cell = (IssuesListCell *)[tableView dequeueReusableCellWithIdentifier:cellPrototypeName];
    if(cell == nil){
        cell = [[IssuesListCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellPrototypeName];
    }
    cell.delegate = self;
    
    NSDictionary *issue = _issueArray[indexPath.section];
//    NSLog(@"%@", issue);
    [cell proceedContent:issue section:indexPath.section viewMode:viewMode];
    
    if ([issue[@"Images"] count] == 0) {
        cell.scrlHeiConstraint.constant = 0;
        cell.scrolBelowLine.hidden = YES;
    } else {
        cell.scrlHeiConstraint.constant = 25;
        cell.scrolBelowLine.hidden = NO;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [GlobalVars sharedInstance].onWorkIssueId = [_issueArray[indexPath.section][@"IssueId"] integerValue];
    
    selectedIndex = indexPath.section;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"goManagerGeneral" sender:self];
    
//    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"TestVC"];
//    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"goManagerGeneral"]){
        IssueManagerGeneralVC *vc = (IssueManagerGeneralVC *)segue.destinationViewController;
        vc.issueDictionary = _issueArray[selectedIndex];
        vc.tableIndex = selectedIndex;
        [GlobalVars sharedInstance].issueManager = vc;
    }
}

@end