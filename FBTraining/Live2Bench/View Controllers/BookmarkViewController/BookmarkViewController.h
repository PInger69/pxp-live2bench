//
//  BookmarkViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabViewController.h"
#import "BookmarkFilterViewController.h"
#import "DeletableTableViewController.h"
#import "PxpMyClipViewFullscreenViewController.h"
#import "PxpFilter.h"
#import "PxpFilterDelegate.h"
#import "TabView.h"


@interface BookmarkViewController : CustomTabViewController<PxpFilterDelegate ,DeletableTableViewControllerDelegate>
{

}
@property (strong,nonatomic) UILabel * progress;
@property (nonatomic, strong)   NSMutableArray               * allClips;
@property (nonatomic,strong)    PxpFilter                    * pxpFilter;
@property (nonatomic,strong)    TabView                      * pxpFilterTab;

@end
