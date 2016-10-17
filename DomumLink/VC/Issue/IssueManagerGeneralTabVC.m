//
//  IssueManagerGeneralTabVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/30/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "IssueManagerGeneralTabVC.h"

#import "NSString+HTML.h"
#import "SVSegmentedControl.h"
#import "IssueManagerGeneralVC.h"
#import "UIViewController+ENPopUp.h"
#import "IssueMsgReadViewController.h"
#import "KGModal.h"
#import "LocationCell.h"
#import "MessageCell.h"
#import "IssueMsgDetailViewController.h"

// Bubble Cell
@interface BubbleCell : UITableViewCell {
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *desclabelHeiConstraint;
@end

@implementation BubbleCell
@end

@interface IssueManagerGeneralTabVC () <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIView *messageInputBoxView;
    
    BOOL isExistingDelayedStatus;
}

@property (weak, nonatomic) IBOutlet UIView *switchView;
@property (weak, nonatomic) IBOutlet UILabel *msgtypeLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *imgScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgscrlHeiConstraint;
@property (weak, nonatomic) IBOutlet UIView *borderlineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgtypeHeiConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputviewHeiConstraint;
@property (weak, nonatomic) IBOutlet UIView *msgtypeView;
@property (nonatomic) id updatemsgObserver;

@property (nonatomic, strong) SVSegmentedControl *msgTypeSegment;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputfieldHeiConstraint;



@end

@implementation IssueManagerGeneralTabVC


CGFloat bubbleHei = 88;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Localization
    isExistingDelayedStatus = NO;
    
    _msgtypeLabel.text = LocalizedString(@"MessageType");
    _messageTextField.placeholder = LocalizedString(@"EnterYourMessageHere");

    // Update UI with user type and permission
    [self updateContentWithUserTypeAndPermission];
    
    // Make up message input box
    CALayer *borderLayer = [CALayer layer];
    borderLayer.borderColor = GRAY_COLOR.CGColor;
    borderLayer.borderWidth = 1;
    borderLayer.frame = CGRectMake(-1, 1, CGRectGetWidth(messageInputBoxView.frame)+2, CGRectGetHeight(messageInputBoxView.frame)+2);
    [messageInputBoxView.layer addSublayer:borderLayer];
    
    
    if(self.issueDictionary) {
        NSString *htmlStr = GET_VALIDATED_STRING(_issueDictionary[@"Description"], @"");
        NSString *issueDescription = [[htmlStr stringByDecodingHTMLEntities] stringByConvertingHTMLToPlainText];
        
        CGSize textSize = [issueDescription sizeWithFont:[UIFont fontWithName:@"OpenSans" size:12] constrainedToSize:CGSizeMake(269, 20000) lineBreakMode: NSLineBreakByWordWrapping]; //Assuming your width is 240
        
        float heightToAdd = MIN(textSize.height, 130.0f) + 35;
        
        bubbleHei = heightToAdd;
        
        
        [self updateImageScroll];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Notification for updated status
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getIssueDetail];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:_updatemsgObserver];
    _updatemsgObserver = nil;
}

#pragma mark - Function for API call

