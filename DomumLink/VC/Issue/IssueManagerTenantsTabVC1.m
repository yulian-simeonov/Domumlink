//
//  IssueManagerTenantsTabVC.m
//  DomumLink
//
//  Created by AnMac on 2/4/15.
//  Copyright (c) 2015 Petr. All rights reserved.
//

#import "IssueManagerTenantsTabVC.h"
#import "IssueAddRecipientCell.h"

@interface IssueManagerTenantsTabVC () <UITableViewDataSource, UITableViewDelegate>{
    IBOutlet UITableView *recipientsTableView;
    
    NSMutableArray *tenantArray;
}

@end

bool addRecipientsClicked;

@implementation IssueManagerTenantsTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    return;
    
    tenantArray = [[NSMutableArray alloc] init];
    [tenantArray addObject:@"Benie Towsend"];
    [tenantArray addObject:@"Alphonso Solberg"];
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

-(void)viewDidLayoutSubviews
{
    if ([recipientsTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [recipientsTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([recipientsTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [recipientsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (IBAction)addRecipientsClicked:(id)sender{
    addRecipientsClicked = addRecipientsClicked ? NO : YES;
    
    [recipientsTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tenantArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = addRecipientsClicked ? @"addRecipientCell" : @"recipientCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    if(addRecipientsClicked){
        IssueAddRecipientCell *addCell = (IssueAddRecipientCell *)cell;
        
        if(indexPath.row == 1)
            addCell.tickImageView.image = [UIImage imageNamed:@"add_tenant_checked"];
        else
            addCell.tickImageView.image = [UIImage imageNamed:@"add_tenant_unchecked"];
            
        addCell.nameLabel.text = tenantArray[indexPath.row];
    }
    else{
        cell.textLabel.text = tenantArray[indexPath.row];
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(addRecipientsClicked){
        
    }
}

@end
