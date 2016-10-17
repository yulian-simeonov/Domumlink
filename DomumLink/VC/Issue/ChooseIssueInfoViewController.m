//
//  ChooseIssueInfoViewController.m
//  DomumLink
//
//  Created by iOS Dev on 6/28/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "ChooseIssueInfoViewController.h"

#import "CreateIssue1VC.h"

@interface ChooseIssueInfoViewController () {
    NSArray *infoArray;
    NSIndexPath *selectedStatusIndexPath;
}

@property (weak, nonatomic) IBOutlet UITableView *infoTable;

@end

@implementation ChooseIssueInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedStatusIndexPath = [NSIndexPath indexPathForRow:_selIndex inSection:0];
    [SVProgressHUD show];
    switch (_infoType) {
        case 1: { // Category type
            self.title = LocalizedString(@"Category");
            [[APIController sharedInstance] getIssueCategoryWithSuccessHandler:^(id jsonData) {
                [SVProgressHUD dismiss];
                
                [jsonData insertObject:@{@"Name" : LocalizedString(@"SelectCategory")} atIndex:0];
                infoArray = [NSArray arrayWithArray:jsonData];
                [_infoTable reloadData];
            } failureHandler:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSLog(@"%@", [error description]);
            }];
        }
            break;
        case 2: { // Location Type
            self.title = LocalizedString(@"Location");
            [[APIController sharedInstance] getIssueLocationTypeWithSuccessHandler:^(id jsonData) {
                [SVProgressHUD dismiss];
                [jsonData insertObject:@{@"Name" : LocalizedString(@"SelectLocation")} atIndex:0];
                infoArray = [NSArray arrayWithArray:jsonData];
                [_infoTable reloadData];
            } failureHandler:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSLog(@"%@", [error description]);
            }];
        }
            break;
        case 3: { // Select building Type
            self.title = LocalizedString(@"Building");
            
            [[APIController sharedInstance] getIssueLocationBuildingsWithSuccessHandler:^(id jsonData) {
                [SVProgressHUD dismiss];
                NSLog(@"%@", jsonData);
                [jsonData insertObject:@{@"Name" : LocalizedString(@"SelectBuilding")} atIndex:0];
                infoArray = [NSArray arrayWithArray:jsonData];
                [_infoTable reloadData];
            } failureHandler:^(NSError *error) {
                [SVProgressHUD dismiss];
                
                NSLog(@"%@", [error description]);
            }];
        }
            break;
        case 4: { // Select building location Type
            self.title = LocalizedString(@"SelectLocation");
            [[APIController sharedInstance] getIssueLocationsWithSuccessHandler:^(id jsonData) {
                [SVProgressHUD dismiss];
                [jsonData insertObject:@{@"Name" : LocalizedString(@"UnspecifiedLocation")} atIndex:0];
                
                infoArray = [NSArray arrayWithArray:jsonData];
                [_infoTable reloadData];
            } failureHandler:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSLog(@"%@", [error description]);
            }];
        }
            break;
        case 5: { // Select Floor Type
            self.title = LocalizedString(@"Floor");
            [[APIController sharedInstance] getIssueLocationFloorsWithLocationId:_locationId LocationBuildingId:_locationBuildingId SuccessHandler:^(id jsonData) {
                [SVProgressHUD dismiss];
                
                [jsonData insertObject:@{@"Name" : LocalizedString(@"DoesNotApplyToAFloor")} atIndex:0];
                
                infoArray = [NSArray arrayWithArray:jsonData];
                [_infoTable reloadData];
            } failureHandler:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSLog(@"%@", [error description]);
            }];
        }
            break;
        case 6: { // Select Unit
            self.title = LocalizedString(@"Unit");
            [[APIController sharedInstance] getIssueLocationApartmentsWithLocationBuildingId:_locationBuildingId SuccessHandler:^(id jsonData) {
                [SVProgressHUD dismiss];
                NSLog(@"%@", jsonData);
                [jsonData insertObject:@{@"Name" : LocalizedString(@"SelectUnit")} atIndex:0];
                
                infoArray = [NSArray arrayWithArray:jsonData];
                [_infoTable reloadData];
            } failureHandler:^(NSError *error) {
                [SVProgressHUD dismiss];
                NSLog(@"%@", [error description]);
            }];
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Action

- (IBAction)backClicked:(id)sender{
    if (selectedStatusIndexPath.row == 0)
        [(CreateIssue1VC *)self.delegate handleIssueInfo:nil Type:_infoType Index:selectedStatusIndexPath.row delegate: self];
    else {
        [(CreateIssue1VC *)self.delegate handleIssueInfo:infoArray[selectedStatusIndexPath.row] Type:_infoType Index:selectedStatusIndexPath.row delegate:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return infoArray.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"changeStatusCell"];
    
    cell.textLabel.text = infoArray[indexPath.row][@"Name"];
    
    if(indexPath.row == selectedStatusIndexPath.row){
        cell.textLabel.font = [UIFont fontWithName:FONTNAME_SEMIBOLD size:cell.textLabel.font.pointSize];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.textLabel.font = [UIFont fontWithName:FONTNAME_REGULAR size:cell.textLabel.font.pointSize];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *oldSelectedIndexPath = [NSIndexPath indexPathForRow:selectedStatusIndexPath.row inSection:0];
    selectedStatusIndexPath = indexPath;
    if (oldSelectedIndexPath.row != selectedStatusIndexPath.row)
        [tableView reloadRowsAtIndexPaths:@[oldSelectedIndexPath, selectedStatusIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    else
        [tableView deselectRowAtIndexPath:selectedStatusIndexPath animated:YES];
    
    if (indexPath.row > 0) {
        [(CreateIssue1VC *)self.delegate handleIssueInfo:infoArray[selectedStatusIndexPath.row] Type:_infoType Index:selectedStatusIndexPath.row delegate:self];
        
        if ([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee) {
            ChooseIssueInfoViewController *destVC = (ChooseIssueInfoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ChooseIssueInfolVC"];
            if (self.infoType == 2) { // Location Type
                if (indexPath.row > 1) {
                    destVC.infoType = 3; // Select Building
                    NSDictionary *locationDict = infoArray[selectedStatusIndexPath.row];
                    if (locationDict)
                        destVC.locationId = [locationDict[@"Value"] integerValue];
                    destVC.delegate = self.delegate;
                    [self.navigationController pushViewController:destVC animated:YES];
                }
            } else if (self.infoType == 3) { // Building Type
                if (self.locationId == ELocationCommonArea) {
                    [(CreateIssue1VC *)self.delegate handleIssueInfo:infoArray[selectedStatusIndexPath.row] Type:_infoType Index:selectedStatusIndexPath.row delegate:self];
                    [self.navigationController popToViewController:self.delegate animated:YES];
                } else if (self.locationId == ELocationApartment) {
                    destVC.infoType = 6; // Select Building
                    destVC.locationId = self.locationId;
                    NSDictionary *buildingDict = infoArray[selectedStatusIndexPath.row];
                    if (buildingDict)
                        destVC.locationBuildingId = [buildingDict[@"Value"] integerValue];
                    destVC.delegate = self.delegate;
                    [self.navigationController pushViewController:destVC animated:YES];
                }
            } else if (self.infoType == 6) { // Unit
                [(CreateIssue1VC *)self.delegate handleIssueInfo:infoArray[selectedStatusIndexPath.row] Type:_infoType Index:selectedStatusIndexPath.row delegate:self];
                [self.navigationController popToViewController:self.delegate animated:YES];
            }
        } else {
            if (self.infoType == 2) { // Location Type
                NSDictionary *locationDict = infoArray[selectedStatusIndexPath.row];
                if (locationDict) {
                    ELocationType locationType = [locationDict[@"Value"] integerValue];
                    if (locationType == ELocationApartment) {  // Choose "My Apartment"
                        [(CreateIssue1VC *)self.delegate handleIssueInfo:locationDict Type:_infoType Index:selectedStatusIndexPath.row delegate:self];
                        [self.navigationController popToViewController:self.delegate animated:YES];
                    } else if (locationType == ELocationCommonArea) {
                        [SVProgressHUD show];
                        
                        [(CreateIssue1VC *)self.delegate handleIssueInfo:locationDict Type:_infoType Index:selectedStatusIndexPath.row delegate:self];
                        
                        [[APIController sharedInstance] getIssueLocationBuildingsWithSuccessHandler:^(id jsonData) {
                            [SVProgressHUD dismiss];
                            NSDictionary *buildingDict = jsonData[0];
                            if (buildingDict) {
                                [(CreateIssue1VC *)self.delegate handleIssueInfo:buildingDict Type:3 Index:1 delegate:self];
                            }
                            [self.navigationController popToViewController:self.delegate animated:YES];
                        } failureHandler:^(NSError *error) {
                            [SVProgressHUD dismiss];
                            NSLog(@"%@", [error description]);
                            [self.navigationController popToViewController:self.delegate animated:YES];
                        }];
                    }
                }
            }
        }
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