- (void)getIssueDetail {
    if (_issueDictionary[@"IssueId"]) {
        [SVProgressHUD show];
        [[APIController sharedInstance] getIssueDetailWithIssueId:[_issueDictionary[@"IssueId"] integerValue] successHandler:^(id jsonData) {
                        NSLog(@"%@", jsonData);
            
            [SVProgressHUD dismiss];
            _issueDictionary = jsonData;
            
            NSMutableArray *tenantMessages = [NSMutableArray array];
            for (NSDictionary *dict in jsonData[@"Messages"]) {
                NSString *creatorId = [NSString stringWithFormat:@"%@", dict[@"Creator"][@"UserId"]];
                if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant) {
                    if ([dict[@"VisibleForTenants"] boolValue] ||
                        [creatorId isEqualToString:[GlobalVars sharedInstance].currentUser.userId]) {
                        
                        [tenantMessages addObject:dict];
                    }
                } else {
                    [tenantMessages addObject:dict];
                }
            }
            _messageArray = (NSArray *)tenantMessages;
            
            [_messageTable reloadData];
            if (_messageArray.count > 0) {
                [_messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_messageArray.count+1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                //                [_messageTable beginUpdates];
                //                [_messageTable endUpdates];
                
                NSString *lastMsg = _messageArray[_messageArray.count - 1][@"Text"];
                
                [jsonData setObject:lastMsg forKey:@"LastMessage"]; // For matching json forward with API_GET_ISSUE_LIST_URL API json.
            }
            
            [jsonData setObject:jsonData[@"Recipients"] forKey:@"Recipients"]; // For matching json forward with API_GET_ISSUE_LIST_URL API json.
            [jsonData setObject:jsonData[@"Assignees"] forKey:@"Assignees"]; // For matching json forward with API_GET_ISSUE_LIST_URL API json.
            
            [self updateImageScroll];
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiIssueUpdated object:_issueDictionary];
            
            [[GlobalVars sharedInstance].issueManager updateContentWithIssueData:_issueDictionary];
            
            
            // Set Delay Button Disable if there is a delay status existing in Easy mode
//            if ([GlobalVars sharedInstance].isEasymode) {
//                for (NSDictionary *messageDict in _messageArray) {
//                    EMessageType messageType = [messageDict[@"MessageEventType"] integerValue];
//                    if (messageType == EMessageTypeStatusChange) {
//                        NSLog(@"%@", messageDict);
//                        if ([messageDict[@"SubStatus"] integerValue] ==  5) { // Delayed Status
//                            isExistingDelayedStatus = YES;
//                            [(IssueManagerGeneralVC *)self.delegate disableDelayButton];
//                            
//                            break;
//                        }
//                    }
//                }
//                
//                if (!isExistingDelayedStatus)
//                    [(IssueManagerGeneralVC *)self.delegate enableChangeStatusButton];
//
//            }
            
            //            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiIssueDetailUpdated object:_issueDictionary];
        } withFailureHandler:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSLog(@"%@", [error description]);
        }];
    }
}

#pragma mark - Functions for UI

- (void)updateContentWithUserTypeAndPermission {
    // Update UI with user type and easy mode
    if ([GlobalVars sharedInstance].currentUser.type == EUserTypeTenant || [GlobalVars sharedInstance].isEasymode) {
        [self removeMessageTypeView];
    } else if ([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee) {
        
        if(self.issueDictionary[@"RecipientType"]){
            ERecipientType type = [self.issueDictionary[@"RecipientType"] integerValue];
            if (type == ERecipientTypeTenant) {
                if ([[GlobalVars sharedInstance] hasWriteMsgOnTenantIssuePermission]) {
                    
                    if ([[GlobalVars sharedInstance] hasSendIssueToTenantPermission]) {
                        [self addMessageTypeView];
                    }
                    else {
                        EUserType createUser;
                        if ([self.issueDictionary[@"Creator"][@"IsGeneratedBySystem"] boolValue]) {
                            createUser = EUserTypeEmployee;
                        } else {
                            createUser = [self.issueDictionary[@"Creator"][@"Type"] integerValue];
                        }
                        if (
                            (
                             createUser == EUserTypeTenant &&
                             [[GlobalVars sharedInstance] hasRespondToTenantCreatedIssuePermission]
                             )
                            ||
                            (
                             createUser == EUserTypeEmployee &&
                             [[GlobalVars sharedInstance] hasRespondToEmployeeCreatedIssuePermission]
                             )
                            )
                        {
                            [self addMessageTypeView];
                        } else {
                            if (![[GlobalVars sharedInstance] hasRespondToTenantCreatedIssuePermission] && ![[GlobalVars sharedInstance] hasRespondToEmployeeCreatedIssuePermission]) { // If the user has only hasWriteMsgOnTenantIssuePermission permission.
                                [self removeImgSendButton];
                            }
                            [self removeMessageTypeView];
                        }
                        
                        if (createUser == EUserTypeEmployee &&
                            ![[GlobalVars sharedInstance] hasRespondToEmployeeCreatedIssuePermission] &&
                            [[GlobalVars sharedInstance] hasRespondToTenantCreatedIssuePermission]) {
                            [self removeImgSendButton];
                        }
                        
                        if (createUser == EUserTypeTenant &&
                            [[GlobalVars sharedInstance] hasRespondToEmployeeCreatedIssuePermission] &&
                            ![[GlobalVars sharedInstance] hasRespondToTenantCreatedIssuePermission]) {
                            [self removeImgSendButton];
                        }
                    }
                } else {
                    [self removeInputField];
                }
            } else {
                if (![[GlobalVars sharedInstance] hasWriteMsgOnTenantIssuePermission]) {
                    [self removeImgSendButton];
                }
                [self removeMessageTypeView];
            }
        }
    } else {
        [self removeMessageTypeView];
    }
    
    if (self.issueDictionary[@"Images"] && [self.issueDictionary[@"Images"] count] > 9) {
        [self removeImgSendButton];
    }
}
- (void)removeInputField {
    _inputfieldHeiConstraint.constant = 0;
    messageInputBoxView.hidden = YES;
}

- (void)removeMessageTypeView {
    _msgtypeHeiConstraint.constant = 0;
    _inputviewHeiConstraint.constant = 32;
    _msgtypeView.hidden = YES;
}

- (void)removeImgSendButton {
    _isImageSendDisabled = YES;
    _imgsendButton.hidden = YES;
    _msgsendButton.hidden = NO;
}

- (void)addMessageTypeView {
    _msgTypeSegment = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:LocalizedString(@"Employee"), LocalizedString(@"Tenant"), nil]];
    _msgTypeSegment.thumb.tintColor = ORANGE_COLOR;
    _msgTypeSegment.frame = CGRectMake(3, 3, _switchView.frame.size.width-6, _switchView.frame.size.height-6);
    
    _messageTextField.placeholder = LocalizedString(@"ThisTextWillBeVisibleToEmployeesOnly");
    
    // Add message type segement
    __weak IssueManagerGeneralTabVC *weakSelf = self;
    _msgTypeSegment.changeHandler = ^(NSUInteger newIndex) {
        NSLog(@"%lu", (unsigned long)newIndex);
        if (newIndex == 0) {
            weakSelf.messageTextField.placeholder = LocalizedString(@"ThisTextWillBeVisibleToEmployeesOnly");
            weakSelf.msgTypeSegment.thumb.tintColor = ORANGE_COLOR;
        }
        else {
            weakSelf.messageTextField.placeholder = LocalizedString(@"EnterYourMsgToTenantsHere");
            weakSelf.msgTypeSegment.thumb.tintColor = [UIColor colorWithRed:90/255.0f green:171/255.0f blue:227/255.0f alpha:1];
        }
    };
    [_switchView addSubview:_msgTypeSegment];
}


