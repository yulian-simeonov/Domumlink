//
//  IssueManagerGeneralTabVC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 1/30/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueManagerGeneralTabVC : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) id delegate;

@property (nonatomic, strong) NSDictionary *issueDictionary;

@property (nonatomic, strong) IBOutlet UITextField *messageTextField;

@property (weak, nonatomic) IBOutlet UIButton *msgsendButton;
@property (weak, nonatomic) IBOutlet UIButton *imgsendButton;
@property (weak, nonatomic) IBOutlet UITableView *messageTable;

@property (retain, nonatomic) NSArray *messageArray;

@property (nonatomic) BOOL isImageSendDisabled;

- (void)getIssueDetail;

@end
