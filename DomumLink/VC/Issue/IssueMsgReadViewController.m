//
//  IssueMsgReadViewController.m
//  DomumLink
//
//  Created by iOS Dev on 7/8/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "IssueMsgReadViewController.h"

@interface IssueMsgReadViewController ()
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;

@end

@implementation IssueMsgReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIFont *systemFont = [UIFont fontWithName:@"OpenSans" size:12.0f];

    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[_issueMessage dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [attrStr addAttributes:@{NSFontAttributeName: systemFont} range:NSMakeRange(0, attrStr.length)];
    _msgTextView.attributedText = attrStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
