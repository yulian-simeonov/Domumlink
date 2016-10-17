//
//  SettingsChangePasswordVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 3/20/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "SettingsChangePasswordVC.h"

@interface SettingsChangePasswordVC (){
    IBOutlet UITableView *passwordTableView;
    
    UITextField *currentPasswordTextField;
    UITextField *newPasswordTextField;
    UITextField *confirmPasswordTextField;
}

@end

enum PasswordRows
{
    Row_Current,
    Row_New,
    Row_Confirm
};

@implementation SettingsChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Change Password";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews{
    if ([passwordTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [passwordTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([passwordTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [passwordTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender{
    if([currentPasswordTextField.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]]){
        if([newPasswordTextField.text isEqualToString:confirmPasswordTextField.text]){
            [[NSUserDefaults standardUserDefaults] setObject:newPasswordTextField.text forKey:@"UserPassword"];
        }
        else{
            ALERT(@"Error", @"Please confirm your new password again.");
            return;
        }
    }
    else{
        ALERT(@"Error", @"Please enter your current password correctly.");
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == currentPasswordTextField) {
        [currentPasswordTextField resignFirstResponder];
        [newPasswordTextField becomeFirstResponder];
        return NO;
    }
    else if(textField == newPasswordTextField)
    {
        [newPasswordTextField resignFirstResponder];
        [confirmPasswordTextField becomeFirstResponder];
        return NO;
    }
    else if(textField == confirmPasswordTextField)
    {
        [self doneButtonClicked:nil];
    }
    
    return [textField resignFirstResponder];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    // Configure the cell
    if (indexPath.row == Row_Current)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CurrentPasswordCellID" forIndexPath:indexPath];
        currentPasswordTextField = (UITextField *)[cell viewWithTag:200];
        currentPasswordTextField.delegate = self;
        [currentPasswordTextField becomeFirstResponder];
    }
    else if (indexPath.row == Row_New)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewPasswordCellID" forIndexPath:indexPath];
        newPasswordTextField = (UITextField *)[cell viewWithTag:200];
        newPasswordTextField.delegate = self;
    }
    else if (indexPath.row == Row_Confirm)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ConfirmPasswordCellID" forIndexPath:indexPath];
        confirmPasswordTextField= (UITextField *)[cell viewWithTag:200];
        confirmPasswordTextField.delegate = self;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
