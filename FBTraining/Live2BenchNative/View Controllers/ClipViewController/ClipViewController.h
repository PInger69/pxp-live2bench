//
//  ClipViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-29.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabViewController.h"
#import "thumbnailCell.h"
#import "Live2BenchViewController.h"
#import "CustomTabBar.h"
#import "CustomButton.h"
#import "ClipCornerView.h"
#import "PxpFilter.h"
#import "TabView.h"


@interface ClipViewController : CustomTabViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIAlertViewDelegate, PxpFilterDelegate>
{
    UILabel             * filterBreadCrumbs;
    BOOL                isEditingClips;
    NSMutableArray      * downloadedTagIds;     // array of downloaded Tags'id
}

@property (nonatomic,strong) NSMutableArray *tagsToDisplay; // THIS IS WHAT YOU ADD TO THE SHOW UP ON SCREEN
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,weak)  PxpFilter           * pxpFilter;

@end
