//
//  BuildingsVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/23/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "BuildingsVC.h"
#import "Building.h"
#import "BuildingStatusCell.h"
#import "BuildingDetailsVC.h"
#import "ActivityIndicator.h"

@interface BuildingsVC (){
    IBOutlet UITableView *buildingsTableView;
}

@end

BOOL isLoading;

NSMutableData *responseData;

NSMutableArray *buildingArray;

NSInteger selectedBuildingInd;

@implementation BuildingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    buildingsTableView.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Localization
    self.title = LocalizedString(@"BuildingStatus");
    
    // Start Connection...
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [SVProgressHUD show];
    }];
    
    [[APIController sharedInstance] feedBuildingsStatusWithSuccessHandler:^(id jsonData) {
        if (jsonData == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            buildingsTableView.hidden = NO;
            NSDictionary *dictionary = (NSDictionary*)jsonData;
            buildingArray = dictionary[@"BuildingStatuses"];
            [buildingsTableView reloadData];
        }
        [SVProgressHUD dismiss];
    } withFailureHandler:^(NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"goBuildingDetails"]){
        BuildingDetailsVC *buildingDetailsVC = (BuildingDetailsVC *)[segue destinationViewController];
        buildingDetailsVC.buildingDict = buildingArray[selectedBuildingInd];
    }
}

- (IBAction)menuClicked:(id)sender{
    [self.sidePanelController showLeftPanelAnimated: YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buildingsTableView.frame.size.width, 25)];
    [footerView setBackgroundColor:self.view.backgroundColor];
    
    return footerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, buildingsTableView.frame.size.width, 5)];
    [bottomBorderView setBackgroundColor:RGB(211, 222, 235)];
    
    return bottomBorderView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return buildingArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 230.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *building = buildingArray[indexPath.section];
    
    BuildingStatusCell *cell = (BuildingStatusCell *)[tableView dequeueReusableCellWithIdentifier:@"buildingStatusCell"];
    if(cell == nil){
        cell = [[BuildingStatusCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:@"buildingStatusCell"];
    }
    [cell proceedContent:@{}];
    
    cell.buildingTitleLabel.text = building[@"BuildingName"];
    cell.buildingImageView.image = nil;
    if (building[@"BuildingImage"] && ![building[@"BuildingImage"] isKindOfClass:[NSNull class]]) {
        [cell.buildingImageView sd_setImageWithURL:[NSURL URLWithString:building[@"BuildingImage"][@"Url"]] placeholderImage:[UIImage imageNamed:@"img_nobuilding"]];
    }
    
    cell.apartmentLabel.text = [building[@"ApartmentVacancies"] stringValue];
    cell.parkingLabel.text = [building[@"ParkingVacancies"] stringValue];
    cell.storageLabel.text = [building[@"StorageVacancies"] stringValue];
    
    cell.normalLabel.text = [building[@"NormalIssues"] stringValue];
    cell.seriousLabel.text = [building[@"SeriousIssues"] stringValue];
    cell.urgentLabel.text = [building[@"UrgentIssues"] stringValue];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedBuildingInd = indexPath.section;
    [self performSegueWithIdentifier:@"goBuildingDetails" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end