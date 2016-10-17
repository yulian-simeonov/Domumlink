//
//  IssueChangeStatusDetailVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 4/17/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "IssueChangeStatusDetailVC.h"
#import "IssueManagerGeneralVC.h"

@interface IssueChangeStatusDetailVC (){
    
    IBOutlet UIButton *cancelButton;
    
    IBOutlet UIButton *submitButton;
    
    
    NSDictionary *statusDict;
}

@property (nonatomic, strong) NSArray *changeStatusDetailArray;
@property (weak, nonatomic) IBOutlet UITableView *statusTable;

@property (nonatomic, retain) NSIndexPath *selectedStatusIndexPath;

@end

@implementation IssueChangeStatusDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [GlobalVars sharedInstance].issueStatusArray[self.changeStatusSelectedInd];

//    changeStatusDetailArray = [GlobalVars sharedInstance].changeStatusArray[self.changeStatusSelectedInd];
    
    _selectedStatusIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
   
    
    // Localization
    [cancelButton setTitle:[NSString stringWithFormat:@" %@", LocalizedString(@"CANCEL")] forState:UIControlStateNormal];
    [submitButton setTitle:[NSString stringWithFormat:@" %@", LocalizedString(@"SUBMIT")] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [SVProgressHUD show];
    
    [[APIController sharedInstance] getPossibleSubStatusesWithIssueId:[GlobalVars sharedInstance].onWorkIssueId targetStatus:self.changeStatusSelectedInd successHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        
        NSLog(@"%@", jsonData);
        
        statusDict = jsonData;
        
        _changeStatusDetailArray = [NSArray arrayWithArray:jsonData[@"PossibleSubStatuses"]];
        
        [_statusTable reloadData];
        NSLog(@"%@", _changeStatusDetailArray);
        if (_changeStatusDetailArray.count == 0) {
            NSLog(@"Empty");
        } else {
            NSLog(@"Existing");
        }
    } failureHandler:^(NSError *error) {
        [SVProgressHUD dismiss];
        
        NSLog(@"%@", [error description]);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeStatusAction:(UIButton *)sender{
    if(sender == cancelButton){
        for (UIViewController *vc in [self.navigationController viewControllers]) {
            if ([vc isMemberOfClass:[IssueManagerGeneralVC class]]) {
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
    }
    else if(sender == submitButton){
        [SVProgressHUD show];
        submitButton.enabled = NO;
        [[APIController sharedInstance] resolveStatusWithIssueId:[GlobalVars sharedInstance].onWorkIssueId targetStatus:[statusDict[@"TargetStatus"] integerValue] force:[statusDict[@"Force"] integerValue] targetSubStatus:[_changeStatusDetailArray[_selectedStatusIndexPath.row][@"IssueSubStatus"] integerValue] reopenMsg:statusDict[@"ReopenMessage"] successHandler:^(id jsonData)  {
            
            [SVProgressHUD dismiss];
            
            submitButton.enabled = YES;
            if ([jsonData[@"Successful"] boolValue]) {
                [[GlobalVars sharedInstance].issueManager updateContentUponStatusChange];
                
                for (UIViewController *vc in [self.navigationController viewControllers]) {
                    if ([vc isMemberOfClass:[IssueManagerGeneralVC class]]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        return;
                    }
                }

            }
        } failureHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
            submitButton.enabled = YES;
            NSLog(@"%@", [error description]);
        }];
    }
    
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _changeStatusDetailArray.count;
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
    
    cell.textLabel.text = _changeStatusDetailArray[indexPath.row][@"Text"];
    
    if(indexPath.row == _selectedStatusIndexPath.row){
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
    NSIndexPath *oldSelectedIndexPath = [NSIndexPath indexPathForRow:_selectedStatusIndexPath.row inSection:0];
    _selectedStatusIndexPath = indexPath;
    if (_selectedStatusIndexPath.row != oldSelectedIndexPath.row) {
        [tableView reloadRowsAtIndexPaths:@[oldSelectedIndexPath, _selectedStatusIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
        [tableView deselectRowAtIndexPath:_selectedStatusIndexPath animated:YES];
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
