//
//  FilterToolboxViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-02-11.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClipViewController.h" 
#import "FilterCell.h"
#import "Globals.h"
#import "UtilitiesController.h"
#import "CustomButton.h"

@class ClipViewController, BookmarkViewController;

@interface FilterToolboxViewController : UIViewController<UIScrollViewDelegate>
{
    Globals *globals;
    NSMutableArray *filterButtonsArr;
    ClipViewController *lbController;

      UILabel *numTagsLabel;
   //   UIImageView *horzDivider;
    NSMutableArray *typesOfTags;
    NSArray *thumbArray;
    NSMutableArray *selectedFilters;
   //   UIView *coloursContainer;
    NSMutableArray *displayArray;
    NSDictionary *superArgs;
    NSArray *tagsRefArray;
    NSMutableDictionary *taggedAttsDict;
     NSMutableDictionary *taggedAttsDictShift;
   //   UIScrollView *eventScrollView;
   //   UIView *linesContainer;
    NSMutableArray *lineButtonsArray;
    //  UIView *additionalAttsContainer;
    UtilitiesController *uController;
   //   UIView *coachPickContainer;
    NSMutableArray *allTagsArray;
      UIScrollView *_eventsView;
    UIScrollView *allFilters;
}

@property (nonatomic,strong) NSMutableDictionary *taggedAttsDict;
@property (nonatomic,strong) NSMutableArray *taggedButtonArr;
@property (nonatomic,strong) NSMutableDictionary *taggedAttsDictShift;
@property (nonatomic,strong) NSMutableDictionary *taggedButtonDictShift;
@property (nonatomic,strong) NSMutableArray *typesOfTags;
@property (nonatomic,strong) NSMutableArray *selectedFilters;
@property (nonatomic,strong) UICollectionView *collectionView;
///new UI
@property (strong, nonatomic)   UIImageView *vertDivider;
@property (strong, nonatomic)   UIImageView *horzDivider;
@property (strong, nonatomic)   UIImageView *shiftlineHorzDivider;
@property (strong, nonatomic)   UIScrollView *eventsView;
//@property (strong, nonatomic)   UIView *eventsView;
@property (strong, nonatomic)   UIScrollView *playerView;
//@property (strong, nonatomic)   UIView *playerView;
@property (strong, nonatomic)   UIView *linePeriodView;
@property (strong, nonatomic)   UIView *usersView;
@property (strong, nonatomic) NSMutableArray *shiftButtons;
@property (strong, nonatomic) NSMutableArray *eventsandPlayerButtons;
@property (strong, nonatomic) NSMutableArray *strengthCoachPickButtons;
//@property (strong, nonatomic) NSMutableArray *shiftLineButtons;
//@property (strong, nonatomic) NSMutableArray *strengthButtons;
@property (strong, nonatomic) NSMutableArray *coachPickButtons;
@property (strong, nonatomic)   UIButton *eventFilterTitleButton;
@property (strong, nonatomic)   UIButton *shiftFilterTitleButton;
@property (strong, nonatomic)   UIImageView *strengthDivider;
@property (nonatomic) BOOL viewdidAppeared;
@property (strong, nonatomic)   UILabel *periodHalfLabel;
@property (strong, nonatomic)   UILabel *offLineandZoneLabel;
@property (strong, nonatomic)   UILabel *defLineLabel;
@property (strong, nonatomic)   UIButton *filterTitleSoccer;
//@property (nonatomic) BOOL showTelestration;
- (void)shiftLineFilter:(id)sender;
//- (void)swipeOutFilter:(id)sender;
- (void)swipeFilter:(id)sender;
- (void)eventsFilter:(id)sender;
///new UI
- (void)viewDidAppear:(BOOL)animated;
//- (void)slideFilterBox:(id)sender;
//- (void)selectAllThumbs;
- (id)initWithArgs:(NSDictionary *)args;
@property (strong, nonatomic)   UILabel *periodorHalfLabel;
@property (strong, nonatomic)   UILabel *strengthLabel;
@property (strong, nonatomic) NSMutableArray *selectedButtonsforSoccer;
@property (strong, nonatomic)  CustomButton *coachPickButtonSoccer;
@property (strong, nonatomic)   UILabel *hockeyZoneLabel;



-(NSMutableArray*)sortClipsWithAttributes:(NSArray *)tagsArr;
-(NSMutableArray*)sortClipsBySelectingforShiftFiltering:(NSArray*)tagsArr;
-(void)createEventTags;
-(void)createSoccerPlayerTags;
-(void)createPlayerTags;
-(void)createColourTags;
-(void)updateDisplayedTagsCount;

@end
