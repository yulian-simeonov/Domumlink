//
//  AssignEmployeesVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 4/18/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"

@interface AssignEmployeesVC : UIViewController <SKSTableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet SKSTableView* tableView;
@property (strong, nonatomic) NSArray *selectedBuildinArray;

@end