- (void)updateImageScroll {
    if(_issueDictionary[@"Images"] && _issueDictionary[@"Images"] != [NSNull null] && [_issueDictionary[@"Images"] count] > 0) {
        _borderlineView.hidden = NO;
        _imgscrlHeiConstraint.constant = 44;
        
        [_imgScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        NSArray *images = _issueDictionary[@"Images"];
        for (int i=0; i<images.count; i++) {
            NSDictionary *imageDict = images[i];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*49, 0, 44, 44)];
            [imageView setClipsToBounds:YES];
            [imageView sd_setImageWithURL:[NSURL URLWithString:GET_VALIDATED_STRING(imageDict[@"PreviewUrl"], @"")] placeholderImage:[UIImage imageNamed:@"img_nobuilding"]];
            [_imgScrollView addSubview:imageView];
            
            imageView.tag = i;
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImageView:)];
            [imageView setUserInteractionEnabled:YES];
            tapGes.numberOfTapsRequired = 1;
            [imageView addGestureRecognizer:tapGes];
        }
        
        _imgScrollView.contentSize = CGSizeMake(49*images.count, 44);
        
        if (self.issueDictionary[@"Images"] && [self.issueDictionary[@"Images"] count] > 9) {
            [self removeImgSendButton];
        }
    } else {
        _borderlineView.hidden = YES;
        _imgscrlHeiConstraint.constant = 0;
    }
}

- (void)onTapImageView:(UIGestureRecognizer *)recognizer {
    UIImageView *view = (UIImageView *)[recognizer view];
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.frame = CGRectMake(0, 0, 300, 300);
    
    NSInteger index = [view tag];
    
    if(_issueDictionary[@"Images"] && _issueDictionary[@"Images"] != [NSNull null]) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:vc.view.frame];
        
        NSArray *images = _issueDictionary[@"Images"];
        for (int i=0; i<images.count; i++) {
            NSDictionary *imageDict = images[i];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*300, 0, 300, 300)];
            [imageView setClipsToBounds:YES];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            
            UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] init];;
            [activity startAnimating];
            [imageView addSubview:activity];
            activity.center = CGPointMake(150, 150);
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:GET_VALIDATED_STRING(imageDict[@"Url"], @"")] placeholderImage:[UIImage imageNamed:@"img_nobuilding"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [activity stopAnimating];
                [activity removeFromSuperview];
            }];
