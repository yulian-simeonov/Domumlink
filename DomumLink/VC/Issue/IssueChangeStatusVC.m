//
//  IssueChangeStatusVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 4/16/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "IssueChangeStatusVC.h"
#import "IssueChangeStatusDetailVC.h"

@interface IssueChangeStatusVC () <UITableViewDataSource, UITableViewDelegate> {
}

@property (weak, nonatomic) IBOutlet UITableView *changeStatusTableView;

@end

@implementation IssueChangeStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = LocalizedString(@"ChangeStatus");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidLayoutSubviews{
    if ([_changeStatusTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_changeStatusTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_changeStatusTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_changeStatusTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant || self.issueStatus == EIssueStatusResolved)
        return 1;
    return self.isIssueCreator ? [GlobalVars sharedInstance].issueStatusArray.count : [GlobalVars sharedInstance].issueStatusArray.count-1;
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
    
    if (indexPath.row == 2) {
        cell.textLabel.textColor = [UIColor redColor];
    }
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant)
        cell.textLabel.text = [GlobalVars sharedInstance].issueStatusArray[2];
    else if (self.issueStatus == EIssueStatusResolved)
        cell.textLabel.text = LocalizedString(@"Reopen");
    else
        cell.textLabel.text = [GlobalVars sharedInstance].issueStatusArray[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"issueChangeStatusDetail" sender:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    IssueChangeStatusDetailVC *changeStatusDetailVC = (IssueChangeStatusDetailVC *)segue.destinationViewController;
    NSIndexPath *selectedIndexPath = [_changeStatusTableView indexPathForSelectedRow];
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant)
        changeStatusDetailVC.changeStatusSelectedInd = 2;
    else if (self.issueStatus == EIssueStatusResolved)
        changeStatusDetailVC.changeStatusSelectedInd = 0;
    else
        changeStatusDetailVC.changeStatusSelectedInd = (int)selectedIndexPath.row;
    [_changeStatusTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

@end
