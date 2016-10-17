//
//  MySidePanelController.m
//  CustomKeyboardGallery
//
//  Created by Urucode on 7/25/14.
//  Copyright (c) 2014 UruCode. All rights reserved.
//

#import "MySidePanelController.h"
#import "HomeVC.h"
#import "BuildingsVC.h"
#import "AppDelegate.h"

@interface MySidePanelController ()


@end

@implementation MySidePanelController

@synthesize centerView;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    self.leftGapPercentage = 270.0f / 320.0f;
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    int i = 0;
    i++;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SetupView" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self setupView];
    }];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SetupView" object:nil];
}

-(NSUInteger)supportedInterfaceOrientations{
    
    UIDevice *device = [UIDevice currentDevice];
    
    if(device.userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.bounceOnCenterPanelChange = NO;
        if (UIInterfaceOrientationIsLandscape(device.orientation))
        {
            NSLog(@"Change to custom UI for landscape");
            self.rightGapPercentage = 0.30f;
            
        }
        else if (UIInterfaceOrientationIsPortrait(device.orientation))
        {
            NSLog(@"Change to custom UI for portrait");
            self.rightGapPercentage = 0.40f;
            
        }

        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        self.rightGapPercentage = 0.85f;
        return UIInterfaceOrientationMaskPortrait;
    }
    

}

/*
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Do any additional setup after loading the view.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {    // The iOS device = iPhone or iPod Touch
        
    }
    else if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    { // The iOS device = iPad
        
        
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            NSLog(@"Change to custom UI for landscape");
            self.rightGapPercentage = 0.40f;
            
        }
        else if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
                 toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            NSLog(@"Change to custom UI for portrait");
            self.rightGapPercentage = 0.85f;
            
        }
    }
    
}
*/



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) awakeFromNib
{
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"]];
    
    [SVProgressHUD show];
    if([GlobalVars sharedInstance].isLoggedIn &&
       [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"] &&
       [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]){
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"];
        
        if ([GlobalVars sharedInstance].currentUser.userId == nil) {
        
            [[APIController sharedInstance] loginWithEmail:username andPassword:password withSuccessHandler:^(id jsonData){
                [SVProgressHUD dismiss];
                
                if(jsonData[@"data"]) {
                    [self performSelector:@selector(setupView) withObject:nil afterDelay:0.5];
//                    [self setupView];
                } else {
                    [SharedAppDelegate showLogin];
                }
            } withFailureHandler:^(NSError *error){
                [SVProgressHUD dismiss];
                [SharedAppDelegate showLogin];
            }];
        } else {
            [self setupView];
        }
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showLogin) userInfo:nil repeats:NO];
    }
}

- (void)showLogin {
    [SharedAppDelegate showLogin];
}

- (void)setupView {
    UINavigationController *navController;
    if([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee){
        
        if ([[GlobalVars sharedInstance] hasBuildingStatusPermission] && ![GlobalVars sharedInstance].isEasymode) {
            BuildingsVC *buildingsVC;
            buildingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"buildingsViewPage"];
            navController = [[UINavigationController alloc] initWithRootViewController: buildingsVC];
        } else {
            navController = [[UINavigationController alloc] initWithRootViewController: [self.storyboard instantiateViewControllerWithIdentifier:@"issuesViewPage"]];
        }
    }
    else if([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant)
    {
        HomeVC *homeVC;
        
        homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewPage"];
        
        navController = [[UINavigationController alloc] initWithRootViewController: homeVC];
    }
    
    
    [self setCenterPanel:navController];
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"sideViewPage"]];
}


#pragma mark - JA side panels UI edit
- (void)styleContainer:(UIView *)container animate:(BOOL)animate duration:(NSTimeInterval)duration {
}

- (void)stylePanel:(UIView *)panel {
}

@end
