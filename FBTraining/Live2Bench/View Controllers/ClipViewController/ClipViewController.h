//
//  ClipViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-29.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagListViewController.h"
#import "thumbnailCell.h"
#import "CustomTabBar.h"
#import "CustomButton.h"
#import "ClipCornerView.h"
#import "PxpFilter.h"
#import "TabView.h"


@interface ClipViewController : TagListViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UIAlertViewDelegate, PxpFilterDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;

@end
