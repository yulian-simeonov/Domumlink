//
//  ActivationVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/12/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "ActivationVC.h"

@interface ActivationVC (){
    IBOutlet UIScrollView *mainScrollView;
    
    IBOutlet UIScrollView *formScrollView;
    
    IBOutlet UIView *smsView;
    IBOutlet UIView *phoneView;
    
    IBOutlet UIButton *smsButton;
    IBOutlet UIButton *phoneButton;
    
    IBOutlet UIView *numberView;
    IBOutlet UIButton *proceedButton;
    IBOutlet UITextField *numberTextField;
    
    IBOutlet UIButton *startoverButton;
    
    IBOutlet UIImageView *backgroundImageView;
    IBOutlet UIImageView *greenTickImageView;
    IBOutlet UILabel *activationLabel;
    
    IBOutletCollection( UIImageView) NSMutableArray *navCircleArray;
}

@end

@implementation ActivationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    smsView.layer.cornerRadius = 3;
    phoneView.layer.cornerRadius = 3;
    
    numberView.layer.cornerRadius = 3;
    proceedButton.layer.cornerRadius = 3;
    
    startoverButton.layer.cornerRadius = 3;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
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

- (IBAction)goSecondPage:(id)sender{
    UIButton *clickedButton = (UIButton *)sender;
    if(clickedButton.tag == 0){
        [formScrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    }
    else if(clickedButton.tag == 1){
        [formScrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    }
    
    UIImageView *navCircle1 = (UIImageView *)[navCircleArray objectAtIndex: 0];
    UIImageView *navCircle2 = (UIImageView *)[navCircleArray objectAtIndex: 1];
    navCircle1.image = [UIImage imageNamed:@"nav_empty_circle"];
    navCircle2.image = [UIImage imageNamed:@"nav_tick_circle"];
}

- (IBAction)goThirdPage:(id)sender{
    [numberTextField resignFirstResponder];
    [mainScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [formScrollView setContentOffset:CGPointMake(640, 0) animated:YES];
    
    UIImageView *navCircle2 = (UIImageView *)[navCircleArray objectAtIndex: 1];
    UIImageView *navCircle3 = (UIImageView *)[navCircleArray objectAtIndex: 2];
    navCircle2.image = [UIImage imageNamed:@"nav_empty_circle"];
    navCircle3.image = [UIImage imageNamed:@"nav_tick_circle"];
    
    backgroundImageView.image = [UIImage imageNamed:@"cloud_background"];
    activationLabel.hidden = YES;
    greenTickImageView.hidden = NO;
}

- (IBAction)startOverClicked:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    return [textField resignFirstResponder];
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    if(!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [mainScrollView setContentOffset:CGPointMake(0, 200) animated:YES];
    }
}

@end
