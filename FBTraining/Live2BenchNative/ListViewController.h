//
//  ListViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-02-13.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabViewController.h"
#import "ListViewCell.h"
#import "ListTableViewController.h"
#import "PxpVideoPlayerProtocol.h"
#import "Tag.h"

#import "TabView.h"

#import "PxpFilter.h"
#import "PxpFilterDelegate.h"

@class TeleViewController;

@interface ListViewController : CustomTabViewController<UITextViewDelegate,UIGestureRecognizerDelegate,PxpFilterDelegate>{

    Tag                         *selectedTag;                        //the tag currently selected playing
    ListTableViewController     *_tableViewController;

}


@property (nonatomic,strong) NSMutableArray              * tagsToDisplay; //array of tags which used for create table view's cells
@property (nonatomic,strong) NSMutableArray              * allTags;
@property (nonatomic,strong) UIViewController <PxpVideoPlayerProtocol>    * videoPlayer;
@property (nonatomic,strong) NSDictionary                * feeds;
@property (nonatomic,strong) NSMutableDictionary         * selectedCellRows; //dictionary of all the information of the cells which have been viewed

@property (nonatomic,strong) PxpFilter                  * pxpFilter;






@end
