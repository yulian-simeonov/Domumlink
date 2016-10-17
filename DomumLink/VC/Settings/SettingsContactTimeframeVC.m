//
//  SettingsContactTimeframeVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 3/20/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "SettingsContactTimeframeVC.h"

@interface SettingsContactTimeframeVC (){
    IBOutlet UITableView *timeframeTableView;
    
    UITextField *notifyFromTextField;
    UITextField *notifyToTextField;
}

@end

enum PasswordRows
{
    Row_Current,
    Row_New,
    Row_Confirm
};

UIDatePicker *fromPicker, *toPicker;

NSDateFormatter *dateFormatter;

@implementation SettingsContactTimeframeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Change Timeframe";
    
    dateFormatter = [GlobalVars sharedInstance].dateFormatterTime;
    [dateFormatter setDateFormat:@"h:mm a"];
    
    fromPicker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, 0, 280, 192)];
    fromPicker.datePickerMode = UIDatePickerModeTime;
    [fromPicker addTarget:self action:@selector(updateDateTextField:)
         forControlEvents:UIControlEventValueChanged];
    
    toPicker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, 0, 280, 192)];
    toPicker.datePickerMode = UIDatePickerModeTime;
    [toPicker addTarget:self action:@selector(updateDateTextField:)
         forControlEvents:UIControlEventValueChanged];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"NotifyFromTime"]){
        fromPicker.date = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotifyFromTime"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"NotifyToTime"]){
        toPicker.date = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotifyToTime"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews{
    if ([timeframeTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [timeframeTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([timeframeTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [timeframeTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (IBAction)backClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender{
    if([fromPicker.date compare: toPicker.date] == NSOrderedAscending){
        [[NSUserDefaults standardUserDefaults] setObject:fromPicker.date forKey:@"NotifyFromTime"];
        [[NSUserDefaults standardUserDefaults] setObject:toPicker.date forKey:@"NotifyToTime"];
    }
    else{
        ALERT(@"Error", @"Please enter a correct timeframe");
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateDateTextField:(UIDatePicker *)sender
{
    if(sender == fromPicker){
        notifyFromTextField.text = [dateFormatter stringFromDate:sender.date];
    }
    else{
        notifyToTextField.text = [dateFormatter stringFromDate:sender.date];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    
    // Configure the cell
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NotifyFromCellID" forIndexPath:indexPath];
        notifyFromTextField = (UITextField *)[cell viewWithTag:200];
        notifyFromTextField.delegate = self;
        notifyFromTextField.inputView = fromPicker;
        [notifyFromTextField becomeFirstResponder];
        [self updateDateTextField: fromPicker];
    }
    else if (indexPath.row == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NotifyToCellID" forIndexPath:indexPath];
        notifyToTextField = (UITextField *)[cell viewWithTag:200];
        notifyToTextField.delegate = self;
        notifyToTextField.inputView = toPicker;
        [self updateDateTextField: toPicker];
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
