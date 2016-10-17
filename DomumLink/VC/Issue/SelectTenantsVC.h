//
//  SelectTenantsVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 4/17/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"

@interface SelectTenantsVC : UIViewController <SKSTableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet SKSTableView* tableView;
@property (assign, nonatomic) NSInteger tenantId;

@end