//
//  ExAutoPagingCenteredCollectionViewFlowLayout.m
//  Rollette
//
//  Created by Emagid Corp on 4/28/14.
//  Copyright (c) 2014 Voated LLC. All rights reserved.
//

#import "ExAutoPagingCenteredCollectionViewFlowLayout.h"

@implementation ExAutoPagingCenteredCollectionViewFlowLayout

- (void)awakeFromNib
{
    self.itemSize = CGSizeMake(90, 39);
    self.minimumInteritemSpacing = 0.0;
    self.minimumLineSpacing = 0.0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end