//
//  SelectImageVC.m
//  DomumLink
//
//  Created by Yulian Simeonov on 4/17/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "SelectImageVC.h"

#import "CreateIssue1VC.h"
#import "UIImage+Util.h"

@interface SelectImageVC (){
    IBOutlet UIButton *takePhotoButton;
    
    IBOutlet UIButton *cameraRollButton;
}
@property (weak, nonatomic) IBOutlet UILabel *takephotoLabel;
@property (weak, nonatomic) IBOutlet UILabel *camerarollLabel;

@end

@implementation SelectImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _takephotoLabel.text = LocalizedString(@"TakePhoto");
    _camerarollLabel.text = LocalizedString(@"CameraRoll");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onClickSetPicture:(UIButton *)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    
    if(sender == takePhotoButton)
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated: YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // user hit cancel
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *uploadImage = [Utilities imageToUploadFromImage:chosenImage];
    
    [[APIController sharedInstance] uploadTempImageWithImageData:UIImageJPEGRepresentation(uploadImage, 1.0) progressHandler:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        [SVProgressHUD showProgress:totalBytesWritten/totalBytesExpectedToWrite status:LocalizedString(@"Uploading")];
    } successHandler:^(id jsonData) {
        [SVProgressHUD dismiss];
        if (jsonData[@"Images"] && [jsonData[@"Images"] count] > 0)
            [self.delegate handleUploadedImage:jsonData[@"Images"][0]];
        else
            [Utilities showMsg:@"Uploading Failed!"];
    } failureHandler:^(NSError *err) {
        NSLog(@"%@", [err description]);
        [SVProgressHUD dismiss];
        [Utilities showMsg:@"Uploading Failed!"];
    }];
    
    //    [mainScrollView setContentOffset:CGPointMake(0, 20)];
}

- (NSMutableData *)generatePostDataForData:(NSData *)imageData
{
    // Generate the post header:
    NSString *post = @"--AaB03x\r\n";
    NSMutableData *postData;
    
    post = [post stringByAppendingString:[NSString stringWithCString:"Content-Disposition: form-data; name=\"imageFile[file]\"; filename=\"imageFile\"\r\nContent-Type: application/octet-stream\r\nContent-Transfer-Encoding: binary\r\n\r\n" encoding:NSASCIIStringEncoding]];
    
    // Get the post header int ASCII format:
    NSData *postHeaderData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Generate the mutable data variable:
    postData = [[NSMutableData alloc] initWithLength:[postHeaderData length] ];
    [postData setData:postHeaderData];
    
    // Add the image:
    [postData appendData: imageData];
    
    // Add the closing boundry:
    [postData appendData: [@"\r\n--AaB03x--" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    
    // Return the post data:
    return postData;
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
