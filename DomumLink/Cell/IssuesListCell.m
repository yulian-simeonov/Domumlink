//
//  IssuesListCell.m
//  DomumLink
//
//  Created by Yulian Simeonov on 1/30/15.
//  Copyright (c) 2015 YulianMobile All rights reserved.
//

#import "IssuesListCell.h"
#import "NSString+HTML.h"
#import "UIViewController+ENPopUp.h"
#import "IssuesVC.h"

@implementation IssuesListCell

@synthesize buildingImageView, buildingThumbnailsView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)proceedContent:(NSDictionary *)issueDict section:(NSInteger)section viewMode:(NSInteger)viewMode {
    
    NSDateFormatter* dateFormatter = [GlobalVars sharedInstance].dateFormatterTime;
    if ([GlobalVars sharedInstance].langCode == ELangEnglish)
        [dateFormatter setDateFormat:@"MMM dd h:mm a"];
    else
        [dateFormatter setDateFormat:@"dd MMM H:mm"];

    self.statusLabel.clipsToBounds = YES;
    
    
        
    NSString *categoryName = issueDict[@"CategoryName"];
    NSDecimalNumber *categoryLevelId = issueDict[@"CategoryLevelId"];
    NSDecimalNumber *submittedDate = issueDict[@"DateSubmitted"];
    
    categoryName = categoryName == (id)[NSNull null] || categoryName.length == 0 ? @"" : categoryName;
    categoryLevelId = categoryLevelId == (id)[NSNull null] ? [[NSDecimalNumber alloc] initWithBool: NO] : categoryLevelId;
    submittedDate = submittedDate == (id)[NSNull null] ? [[NSDecimalNumber alloc] initWithBool: 0] : submittedDate;
    
    self.titleLabel.text = categoryName;
    
    if ([GlobalVars sharedInstance].currentUser.type != EUserTypeTenant) {
        self.createdForLabel.hidden = NO;
        
        if(issueDict[@"RecipientType"]){
            NSInteger type = [issueDict[@"RecipientType"] integerValue];
            if (type == 0) {
                self.createdForLabel.text = LocalizedString(@"Internal");
                self.createdForLabel.backgroundColor = ORANGE_COLOR;
                
                self.tenantsLabel.hidden = YES;
            } else if (type == 1) {
                self.tenantsLabel.hidden = NO;
                self.createdForLabel.text = LocalizedString(@"Tenant");
                self.createdForLabel.backgroundColor = NAV_BAR_COLOR;
            } else if (type == 2) {
                self.tenantsLabel.hidden = NO;                
                self.createdForLabel.text = LocalizedString(@"Support");
                self.createdForLabel.backgroundColor = [UIColor colorWithRed:209/255.0f green:240/255.0f blue:209/255.0f alpha:1.0f];
            }
        }
        _counterHeiConstraint.constant = 26;
        _counterView.hidden = NO;
    } else {
        self.createdForLabel.hidden = YES;
        _counterHeiConstraint.constant = 0;
        _counterView.hidden = YES;
    }
    
//    if(![categoryLevelId boolValue]){
//        self.priorityImageView.image = [UIImage imageNamed:@"issues_priority_normal"];
//    }
//    else{
//        self.priorityImageView.image = [UIImage imageNamed:@"issues_priority_strong"];
//    }
    
    if([issueDict[@"IsUnread"] boolValue]){
        self.priorityImageView.hidden = NO;
        self.priorityImageView.image = [UIImage imageNamed:@"ico_newissue"];
    }
    else if([issueDict[@"IsUpdated"] boolValue]){
        self.priorityImageView.hidden = NO;
        self.priorityImageView.image = [UIImage imageNamed:@"ico_updatedissue"];
    } else {
        self.priorityImageView.hidden = YES;
    }
    
    if([issueDict[@"Creator"][@"IsGeneratedBySystem"] boolValue]){
        self.generatedByLabel.hidden = NO;
        self.generatedByLabel.text = LocalizedString(@"SystemGenerated");
    }
    else{
//        self.generatedByLabel.text = @"User Generated";
        self.generatedByLabel.hidden = YES;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: [submittedDate doubleValue]];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSInteger daysAgo = [currentDate timeIntervalSinceDate:date];
    self.createdOnLabel.text = LocalizedDateString([dateFormatter stringFromDate: date]);
    self.daysAgoLabel.text = [NSString stringWithFormat:@"%i%@", (int)(daysAgo/86400), LocalizedString(@"D")];
    
    // Update status color according sub status
    NSInteger statusCode = [issueDict[@"Status"] integerValue];
    NSInteger subStatusCode = [issueDict[@"SubStatus"] integerValue];
    
    UIColor *statusColor = [[GlobalVars sharedInstance] getStatusColorWithStatus:statusCode SubStatusCode:subStatusCode];
    
    NSString *statusString = [GET_VALIDATED_STRING(issueDict[@"StatusName"], @"") uppercaseString];
    NSString *subStatusString = GET_VALIDATED_STRING(issueDict[@"SubStatusName"], @"");
//    if ()
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   %@ %@", statusString, subStatusString]];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:statusColor range:[attributedString.string rangeOfString:statusString]];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONTNAME_BOLD size:self.statusLabel.font.pointSize] range:[attributedString.string rangeOfString:statusString]];
    self.statusLabel.attributedText = attributedString;
    
    self.statusBarView.backgroundColor = statusColor;

    // Status for viewmode:1
    CALayer *leftBorder = [CALayer layer];
    leftBorder.borderColor = statusColor.CGColor;
    leftBorder.borderWidth = 3;
    leftBorder.frame = CGRectMake(0, -3, CGRectGetWidth(self.statusLabel.frame)+3, CGRectGetHeight(self.statusLabel.frame)+6);
    
    [self.statusLabel.layer addSublayer:leftBorder];

    
    // Format all text fields
    self.nolocationView.hidden = NO;
    self.nolocationLabel.hidden = YES;
    self.buildingImageView.hidden = YES;
    self.nameLocationLabel.text = LocalizedString(@"NOLOCATIONSPECIFIED");
    self.addressBigLabel.text = @"";
    self.addressLabel.text = @"";
    self.buildingImageView.image = [UIImage imageNamed:@"img_nobuilding"];
    self.detailLabel.text = @"";
    self.dueDateLabel.text = @"";
    self.floorNameLabel.text = @"";
    _nolocspecifiedLabel.text = LocalizedString(@"NOLOCATIONSPECIFIED");
    
    if([Utilities isValidString:issueDict[@"LocationInfo"][@"BuildingId"]]) {
        self.nolocationLabel.hidden = YES;
        self.nolocationView.hidden = YES;
        self.buildingImageView.hidden = NO;
        
        NSString *buildingNameStr = GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"BuildingName"], @"");
        NSString *buildingAddrStr = [NSString stringWithFormat:@"%@, %@", GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"AddressLine1"], @""), GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"City"], @"")];
        
        if(viewMode == 0)
        {
            self.nameLocationLabel.text = [NSString stringWithFormat:@"%@, %@", buildingNameStr, buildingAddrStr];
        }
        else{
            self.addressBigLabel.text = buildingNameStr;
            self.addressLabel.text = buildingAddrStr;
            
            if (issueDict[@"LocationInfo"][@"BuildingImageUrl"] && ![issueDict[@"LocationInfo"][@"BuildingImageUrl"] isKindOfClass:[NSNull class]]) {
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    [self.buildingImageView sd_setImageWithURL:[NSURL URLWithString:GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"BuildingImageUrl"], @"")] placeholderImage:[UIImage imageNamed:@"img_nobuilding"]];
                }];
            }
        }
    }
    
    // Scrollview for showing building images
    if (viewMode == 1) { // Two lines view
        if ([Utilities isValidString:issueDict[@"Description"]]) {
            NSString *htmlStr = [GET_VALIDATED_STRING(issueDict[@"Description"], @"") stringByReplacingOccurrencesOfString:@"<br/>" withString:@"linebreak"];
            NSString *issueDescription = [[htmlStr stringByDecodingHTMLEntities] stringByConvertingHTMLToPlainText];
            
            NSArray *descStrArray = [issueDescription componentsSeparatedByString:@"linebreak"];
            if(descStrArray.count)
                self.detailLabel.text = descStrArray[0];
            if(descStrArray.count > 1) {
                self.dueDateLabel.text = descStrArray[1];
            }
        }
        
        if ([Utilities isValidString:issueDict[@"LocationInfo"][@"ApartmentName"]]) {
            _floorNameLabel.text = [NSString stringWithFormat:@"%@. %@",LocalizedString(@"Apt"), GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"ApartmentName"], @"")];
        }
        
        if ([Utilities isValidString:issueDict[@"LocationInfo"][@"FloorName"]]) {
            _floorNameLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", _floorNameLabel.text, LocalizedString(@"Floor"), GET_VALIDATED_STRING(issueDict[@"LocationInfo"][@"FloorName"], @"")];
        }
        
        
        
        if(issueDict[@"Images"] && issueDict[@"Images"] != [NSNull null]) {
            self.buildingThumbnailsView.hidden = NO;
            
            [self.buildingThumbnailsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            
            NSArray *images = issueDict[@"Images"];
            for (int i=0; i<images.count; i++) {
                NSDictionary *imageDict = images[i];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i*30, 0, 25, 25)];
                [imageView setClipsToBounds:YES];
                [imageView sd_setImageWithURL:[NSURL URLWithString:GET_VALIDATED_STRING(imageDict[@"PreviewUrl"], @"")] placeholderImage:[UIImage imageNamed:@"img_nobuilding"]];
                [self.buildingThumbnailsView addSubview:imageView];
                imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
                imageView.layer.borderWidth = 1.0f;
                imageView.tag = section*99999 + i;
                
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapImageView:)];
                [imageView setUserInteractionEnabled:YES];
                tapGes.numberOfTapsRequired = 1;
                [imageView addGestureRecognizer:tapGes];
            }
            
            self.buildingThumbnailsView.contentSize = CGSizeMake(30*images.count, 25);
        } else {
            self.buildingThumbnailsView.hidden = YES;
        }
    }
    
    NSArray *employeeArray;
    if(issueDict[@"RecipientType"]){
        NSInteger type = [issueDict[@"RecipientType"] integerValue];
        if (type == 0) { // For the internal issue, employee is counted with Recipients count.
            if(issueDict[@"Recipients"] && issueDict[@"Recipients"] != [NSNull null]){
                employeeArray = issueDict[@"Recipients"];
            }
            else{
                employeeArray = @[];
            }
        } else {
            if(issueDict[@"Assignees"] && issueDict[@"Assignees"] != [NSNull null]){
                employeeArray = issueDict[@"Assignees"];
            }
            else{
                employeeArray = @[];
            }
        }
    }
    self.employeesLabel.text = [NSString stringWithFormat:@"%@ (%li)", LocalizedString(@"Employees"), (unsigned long)employeeArray.count];
    
    
    if(issueDict[@"Recipients"] && issueDict[@"Recipients"] != [NSNull null]){
        NSArray *tenantArray = issueDict[@"Recipients"];
        self.tenantsLabel.text = [NSString stringWithFormat:@"%@ (%li)", LocalizedString(@"Tenants"), (unsigned long)tenantArray.count];
    }
    else{
        self.tenantsLabel.text =[NSString stringWithFormat:@"%@ (0)", LocalizedString(@"Tenants")];
    }
    
    self.messagesLabel.text = GET_VALIDATED_STRING(issueDict[@"LastMessage"], LocalizedString(@"NoMessagesToDisplay"));
    self.serialNoLabel.text = [NSString stringWithFormat:@"%@ #: %@", LocalizedString(@"Issue"), [GET_VALIDATED_STRING(issueDict[@"GeneratedId"], @"") stringByReplacingOccurrencesOfString:@"-" withString:@" "]];
}

- (void)onTapImageView:(UIGestureRecognizer *)recognizer {
    UIImageView *view = (UIImageView *)[recognizer view];
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.frame = CGRectMake(0, 0, 300, 300);
    
    NSInteger tag = [view tag];
    NSInteger section = tag/99999;
    NSInteger index = tag%99999;
    
    NSDictionary *dict = [(IssuesVC *)self.delegate issueArray][section];
    
    if(dict[@"Images"] && dict[@"Images"] != [NSNull null]) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:vc.view.frame];
        
        NSArray *images = dict[@"Images"];
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
    
    [self.delegate presentPopUpViewController:vc];
}

@end
