//
//  IssueMsgDetailViewController.m
//  DomumLink
//
//  Created by Yosemite on 11/12/15.
//  Copyright © 2015 YulianMobile All rights reserved.
//

#import "IssueMsgDetailViewController.h"

@interface TimeAndPermissionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *permissionLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permissionLabelHeiConstraint;
@end

@implementation TimeAndPermissionCell

@end

@interface BasicTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation BasicTableViewCell

@end

@interface IssueMsgDetailViewController () <UITableViewDataSource, UITableViewDelegate> {
    
    NSArray *identifiers;
    NSAttributedString *msgString;
    NSDateFormatter *formatter;
    NSAttributedString *employeeAtrString;
    NSAttributedString *tenantAtrString;
    NSString *permissionStr;
    NSString *submittedAtStr;
}

@property (weak, nonatomic) IBOutlet UITableView *msgTable;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation IssueMsgDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    identifiers = @[@"DateCell", @"BasicCell"];
    
    formatter = [GlobalVars sharedInstance].dateFormatterTime;
    if ([GlobalVars sharedInstance].langCode == ELangEnglish)
        [formatter setDateFormat:@"MMM dd yyyy - h:mma"];
    else
        [formatter setDateFormat:@"dd MMM yyyy - H:mm"];

    _titleLabel.text = LocalizedString(@"MessageDetails");
    
    // Created Time and Permission Label
    NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:[_issueMessageDict[@"DateSubmitted"] integerValue]];
    submittedAtStr = [formatter stringFromDate:createdDate];
    
    
    EUserType creatorType = [_issueMessageDict[@"Creator"][@"UserType"] integerValue];
    BOOL visibleForTenants = [_issueMessageDict[@"VisibleForTenants"] boolValue];
    NSInteger messageType = _issueDescription ? 0 : [Utilities isValidString:_issueMessageDict[@"SubStatusName"]] ? 1 : 2; // 0: Issue Description, 1: Status message, 2: General Message
    
    if (messageType == 1) { // Status Message
        permissionStr = nil;
    } else if (messageType == 2) { // General Message
        if (_isTenantIssue) { // Tenant Issue
            if (creatorType == EUserTypeEmployee && visibleForTenants) {
                permissionStr = LocalizedString(@"VisibleTenantsAndEmployees");
            } else if (creatorType == EUserTypeEmployee && !visibleForTenants) {
                permissionStr = LocalizedString(@"VisibleEmployeesOnly");
            } else if (creatorType == EUserTypeTenant && !visibleForTenants) {
                permissionStr = LocalizedString(@"VisibleOneTenantAndEmployee");
            } else if (visibleForTenants) {
                permissionStr = LocalizedString(@"VisibleTenantsAndEmployees");
            }
        } else { // Internale & Support Issue
            permissionStr = LocalizedString(@"VisibleEmployeesOnly");
        }
    } else if (messageType == 0) { // Issue Description
        if (_isTenantIssue) {
            if (_issueCreatorType == EUserTypeEmployee)
                permissionStr = LocalizedString(@"VisibleTenantsAndEmployees");
            else if (_issueCreatorType == EUserTypeTenant)
                permissionStr = LocalizedString(@"VisibleOneTenantAndEmployee");
        } else {
            permissionStr = LocalizedString(@"VisibleEmployeesOnly");
        }
    } else {
        permissionStr = nil;
    }
    
    UIFont *systemFont = [UIFont systemFontOfSize:15.0f];
    
    NSString *str = _issueMessageDict[@"Text"];
    if (_issueDescription) {
        str = _issueDescription;
        NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:[_issueCreatedDate integerValue]];
        submittedAtStr = [formatter stringFromDate:createdDate];
    } else {
        if ([Utilities isValidString:_issueMessageDict[@"SubStatusName"]]) {
            str = _issueMessageDict[@"SubStatusName"];
        }
    }
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[str dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [attrStr addAttributes:@{NSFontAttributeName: systemFont, NSForegroundColorAttributeName:[UIColor darkGrayColor]} range:NSMakeRange(0, attrStr.length)];
    msgString = attrStr;
    NSLog(@"%@", _issueMessageDict);
    
    [_msgTable reloadData];
    
    
    if (messageType == 0) { // Issue Description
        [SVProgressHUD show];

        [[APIController sharedInstance] getIssueReadStatusWithIssueId:_issueId SuccessHandler:^(id jsonData) {
            [SVProgressHUD dismiss];
            NSLog(@"%@", jsonData);
            
            NSArray *employeesRead = jsonData[@"Employees"];
            employeeAtrString = [self createAttrString:employeesRead];
            
            NSMutableArray *muArray = [NSMutableArray arrayWithArray:identifiers];
            
            if (employeeAtrString) {
                [muArray addObject:@"EmployeesCell"];
            }
            
            tenantAtrString = [self createAttrString:jsonData[@"Tenants"]];
            
            if (tenantAtrString) {
                [muArray addObject:@"TenantsCell"];
            }
            
            identifiers = muArray;
            
            [_msgTable reloadData];
        } failureHandler:^(NSError *err) {
            NSLog(@"%@", [err description]);
        }];
    } else if (messageType == 2) { // General Message
        [SVProgressHUD show];

        [[APIController sharedInstance] getMsgReadStatusWithMessageId:_issueMessageDict[@"MessageId"] SuccessHandler:^(id jsonData) {
            [SVProgressHUD dismiss];
            NSLog(@"%@", jsonData);
            
            NSArray *employeesRead = jsonData[@"Employees"];
            employeeAtrString = [self createAttrString:employeesRead];
            
            NSMutableArray *muArray = [NSMutableArray arrayWithArray:identifiers];
            
            if (employeeAtrString) {
                [muArray addObject:@"EmployeesCell"];
            }
            
            tenantAtrString = [self createAttrString:jsonData[@"Tenants"]];
            
            if (tenantAtrString) {
                [muArray addObject:@"TenantsCell"];
            }
            
            identifiers = muArray;
            
            [_msgTable reloadData];
        } failureHandler:^(NSError *err) {
            NSLog(@"%@", [err description]);
        }];

    }
}

