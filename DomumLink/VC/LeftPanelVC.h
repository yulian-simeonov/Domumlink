//
//  LeftPanelVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/15/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySidePanelController.h"
#import "JASidePanelController.h"

typedef enum {
    IssuesButton = 0,
    TenantsButton,
    BuildingButton
} ButtonActive;

@interface LeftPanelVC : UIViewController
{
    NSMutableArray *menuRows;
    
    IBOutlet UIButton *settingsButton;
}
@property (weak, nonatomic) IBOutlet UIView *menuView;

- (IBAction)issuesButtonPressed:(id)sender;
- (IBAction)tenantsButtonPressed:(id)sender;
- (IBAction)buildingButtonPressed:(id)sender;

//-(void)selectActiveButton:(ButtonActive) selected withActual:(ButtonActive) actual;

@end
