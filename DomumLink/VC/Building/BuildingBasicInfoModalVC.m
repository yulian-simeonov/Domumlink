//
//  BuildingBasicInfoModalVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/30/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "BuildingBasicInfoModalVC.h"

@interface BuildingBasicInfoModalVC () <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UILabel *statusLabel;
    
    IBOutlet UILabel *priceLabel;
    
    
    NSArray *tenantArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tenantTable;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;

// Localization
@property (weak, nonatomic) IBOutlet UILabel *unitDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *curPriceDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *tenantsDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;


@end

NSMutableData *responseData;

@implementation BuildingBasicInfoModalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Localization
    _informationLabel.text = LocalizedString(@"INFORMATION");
    _unitDescLabel.text = LocalizedString(@"Unit");
    _statusDescLabel.text = LocalizedString(@"Status");
    _curPriceDescLabel.text = LocalizedString(@"CurrentPrice");
    _tenantsDescLabel.text = LocalizedString(@"TENANTS");
    
    
    statusLabel.text = @"";
    priceLabel.text = @"";
    
    responseData = [[NSMutableData alloc] init];
    [SVProgressHUD show];
        
    [[APIController sharedInstance] getBuildingUnitsDetailWithUnitId:[self.unitId integerValue] successHandler:^(id jsonData) {
        if (jsonData == nil) {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:jsonData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            NSDictionary *dictionary = (NSDictionary*)jsonData;
            NSDictionary *unitDict = dictionary[@"Unit"];
            
            NSString *renovStatus = unitDict[@"RenovationStatus"];
            if ([renovStatus isKindOfClass:[NSDictionary class]])
                renovStatus = [(NSDictionary *)renovStatus objectForKey:@"Description"];
            else
                renovStatus = [Utilities formatStringWithSpace:renovStatus];
            
            statusLabel.text = renovStatus;
            priceLabel.text = [NSString stringWithFormat:@"$%@ (CAD)", [unitDict[@"Price"] stringValue]];
            _unitLabel.text = [NSString stringWithFormat:@"%@", unitDict[@"UnitName"]];
            
            if (jsonData[@"Tenants"] && [jsonData[@"Tenants"] isKindOfClass:[NSArray class]]) {
                tenantArray = [NSArray arrayWithArray:jsonData[@"Tenants"]];
                [_tenantTable reloadData];
            }
        }
        [SVProgressHUD dismiss];
    } failureHandler:^(NSError *error) {
        NSLog(@"%@", [error description]);
        [SVProgressHUD dismiss];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *tenant = tenantArray[indexPath.row];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"GoTenantDetail" object:@{@"TenantID" : tenant[@"UserId"]}];

    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoTenantDetail" object:@{@"TenantID" : tenant[@"UserId"]}];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tenantArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TenantCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = tenantArray[indexPath.row][@"Name"];
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0f];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}
- (IBAction)onClickClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