//            [imageView sd_setImageWithURL:[NSURL URLWithString:GET_VALIDATED_STRING(imageDict[@"MediumPreviewUrl"], @"")] placeholderImage:[UIImage imageNamed:@"img_nobuilding"]];
            [scrollView addSubview:imageView];
            imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
            imageView.layer.borderWidth = 1.0f;
        }
        
        scrollView.contentSize = CGSizeMake(300*images.count, 300);
        scrollView.pagingEnabled = YES;
        scrollView.contentOffset = CGPointMake(300*index, 0);
        scrollView.showsHorizontalScrollIndicator = NO;
        
        [vc.view addSubview:scrollView];
    }
    
    [self presentPopUpViewController:vc];
}

#pragma mark - UIButton Action
- (IBAction)selectPictureClicked:(id)sender {
    [_messageTextField resignFirstResponder];
    [(IssueManagerGeneralVC *)_delegate closeTabScrollView];
    
    UIActionSheet *cameraPopup = [[UIActionSheet alloc] initWithTitle:LocalizedString(@"SelectCameraOption") delegate: self cancelButtonTitle:LocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"TakePhoto"), LocalizedString(@"ChoosePhoto"), nil];
    cameraPopup.tag = 1;
    [cameraPopup showInView:self.view];
}

- (IBAction)sendMessageClicked:(id)sender{
    // Start Connection...
    [SVProgressHUD show];
    
    BOOL isVisibleTenants = _msgTypeSegment.selectedSegmentIndex == 1;
    
    [[APIController sharedInstance] postIssueMessageWithIssueId:_issueDictionary[@"IssueId"] andMessageStr:_messageTextField.text isVisibleForTenants:isVisibleTenants successHandler:^(id jsonData) {
        
        [SVProgressHUD dismiss];
        
        [self getIssueDetail];
    } failureHandler:^(NSError *error) {
        NSLog(@"%@", [error description]);
        [SVProgressHUD dismiss];
    }];
    
    _messageTextField.text = @"";
    if (!_isImageSendDisabled) {
        _msgsendButton.hidden = YES;
        _imgsendButton.hidden = NO;
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex < 2)
        [self showImagePicker: (bool)buttonIndex];
}

- (void)showImagePicker: (BOOL)cameraoption{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    
    if(cameraoption){
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    else{
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
            return;
        }
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:picker animated: YES completion:NULL];
}