- (NSAttributedString *)createAttrString:(NSArray *)array {
    if (array.count > 0) {
        NSMutableAttributedString *muAtrStr = [[NSMutableAttributedString alloc] init];
        for (NSDictionary *dict in array) {
            
            NSAttributedString *readTimeAttrStr;
            if (![dict[@"IsRead"] boolValue]) {
                NSString *unread = [NSString stringWithFormat:@"(%@)\n", LocalizedString(@"UnRead")];
                readTimeAttrStr= [[NSAttributedString alloc] initWithString:unread attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0f], NSForegroundColorAttributeName : [UIColor redColor]}];
            } else {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dict[@"ReadTime"] integerValue]];
                UIColor *color = [UIColor colorWithRed:72/255.0f green:130/255.0f blue:67/255.0f alpha:1.0];
                
                NSString *readTimeStr = [NSString stringWithFormat:@"%@\n", LocalizedDateString([formatter stringFromDate:date])];

                readTimeAttrStr= [[NSAttributedString alloc] initWithString:readTimeStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0f], NSForegroundColorAttributeName : color}];
            }
            
            NSAttributedString *nameAttrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - ", dict[@"Name"]] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.0f], NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
            
            [muAtrStr appendAttributedString:nameAttrStr];
            [muAtrStr appendAttributedString:readTimeAttrStr];
        }
        
        return (NSAttributedString *)muAtrStr;
    } else {
        return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (permissionStr)
            return 50.0f;
        else
            return 30;
    } else {
        return [self heightForBasicCellAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return identifiers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiers[indexPath.row] forIndexPath:indexPath];
    
    NSString *identifier = identifiers[indexPath.row];
    if ([identifier isEqualToString:@"DateCell"]) {
        [(TimeAndPermissionCell *)cell createdAtLabel].text = LocalizedDateString(submittedAtStr);
        if (permissionStr) {
            [(TimeAndPermissionCell *)cell permissionLabel].hidden = NO;
            [(TimeAndPermissionCell *)cell permissionLabel].text = permissionStr;
        }
        else {
            [(TimeAndPermissionCell *)cell permissionLabel].hidden = YES;
        }
    } else
    if ([identifier isEqualToString:@"BasicCell"]) {
        [(BasicTableViewCell *)cell subtitleLabel].attributedText = msgString;
        NSString *titleStr = _issueDescription ? _issueCreator : _issueMessageDict[@"Creator"][@"UserName"];
        [(BasicTableViewCell *)cell titleLabel].text = [NSString stringWithFormat:@"%@:", titleStr];
    } else if ([identifier isEqualToString:@"EmployeesCell"]) {
        [(BasicTableViewCell *)cell subtitleLabel].attributedText = employeeAtrString;
        [(BasicTableViewCell *)cell titleLabel].text = LocalizedString(@"EmployeeReadStatus");
    } else if ([identifier isEqualToString:@"TenantsCell"]) {
        [(BasicTableViewCell *)cell subtitleLabel].attributedText = tenantAtrString;
        [(BasicTableViewCell *)cell titleLabel].text = LocalizedString(@"TenantReadStatus");
    }
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static BasicTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.msgTable dequeueReusableCellWithIdentifier:@"BasicCell"];
    });
    
    NSString *identifier = identifiers[indexPath.row];
    
    if ([identifier isEqualToString:@"BasicCell"]) {
        sizingCell.subtitleLabel.attributedText = msgString;
    } else if ([identifier isEqualToString:@"EmployeesCell"]) {
        sizingCell.subtitleLabel.attributedText = employeeAtrString;
    } else if ([identifier isEqualToString:@"TenantsCell"]) {
        sizingCell.subtitleLabel.attributedText = tenantAtrString;
    }
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.msgTable.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

#pragma mark - UIButton Action
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
