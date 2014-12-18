//
//  BookmarkFilterViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-04-05.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "BookmarkViewController.h"

@class BookmarkViewController;

@interface BookmarkFilterViewController : UIViewController<UIScrollViewDelegate>
{
    IBOutlet UIScrollView *oppScrollView;    
    IBOutlet UIScrollView *dateScrollView;
    IBOutlet UIScrollView *eventScrollView;
    IBOutlet UILabel *numTagsLabel;
    Globals *globals;
    NSMutableArray *taggedButtonArr;
    NSMutableDictionary *taggedAttsDict;
    NSMutableArray *displayArray;    
    NSMutableArray *eventsArray;
    NSDictionary *superArgs;
    BookmarkViewController *bkViewController;
    IBOutlet UIButton*bookMarkFilterTitleButton;
    UIScrollView *allFilters;
}

@property (nonatomic, strong) BookmarkViewController* bookmarkViewController;


- (IBAction)finishedSwipe:(id)sender;
- (IBAction)finishedSwipeOutside:(id)sender;
@property (nonatomic, strong) NSMutableDictionary *allEvents;
@property (nonatomic) BOOL finishedSwipe;
- (IBAction)swipeFilter:(id)sender;
- (void)showHideFilterInfo:(BOOL)show;
-(void)viewWillAppear:(BOOL)animated;
- (id)initWithArgs:filterArgs;

@end
