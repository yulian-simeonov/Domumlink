//
//  VC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/12/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "LoginVC.h"
#import "JSON.h"
#import "ActivityIndicator.h"
#import "HomeVC.h"
#import "MySidePanelController.h"

@interface LoginVC (){
    IBOutlet UIScrollView *mainScrollView;
    
    IBOutlet UIView *emailView;
    IBOutlet UIView *passwordView;
    
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextField *passwordTextField;
    
    IBOutlet UIButton *loginButton;
    IBOutlet UIButton *activateButton;
}

@end

BOOL isLoading;

NSMutableData *responseData;

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor purpleColor]];
    
    emailView.layer.cornerRadius = 3;
    passwordView.layer.cornerRadius = 3;
    loginButton.layer.cornerRadius = 3;
    activateButton.layer.cornerRadius = 3;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
    emailTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    passwordTextField.text = @""; //[[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"];
}

- (void)viewDidAppear:(BOOL)animated{
//    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]){
//        emailTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
//        passwordTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"];
//        [self onLogin:nil];
//    }
//    NSDictionary *authCookieDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"AuthCookieDict"];
//    if(authCookieDict){
//        [GlobalVars sharedInstance].authCookie = [[NSHTTPCookie alloc] initWithProperties: authCookieDict];
//        
//        MySidePanelController *panelController = [self.storyboard instantiateViewControllerWithIdentifier:@"sidePanel"];
//        [self presentViewController:panelController animated:YES completion: nil];
//        return;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) {
        [emailTextField resignFirstResponder];
        [passwordTextField becomeFirstResponder];
        return NO;
    }
    else
    {
        [loginButton sendActionsForControlEvents: UIControlEventTouchUpInside];
    }
    
    [mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    return [textField resignFirstResponder];
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    if(!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    CGRect keyboardFrameInWindow;
    
//    int h = keyboardFrameInWindow.size.height;
    //NSLog(@"h: %d, bo.zie: %f, y:%f, hei:%f", h, myscroller.bounds.size.height, _passwordTxt.frame.origin.y, _passwordTxt.frame.size.height);
    
//    int offset = h - (mainScrollView.bounds.size.height - passwordView.superview.frame.origin.y - passwordView.superview.frame.size.height)+160;
    //NSLog(@"offset : %d", offset);
    if (mainScrollView.contentOffset.y == 0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (SCRN_HEIGHT == 480)
            [mainScrollView setContentOffset:CGPointMake(0, 120) animated:YES];
        else
            [mainScrollView setContentOffset:CGPointMake(0, 50) animated:YES];
    }
}

- (IBAction)onLogin:(UIButton *)sender{
    
    if (isLoading)
        return;
    
    NSString *username = emailTextField.text;
    NSString *password = passwordTextField.text;
    
    if ([username isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Please enter your username." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }else if ([password isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Warnning" message:@"Please enter your password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    [SVProgressHUD show];
    
    [[APIController sharedInstance] loginWithEmail:username andPassword:password withSuccessHandler:^(id jsonData){
        NSLog(@"%@", jsonData);
        [SVProgressHUD dismiss];
        if(jsonData[@"data"]) {
            [SharedAppDelegate showSidePanel];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateSideMenu" object:nil];
    } withFailureHandler:^(NSError *error){
        [SVProgressHUD dismiss];
        [Utilities showMsg:@"The user name or password is incorrect. Please verify and try again."];
        passwordTextField.text = @"";
    }];
    
//    // Start Connection...
//    [[ActivityIndicator currentIndicator] show];
//    
//    responseData = [[NSMutableData alloc] init];
//    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:API_LOGIN_URL]];
//    [req setHTTPMethod:@"POST"];
//    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//    
//    NSString *body = [NSString stringWithFormat:@"userEmail=%@&password=%@", username, password];
//    [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
//    [NSURLConnection  connectionWithRequest:req delegate:self];
//    isLoading = YES;
}


@end