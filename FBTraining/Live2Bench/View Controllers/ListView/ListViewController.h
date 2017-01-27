//
//  ListViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-02-13.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagListViewController.h"
#import "ListViewCell.h"
#import "ListTableViewController.h"
#import "PxpVideoPlayerProtocol.h"
#import "Tag.h"

#import "TabView.h"

#import "PxpFilter.h"
#import "PxpFilterDelegate.h"

@interface ListViewController : TagListViewController<UITextViewDelegate,UIGestureRecognizerDelegate>


@property (nonatomic,strong) UIViewController <PxpVideoPlayerProtocol>    * videoPlayer;
@property (nonatomic,strong) NSDictionary                * feeds;
@property (nonatomic,strong) NSMutableDictionary         * selectedCellRows; //dictionary of all the information of the cells which have been viewed


// this method will be called in the ListTableViewController
-(void)onTagHasBeenHighlighted:(Tag*)tag;



@end
