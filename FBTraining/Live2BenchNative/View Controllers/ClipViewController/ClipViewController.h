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



@class Live2BenchViewController;
@class CustomTabBar;
@class thumbnailCell;

@interface ClipViewController : CustomTabViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIAlertViewDelegate, PxpFilterDelegate>
{
    NSMutableArray      * _tagsToDisplay;       // array of tags which will display in clip view
    UILabel             * filterBreadCrumbs;
    BOOL                isEditingClips;
    NSMutableArray      * arrayToBeDeleted;     // is this even being used
    NSMutableArray      * downloadedTagIds;     // array of downloaded Tags'id
}

@property (nonatomic,strong) NSMutableArray *tagsToDisplay; // THIS IS WHAT YOU ADD TO THE SHOW UP ON SCREEN
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,weak)  PxpFilter           * pxpFilter;

@end