#pragma mark - UIImagePickerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // user hit cancel
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //assign the mediatype to a string
    UIImage *chosenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    UIImage *uploadImage = [Utilities imageToUploadFromImage:chosenImage];

    [[APIController sharedInstance] addIssueImageWithIssueId:_issueDictionary[@"IssueId"] imageData:UIImageJPEGRepresentation(uploadImage, 1.0) progressHandler:^(NSUInteger __unused bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        [SVProgressHUD showProgress:totalBytesWritten/totalBytesExpectedToWrite status:LocalizedString(@"Uploading")];
    } successHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        [self getIssueDetail];
    } failureHandler:^(NSError *error) {
        NSLog(@"%@", [error description]);
        [SVProgressHUD dismiss];
        [self getIssueDetail];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeKeyBoard {
    [_messageTextField resignFirstResponder];
    [(IssueManagerGeneralVC *)self.delegate closeTabScrollView];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ERecipientType type = [self.issueDictionary[@"RecipientType"] integerValue];
    BOOL isTenantIssue = type == ERecipientTypeTenant;
    if (indexPath.row == 1) {
                
        NSString *htmlStr = GET_VALIDATED_STRING(_issueDictionary[@"Description"], @"");
        NSString *issueDescription = [htmlStr stringByDecodingHTMLEntities] ;
        
        if ([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee) {
            IssueMsgDetailViewController *msgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IssueMsgDetailVC"];
            msgVC.providesPresentationContextTransitionStyle = YES;
            msgVC.definesPresentationContext = YES;
            msgVC.modalPresentationStyle = UIModalPresentationCustom;
            msgVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            msgVC.issueId = _issueDictionary[@"IssueId"];
            msgVC.issueDescription = issueDescription;
            msgVC.issueCreator = _issueDictionary[@"Creator"][@"Name"];
            msgVC.issueCreatorType = [_issueDictionary[@"Creator"][@"Type"] integerValue];
            msgVC.isTenantIssue = isTenantIssue;
            msgVC.issueCreatedDate = _issueDictionary[@"DateSubmitted"];
            
            [self presentViewController:msgVC animated:YES completion:nil];
            
            [self closeKeyBoard];
        } else if (bubbleHei > 140) {
            IssueMsgReadViewController *msgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IssueMsgReadVC"];
            msgVC.providesPresentationContextTransitionStyle = YES;
            msgVC.definesPresentationContext = YES;
            msgVC.modalPresentationStyle = UIModalPresentationCustom;
            msgVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            msgVC.issueMessage = issueDescription;
            [self presentViewController:msgVC animated:YES completion:nil];
            
            [self closeKeyBoard];
        }
        
        
    } else if (indexPath.row > 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([GlobalVars sharedInstance].currentUser.type == EUserTypeEmployee) {
            IssueMsgDetailViewController *msgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IssueMsgDetailVC"];
            msgVC.providesPresentationContextTransitionStyle = YES;
            msgVC.definesPresentationContext = YES;
            msgVC.modalPresentationStyle = UIModalPresentationCustom;
            msgVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            NSDictionary *dict = _messageArray[indexPath.row-2];

            msgVC.issueId = _issueDictionary[@"IssueId"];
            msgVC.issueMessageDict = dict;

            msgVC.isTenantIssue = isTenantIssue;
            [self presentViewController:msgVC animated:YES completion:nil];
            
            [self closeKeyBoard];
        } else
            if (cell.frame.size.height > 180) {
            IssueMsgReadViewController *msgVC = [self.storyboard instantiateViewControllerWithIdentifier:@"IssueMsgReadVC"];
            msgVC.providesPresentationContextTransitionStyle = YES;
            msgVC.definesPresentationContext = YES;
            msgVC.modalPresentationStyle = UIModalPresentationCustom;
            msgVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            NSDictionary *dict = _messageArray[indexPath.row-2];
            
            msgVC.issueMessage = dict[@"Text"];
            [self presentViewController:msgVC animated:YES completion:nil];
                
            [self closeKeyBoard];
            
            }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messageArray.count+2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        LocationCell *cell = (LocationCell *)[tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
        [cell proceedContents:_issueDictionary];
        
        return cell;
    } else if (indexPath.row == 1) {
        BubbleCell *cell = (BubbleCell *)[tableView dequeueReusableCellWithIdentifier:@"BubbleCell"];
        
        UILabel *descLabel = (UILabel *)[cell viewWithTag:10];
        UIView *messageBubbleView = (UIView *)[cell viewWithTag:12];
        
        messageBubbleView.layer.borderColor = LIGHT_GRAY_COLOR.CGColor;
        messageBubbleView.layer.borderWidth = 1;
        
        if(self.issueDictionary) {
            NSString *htmlStr = GET_VALIDATED_STRING(_issueDictionary[@"Description"], @"");
            NSString *issueDescription = [htmlStr stringByDecodingHTMLEntities];
            UIFont *systemFont = [UIFont fontWithName:@"OpenSans" size:12.0f];

            NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[issueDescription dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];

            [attrStr addAttributes:@{NSFontAttributeName: systemFont} range:NSMakeRange(0, attrStr.length)];
            
            descLabel.attributedText = attrStr;
        }
        return cell;
    } else {
    
        static NSString *cellIdentifier = @"MessageCell";
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        NSDictionary *dict = _messageArray[indexPath.row-2];
        
        [cell proceedContents:dict];
        
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 83;
    } else if (indexPath.row == 1) {
        return bubbleHei;
    }
    NSDictionary *dict = _messageArray[indexPath.row-2];
    CGSize textSize = [dict[@"Text"] sizeWithFont:[UIFont fontWithName:@"OpenSans" size:12] constrainedToSize:CGSizeMake(285, 20000) lineBreakMode: NSLineBreakByWordWrapping]; //Assuming your width is 240
    
    float heightToAdd;
    if ([Utilities isValidString:dict[@"StatusName"]]) {
        heightToAdd = 83;
    } else {
        heightToAdd = MIN(textSize.height, 140) + 7 + 23 + 15;
    }
    return heightToAdd;
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