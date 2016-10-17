//
//  TenantsVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/22/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "TenantsVC.h"
#import "TenantDetailsVC.h"
#import "UIScrollView+BottomRefreshControl.h"

@interface TenantsVC (){
    IBOutlet UITableView *tenantsTableView;
    NSInteger pageId;
}

@property (strong, nonatomic) NSMutableArray *tenantArray;

@end

BOOL isLoading;

NSMutableData *responseData;

NSInteger selectedTenantInd;

@implementation TenantsVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Localization
    self.title = LocalizedString(@"Tenants");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    tenantsTableView.hidden = YES;
    // Start Connection...
    responseData = [[NSMutableData alloc] init];
    _tenantArray = [NSMutableArray array];
    // Add bottom refresh to Tableview
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    refreshControl.triggerVerticalOffset = 100.;
    [refreshControl addTarget:self action:@selector(bottomRefreshHandler) forControlEvents:UIControlEventValueChanged];
    tenantsTableView.bottomRefreshControl = refreshControl;
    
    pageId = 1;
    [self getFeeds:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)bottomRefreshHandler {
    pageId = pageId + 1;
    [self getFeeds:NO];
}

- (void)getFeeds:(BOOL)isTopRefresh {
    [SVProgressHUD show];
    [[APIController sharedInstance] feedTenantsWithBuildingId:nil PageNumber:pageId successHandler:^(id jsonData) {
        if (jsonData == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            if (isTopRefresh)
                [_tenantArray removeAllObjects];
            
            tenantsTableView.hidden = NO;
            NSDictionary *dictionary = (NSDictionary*)jsonData;
            [_tenantArray addObjectsFromArray:dictionary[@"Tenants"]];
            
            [GlobalVars sharedInstance].tenantArray = _tenantArray;
            [tenantsTableView reloadData];
            
            [tenantsTableView.bottomRefreshControl endRefreshing];
        }
        [SVProgressHUD dismiss];
    } withFailureHandler:^(NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"goTenantDetails"]){
        TenantDetailsVC *tenantDetailsVC = (TenantDetailsVC *)[segue destinationViewController];
        tenantDetailsVC.tenantDict = _tenantArray[selectedTenantInd];
        tenantDetailsVC.tenantId = _tenantArray[selectedTenantInd][@"TenantId"];
    }
}

-(void)viewDidLayoutSubviews{
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor]};
    UIColor *color = [[UIColor alloc] initWithRed:(90.0/255.0) green:(171.0/255.0) blue:(227.0/255.0) alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:color];
    for(UIBarButtonItem *button in self.navigationController.navigationBar.subviews){
        button.tintColor = [UIColor whiteColor];
    }
}

- (IBAction)menuClicked:(id)sender{
    [self.sidePanelController showLeftPanelAnimated: YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tenantsTableView.frame.size.width, 25)];
    [footerView setBackgroundColor:self.view.backgroundColor];

    return footerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tenantsTableView.frame.size.width, 5)];
    [bottomBorderView setBackgroundColor:RGB(211, 222, 235)];
    
    return bottomBorderView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _tenantArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tenantCell"];
    
    cell.textLabel.text = _tenantArray[indexPath.section][@"Name"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedTenantInd = indexPath.section;
    [tenantsTableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"goTenantDetails" sender:self];
}

@end
