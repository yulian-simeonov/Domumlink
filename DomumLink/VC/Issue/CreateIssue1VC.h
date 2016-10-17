//
//  CreateIssue1VC.h
//  DomumLink
//
//  Created by Yulian Simeonov on 4/17/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateIssue1VC : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (nonatomic) ERecipientType recipientType;
@property (assign, nonatomic) NSInteger tenantId;
@property (strong, nonatomic) NSDictionary* tenantBuildingInfo;

- (void)handleIssueInfo:(NSDictionary *)info Type:(NSInteger)type Index:(NSInteger)index delegate:(id)delegate;
- (void)handleUploadedImage:(NSDictionary *)imageInfo;

@end
