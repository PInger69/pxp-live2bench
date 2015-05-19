
//
//  ListViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-02-13.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "ListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ExportPlayersPopoverController.h"
#import "ExportPlayersPopoverController.h"
#import "AbstractFilterViewController.h"
#import "FBTFilterViewController.h"
#import "BreadCrumbsViewController.h"
#import "CommentingRatingField.h"
#import "HeaderBarForListView.h"
#import "VideoBarListViewController.h"
#import "FeedSwitchView.h"
#import "Feed.h"
#import "RJLVideoPlayer.h"
#import "L2BVideoBarViewController.h"

#import "FullScreenViewController.h"
#import "Tag.h"



#define SMALL_MEDIA_PLAYER_HEIGHT   340
#define TOTAL_WIDTH                1024
#define NOTCOACHPICK                  0
#define RATINGBUTTON_NOT_SELECT       0
#define IS_FULLSCREEN                 1 // dead?
#define LITTLE_ICON_DIMENSIONS       30
#define COMMENTBOX_HEIGHT           210
#define COMMENTBOX_WIDTH            530//520

@interface ListViewController ()

@property (strong, nonatomic) L2BVideoBarViewController *videoBarViewController;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) FullScreenViewController *fullScreenViewController;
@property (strong, nonatomic) UIButton *filterButton;
@property (strong, nonatomic) UIButton *dismissFilterButton;

//@property (strong, nonatomic) NSDictionary *eventTags;

@end

@implementation ListViewController{
    
    UIImageView *teleView; //telestration for listview
    UIImageView *playbackRateBackGuide;
    UIImageView *playbackRateForwardGuide;
    UILabel *playbackRateBackLabel;
    UILabel *playbackRateForwardLabel;
    BOOL isModifyingPlaybackRate;
    BOOL isFrameByFrame;
    float playbackRateRadius;
    float frameByFrameInterval;
    
    TestFilterViewController        * componentFilter;
    BreadCrumbsViewController       * breadCrumbVC;
    HeaderBarForListView            * headerBar;
    CommentingRatingField           * commentingField;
    VideoBarListViewController      * newVideoControlBar;
}
@synthesize breadCrumbsView;
@synthesize selectedCellRows;
NSMutableArray *oldEventNames;


//static const NSInteger kDeleteAlertTag = 242;
//static const NSInteger kCannotDeleteAlertTag = 243;

-(instancetype)initWithAppDelegate:(AppDelegate *)appDel{
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"List View", nil) imageName:@"listTab"];
        //        globals = [Globals instance];
        
        oldEventNames = [[NSMutableArray alloc] init];
        //[self initializeOldEventNames];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializeOldEventNames) name:@"oldEventsUpdated" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sendBookmarkRequest) name:@"sendOldBookmarkRequest" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(feedSelected:) name:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTag:) name:@"NOTIF_DELETE_TAG" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTag:) name:@"NOTIF_DELETE_SYNCED_TAG" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(listViewTagReceived:) name:NOTIF_TAG_RECEIVED object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveEventStopped:) name:NOTIF_LIVE_EVENT_STOPPED object:nil];
        
        
        //        self.allTags = [[NSMutableArray alloc]init];
        //        self.tagsToDisplay = [[NSMutableArray alloc]init];
        _tableViewController = [[ListTableViewController alloc]init];
        _tableViewController.contextString = @"TAG";
        [self addChildViewController:_tableViewController];
        //_tableViewController.listViewControllerView = self.view;
        //_tableViewController.tableData = self.tagsToDisplay;
        
        /*
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_TAGS_ARE_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSLog(@"READY!");
            self.tagsToDisplay =[ NSMutableArray arrayWithArray:[appDel.encoderManager.eventTags allValues]];
            _tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
            [_tableViewController.tableView reloadData];
            
        }];
         */
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_LIST_VIEW_TAG object:nil queue:nil usingBlock:^(NSNotification *note) {
            selectedTag = note.object;
        
            [commentingField clear];
            commentingField.enabled             = YES;
            commentingField.text                = selectedTag.comment;
            commentingField.ratingScale.rating  = selectedTag.rating;
            [newVideoControlBar setTagName: selectedTag.name];
        }];

        
    }
    return self;
    
}

- (void)deleteTag: (NSNotification *)note {
    [self.tagsToDisplay removeObject: note.object];
    _tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
    [_tableViewController reloadData];
}

- (void)listViewTagReceived:(NSNotification*)note {
    
    if (note.object) {
        [self.tagsToDisplay addObject: note.object];
        _tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
        [_tableViewController reloadData];
    }
    
}

- (void)sortFromHeaderBar:(id)sender
{
    _tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
    [_tableViewController reloadData];
}

-(NSMutableArray*)sortArrayFromHeaderBar:(NSMutableArray*)toSort headerBarState:(HBSortType) sortType
{
    
    NSSortDescriptor *sorter;
    //Fields are from HeaderBar.h
    if(sortType & TIME_FIELD){
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"displayTime"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(compare:)];
        
    } else if (sortType & DATE_FIELD) {
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"event"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(caseInsensitiveCompare:)];
        
    }  else if (sortType & NAME_FIELD) {
        sorter = [NSSortDescriptor
                  sortDescriptorWithKey:@"name"
                  ascending:(sortType & ASCEND)?YES:NO
                  selector:@selector(caseInsensitiveCompare:)];
    } else {
        return toSort;
    }
    
    return [NSMutableArray arrayWithArray:[toSort sortedArrayUsingDescriptors:@[sorter]]];
}

//this method will be triggered if user pinches the video view. Based on the pinch velocity, will enter full screen or back to normal screen
- (void)handlePinchGuesture:(UIGestureRecognizer *)recognizer{
    
    if((self.pinchGesture.velocity > 0.5 || self.pinchGesture.velocity < -0.5) && self.pinchGesture.numberOfTouches == 2){
        if (CGRectContainsPoint(self.view.bounds, [self.pinchGesture locationInView:self.view]))
        {
            
            
            if (self.pinchGesture.scale >1) {
                self.fullScreenViewController.enable = YES;
                //                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_FULLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }else if (self.pinchGesture.scale < 1){
                self.fullScreenViewController.enable = NO;
                //                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }
        }
    }
    
}


/*- (void)initializeOldEventNames
 {
 if (!oldEventNames){
 oldEventNames = [[NSMutableArray alloc] init];
 }
 //    NSArray *events = [[NSArray alloc] initWithContentsOfFile:[globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"EventsHid.plist"]];
 //    for (NSDictionary* event in events){
 //        [oldEventNames addObject:[event objectForKey:@"name"]];
 //    }
 }*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewTags:) name:@"updateListView" object:nil];
    //video url changed
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeCurrentTimeObserver) name:@"setvideourl" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrubbingDestroyLoopMode) name:NOTIF_DESTROY_TELE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrubbingDestroyLoopMode) name:@"scrubbingDestroyLoopMode" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popoverDidFinishSelection) name:@"ExportPlayersPopoverControllerDidFinishSelection" object:nil];
    
    [self setupView];

     _tableViewController.tableView.delaysContentTouches = NO;
     fullScreenMode = FALSE;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFullScreen) name:@"Entering FullScreen" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFullScreen) name:@"Exiting FullScreen" object:nil];
    [self initialVideoControlBar];
    
    // Richard
    breadCrumbVC = [[BreadCrumbsViewController alloc]initWithPoint:CGPointMake(25, 64)];
    [self.view addSubview:breadCrumbVC.view];
    
    
    headerBar = [[HeaderBarForListView alloc]initWithFrame:CGRectMake(540,55,TOTAL_WIDTH, LABEL_HEIGHT) defaultSort:TIME_FIELD | DESCEND];
    [headerBar onTapPerformSelector:@selector(sortFromHeaderBar:) addTarget:self];
    [self.view addSubview:headerBar];


    
    
#pragma mark- VIDEO PLAYER INITIALIZATION HERE
    
    self.videoPlayer = [[RJLVideoPlayer alloc]initWithFrame:CGRectMake(0, 52, COMMENTBOX_WIDTH +10 , SMALL_MEDIA_PLAYER_HEIGHT )];
    //[self.videoPlayer initializeVideoPlayerWithFrame:CGRectMake(2, 114, COMMENTBOX_WIDTH, SMALL_MEDIA_PLAYER_HEIGHT)];
    self.videoPlayer.playerContext = STRING_LISTVIEW_CONTEXT;
    //[self.videoPlayer playFeed:_feedSwitch.primaryFeed];
    
    
    self.videoBarViewController = [[L2BVideoBarViewController alloc]initWithVideoPlayer:self.videoPlayer];
    //[_videoBarViewController.startRangeModifierButton   addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    //[_videoBarViewController.endRangeModifierButton     addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_LIVE];
    [self.videoBarViewController viewDidAppear: YES];
    //[self.videoBarViewController createTagMarkers];
    
    [self.view addSubview:self.videoPlayer.view];
    [self.view addSubview:self.videoBarViewController.view];
    
    self.fullScreenViewController = [[FullScreenViewController alloc]initWithVideoPlayer:self.videoPlayer];
    self.fullScreenViewController.context = @"ListView Tab";
    //[self.fullScreenViewController setMode: L2B_FULLSCREEN_MODE_DEMO];
    [self.view addSubview: self.fullScreenViewController.view];
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGuesture:)];
    [self.view addGestureRecognizer: self.pinchGesture];
    
    //    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(detectSwipe:)];
    //    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    //    [self.videoPlayer.view addGestureRecognizer:swipeGestureRecognizer];
    //
    //    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(detectSwipe:)];
    //    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    //    [self.videoPlayer.view addGestureRecognizer:swipeGestureRecognizer];
    
    
    
}

//-(void)viewDidAppear:(BOOL)animated{
//    [self.videoBarViewController.tagMarkerController cleanTagMarkers];
//    [self.videoBarViewController.tagMarkerController createTagMarkers];
//}

//-(void)clipViewTagReceived:(NSNotification*)note
//{
//    if (note.object) {
//        [self.tagsToDisplay addObject: note.object];
//        [_tableViewController.tableData addObject:note.object];
//        [_tableViewController reloadData];
//        //[_collectionView reloadData];
//    }
//}

-(void)viewWillAppear:(BOOL)animated{
    
    //    [super viewWillAppear:animated];
    //
    //    [globals.VIDEO_PLAYER_LIVE2BENCH pause];
    //
    //    //will enter list view, start playing video
    //    if (globals.CURRENT_PLAYBACK_EVENT && ![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
    //
    //        [videoPlayer play];
    //
    //        if (!videoPlayer.timeObserver) {
    //            //NSLog(@"readd time observer");
    //            [videoPlayer addPlayerItemTimeObserver];
    //        }
    //
    //    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LIST_VIEW_CONTROLLER_FEED object:nil userInfo:@{@"block" : ^(NSDictionary *feeds, NSArray *eventTags){
        if(feeds && !self.feeds){
            self.feeds = feeds;
            Feed *theFeed = [[feeds allValues] firstObject];
            [self.videoPlayer playFeed:theFeed];
        }
        
        if (!self.tagsToDisplay) {
            self.tagsToDisplay = [NSMutableArray arrayWithArray:[eventTags copy]];
            _tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
            [_tableViewController reloadData];
        }
        
    }}];
    
    
    wasPlayingIndexPath = nil;
    
    for(int i=0;i<4;i++)
    {
        NSMutableArray *sectionArray = [[NSMutableArray alloc]init];
        [typesOfTags addObject:sectionArray];
    }
     
    cellCounter     = 0;
    fullScreenMode  = FALSE;
    _tableViewController.isEditable = FALSE;
    
    [tagEventName setHidden:TRUE];
    //NSLog(@"testing");
    //[self makeLocalBookmark];
    
    // Richard
    [commentingField clear];
    commentingField.ratingScale.rating = 0;
    commentingField.enabled = NO;
    if(![self.view.subviews containsObject:componentFilter.view])
    {
        [self.view addSubview:componentFilter.view];
    }
    //[componentFilter refresh]; // refresh list when View
    
    // End Richard
    
    //    if (!newVideoControlBar) newVideoControlBar = [[VideoBarListViewController alloc]initWithVideoPlayer:videoPlayer];
    //    [self.view addSubview:newVideoControlBar.view];
    //
    //    [newVideoControlBar viewDidAppear:NO];
    
    
    //    [newVideoControlBar.view setFrame:CGRectMake(500, 200, 100, 100)];
    
    
}


/*
 
 - (void)fetchedData
 {
 //   ////NSLog(@"globals.CURRENT_EVENT_THUMBNAILS count in list view %d",globals.CURRENT_EVENT_THUMBNAILS.count);
 //    NSMutableArray *tempAllTags = [[globals.CURRENT_EVENT_THUMBNAILS allValues]mutableCopy];
 //    allTags = [tempAllTags mutableCopy];
 //    //"type" value: #default = 0; #stop line/zone = 2;#telestration = 4;#player end shift = 6;#period/half end = 8/18; #strength end  = 10
 //    for(NSDictionary *tag in tempAllTags){
 //
 //        if([[tag objectForKey:@"type"] intValue]==8 || [[tag objectForKey:@"type"] intValue]==18 || [[tag objectForKey:@"type"] intValue]==20 || [[tag objectForKey:@"type"] intValue]==22 || ([[tag objectForKey:@"type"] intValue]&1) ){
 //            [allTags removeObject:tag];
 //        }
 //    }
 //
 //    NSMutableArray *openEndStrings = [[NSMutableArray alloc] init]; //will use this array for open and end types of different sports -- soccer will be 17,18 hockey will be 7,8
 //    if([globals.WHICH_SPORT isEqualToString:@"hockey"])
 //    {
 //        [openEndStrings addObject:@"7"];
 //        [openEndStrings addObject:@"8"];
 //    }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
 //    {
 //        [openEndStrings addObject:@"17"];
 //        [openEndStrings addObject:@"18"];
 //    }else{
 //        //for testing
 //        [openEndStrings addObject:@"100"];
 //        [openEndStrings addObject:@"101"];
 //    }
 //
 //    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
 //    for(NSDictionary *tag in allTags){
 //
 //        if(![globals.ARRAY_OF_COLOURS containsObject:[tag objectForKey:@"colour"]]&&[tag objectForKey:@"colour"]!=nil)
 //        {
 //            [globals.ARRAY_OF_COLOURS  addObject:[tag objectForKey:@"colour"]];
 //        }
 //    //type == 2, line tag;type == 0 normal tag;type ==100, duration tag; if the tag was deleted, type value will be 3 and "deleted" value will be 1
 //        if(([[tag objectForKey:@"type"] intValue]==0 || [[tag objectForKey:@"type"] intValue]==4 || [[tag objectForKey:@"type"] intValue]==100) && [[tag objectForKey:@"type"]integerValue]!=3&& [tag  objectForKey:@"name"]!=nil)
 //        {
 //            [tempArray addObject:tag];
 //
 //            if(![[typesOfTags objectAtIndex:0] containsObject:[tag  objectForKey:@"name"]] && [tag  objectForKey:@"name"]!=nil && [[tag objectForKey:@"name"] rangeOfString:@"Pl. "].location == NSNotFound)
 //            {
 //                [[typesOfTags objectAtIndex:0] addObject:[tag  objectForKey:@"name"]];
 //            }
 //
 //            if ([[tag  objectForKey:@"player"]count]>0 && ![[[tag  objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""] ) {
 //                NSMutableSet* set1 = [NSMutableSet setWithArray:[typesOfTags objectAtIndex:3]];
 //                NSMutableSet* set2 = [NSMutableSet setWithArray:[tag  objectForKey:@"player"]];
 //                [set1 intersectSet:set2]; //this will give you only the obejcts that are in both sets
 //                NSArray* intersectArray = [set1 allObjects];
 //                if (intersectArray.count < [[tag objectForKey:@"player"]count]) {
 //                    NSMutableArray *tempPlayerArr = [[tag objectForKey:@"player"]mutableCopy];
 //                    //new players which are not included in the array typesoftags
 //                    [tempPlayerArr removeObjectsInArray:intersectArray];
 //                    [[typesOfTags objectAtIndex:3] addObjectsFromArray:tempPlayerArr];
 //                }
 //            }
 //
 //
 //        }else if([[tag objectForKey:@"type"] intValue]==10 && [[tag objectForKey:@"type"]integerValue]!=3 && [tag  objectForKey:@"name"]!=nil){
 //            [tempArray addObject:tag];
 //            //strength tags
 //            if(![[typesOfTags objectAtIndex:2] containsObject:[tag  objectForKey:@"name"]])
 //            {
 //                [[typesOfTags objectAtIndex:2] addObject:[tag  objectForKey:@"name"]];
 //            }
 //
 //        }else if(!([[tag objectForKey:@"type"] intValue]&1) && [[tag objectForKey:@"type"]integerValue]!=3 && [tag  objectForKey:@"name"]!=nil && ![openEndStrings containsObject:[NSString stringWithFormat:@"%@",[tag objectForKey:@"type"]]]){
 //            [tempArray addObject:tag];
 //            //normal tag
 //            if(![[typesOfTags objectAtIndex:1] containsObject:[tag  objectForKey:@"name"]])
 //            {
 //                [[typesOfTags objectAtIndex:1] addObject:[tag  objectForKey:@"name"]];
 //            }
 //        }
 //    }
 //
 //    //globals.THUMBNAIL_COUNT_REF_ARRAY = tempArray;
 //    if (tempArray.count > 0) {
 //        [self createBreadCrumbsView];
 //        self.edgeSwipeButtons.hidden = NO;
 //
 //    }else{
 //        [breadCrumbsView removeFromSuperview];
 //        breadCrumbsView  = nil;
 //        self.edgeSwipeButtons.hidden = YES;
 //    }
 //
 //    if(!globals.TAGGED_ATTS_DICT.count && !globals.TAGGED_ATTS_DICT_SHIFT.count){
 //        tempArray = [[self sortArrayByTime:tempArray]mutableCopy];
 //        self.tagsToDisplay = [tempArray mutableCopy];
 //        globals.TYPES_OF_TAGS = typesOfTags;
 //        if (!globals.FINISHED_LOADING_THUMBNAIL_IMAGES){
 //            @try {
 //                downloadedTagIds = [globals.DOWNLOADED_THUMBNAILS_SET mutableCopy];
 //            }
 //            @catch (NSException *exception) {
 //                NSLog(@"downloadedTagIds: %@",exception.reason);
 //            }
 //        }
 //        [self.myTableView reloadData];
 //        globals.THUMBNAIL_COUNT_REF_ARRAY = self.tagsToDisplay;
 //
 //    } else {
 //        if ([self.view.subviews count] > 0){
 //            if(![self.view.subviews containsObject:filterToolBoxListViewController.view])
 //            {
 //                [filterToolBoxListViewController.view setFrame:filterContainer.frame];
 //                [self.view addSubview:filterToolBoxListViewController.view];
 //                filterToolBoxListViewController.typesOfTags = typesOfTags;
 //                globals.TYPES_OF_TAGS=typesOfTags;
 //                [filterToolBoxListViewController viewDidAppear:TRUE];
 //                // filterToolBoxListViewController.showTelestration = FALSE;
 //            }
 //        }
 //    }
 }
 */


// Override to support editing the table view.
// enable swipe to delete but only on individual cells
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //add code here for when you hit delete
//          NSDictionary *tag = [self.tagsToDisplay objectAtIndex:indexPath.row];
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjects:[[NSArray alloc] initWithObjects:tag,indexPath, nil] forKeys:[[NSArray alloc]initWithObjects:@"tag",@"indexpath", nil]];
//        [selectedCellRows setObject:dict forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
//        [self deleteCells];
//
//    }
//}




//  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  //
-(void)receiveFilteredArrayFromFilter:(id)filter
{
    _tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
    [_tableViewController reloadData];
}
//  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  //

#pragma mark - Edge Swipe Buttons Delegate Methods

- (void)slideFilterBox
{
    
    //    float boxXValue = filterToolBoxListViewController.view.frame.origin.x>=self.view.frame.size.width? 60 : self.view.frame.size.width;
    //    if (boxXValue == 60)
    //    {
    //        [filterToolBoxListViewController updateDisplayedTagsCount];boo
    //        //clear the previous filter set
    //        [breadCrumbsView removeFromSuperview];
    //        breadCrumbsView  = nil;
    //
    //        if(!self.blurView)
    //        {
    //            self.blurView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, 1024, 768-55)];
    ////            self.blurView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    ////            UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    ////            [self.blurView addGestureRecognizer:tapRec];
    ////            [self.view addSubview:self.blurView];
    //            componentFilter = [[TestFilterViewController alloc]initWithTagArray: self.tagsToDisplay];
    //        }
    //
    ////        self.blurView.hidden = NO;
    //        //[self.view bringSubviewToFront:filterToolBoxListViewController.view];
    //        //[self.view bringSubviewToFront:componentFilter.view];
    //    }
    //    else{
    ////        self.blurView.hidden = YES;
    //
    //        [self createBreadCrumbsView];
    //    }
    
    //    //[componentFilter open:YES]; //Richard
    //    UIButton *dismissButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
    //    [dismissButton addTarget:self action:@selector(dismissFilter:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview: dismissButton];
    
    //[componentFilter.view removeFromSuperview];
    //componentFilter= nil;
    
    if (!componentFilter) {
        componentFilter = [[TestFilterViewController alloc]initWithTagArray: self.tagsToDisplay];
    }
    
    self.dismissFilterButton = [[UIButton alloc] initWithFrame: self.view.bounds];
    [self.dismissFilterButton addTarget:self action:@selector(dismissFilter:) forControlEvents:UIControlEventTouchUpInside];
    self.dismissFilterButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [self.view addSubview: self.dismissFilterButton];
    
    //componentFilter.rawTagArray = self.tagsToDisplay;
    //componentFilter = [[TestFilterViewController alloc]initWithTagArray: self.tagsToDisplay];
    componentFilter.rangeSlider.highestValue = [(UIViewController <PxpVideoPlayerProtocol> *)self.videoPlayer durationInSeconds];
    
    [componentFilter onSelectPerformSelector:@selector(receiveFilteredArrayFromFilter:) addTarget:self];
    //[componentFilter onSwipePerformSelector:@selector(slideFilterBox) addTarget:self];
    componentFilter.finishedSwipe = TRUE;
    
    [self.view addSubview:componentFilter.view];
    componentFilter.rangeSlider.highestValue = [((UIViewController <PxpVideoPlayerProtocol> *)self.videoPlayer) durationInSeconds];
    [componentFilter setOrigin:CGPointMake(60, 190)];
    [componentFilter close:NO];
    [componentFilter viewDidAppear:TRUE];
    [componentFilter open:YES];
}

-(void)dismissFilter: (UIButton *)dismissButton{
    [componentFilter close:YES];
    [dismissButton removeFromSuperview];
    //[self performSelector:@selector(componentNil) withObject:self afterDelay:0.3f];
    //[self.edgeSwipeButtons deselectAllButtons];
}

-(void) componentNil{
    // [componentFilter.view removeFromSuperview];
    //componentFilter = nil;
}

//- (void)backgroundTapped
//{
//
//    //    [self slideFilterBox];
//    [self.edgeSwipeButtons deselectButtonAtIndex:1];
//    [componentFilter close:YES];
//    self.blurView.hidden = YES;
//    //[self performSelector:@selector(componentNil) withObject:self afterDelay:0.3f];
//}



//switch to edit mode which allow the user to select tags and delete them
-(void)editingClips:(BOOL)isEditing
{
    
    if (isEditing) {
        _tableViewController.isEditable = TRUE;
        [_tableViewController reloadData];
    }
    else
    {
        _tableViewController.isEditable = FALSE;
//        [self.edgeSwipeButtons deselectButtonAtIndex:2];
        [self cancelEditingCells];
    }
    
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
}


- (void)popoverDidFinishSelection
{
    [_popover dismissPopoverAnimated:YES];
    [self popoverControllerDidDismissPopover:_popover];
}


#pragma mark -

//when come back to list view from othe view, get all the tags which had been viewed and will mark these tags when populating all tags in the list view table

-(NSMutableArray*)sortArrayByTime:(NSMutableArray*)arr
{
    NSArray *sortedArray;
    sortedArray = [arr sortedArrayUsingComparator:(NSComparator)^(id a, id b) {
        NSNumber *num1 =[ NSNumber numberWithFloat:[[a objectForKey:@"starttime"] floatValue]];
        NSNumber *num2 = [ NSNumber numberWithFloat:[[b objectForKey:@"starttime"] floatValue]];
        
        return [num1 compare:num2];
    }];
    
    return (NSMutableArray*)sortedArray;
}


////return the totoal number of tags displayed in the table view
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [self.tagsToDisplay count];
//    //return [self.allTags count];
//}

// This will tell your UITableView what data to put in which cells in your table.
/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 //fixed the issue: when lots of tags created, couldn't scroll to tableview bottom
 [self.myTableView setContentSize:CGSizeMake(self.myTableView.frame.size.width,[self.tagsToDisplay count]*CELL_HEIGHT )];
 
 ListViewCell *cell = (ListViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ListViewCell"];
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 //fixed: randomly highlight cells problem
 cell.backgroundView = nil;
 cell.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
 cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
 //cell.backgroundColor = [UIColor redColor];
 
 UIView* backgroundView = [ [ UIView alloc ] initWithFrame:cell.frame ];
 backgroundView.backgroundColor = [UIColor clearColor];
 backgroundView.layer.borderColor = [PRIMARY_APP_COLOR CGColor];
 cell.backgroundView = backgroundView;
 ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc]init];
 NSString *url = [self.tagsToDisplay[indexPath.row] objectForKey:@"url"];
 [imageAssetManager imageForURL:url atImageView:cell.tagImage];
 
 
 //    if (!globals.FINISHED_LOADING_THUMBNAIL_IMAGES && [downloadedTagIds count] != [globals.DOWNLOADED_THUMBNAILS_SET count]){
 //        @try {
 //            downloadedTagIds = [globals.DOWNLOADED_THUMBNAILS_SET mutableCopy];
 //        }
 //        @catch (NSException *exception) {
 //            NSLog(@"downloadedTagIds: %@",exception.reason);
 //        }
 //    }
 //    NSMutableArray *openEndStrings = [[NSMutableArray alloc] init]; //will use this array for open and end types of different sports -- soccer will be 17,18 hockey will be 7,8
 //    if([globals.WHICH_SPORT isEqualToString:@"hockey"])
 //    {
 //        //period tag for hockey
 //        [openEndStrings addObject:@"7"];
 //        [openEndStrings addObject:@"8"];
 //    }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
 //    {
 //        //half tag for hockey
 //        [openEndStrings addObject:@"17"];
 //        [openEndStrings addObject:@"18"];
 //    }else if ([globals.WHICH_SPORT isEqualToString:@"football"])
 //    {
 //        [openEndStrings addObject:@"21"];
 //        [openEndStrings addObject:@"22"];
 //    }else if ([globals.WHICH_SPORT isEqualToString:@"football training"])
 //    {
 //        [openEndStrings addObject:@"23"];
 //        [openEndStrings addObject:@"24"];
 //    }
 //    else{
 //        //this will happen if the there is new tag coming when the user stops the live event (globals.WHICH_SPORT is empty), then just return; Otherwise the app will crash
 //        //return cell;
 //        //for testing
 //        [openEndStrings addObject:@"100"];
 //        [openEndStrings addObject:@"101"];
 //    }
 //
 //
 //    NSDictionary *tag = [self tagAtIndexPath:indexPath];
 //
 //    globals.THUMBNAILS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"thumbnails"];
 //    //path of the thumb image file in the local folder
 //    NSString *currentImage = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[[tag objectForKey:@"url"] lastPathComponent]];
 //    //if the image file is not downloaded to the local folder, redownloaded
 //    if (![[NSFileManager defaultManager] fileExistsAtPath:currentImage]) {
 //        cell.imageLoaded = [self redownloadImageFromtheServer:tag];
 //    }else{
 //
 //        //if the image file is already downloaded, set the boolean value cell.imageLoaded to TRUE
 //        cell.imageLoaded = TRUE;
 //    }
 //
 //    if (cell.imageLoaded){
 //        //if the thumb image has been downloaded, present the image
 //
 //        cell.tagImage.contentMode = UIViewContentModeCenter;
 //        [cell.tagImage setImage:[UIImage imageWithContentsOfFile:currentImage]];
 //        cell.tagImage.contentMode = UIViewContentModeScaleToFill;
 //        //[cell.tagImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"live.png"] options:nil completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {[weakCell.tagActivityIndicator stopAnimating];weakCell.tagImage.contentMode = UIViewContentModeScaleToFill;}];
 //    } else {
 //        //if the thumb image has not been downloaded, present the default image (live.png)
 //
 //        cell.tagImage.contentMode = UIViewContentModeCenter;
 //        [cell.tagImage setImage:[UIImage imageNamed:@"live.png"]];
 //    }
 //    //if it is in edit mode and the cell in the indexPath was selected, display the checkmark and hide bookmark button and coachpick button
 //    //otherwise, hide checkmark view and display bookmark button and coachpick button
 //    if([[selectedCellRows allKeys] containsObject:[NSString stringWithFormat:@"%d",indexPath.row]] && isEditingMode){
 //        [cell.translucentEditingView setHidden:FALSE];
 //        [cell.checkmarkOverlay setHidden:FALSE];
 //        [cell.bookmarkButton setHidden:TRUE];
 //        [cell.coachpickButton setHidden:TRUE];
 //
 //    }else {
 //        [cell.translucentEditingView setHidden:TRUE];
 //        [cell.checkmarkOverlay setHidden:TRUE];
 //        [cell.bookmarkButton setHidden:FALSE];
 //        [cell.coachpickButton setHidden:FALSE];
 //    }
 //
 //    //Disable bookmarking if duration is less than 1 second or greater than 5 minutes
 //    if ([[tag objectForKey:@"duration"] integerValue] > 300 || [[tag objectForKey:@"duration"] integerValue] < 1){
 ////        [cell.bookmarkButton setEnabled:FALSE];
 //        [cell.bookmarkButton setAlpha:0.7f];
 //    } else {
 ////        [cell.bookmarkButton setEnabled:TRUE];
 //        [cell.bookmarkButton setAlpha:1.0f];
 //    }
 //
 //    NSString *thumbNameStr = [tag objectForKey:@"name"];
 //
 //    [cell.tagname setText:thumbNameStr];
 //    [cell.tagname setFont:[UIFont boldSystemFontOfSize:18.f]];
 //
 //    if ([globals.WHICH_SPORT isEqualToString:@"medical"] || [globals.WHICH_SPORT isEqualToString:@""]) {
 //
 //        NSString *durationString = [NSString stringWithFormat:@"%@s",[tag objectForKey:@"duration"]];
 //        [cell.tagInfoText setText:[NSString stringWithFormat:@"Duration: %@ ",durationString]];
 //        [cell.playersNumberLabel setHidden:TRUE];
 //        [cell.playersLabel setHidden:TRUE];
 //    }else{
 //        NSString *periodString;
 //
 //        if(globals.ARRAY_OF_PERIODS && globals.ARRAY_OF_PERIODS.count > 0 ){
 //
 //            NSString *tagTime = [NSString stringWithFormat:@"%@",[tag objectForKey:@"time"] ];
 //            NSString *closestTagTime ;
 //            NSDictionary *timeDictionary;
 //            NSMutableArray *t;
 //
 //
 //            t = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:[openEndStrings objectAtIndex:1]]];
 //            if(globals.HAS_MIN)
 //            {
 //                [t addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:[openEndStrings objectAtIndex:0]]];
 //            }
 //            NSMutableArray *temp=[t mutableCopy];
 //
 //            // force all times to be strings -- makes it easier to search for items in dictionary later
 //            for(NSNumber* obj in t)
 //            {
 //                int i = [t indexOfObject:obj];
 //                [temp replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@",obj]];
 //            }
 //            t=[temp mutableCopy];
 //            temp=nil;
 //            //sorting
 //            [t sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
 //                return [str1 compare:str2 options:(NSNumericSearch)];
 //            }];
 //
 //            int periodIndex=-1;
 //
 //            NSInteger *sortedIndex = 0;
 //            if (t.count >= 1) {
 //                int binSearchIndex =[t binarySearch:tagTime] ; // binsearch returns -1 if time not found
 //                binSearchIndex = (int)binSearchIndex <0 ? 0:binSearchIndex; // make sure the binary search index is greater then 0
 //
 //                sortedIndex=(int)binSearchIndex >t.count-1 ? t.count-1 : binSearchIndex-1;
 //                sortedIndex=(int)sortedIndex <0 ? 0:sortedIndex; //make sure index isn't less then 0
 //
 //                closestTagTime = [NSString stringWithFormat:@"%@",[t objectAtIndex:sortedIndex]];
 //
 //                timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey: closestTagTime]];
 //
 //                periodIndex = [[timeDictionary objectForKey:[openEndStrings objectAtIndex:1]] integerValue];
 //                if(!periodIndex)
 //                {
 //                    periodIndex=[[timeDictionary objectForKey:[openEndStrings objectAtIndex:0]] integerValue];
 //                }
 //
 //            }
 //
 //            if (periodIndex < 0) {
 //                periodIndex = 0;
 //            }
 //            periodString = [NSString stringWithFormat:@"%@",[globals.ARRAY_OF_PERIODS objectAtIndex:periodIndex]];
 //        }else if ([tag objectForKey:@"period"]) {
 //            periodString = [tag objectForKey:@"period"];
 //        } else {
 //            periodString = @"";
 //        }
 //
 //        NSString *durationString = [NSString stringWithFormat:@"%@s",[tag objectForKey:@"duration"]];
 //        if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
 //            [cell.tagInfoText setText:[NSString stringWithFormat:@"Duration: %@ \nPeriod: %@ ",durationString,periodString]];
 //        }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]){
 //            [cell.tagInfoText setText:[NSString stringWithFormat:@"Duration: %@ \nHalf: %@ ",durationString,periodString]];
 //        }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
 //            [cell.tagInfoText setText:[NSString stringWithFormat:@"Duration: %@ \nQuarter: %@ ",durationString,periodString]];
 //        }else if([globals.WHICH_SPORT isEqualToString:SPORT_FOOTBALL_TRAINING] && ([[tag objectForKey:@"type"] intValue] == 99 || [[tag objectForKey:@"type"] intValue] == 100)){
 //            NSString *subtagString = [tag objectForKey:@"subtag"]?[tag objectForKey:@"subtag"]:@"";
 //            [cell.tagInfoText setText:[NSString stringWithFormat:@"Duration: %@ \nSubtag: %@",durationString,subtagString]];
 //        }else {
 //            [cell.tagInfoText setText:[NSString stringWithFormat:@"Duration: %@ \nPeriod: %@ ",durationString,periodString]];
 //        }
 //
 //
 //        NSString *playerString;
 //        if ([[tag objectForKey:@"player"]count]>0 && ![[[tag objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""] ) {
 //            playerString = [[tag  objectForKey:@"player"] componentsJoinedByString: @","];
 //        }else{
 //            playerString = @"";
 //        }
 //        [cell.playersNumberLabel setText:playerString];
 //        [cell.playersNumberLabel setFrame:CGRectMake(cell.playersNumberLabel.frame.origin.x, cell.playersNumberLabel.frame.origin.y, 9.0f*playerString.length + 3.0f, cell.playersNumberLabel.frame.size.height)];
 //        [cell.tagPlayersView setContentSize:CGSizeMake(9.0f*playerString.length, cell.tagPlayersView.contentSize.height)];
 //    }
 //
 //    [cell.tagtime setText: [tag objectForKey:@"displaytime"]];
 //
 //    UIColor *thumbColour = [uController colorWithHexString:[tag objectForKey:@"colour"]];
 //    [cell.tagcolor changeColor:thumbColour withRect:cell.tagcolor.frame];
 //    //when the tag is viewed or coachpicked or bookmarked, the viewed information is saved in the dictionary:"globals.CURRENT_EVENT_THUMBNAILS".So if repopulate the table view, we should always check the latest tag
 //    NSMutableDictionary *updatedTag = [NSMutableDictionary dictionaryWithDictionary:[globals.CURRENT_EVENT_THUMBNAILS objectForKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]]];
 //
 //    thumbRatingArray = [[NSMutableArray alloc]initWithObjects:cell.tagRatingOne,cell.tagRatingTwo,cell.tagRatingThree,cell.tagRatingFour,cell.tagRatingFive,nil];
 //
 //    int ratingValue = [[updatedTag objectForKey:@"rating"]integerValue];
 //    if (ratingValue > [thumbRatingArray count]){
 //        ratingValue = [thumbRatingArray count];
 //    } else if (ratingValue < 0){
 //        ratingValue = 0;
 //    }
 //    for (int i=0; i<ratingValue; i++) {
 //        UIView *ratingView = [thumbRatingArray objectAtIndex:i];
 //        [ratingView setHidden:FALSE];
 //    }
 //    //have to hide the other rating views;otherwise, rating stars will randomly display in thumbnails
 //    for (int i = ratingValue; i<5; i++) {
 //        UIView *ratingView = thumbRatingArray.count > 0 ? [thumbRatingArray objectAtIndex:i] : [[UIView alloc] init];
 //        [ratingView setHidden:TRUE];
 //    }
 //
 //
 //    coachPickMode = [[updatedTag objectForKey:@"coachpick"] intValue];
 //    [cell.coachpickButton setContentMode:UIViewContentModeScaleAspectFill];
 //    //if it is not coach pick, coachPickMode is equal to 0, otherwise equals to 1
 //    if (coachPickMode == NOTCOACHPICK) {
 //        [cell.coachpickButton setSelected:FALSE];
 //    }else{
 //        [cell.coachpickButton setSelected:TRUE];
 //    }
 //    [cell.coachpickButton addTarget:self action:@selector(coachSelected:event:) forControlEvents:UIControlEventTouchUpInside];
 //    [cell.bookmarkButton setContentMode:UIViewContentModeScaleAspectFill];
 //    //if the tag is not contained in book
 //    if (![[[globals.BOOKMARK_TAGS objectForKey:[updatedTag objectForKey:@"event"]] allKeys] containsObject:[NSString stringWithFormat:@"%@",[updatedTag objectForKey:@"id"]]]) {
 //        if ([[downloadingTagsDict objectForKey:[updatedTag objectForKey:@"event"]] containsObject:[updatedTag objectForKey:@"id"]]) {
 //            [cell.bookmarkButton setState:DBDownloading];
 //        }else{
 //            [cell.bookmarkButton setState:DBDefault];
 //        }
 //    }else{
 //        [cell.bookmarkButton setState:DBDownloaded];
 //    }
 //    [cell.bookmarkButton addTarget:self action:@selector(bookmarkSelected:event:) forControlEvents:UIControlEventTouchUpInside];
 //
 //    //when just back from full screen (viewWillAppearCalled!=0 && !(viewWillAppearCalled&1) ), the cell which was viewed will be highlighted;otherwise, the cell background will be marked as "lightgray"
 //    if([globals.THUMBS_WERE_SELECTED_LISTVIEW containsObject: [tag objectForKey:@"id"]]){
 //        //if([globals.THUMB_WAS_SELECTED_LISTVIEW isEqual: [tag objectForKey:@"id"]]){
 //           // cell.backgroundView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
 //        //}else{
 //            cell.backgroundView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
 //        //}
 //    }
 //    cellCounter++;
 //    //called when all cells are loaded
 //    if ( cellCounter <=1){
 //
 //        //if filtertoolbox hasn't been created yet, make it and add to view
 //        if(![self.view.subviews containsObject:filterToolBoxListViewController.view])
 //        {
 //            [filterToolBoxListViewController.view setFrame:filterContainer.frame];
 //            [self.view addSubview:filterToolBoxListViewController.view];
 //            filterToolBoxListViewController.typesOfTags = typesOfTags;
 //            [self.view insertSubview:filterToolBoxListViewController.view atIndex:self.view.subviews.count-1];
 //
 //            //filterToolBoxListViewController.showTelestration = FALSE;
 //
 //        }
 //    }
 //
 //    filterToolBoxListViewController.typesOfTags = typesOfTags;
 
 return cell;
 }*/

//mark the tag as coachpick tag or not
-(void)coachSelected:(id)sender event:(UIEvent *)event{
    //    if(isEditingMode){
    //        return;
    //    }
    //    CustomButton *button = (CustomButton *)sender;
    //    NSString *coachValue;
    //    NSIndexPath *indexPath = [myTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:myTableView]];
    //    NSMutableDictionary *cellTag = [[NSMutableDictionary alloc] initWithDictionary:[self tagAtIndexPath:indexPath]];
    //    NSString *coachTagId = [cellTag objectForKey:@"id"];
    //    NSMutableDictionary *tag = [NSMutableDictionary dictionaryWithDictionary:[globals.CURRENT_EVENT_THUMBNAILS objectForKey:[NSString stringWithFormat:@"%@",coachTagId]]];
    //    coachPickMode = [[tag objectForKey:@"coachpick"] intValue];
    //
    //    if (coachPickMode == 0) {
    //        button.selected = TRUE;
    //        coachPickMode = 1;
    //        coachValue = [NSString stringWithFormat:@"%d",coachPickMode];
    //        [tag setValue:coachValue forKey:@"coachpick"];
    //
    //    }else if(coachPickMode == 1){
    //        button.selected = FALSE;
    //        coachPickMode = 0;
    //        coachValue = [NSString stringWithFormat:@"%d",coachPickMode];
    //        [tag setValue:coachValue forKey:@"coachpick"];
    //
    //    }
    //
    //    if ([[tag objectForKey:@"bookmark"]integerValue] ==1) {
    //        [[globals.BOOKMARK_TAGS objectForKey:[tag objectForKey:@"event"]] setObject:tag forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
    //        [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    //    }
    //
    //    //if ((globals.IS_LOCAL_PLAYBACK && !globals.HAS_MIN)||!globals.eventExistsOnServer){
    //    if (!globals.HAS_MIN ||(globals.HAS_MIN && !globals.eventExistsOnServer)){
    //        [tag setObject:@"1" forKey:@"edited"];
    //        [globals.CURRENT_EVENT_THUMBNAILS setObject:tag forKey:[NSString stringWithFormat:@"%@",coachTagId]];
    //    }else{
    //        [globals.CURRENT_EVENT_THUMBNAILS setObject:tag forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
    //
    //        //current absolute time in seconds
    //        double currentSystemTime = CACurrentMediaTime();
    //        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:coachValue,@"coachpick",globals.EVENT_NAME,@"event",userId,@"user",coachTagId,@"id",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime", nil];
    //
    //        NSError *error;
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    //        NSString *jsonString;
    //        if (! jsonData) {
    //
    //        } else {
    //            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        }
    //
    //
    //        NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    //
    //        //callback method and parent view controller reference for the appqueue
    //        NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
    //        NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
    //        NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //        [globals.APP_QUEUE enqueue:url dict:instObj];
    //    }
    //
}

//download the tag to myclip view
-(void)bookmarkSelected:(id)sender event:(UIEvent *)event{
    //
    //    if(isEditingMode){
    //        return;
    //    }
    //
    //    uint64_t totalFreeSpace = 0;
    //    __autoreleasing NSError *error = nil;
    //    NSArray *fileSystemPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSDictionary *fileSystemDictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[fileSystemPaths lastObject] error: &error];
    //    NSNumber *freeFileSystemSizeInBytes = [fileSystemDictionary objectForKey:NSFileSystemFreeSize];
    //    totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    //    //dowload tags only if the free space is greater than 500M
    //    if (totalFreeSpace < 500 * 1048576) {
    //        CustomAlertView *alert = [[CustomAlertView alloc] init];
    //        [alert setTitle:@"myplayXplay"];
    //        [alert setMessage:@"Not enough space in the device. Please free some space before downloading clips."];
    //        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
    //        [alert addButtonWithTitle:@"OK"];
    //        [alert show];
    ////        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
    //        return;
    //    }
    //
    //
    //    DownloadButton *button = (DownloadButton *)sender;
    //    if ([button.accessibilityValue isEqualToString:@"bookmarkSelectedPNG"]) {
    //        //already downloaded
    //        return;
    //    }
    //    NSString *bookmarkValue;
    //    NSIndexPath *indexPath;
    //    if (fullScreenMode) {
    //        indexPath = [NSIndexPath indexPathForRow:wasPlayingIndexPath.row inSection:0];
    //    }else{
    //        indexPath = [myTableView indexPathForRowAtPoint:[[[event touchesForView:sender] anyObject] locationInView:myTableView]];
    //    }
    //    NSMutableDictionary *cellTag = [[NSMutableDictionary alloc] initWithDictionary:[self tagAtIndexPath:indexPath]];
    //    NSString *bookmarkTagId = [cellTag objectForKey:@"id"];
    //    NSMutableDictionary *tag = [NSMutableDictionary dictionaryWithDictionary:[globals.CURRENT_EVENT_THUMBNAILS objectForKey:[NSString stringWithFormat:@"%@",[cellTag objectForKey:@"id"]]]];
    //
    //    //download telestration
    //    if([[tag objectForKey:@"type"]intValue] == 4){
    //        NSString *imgName =[NSString stringWithFormat:@"telestration_%@_%@.png",[tag objectForKey:@"event"],[tag objectForKey:@"id"]];;
    //        NSData * imageData;
    //        NSString *teleFilePath = [globals.BOOKMARK_PATH stringByAppendingPathComponent:imgName];;
    //
    //        if(globals.HAS_MIN && globals.eventExistsOnServer )
    //        {
    //            //if there is server available and the event is also from the current server.
    //            //First: check if there is image existing in the path "thumbFilePath". If there is, this tag was made in offline and was synced to the server, then
    //            //get the image data from the file path, since this telestration image is accurate.TODO: if we could make sure online downloading is accurate, then
    //            //thus first step is not needed anymore.
    //            //Second: If no image existing in the path "thumbFilePath", and if tag dictionary has the key "telefull", then download the telestration image from the URL: [tag objectForKey:@"telefull"].
    //            //Third: If no key "telefull" in tag dictionary, then download the telestration image from the URL: [tag objectForKey:@"url"].
    //
    //            //Use [tag objectForKey:@"time"] instead of [tag objectForKey:@"id"], because offline tag, id value is same as "time" value and id value will change after sync to server;
    //            NSString *thumbLocalImageName = [NSString stringWithFormat:@"teleLocal%@.jpg",[tag objectForKey:@"time"]];
    //            NSString *thumbLocalFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",thumbLocalImageName]];
    //
    //            if ([[NSFileManager defaultManager]fileExistsAtPath:thumbLocalFilePath]) {
    //                imageData = [NSData dataWithContentsOfFile:thumbLocalFilePath];
    //            }else if([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location != NSNotFound){
    //                //if mp4 file is playing, generate telestration locally since it is accurate this way;
    //                imageData = [self generateTelestration:tag];
    //            }else if([tag objectForKey:@"telefull"]){
    //                NSURL * imageURL = [NSURL URLWithString:[tag objectForKey:@"telefull"]];
    //                imageData = [NSData dataWithContentsOfURL:imageURL];
    //            }else{
    //                NSURL * imageURL = [NSURL URLWithString:[tag objectForKey:@"url"]];
    //                imageData = [NSData dataWithContentsOfURL:imageURL];
    //            }
    //
    //        }else{
    //
    //            if ([[tag objectForKey:@"local"]intValue] == 1) {
    //                //if the tele tag was made in offline, tele image is saved in the "thumbFilePath". Get the tele image, re-save it under bookmark folder;
    //
    //                NSString *thumbImageName = [NSString stringWithFormat:@"tn%@.jpg",[tag objectForKey:@"id"]];
    //                NSString *thumbFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",thumbImageName]];
    //                imageData = [NSData dataWithContentsOfFile:thumbFilePath];
    //
    //            }else{
    //
    //                NSString *thumbLocalImageName = [NSString stringWithFormat:@"teleLocal%@.jpg",[tag objectForKey:@"time"]];
    //                NSString *thumbLocalFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",thumbLocalImageName]];
    //                if ([[NSFileManager defaultManager]fileExistsAtPath:thumbLocalFilePath]) {
    //                    //if there is image existing in the path "thumbFilePath", this tag was made in offline mode before and was synced to the server, then
    //                    //get the image data from the file path
    //                    imageData = [NSData dataWithContentsOfFile:thumbLocalFilePath];
    //                }else{
    //                    //if the tele tag was made on line, generate the tele image locally.
    //                    imageData = [self generateTelestration:tag];
    //                }
    //
    //            }
    //        }
    //
    //        if (imageData != nil) {
    //            //if the imageData is not nil, save it in the path "teleFilePath"(under the bookmark folder)
    //            [imageData writeToFile:teleFilePath atomically:YES];
    //
    //            [button setState:DBDownloaded];
    //            [tag setObject:@"1" forKey:@"bookmark"];
    //            [tag setObject:@"1" forKey:@"modified"];
    //            if (![[globals.BOOKMARK_TAGS allKeys] containsObject:[tag objectForKey:@"event"]]) {
    //                [globals.BOOKMARK_TAGS setObject:[[NSMutableDictionary alloc]initWithObjects:[[NSArray alloc]initWithObjects:tag, nil] forKeys:[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]], nil]] forKey:[tag objectForKey:@"event"]];
    //            } else {
    //                [[globals.BOOKMARK_TAGS objectForKey:[tag objectForKey:@"event"]] setObject:tag forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
    //            }
    //            [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    //
    //            NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
    //
    //            if([fileManager fileExistsAtPath:orderedBookmarkPlist isDirectory:false])
    //            {
    //                NSMutableArray *t = [[NSMutableArray alloc] initWithContentsOfFile:orderedBookmarkPlist]; // temp array for the ordered list of bookmarks
    //                [t insertObject:tag atIndex:0];//add the new bookmark to the top of the list
    //                [t writeToFile:orderedBookmarkPlist atomically:TRUE];
    //            }
    //
    //        }else{
    //            //if the image data is nil, show the error alert view
    //            UIAlertView *alert = [[UIAlertView alloc] init];
    //            [alert setTitle:@"myplayXplay"];
    //            [alert setMessage:@"There was an error downloading the telestration, please try again."];
    //            [alert setDelegate:nil];
    //            [alert addButtonWithTitle:@"OK"];
    //            [alert show];
    //        }
    //
    //    }else{
    //        //download video tags
    //        //only download tags which are less than 5mins
    //        if ([[tag objectForKey:@"duration"]integerValue] > 300 || [[tag objectForKey:@"duration"]integerValue] < 1) {
    //            UIAlertView *alert = [[UIAlertView alloc] init];
    //            [alert setTitle:@"myplayXplay"];
    //            [alert setMessage:@"Please try to download tags which are less than 5 minutes and longer than 1 second."];
    //            [alert setDelegate:nil];
    //            [alert addButtonWithTitle:@"OK"];
    //            [alert show];
    //            return;
    //        }
    //
    //        int bookmarkMode = [[tag objectForKey:@"bookmark"] intValue];
    //
    //        if ([button.accessibilityValue isEqualToString:@"bookmarkUnselectedPNG"]||[button.accessibilityValue isEqualToString:@"bookmarkDownloadingPNG"]) {
    //            if ([button.accessibilityValue isEqualToString:@"bookmarkUnselectedPNG"]) {
    //                [button setState:DBDownloading];
    //
    //                if (fullScreenMode && wasPlayingIndexPath) {
    //                    ListViewCell *cell = (ListViewCell*)[myTableView cellForRowAtIndexPath:wasPlayingIndexPath];
    //                    [cell.bookmarkButton setState:DBDownloading];
    //                }
    //                if (globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS<0) {
    //                    globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS = 0;
    //                }
    //                globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS++;
    //                globals.DID_FINISH_RECEIVE_BOOKMARK_VIDEO = FALSE;
    //                globals.RECEIVED_ONE_BOOKMARK_VIDEO = FALSE;
    //                //[downloadingTagsArray addObject:bookmarkTagId];
    //
    //                if (![[downloadingTagsDict allKeys] containsObject:[tag objectForKey:@"event"]]) {
    //                    [downloadingTagsDict setObject:[NSMutableArray arrayWithObject:bookmarkTagId] forKey:[tag objectForKey:@"event"]];
    //                } else {
    //                    [[downloadingTagsDict objectForKey:[tag objectForKey:@"event"]] addObject:bookmarkTagId];
    //                }
    //            }
    //            bookmarkMode = 1;
    //            bookmarkValue = [NSString stringWithFormat:@"%d",bookmarkMode];
    //        }
    //
    //        //offline mode, create clips locally
    //        if (globals.IS_LOCAL_PLAYBACK){
    //            //NSLog(@"offline boomark");
    //            //Be consistent with online mode
    //            NSMutableDictionary *dictionaryOfObj = [[NSMutableDictionary alloc]init];
    //            [dictionaryOfObj setObject:tag forKey:@"tag"];
    //
    //            if (!globals.BOOKMARK_QUEUE){
    //                globals.BOOKMARK_QUEUE = [NSMutableArray arrayWithObject:dictionaryOfObj];
    //            } else {
    //                [globals.BOOKMARK_QUEUE addObject:dictionaryOfObj];
    //            }
    //
    //            //        NSArray *queueKey = [NSArray arrayWithObjects:[tag objectForKey:@"event"], [tag objectForKey:@"url"], nil];
    //            //        if (!globals.BOOKMARK_QUEUE_KEYS){
    //            //            globals.BOOKMARK_QUEUE_KEYS = [NSMutableArray arrayWithObject: queueKey];
    //            //        } else {
    //            //            [globals.BOOKMARK_QUEUE_KEYS addObject: queueKey];
    //            //            [globals.BOOKMARK_QUEUE_KEYS writeToFile:globals.BOOKMARK_QUEUE_PATH atomically:YES];
    //            //        }
    //
    //            if ([globals.BOOKMARK_QUEUE count] == 1){
    //                [self makeLocalBookmark];
    //            }
    //
    //        } else {
    //            //online mode, create clips from the server
    //            double currentSystemTime = CACurrentMediaTime();
    //            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
    //                                         bookmarkValue,@"bookmark",
    //                                         globals.EVENT_NAME,@"event",
    //                                         [NSString stringWithFormat:@"%f",currentSystemTime], @"requesttime",
    //                                         userId,@"user",
    //                                         bookmarkTagId,@"id", nil];
    //            NSError *error;
    //            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    //            NSString *jsonString;
    //            if (! jsonData) {
    //
    //            } else {
    //                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //                jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //            }
    //
    //            NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    //
    //            //callback method and parent view controller reference for the appqueue
    //            NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(tagModCallback:)],self,@"60", nil];
    //            NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller",@"timeout", nil];
    //            NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //
    //            NSMutableDictionary *dictionaryOfObj = [[NSMutableDictionary alloc]init];
    //            [dictionaryOfObj setObject:instObj forKey:url];
    //            //[tag setObject:[NSString stringWithFormat:@"%.0f",[[tag objectForKey:@"duration"]floatValue]+10] forKey:@"duration"];
    //            [dictionaryOfObj setObject:tag forKey:@"tag"];
    //
    //            if (!globals.BOOKMARK_QUEUE){
    //                globals.BOOKMARK_QUEUE = [NSMutableArray arrayWithObject:dictionaryOfObj];
    //            } else {
    //                [globals.BOOKMARK_QUEUE addObject:dictionaryOfObj];
    //            }
    //
    //            if ([globals.BOOKMARK_QUEUE count] == 1){
    //                [self sendTheNextRequest];
    //            }
    //
    //            //        if (!convertNextBookmarkVideoTimer) {
    //            //            convertNextBookmarkVideoTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(checkRequestStatus:) userInfo:nil repeats:YES];
    //            //            [[NSRunLoop mainRunLoop] addTimer:convertNextBookmarkVideoTimer forMode:NSDefaultRunLoopMode];
    //            //            //[convertNextBookmarkVideoTimer fire];
    //            //        }
    //        }
    //
    //    }
}


//generate telestration for "tag" in offline mode
-(NSData*)generateTelestration:(NSDictionary*)tag{
    
    //    CGSize newSize = CGSizeMake(1024, 576);
    //    NSURL *videoURL = [NSURL fileURLWithPath:[[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"/videos/main.mp4"]];
    //    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    //    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    //    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    //    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    //    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeProductionAperture;
    //    [imageGenerator setMaximumSize:CGSizeMake(1024, 576)];//190,106
    //    CMTime time = CMTimeMake([[tag objectForKey:@"time"]intValue],1);//CMTimeMake(30, 1);
    //    //CMTime actualTime;
    //    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    //    //create thumb image from avplayer
    //    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    //    CGImageRelease(imageRef);
    //
    //    //retrieving the tele drawning image from the path "teleFilePath"
    //    NSString *teleName = [NSString stringWithFormat:@"tl%@.png",[tag objectForKey:@"id"]];
    //    NSString *teleFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleName]];
    //    UIImage *teleImage = [[UIImage alloc]initWithContentsOfFile:teleFilePath];
    //
    //    // create a new bitmap image context at the device resolution (retina/non-retina)
    //    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    //
    //    // get context
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //
    //    // push context to make it current
    //    // (need to do this manually because we are not drawing in a UIView)
    //    UIGraphicsPushContext(context);
    //
    //    // drawing code comes here- look at CGContext reference
    //    // for available operations
    //    // this example draws the inputImage into the context
    //    [thumbnail drawInRect:CGRectMake(0, 0, 1024, 576)];//blendMode:kCGBlendModeScreen alpha:1.0];
    //    [teleImage drawInRect:CGRectMake(0, -65, 1024, 768)]; //blendMode:kCGBlendModeScreen alpha:1.0];
    //    //[thumbnail drawInRect:CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT) blendMode:kCGBlendModeNormal alpha:0.8];        // pop context
    //    UIGraphicsPopContext();
    //
    //    // get a UIImage from the image context- enjoy!!!
    //    UIImage *teleThumbImage = UIGraphicsGetImageFromCurrentImageContext();
    //
    //    //UIGraphicsBeginImageContext(newSize);
    //    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    //    [teleThumbImage drawInRect:CGRectMake(0, 0, newSize.width ,newSize.height)];
    //    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    //
    //    // clean up drawing environment
    //    UIGraphicsEndImageContext();
    //
    //    NSData *thumbData = UIImageJPEGRepresentation(outputImage, 1.0);
    //
    //    //save the telestration in local file folder for future use.(Will be used in this case: If the user mistakenly deleted the downloaded tele file and wants to redownload
    //    //when the server is on, then this locally saved image will be used and it is accurate.)
    //    NSString *teleLocalName = [NSString stringWithFormat:@"teleLocal%@.jpg",[tag objectForKey:@"time"]];
    //    NSString *teleLocalFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleLocalName]];
    //    [thumbData writeToFile:teleLocalFilePath atomically:YES];
    //
    //    return thumbData;
    return nil;;
}

/*TO DELETE
 //when the previous downloading finished or failed, send the next request from globals.BOOKMARK_QUEUE_KEYS
 -(BOOL)isOldEventName:(NSString*)name{
 for (NSString* oldEvent in oldEventNames){
 if ([oldEvent isEqualToString:name]){
 return TRUE;
 }
 }
 return FALSE;
 }
 */
/*******************STRUCTURE OF globals.BOOKMARK_QUEUE*************************
 globals.BOOKMARK_QUEUE is array of dictionaries.
 
 Each dictionary object is:
 
 requestURL:{callbackmethod, controller,timeout time}
 tag:{tag}
 
 Please check the method:bookmarkSelected:(id)sender event:(UIEvent *)event for details
 */

-(void)sendTheNextRequest
{
    
    //    if (!globals.HAS_MIN) {
    //        return;
    //    }
    //
    //    if (globals.BOOKMARK_QUEUE.count > 0) {
    //
    //        id currentURLString = [[[globals.BOOKMARK_QUEUE objectAtIndex:0]allKeys] objectAtIndex:0];
    //        if([currentURLString isEqual:@"tag"]){
    //            currentURLString = [[[globals.BOOKMARK_QUEUE objectAtIndex:0]allKeys] objectAtIndex:1];
    //        }
    //         NSURLRequest *urlRequest;
    //        self.isTagModRequest = TRUE;
    //        if([currentURLString isKindOfClass:[NSString class]])
    //        {
    //            urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:currentURLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    //        }else{
    //            urlRequest = (NSURLRequest*)currentURLString;
    //        }
    //
    //        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    //        //[connection start];
    //        if (connection) {
    //            ////////NSLog(@"connection successs");
    //        }else{
    //            ////////NSLog(@"connection failed");
    //        }
    //
    //    }
}

//create clip video locally
//-(void) makeLocalBookmark
//{
//    NSURL *videoURL;
//    CMTime start;
//    NSDictionary *currentBookmark;
//    NSError* error;
//    CMTime eDuration;
//    NSString *tagVideoPath;
//    NSURL *videoFileURL;
//    if(![[NSFileManager defaultManager] fileExistsAtPath:globals.BOOKMARK_VIDEO_PATH])
//    {
//        [fileManager createDirectoryAtPath:globals.BOOKMARK_VIDEO_PATH withIntermediateDirectories:YES attributes:nil error:&error];
//    }
//    NSString *oldTagVideoPath;
//
//    if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location != NSNotFound) {
//        currentBookmark = [[globals.BOOKMARK_QUEUE objectAtIndex:0]objectForKey:@"tag"];
//        tagVideoPath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[currentBookmark objectForKey:@"event"] stringByAppendingFormat:@"_vid_%@.mp4",[currentBookmark objectForKey:@"id"]]]];
//        videoFileURL = [NSURL fileURLWithPath:tagVideoPath];
//
//        NSString *pathToThisEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:[currentBookmark objectForKey:@"event"]] stringByAppendingPathComponent:@"videos/main.mp4"];
//        videoURL = [NSURL fileURLWithPath:pathToThisEventVid];
//
//
//        float clipStartTime =[[currentBookmark objectForKey:@"starttime"] floatValue];
//        if (clipStartTime < 0){
//            clipStartTime = 0;
//        }
//        start = CMTimeMakeWithSeconds(clipStartTime, 600);
//        eDuration  = CMTimeMakeWithSeconds([[currentBookmark objectForKey:@"duration"] floatValue], 600);
//        [currentBookmark setValue:[NSString stringWithFormat:@"vid_%@.mp4", [currentBookmark objectForKey:@"id"]] forKey:@"vidurl"];
//    }else{
//        NSDictionary *tagInfoDict = [globals.TAGS_DOWNLOADED_FROM_SERVER objectAtIndex:0];
//        currentBookmark = [tagInfoDict objectForKey:@"tag"];
//        tagVideoPath = [tagInfoDict objectForKey:@"videoPath"];//[globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[[currentBookmark objectForKey:@"event"] stringByAppendingFormat:@"_vid_%@.mp4",[currentBookmark objectForKey:@"id"]]]];
//        videoFileURL = [NSURL fileURLWithPath:tagVideoPath];
//
//        //find the low quality video and then recreated
//        oldTagVideoPath = [tagInfoDict objectForKey:@"testPath"];//[globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/test%@",[[currentBookmark objectForKey:@"event"] stringByAppendingFormat:@"_vid_%@.mp4",[currentBookmark objectForKey:@"id"]]]];
//        videoURL = [NSURL fileURLWithPath: oldTagVideoPath];
//        start = kCMTimeZero;
//        eDuration  = CMTimeMakeWithSeconds([[currentBookmark objectForKey:@"duration"] floatValue], 600);
//    }
//
//
//    AVAsset *asset = [AVAsset assetWithURL:videoURL];
//    CMTimeRange eRange = CMTimeRangeMake(start, eDuration);
//
//    if([[NSFileManager defaultManager] fileExistsAtPath:tagVideoPath])
//    {
//        //BOOL success = [fileManager removeItemAtPath:tagVideoPath error:&error];
//        //if (!success) //////NSLog(@"Error: %@", [error localizedDescription]);
//    }
//
//    BOOL canExport = NO;
//    @autoreleasepool {
//        exportSession = nil;
//        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
//        if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]){
//            exportSession = [[AVAssetExportSession alloc]  initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
//            canExport = YES;
//            exportSession.outputURL = videoFileURL;
//            exportSession.outputFileType = AVFileTypeMPEG4;
//            exportSession.timeRange = eRange;
//            [exportSession exportAsynchronouslyWithCompletionHandler:^{
//                ////////NSLog(@"Export session status: %d",[exportSession status]);
//                switch ([exportSession status]) {
//                    case AVAssetExportSessionStatusFailed:
//                         if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location != NSNotFound) {
//                            //TODO: handle failed case
//                            [self handleNewBookmark:[[globals.BOOKMARK_QUEUE objectAtIndex:0] objectForKey:@"tag"]];
//                         }else{
//                             //if recreate tag fails, use the low quality video
//                             if([[NSFileManager defaultManager] fileExistsAtPath:oldTagVideoPath])
//                             {
//                                 NSData *data = [NSData dataWithContentsOfFile:oldTagVideoPath];
//                                 [data writeToFile:tagVideoPath atomically:YES];
//                                 [[NSFileManager defaultManager] removeItemAtPath:oldTagVideoPath error:nil];
//                             }
//
//                            [self updateTableView];                         }
//                        //NSLog(@"Export failed");
//                       //                              localizedDescription]);
//                        break;
//                    case AVAssetExportSessionStatusCancelled:
//                       // //////NSLog(@"Export canceled");
//                        break;
//                    case AVAssetExportSessionStatusUnknown:
//                       // //////NSLog(@"Export status unknown: %@", [[exportSession error]
//                       //                                      localizedDescription]);
//                        break;
//                    case AVAssetExportSessionStatusExporting:
//                       // //////NSLog(@"Export exporting");
//                        break;
//                    case AVAssetExportSessionStatusWaiting:
//                       // //////NSLog(@"Export waiting");
//                        break;
//                    case AVAssetExportSessionStatusCompleted:
//                        //NSLog(@"Export success.");
//                        if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location != NSNotFound) {
//                             [self handleNewBookmark:[[globals.BOOKMARK_QUEUE objectAtIndex:0] objectForKey:@"tag"]];
//                        }else{
//                            if([[NSFileManager defaultManager] fileExistsAtPath:oldTagVideoPath])
//                            {
//                                [[NSFileManager defaultManager] removeItemAtPath:oldTagVideoPath error:nil];
//                            }
//                            [self updateTableView];
//                        }
//
//                        break;
//                    default:
//                       // //////NSLog(@"Something else happened to the export?");
//                        break;
//                }
//            }];
//        } else if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality] && !canExport){
//            exportSession = [[AVAssetExportSession alloc]  initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
//            canExport = YES;
//            exportSession.outputURL = videoFileURL;
//            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
//            CMTimeRange eRange = CMTimeRangeMake(start, eDuration);
//            exportSession.timeRange = eRange;
//            [exportSession exportAsynchronouslyWithCompletionHandler:^{
//                switch ([exportSession status]) {
//                    case AVAssetExportSessionStatusFailed:
//                        //                        //////NSLog(@"Export failed: %@", [[exportSession error]
//                        //                                                     localizedDescription]);
//                        break;
//                    case AVAssetExportSessionStatusCancelled:
//                        ////////NSLog(@"Export canceled");
//                        break;
//                    default:
//                        //TODO: what is default
//                        if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location != NSNotFound){
//                             [self handleNewBookmark:[[globals.BOOKMARK_QUEUE objectAtIndex:0] objectForKey:@"tag"]];
//                        }else{
//                            if([[NSFileManager defaultManager] fileExistsAtPath:oldTagVideoPath])
//                            {
//                                [[NSFileManager defaultManager] removeItemAtPath:oldTagVideoPath error:nil];
//                            }
//                            [self updateTableView];
//                        }
//
//                        break;
//
//                }
//            }];
//        } else {
//            ////////NSLog(@"No file was created");
//        }
//    }
//}

//when new bookmark tag is created, update the globals variables properly
- (void) handleNewBookmark:(NSDictionary *)currentBookmark
{
    //    if (!currentBookmark) {
    //        return;
    //    }
    //    if(![receivedTagArr containsObject:[currentBookmark objectForKey:@"id"]]){
    //        globals.NUMBER_OF_BOOKMARK_TAG_RECEIVED++;
    //        globals.RECEIVED_ONE_BOOKMARK_VIDEO = TRUE;
    //        [receivedTagArr addObject:[currentBookmark objectForKey:@"id"]];
    //    }
    //    [[downloadingTagsDict objectForKey:[currentBookmark objectForKey:@"event"]] removeObject:[currentBookmark objectForKey:@"id"]];
    //    //NSLog(@"handleNewBookmark, reload data");
    //    //[myTableView reloadData];
    //    globals.THUMBNAIL_COUNT_REF_ARRAY = self.tagsToDisplay;
    //
    //    if (![[globals.BOOKMARK_TAGS allKeys] containsObject:[currentBookmark objectForKey:@"event"]]) {
    //        [globals.BOOKMARK_TAGS setObject:[[NSMutableDictionary alloc]initWithObjects:[[NSArray alloc]initWithObjects:currentBookmark, nil] forKeys:[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[currentBookmark objectForKey:@"id"]], nil]] forKey:[currentBookmark objectForKey:@"event"]];
    //    }else{
    //        [[globals.BOOKMARK_TAGS objectForKey:[currentBookmark objectForKey:@"event"]] setObject:currentBookmark forKey:[NSString stringWithFormat:@"%@",[currentBookmark objectForKey:@"id"]]];
    //    }
    //    //url for ordered plist
    //    NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
    //
    //    if(!fileManager)
    //    {
    //        fileManager = [NSFileManager defaultManager];
    //    }
    //
    //    //we want to add the new bookmark to the drag and drop ordred list of bookmarks, but we are going to add it to the top
    //    //of the array so its easier for the user to find
    //    NSMutableArray *t = [[NSMutableArray alloc] initWithContentsOfFile:orderedBookmarkPlist]; // temp array for the ordered list of bookmarks
    //    [t insertObject:currentBookmark atIndex:0];//add the new bookmark to the top of the list
    //    [t writeToFile:orderedBookmarkPlist atomically:TRUE];
    //
    //    [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    //    if (globals.BOOKMARK_QUEUE.count > 0) {
    //          [globals.BOOKMARK_QUEUE removeObjectAtIndex:0];
    //    }
    //
    ////    if (globals.BOOKMARK_QUEUE_KEYS.count > 0) {
    ////        [globals.BOOKMARK_QUEUE_KEYS removeObjectAtIndex:0];
    ////    }
    ////
    ////    [globals.BOOKMARK_QUEUE_KEYS writeToFile:globals.BOOKMARK_QUEUE_PATH atomically:YES];
    ////
    //    if ([globals.BOOKMARK_QUEUE count] > 0){
    //        [self makeLocalBookmark];
    //    }
    //
}





-(void) feedSelected: (NSNotification *) notification
{
    
    NSDictionary *userInfo = [notification.userInfo objectForKey:@"forFeed"];
    
    float time              = [[[notification.userInfo objectForKey:@"forFeed"] objectForKey:@"time"] floatValue];
    float dur               = [[[notification.userInfo objectForKey:@"forFeed"] objectForKey:@"duration"] floatValue];
    CMTime cmtime           = CMTimeMake(time, 1);
    CMTime cmDur            = CMTimeMake(dur, 1);
    
    CMTimeRange timeRange   = CMTimeRangeMake(cmtime, cmDur);
    
//    NSString *pick = [userInfo objectForKey:@"feed"];
    
    //    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED object:nil userInfo:@{@"context":STRING_LISTVIEW_CONTEXT,
    //                                                                                                          @"feed":pick,
    //                                                                                                          @"time":[userInfo objectForKey:@"time"],
    //                                                                                                          @"duration":[userInfo objectForKey:@"duration"],
    //                                                                                                          @"state":[NSNumber numberWithInteger:PS_Play]}];
    
    [self.videoPlayer playFeed:[userInfo objectForKey:@"feed"] withRange:timeRange];
    self.videoPlayer.looping = NO;
    selectedTag = userInfo[@"forWhole"];
    
    [commentingField clear];
    commentingField.enabled             = YES;
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    
    [newVideoControlBar setTagName:[currentPlayingTag objectForKey:@"name"]];
}


//loop tag
-(void)loopTag
{
    //NSLog(@"loop tag!");
    //    [videoPlayer.avPlayer seekToTime:CMTimeMakeWithSeconds(globals.HOME_START_TIME, 600)];
}



-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //    [savedMsgLabel setHidden:TRUE];
}

//user clicked in a textbox field - animate the screen to move up with the keyboard
- (void)keyboardWillShow:(NSNotification *)note
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         //what kind of animation
                         [self.view setFrame:CGRectMake(0, -335, self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                     }];
}
//user clicked out of a textbox field - animate the screen to move down with the keyboard
- (void)keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         //what to do for animation
                         [self.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                     }
                     completion:^(BOOL finished){
                     }];
}

-(void)showHideTele
{
    //    if its there is a telestration playing, make sure you hide the small one when we are showing the big one
    //    if(globals.IS_TELE){
    //        if(self.videoPlayer.teleBigView){
    //            [teleView removeFromSuperview];
    //            teleView=nil;
    //        }
    //        globals.IS_TELE = FALSE;
    //        globals.CURRENT_PLAYBACK_TAG = nil;
    //        [self.videoPlayer play];
    //        [tagEventName setHidden:TRUE];
    //        wasPlayingIndexPath = nil;
    //    }
    
}

//initialize the controls for list view
-(void)setupView
{
    
    // Richard
    commentingField = [[CommentingRatingField alloc]initWithFrame:CGRectMake(10,485 -50, COMMENTBOX_WIDTH, COMMENTBOX_HEIGHT+60 +50) title:NSLocalizedString(@"Comment",nil)];
    commentingField.enabled = NO;
    [commentingField onPressRatePerformSelector:@selector(sendRating:) addTarget:self];
    [commentingField onPressSavePerformSelector:@selector(sendComment) addTarget:self];
    [self.view addSubview:commentingField];
    // End
    
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    filterContainer = [[UIView alloc] initWithFrame:CGRectMake(TOTAL_WIDTH, 450, self.view.bounds.size.width-100, 370.0f)];
    [filterContainer setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:filterContainer];
    
    
    
    [self.view addSubview: _tableViewController.tableView];
    
    self.filterButton = [[UIButton alloc] initWithFrame:CGRectMake(950, 710, 74, 58)];
    [self.filterButton setTitle:NSLocalizedString(@"Filter",nil) forState:UIControlStateNormal];
    [self.filterButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(slideFilterBox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.filterButton];
    
    //    UIImageView *commentBoxTitleBar = [[UIImageView alloc]initWithFrame:CGRectMake(2,SMALL_MEDIA_PLAYER_HEIGHT+140,COMMENTBOX_WIDTH, LABEL_HEIGHT)];
    //    commentBoxTitleBar.backgroundColor = [UIColor clearColor];
    //    [self.view addSubview:commentBoxTitleBar];
    //
    //    commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, LABEL_WIDTH, LABEL_HEIGHT)];
    //    commentLabel.text = @"Comment";
    //    commentLabel.font = [UIFont defaultFontOfSize:18.f];
    //    commentLabel.textColor = [UIColor blackColor];
    //    commentLabel.backgroundColor = [UIColor clearColor];
    //    [commentLabel setAlpha:0.3];
    //    [commentBoxTitleBar addSubview:commentLabel];
    //
    //    commentBox = [[UIView alloc]initWithFrame:CGRectMake(2,SMALL_MEDIA_PLAYER_HEIGHT+170, COMMENTBOX_WIDTH, COMMENTBOX_HEIGHT-10)];//y was 112
    //    commentBox.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //    commentBox.layer.borderWidth = 1;
    //    [self.view addSubview:self.commentBox];
    //
    //    commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, commentBox.frame.size.width, commentBox.frame.size.height-55)];
    //    commentTextView.returnKeyType = UIReturnKeyDone;
    //    [commentTextView setFont:[UIFont systemFontOfSize:18]];
    //    commentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //    commentTextView.layer.borderWidth = 1;
    //    [commentTextView setDelegate:self];
    //    [commentBox addSubview:commentTextView];
    
    //    for(int buttonIndex = 0;buttonIndex<5;buttonIndex++) {
    //        CustomButton *ratingButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //        [ratingButton setFrame:CGRectMake(320 + 40*buttonIndex, commentTextView.frame.origin.y+commentTextView.frame.size.height+20, 20,20)];
    //        [ratingButton setImage:[UIImage imageNamed:@"rating_unselected.png"] forState:UIControlStateNormal];
    //        [ratingButton setAccessibilityLabel:@"0"];
    //        [ratingButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    //        [ratingButton addTarget:self action:@selector(sendRating:) forControlEvents:UIControlEventTouchUpInside];
    //        [self.commentBox addSubview:ratingButton];
    //        [ratingButtonArray addObject:ratingButton];
    //    }
    //
    //    UILabel *ratingLabel = [[UILabel alloc]initWithFrame:CGRectMake(230, commentTextView.frame.origin.y+commentTextView.frame.size.height+16, 60, 30)];
    //    [ratingLabel setTextAlignment:NSTextAlignmentRight];
    //    [ratingLabel setText:@"Rating"];
    //    [ratingLabel setFont:[UIFont defaultFontOfSize:18.0f]];
    //    [ratingLabel setTextColor:[UIColor blackColor]];
    //    [self.commentBox addSubview:ratingLabel];
    //
    
    //    selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [selectAllButton setFrame:CGRectMake(editButton.frame.origin.x + editButton.frame.size.width+10,editButton.frame.origin.y,80 ,25)];//(cancelButton.frame.origin.x + cancelButton.frame.size.width + 5,cancelButton.frame.origin.y, 50, 25)];
    //    [selectAllButton setTitle:@"select all" forState:UIControlStateNormal];
    //    [selectAllButton setBackgroundImage:[UIImage imageNamed:@"tab-bar.png"] forState:UIControlStateNormal];
    //    [selectAllButton addTarget:self action:@selector(selectAllCells:) forControlEvents:UIControlEventTouchUpInside];
    //    [selectAllButton setHidden:TRUE];
    
    
    //    savedMsgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, commentTextView.frame.size.height/2.0 - 20, commentTextView.frame.size.width, 40)];
    //    [savedMsgLabel setText:@"Comment was saved!"];
    //    [savedMsgLabel setFont:[UIFont defaultFontOfSize:18.0f]];
    //    [savedMsgLabel setTextColor:PRIMARY_APP_COLOR];
    //    [savedMsgLabel setTextAlignment:NSTextAlignmentCenter];
    //    [savedMsgLabel setHidden:TRUE];
    //    [commentTextView addSubview:savedMsgLabel];
    //
    //    clearButton = [BorderButton buttonWithType:UIButtonTypeCustom];
    //    [clearButton setFrame:CGRectMake(commentBox.frame.origin.x+2, CGRectGetMaxY(commentBox.frame) + 10, 50, 25)];
    //    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    //    //[clearButton setBackgroundImage:[UIImage imageNamed:@"tab-bar.png"] forState:UIControlStateNormal];
    //    [clearButton addTarget:self action:@selector(clearButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    //
    
    //    submitCommentButton = [BorderButton buttonWithType:UIButtonTypeCustom];
    //    [submitCommentButton setFrame:CGRectMake(commentBox.frame.origin.x+commentBox.frame.size.width - 55,clearButton.frame.origin.y, 50, 25)];
    //    [submitCommentButton setTitle:@"Save" forState:UIControlStateNormal];
    //    //[submitCommentButton setBackgroundImage:[UIImage imageNamed:@"tab-bar.png"] forState:UIControlStateNormal];
    //    [submitCommentButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
    //
    //    [self.view addSubview:submitCommentButton];
    //    [self.view addSubview:clearButton];
    
    
    //    self.edgeSwipeButtons = [[EdgeSwipeEditButtonsView alloc] initWithFrame:CGRectMake(TOTAL_WIDTH-44, 55, 44, 768-55)];
    //    self.edgeSwipeButtons.delegate = self;
    //    [self.view addSubview:self.edgeSwipeButtons];
    
    
    //    UIButton* exportButton = [[UIButton alloc] initWithFrame:CGRectMake(1024- 45, 60, 30, 30)];
    //    [exportButton setImage:[UIImage imageNamed:@"tempShareIcon.png"] forState:UIControlStateNormal];
    //    [exportButton addTarget:self action:@selector(exportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:exportButton];
}

//select all the tags in the list view
-(void)selectAllCells:(id)sender
{
    
    for (int row = 0; row < [self.tagsToDisplay count]; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        NSDictionary *tag = [self.tagsToDisplay objectAtIndex:indexPath.row];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjects:[[NSArray alloc] initWithObjects:tag,indexPath, nil] forKeys:[[NSArray alloc]initWithObjects:@"tag",@"indexpath", nil]];
        [selectedCellRows setObject:dict forKey:[NSString stringWithFormat:@"%d",row]];
    }
    [_tableViewController reloadData];
}


//catch response of deletion alertview and do thigns with it
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(alertView.tag == kCannotDeleteAlertTag)
//    {
//        [self editingClips:NO];
//        return;
//    }
//
//    else if(alertView.tag == kDeleteAlertTag)
//    {
//        if (buttonIndex == 0)
//        {
//            NSMutableArray *tempArr = [self.tagsToDisplay mutableCopy];
//            // Ok, delete the tags and also sender the information to the server
//            for (NSDictionary *dict in [selectedCellRows allValues] ) {
//
//                NSMutableDictionary *tag = [dict objectForKey:@"tag"];
//
//                // if current playing tag is deleted, stop the video
//                if ([[tag objectForKey:@"id"] isEqual: [currentPlayingTag objectForKey:@"id"]]) {
//                    //[self.videoPlayer pause];
//                }
//
//                //tempArr will used to update displayTags array; if you remove obj directly from displayTags array , [self tagAtIndexPath:indexPath] will have error
//                [tempArr removeObject:tag];
//
//                //remove  the tag marker
//                //                [[[globals.TAG_MARKER_OBJ_DICT objectForKey:[NSString stringWithFormat:@"%f",[[tag objectForKey:@"id"] doubleValue] ]] markerView] removeFromSuperview];
//                //
//                //                if (!globals.HAS_MIN ||(globals.HAS_MIN && !globals.eventExistsOnServer)){
//                //
//                //                    //if this tag was created in offline mode, just delete it
//                //                   if ([[tag objectForKey:@"local"] intValue] == 1){
//                //
//                //                        //delete the tag from the global dictionary of tags
//                //
//                //                        [globals.CURRENT_EVENT_THUMBNAILS removeObjectForKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
//                //
//                //                    }else {
//                //                     //if the tag was created in online mode, modified the tag dictionary; once connecting with the server, send the deleting request to the server and it will be deleted from the server
//                //                        [tag setObject:@"3" forKey:@"type"];
//                //                        [tag setObject:@"1" forKey:@"deleted"];
//                //                        [tag setObject:@"1" forKey:@"edited"];
//                //                        [globals.CURRENT_EVENT_THUMBNAILS setObject:tag forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
//                //                        //Remove image
//                //                        NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[tag objectForKey:@"id"]];
//                //                        NSString *imagePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
//                //                        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
//                //                    }
//                //
//                //                }else{
//                //                    //current absolute time in seconds
//                //                    double currentSystemTime = CACurrentMediaTime();
//                //                    //now we send the deleted tag information throught the queue to the server
//                //                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"1",@"delete",globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",[tag objectForKey:@"id"],@"id", nil];
//                //
//                //                    //Remove from global tag array
//                //                    [globals.CURRENT_EVENT_THUMBNAILS removeObjectForKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
//                //
//                //                    NSError *error;
//                //                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
//                //                    NSString *jsonString;
//                //                    if (! jsonData) {
//                //
//                //                    } else {
//                //                        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                //                        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                //                    }
//                //
//                //
//                //                    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
//                //
//                //                    //callback method and parent view controller reference for the appqueue
//                //                    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
//                //                    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
//                //                    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//                //                    [globals.APP_QUEUE enqueue:url dict:instObj];
//                //                }
//
//            }
//
//            //in offline mode, save all the modified tags locally
//            //            if (!globals.HAS_MIN ||(globals.HAS_MIN && !globals.eventExistsOnServer)){
//            //
//            //                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//            //                                                         (unsigned long)NULL), ^(void) {
//            ////                    NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
//            //
//            ////                    [globals.CURRENT_EVENT_THUMBNAILS writeToFile:filePath atomically:YES];
//            //
//            //                });
//            //            }
//
//            //update the array of tags which will be used to display
//            [self.tagsToDisplay removeAllObjects];
//            self.tagsToDisplay = [tempArr mutableCopy];
//            [selectedCellRows removeAllObjects];
//            [_tableViewController reloadData];
//            //            globals.THUMBNAIL_COUNT_REF_ARRAY = self.tagsToDisplay;
//        }
//        else if (buttonIndex == 1)
//        {
//            // No, cancel the action to delete tags
//        }
//        [self editingClips:NO];
//
//    }
//    [CustomAlertView removeAlert:alertView];
//    //    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alertView];
//
//}

//exit from the editing mode
-(void)cancelEditingCells
{
    if ([selectedCellRows count]) {//uncheck all the check box and clear the selectedCellRows array
        [selectedCellRows removeAllObjects];
    }else{ // if not check box is selected, press cancel button will go back to normal mode
        _tableViewController.isEditable = FALSE;
    }
    [_tableViewController reloadData];
    
}

//save the rating info
-(void)sendRating:(id)sender
{
    
    RatingInput * cmtRateField = (RatingInput *) sender;
    //NSString *ratingValue = [NSString stringWithFormat:@"%d",cmtRateField.rating];
    
    
    
    selectedTag.rating = cmtRateField.rating;
    [_tableViewController reloadData];
    
    
    
    //if ([[selectedTag objectForKey:@"bookmark"]integerValue] ==1) {
        //        [[globals.BOOKMARK_TAGS objectForKey:[selectedTag objectForKey:@"event"]]  setObject:selectedTag forKey:[NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]]];
        //        [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    //}
    
    //    if (globals.HAS_MIN && globals.eventExistsOnServer){
    //        //current absolute time in seconds
    //        double currentSystemTime = CACurrentMediaTime();
    //
    //        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:ratingValue,@"rating",globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",userId,@"user",tagId,@"id", nil];
    //
    //        NSError *error;
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    //        NSString *jsonString;
    //        if (! jsonData) {
    //
    //        } else {
    //            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        }
    //
    //
    //        NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    //
    //        NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
    //        NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
    //        NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //        [globals.APP_QUEUE enqueue:url dict:instObj];
    //    }else{
    //         [selectedTag setObject:@"1" forKey:@"edited"];
    //    }
    
    //handle offline mode, save comment information in local storage
    //    [globals.CURRENT_EVENT_THUMBNAILS setObject:selectedTag forKey:[NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]]];
    
    //    ListViewCell *cell = (ListViewCell*)[myTableView cellForRowAtIndexPath:wasPlayingIndexPath];
    //    //if the user is scrolling the tableview, cell will be nil value
    //    if (!cell) {
    //        return;
    //    }
    //    thumbRatingArray = [[NSMutableArray alloc]initWithObjects:cell.tagRatingOne,cell.tagRatingTwo,cell.tagRatingThree,cell.tagRatingFour,cell.tagRatingFive,nil];
    
    //    for (int i=0; i<ratingButtonIndex+1; i++) {
    //        UIView *ratingView = [thumbRatingArray objectAtIndex:i];
    //        [ratingView setHidden:FALSE];
    //    }
    //    //have to hide the other rating views;otherwise, rating stars will randomly display in thumbnails
    //    for (int i = ratingButtonIndex+1; i<5; i++) {
    //        UIView *ratingView = [thumbRatingArray objectAtIndex:i];
    //        [ratingView setHidden:TRUE];
    //    }
    
}

//save comment
-(void)sendComment
{
    
    
    NSString *comment;
    //Richard
    
    [commentingField.textField resignFirstResponder];
    comment = commentingField.textField.text;
    
    // End Richard
    //    [commentTextView resignFirstResponder];
    //
    //    if (commentTextView.text) {
    //        comment = commentTextView.text;
    //    }else{
    //        comment = @"";
    //    }
    
    selectedTag.comment = comment;
    
    //    if ([[selectedTag objectForKey:@"bookmark"]integerValue] ==1) {
    //        [[globals.BOOKMARK_TAGS objectForKey:[selectedTag objectForKey:@"event"]] setObject:selectedTag forKey:[NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]]];
    //        [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    //    }
    
    //    if (globals.HAS_MIN && globals.eventExistsOnServer) {
    //        //current absolute time in seconds
    //        double currentSystemTime = CACurrentMediaTime();
    //        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:comment,@"comment",globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",userId,@"user",tagId,@"id", nil];
    //
    //        NSError *error;
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    //        NSString *jsonString;
    //        if (! jsonData) {
    //
    //        } else {
    //            jsonString  = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //            jsonString  = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        }
    //        NSString *url           = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    //        NSArray *objects        = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
    //        NSArray *keys           = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
    //        NSDictionary *instObj   = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //        [globals.APP_QUEUE enqueue:url dict:instObj];
    //    }else{
    //        [selectedTag setObject:@"1" forKey:@"edited"];
    //    }
    //
    //    //handle offline mode, save comment information in local storage
    //    [globals.CURRENT_EVENT_THUMBNAILS setObject:selectedTag forKey:[NSString stringWithFormat:@"%@",[selectedTag objectForKey:@"id"]]];
    //
    //    for (CustomButton *button in ratingButtonArray) {
    //        [button setImage:[UIImage imageNamed:@"rating_unselected.png"] forState:UIControlStateNormal];
    //        [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    //        [button setAccessibilityLabel:@"0"];
    //    }
    
    //    commentTextView.text = @"";
    //    [savedMsgLabel setHidden:FALSE];
    
}

//callback function when receive new bookmark tag
-(void)tagModCallback:(id)newTagInfo
{
    //
    //    if (newTagInfo!=NULL) {
    //        //the updated tag
    //        newTagInfoDict = [[NSMutableDictionary alloc]initWithDictionary:newTagInfo];
    //
    //        if ([newTagInfo objectForKey:@"vidurl"]) {
    //
    //            [newTagInfoDict setObject:@"1" forKey:@"bookmark"];
    //            if ([[newTagInfoDict objectForKey:@"event"] isEqualToString:globals.EVENT_NAME])
    //                [globals.CURRENT_EVENT_THUMBNAILS setObject:newTagInfoDict forKey:[NSString stringWithFormat:@"%@",[newTagInfo objectForKey:@"id"]]];
    //             NSURL *url = [[NSURL alloc]initWithString:[[newTagInfo objectForKey:@"vidurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //            //[bookmarkQueue insertObject:newTagInfoDict atIndex:0];
    //
    //            self.isTagModRequest = FALSE;
    //            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    //
    //            NSURLConnection *conn = [[NSURLConnection alloc] init];
    //            (void)[conn initWithRequest:request delegate:self];
    //
    //        } else {
    //
    //            //is no video url got from server, pop up alert view
    //            if (!noVideoURLAlert) {
    //                noVideoURLAlert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:@"Could not download clip from the server. Please make sure the server is up to date." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //                [noVideoURLAlert show];
    ////                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:noVideoURLAlert];
    //            }
    //
    //            if (globals.BOOKMARK_QUEUE.count > 0) {
    //                NSDictionary *tagInfoDict = [globals.BOOKMARK_QUEUE objectAtIndex:0];
    //                //[globals.BOOKMARK_QUEUE_FAILED addObject:tagInfoDict];
    //                NSDictionary *currentBookmark = [tagInfoDict objectForKey:@"tag"];
    //                [[downloadingTagsDict objectForKey:[currentBookmark objectForKey:@"event"]] removeObject:[currentBookmark objectForKey:@"id"]];
    //
    //                [globals.BOOKMARK_QUEUE removeObjectAtIndex:0];
    //            }
    //
    //            globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS--;
    //
    //            if (globals.BOOKMARK_QUEUE.count > 0) {
    //                [self sendTheNextRequest];
    //            }else if ([aCopyOfUnfinishedTags count] > 0){
    //                [self sendOneRequest];
    //            }
    //
    ////            [globals.BOOKMARK_QUEUE_FAILED addObject:[globals.BOOKMARK_QUEUE_KEYS objectAtIndex:0]];
    ////            if (globals.BOOKMARK_QUEUE_KEYS.count > 0) {
    ////                 [globals.BOOKMARK_QUEUE_KEYS removeObjectAtIndex:0];
    ////            }
    ////            [globals.BOOKMARK_QUEUE_KEYS writeToURL:[NSURL URLWithString:globals.BOOKMARK_QUEUE_PATH] atomically:YES];
    ////            if ([globals.BOOKMARK_QUEUE_KEYS count] > 0 || [globals.BOOKMARK_QUEUE count] >0){
    ////                [self sendTheNextRequest];
    ////            }
    //        }
    //    }
}

/*********
 the following NSURLConnection protocal methods are used for receiving bookmark response
 *******/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    //    [_responseData appendData:data];
    //    if(_responseData.length > 10000000 && !self.isTagModRequest){
    //
    //        NSError* error;
    //        if(![[NSFileManager defaultManager] fileExistsAtPath:globals.BOOKMARK_VIDEO_PATH])
    //        {
    //            [fileManager createDirectoryAtPath:globals.BOOKMARK_VIDEO_PATH withIntermediateDirectories:YES attributes:nil error:&error];
    //		}
    //        //NSURL *url = [[NSURL alloc]initWithString:[[bookmarkQueue objectAtIndex:0] objectForKey:@"vidurl"]];
    //        NSDictionary *currentBookmark = newTagInfoDict;
    //        NSString *videoNameStr = [[currentBookmark objectForKey:@"event"] stringByAppendingFormat:@"_%@",[[currentBookmark objectForKey:@"vidurl"] lastPathComponent]];
    //        NSString *videoName;
    //        videoName = [NSString stringWithFormat:@"test%@",videoNameStr];
    //        //add video to directory
    //        NSString *videoFilePath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",videoName]];
    //        NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:videoFilePath];
    //        if(output == nil) {
    //            [[NSFileManager defaultManager] createFileAtPath:videoFilePath contents:nil attributes:nil];
    //            output = [NSFileHandle fileHandleForWritingAtPath:videoFilePath];
    //        } else {
    //            [output seekToEndOfFile];
    //        }
    //
    //		//[output truncateFileAtOffset:[output seekToEndOfFile]]; //setting aFileHandle to write at the end of the file
    //
    //		[output writeData:_responseData]; //actually write the data
    //
    //        //        unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:videoFilePath error:nil] fileSize];
    //        //        if (fileSize){
    //        //            ////////NSLog(@"Length of file: %llu", fileSize);
    //        //        }
    //		_responseData = nil;
    //		_responseData = [[NSMutableData alloc] init];
    //	}
    //    ////////NSLog(@"file length: %i",[_responseData length]);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //    // The request is complete and data has been received
    //    // You can parse the stuff in your instance variable now
    //    if (!_responseData) {
    //        return;
    //    }
    //
    //    id json;
    //    if(self.isTagModRequest)
    //    {
    //        json = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    //        if ([[json objectForKey:@"success"]integerValue] == 0) {
    //            //TODO:if the current event was downloaded from other encoder, could not generate bookmark from current servr and no error msg received from current encoder
    //            if ([json objectForKey:@"msg"]) {
    //                CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:[NSString stringWithFormat:@"Download clips failed. %@",[json objectForKey:@"msg"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //                [alert show];
    ////                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
    //            }
    //
    //            //tagmod failed, remove the old request
    //            if (globals.BOOKMARK_QUEUE.count > 0) {
    //                NSDictionary *tagInfoDict = [globals.BOOKMARK_QUEUE objectAtIndex:0];
    //                //[globals.BOOKMARK_QUEUE_FAILED addObject:tagInfoDict];
    //                NSDictionary *currentBookmark = [tagInfoDict objectForKey:@"tag"];
    //                [[downloadingTagsDict objectForKey:[currentBookmark objectForKey:@"event"]] removeObject:[currentBookmark objectForKey:@"id"]];
    //                [globals.BOOKMARK_QUEUE removeObjectAtIndex:0];
    //            }
    //
    //            globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS--;
    //
    //            //if the queue is not empty, send the next request
    //            if (globals.BOOKMARK_QUEUE.count > 0) {
    //                [self sendTheNextRequest];
    //            }else if ([aCopyOfUnfinishedTags count] > 0){
    //                [self sendOneRequest];
    //            }
    //
    //
    //        }else{
    //            [self tagModCallback:json];
    //        }
    //    } else {
    //        NSDictionary *currentBookmark = newTagInfoDict;
    //        NSError* error;
    //
    //        if(![[NSFileManager defaultManager] fileExistsAtPath:globals.BOOKMARK_VIDEO_PATH])
    //        {
    //            [fileManager createDirectoryAtPath:globals.BOOKMARK_VIDEO_PATH withIntermediateDirectories:YES attributes:nil error:&error];
    //        }
    //        //add video to directory
    //       // NSURL *url = [[NSURL alloc]initWithString:[[currentBookmark objectForKey:@"vidurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //        NSString *videoNameStr = [[currentBookmark objectForKey:@"event"] stringByAppendingFormat:@"_%@",[[currentBookmark objectForKey:@"vidurl"] lastPathComponent]];
    //        NSString *videoName;
    //        videoName = [NSString stringWithFormat:@"test%@",videoNameStr];
    //
    //        NSString *videoFilePath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",videoName]];
    //        NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:videoFilePath];
    //        if(output == nil) {
    //            [[NSFileManager defaultManager] createFileAtPath:videoFilePath contents:nil attributes:nil];
    //            output = [NSFileHandle fileHandleForWritingAtPath:videoFilePath];
    //        } else {
    //            [output seekToEndOfFile];
    //        }
    //        //[output truncateFileAtOffset:[output seekToEndOfFile]]; //setting aFileHandle to write at the end of the file
    //
    //        [output writeData:_responseData]; //actually write the data
    //
    //        NSString *finalVideoPath = [globals.BOOKMARK_VIDEO_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",videoNameStr]];
    //        //globals.TAGS_DOWNLOADED_FROM_SERVER is an array of dictionaries.Each dictionary object has keys:@"tag",@"testPath",@"videoPath".
    //        //@"tag": tag dictioanrary current downloaded
    //        //@"testPath" is the temporary path for saving the downloaded full rez or low quality video
    //        //@"videoPath" is the final path saving the bookmark video
    //        if (!globals.TAGS_DOWNLOADED_FROM_SERVER) {
    //            globals.TAGS_DOWNLOADED_FROM_SERVER = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:currentBookmark,@"tag",videoFilePath,@"testPath",finalVideoPath,@"videoPath", nil]];
    //        }else{
    //            [globals.TAGS_DOWNLOADED_FROM_SERVER addObject:[NSDictionary dictionaryWithObjectsAndKeys:currentBookmark,@"tag",videoFilePath,@"testPath",finalVideoPath,@"videoPath", nil]];
    //        }
    //        //NSLog(@"added to globals.TAGS_DOWNLOADED_FROM_SERVER");
    //        if (globals.BOOKMARK_QUEUE.count > 0) {
    //            [globals.BOOKMARK_QUEUE removeObjectAtIndex:0];
    //        }
    //
    //         if (globals.BOOKMARK_QUEUE.count > 0) {
    //             [self sendTheNextRequest];
    //         }else if ([aCopyOfUnfinishedTags count] > 0){
    //             [self sendOneRequest];
    //         }
    //
    ////        if (!globals.NEED_RECREATE_BOOKMARK_VIDEO) {
    ////            [self updateTableView];
    ////        }else{
    //        if (globals.TAGS_DOWNLOADED_FROM_SERVER.count == 1) {
    //            //NSLog(@"count == 1; recreate video clip.");
    //            [self makeLocalBookmark];
    //        }
    //
    ////        }
    //
    //        //make sure all bookmark tags have processed before the process bar in bookmark view "done!"
    //        _responseData = nil;
    //
    //  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //    _responseData = nil;
    //
    //    if ([globals.BOOKMARK_QUEUE count] > 0){
    //
    //        NSDictionary *tagInfoDict = [globals.BOOKMARK_QUEUE objectAtIndex:0];
    //        if (!failedBookmarkTagsArr || ![failedBookmarkTagsArr containsObject:tagInfoDict]) {
    //            //If the request failed the first time, resend request
    //            if (!failedBookmarkTagsArr) {
    //                failedBookmarkTagsArr = [NSMutableArray arrayWithObject:tagInfoDict];
    //            }else{
    //                [failedBookmarkTagsArr addObject:tagInfoDict];
    //            }
    //
    //            [self sendTheNextRequest];
    //        }else{
    //            //If the request failed twice, added it to globals.BOOKMARK_QUEUE_FAILED and remove it from globals.BOOKMARK_QUEUE, then send the next request
    //
    //            [globals.BOOKMARK_QUEUE_FAILED addObject:tagInfoDict];
    //            NSDictionary *currentBookmark = [tagInfoDict objectForKey:@"tag"];
    //            [[downloadingTagsDict objectForKey:[currentBookmark objectForKey:@"event"]] removeObject:[currentBookmark objectForKey:@"id"]];
    //            [globals.BOOKMARK_QUEUE removeObjectAtIndex:0];
    //
    //            globals.NUMBER_OF_BOOKMARK_TAG_TO_PROCESS--;
    //            //if the queue is not empty, send the next request
    //            if (globals.BOOKMARK_QUEUE.count > 0) {
    //                [self sendTheNextRequest];
    //            }else if ([aCopyOfUnfinishedTags count] > 0){
    //                [self sendOneRequest];
    //            }
    //        }
    //    }
}

//update list view table view and update globals varibals
//-(void)updateTableView
//{
//    if(globals.TAGS_DOWNLOADED_FROM_SERVER.count < 1) {
//        return;
//    }
//
//    NSDictionary *currentBookmark = [[globals.TAGS_DOWNLOADED_FROM_SERVER objectAtIndex:0]objectForKey:@"tag"];//newTagInfoDict;
//    if(![receivedTagArr containsObject:[currentBookmark objectForKey:@"id"]]){
//        globals.NUMBER_OF_BOOKMARK_TAG_RECEIVED++;
//        globals.RECEIVED_ONE_BOOKMARK_VIDEO = TRUE;
//        [receivedTagArr addObject:[currentBookmark objectForKey:@"id"]];
//    }
//    [[downloadingTagsDict objectForKey:[currentBookmark objectForKey:@"event"]] removeObject:[currentBookmark objectForKey:@"id"]];
//
//    if (![[globals.BOOKMARK_TAGS allKeys] containsObject:[currentBookmark objectForKey:@"event"]]) {
//        [globals.BOOKMARK_TAGS setObject:[[NSMutableDictionary alloc]initWithObjects:[[NSArray alloc]initWithObjects:currentBookmark, nil] forKeys:[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%@",[currentBookmark objectForKey:@"id"]], nil]] forKey:[currentBookmark objectForKey:@"event"]];
//    } else {
//        [[globals.BOOKMARK_TAGS objectForKey:[currentBookmark objectForKey:@"event"]] setObject:currentBookmark forKey:[NSString stringWithFormat:@"%@",[currentBookmark objectForKey:@"id"]]];
//    }
//    [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
//
//    //NSLog(@"updateTableView, reload data");
//    //[myTableView reloadData];
//
//    NSString *orderedBookmarkPlist=[globals.BOOKMARK_PATH stringByAppendingPathComponent:@"orderedBookmarks.plist"];
//
//    if([fileManager fileExistsAtPath:orderedBookmarkPlist isDirectory:false])
//    {
//        NSMutableArray *t = [[NSMutableArray alloc] initWithContentsOfFile:orderedBookmarkPlist]; // temp array for the ordered list of bookmarks
//        [t insertObject:currentBookmark atIndex:0];//add the new bookmark to the top of the list
//        [t writeToFile:orderedBookmarkPlist atomically:TRUE];
//    }
//
//    if (globals.TAGS_DOWNLOADED_FROM_SERVER.count > 0) {
//        [globals.TAGS_DOWNLOADED_FROM_SERVER removeObjectAtIndex:0];
//    }
//
//     if (globals.TAGS_DOWNLOADED_FROM_SERVER.count > 0) {
//         //shouldRecreateNextTag = TRUE;
//         //NSLog(@"more tag videos being downloaded");
//         [self makeLocalBookmark];
//     }
//}


//initialise the video control bar which is right under the video player
-(void)initialVideoControlBar
{
    //    self.videoControlBar = [[UIView alloc]initWithFrame:CGRectMake(2,  SMALL_MEDIA_PLAYER_HEIGHT + 114, COMMENTBOX_WIDTH, 30)];
    //    [self.videoControlBar setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    //    [self.videoControlBar setAlpha:0.6];
    //    [self.videoControlBar setUserInteractionEnabled:TRUE];
    //    [self.view addSubview:videoControlBar];
    //
    //    slowMoButton =  [CustomButton buttonWithType:UIButtonTypeCustom];
    //    [slowMoButton setFrame:CGRectMake(43,self.videoControlBar.frame.origin.y, LITTLE_ICON_DIMENSIONS+10, LITTLE_ICON_DIMENSIONS)];
    //    [slowMoButton setContentMode:UIViewContentModeScaleAspectFill];
    //    NSString *imageName = (globals.PLAYBACK_SPEED == 1.0f)?@"normalsp.png" :@"slowmo.png";
    //    [slowMoButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    //    //self.videoPlayer.avPlayer.rate = globals.PLAYBACK_SPEED;
    //    //if (globals.PLAYBACK_SPEED > 0) {
    //    //    [self.videoPlayer setRate:globals.PLAYBACK_SPEED];
    //    //}else{
    //        [self.videoPlayer play];
    //    //}
    //    [slowMoButton addTarget:self action:@selector(slowMoController:) forControlEvents:UIControlEventTouchUpInside];
    //    [slowMoButton setAccessibilityLabel:@"normal"];
    //    [slowMoButton setHidden:TRUE];
    //    [self.view insertSubview:slowMoButton aboveSubview:videoControlBar];
    //
    //    //add go back button
    //    currentSeekBackButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    currentSeekBackButton = [[CustomButton alloc]initWithFrame:CGRectMake(slowMoButton.frame.origin.x + slowMoButton.frame.size.width + 10, slowMoButton.frame.origin.y, slowMoButton.frame.size.height, slowMoButton.frame.size.height)];
    //    [currentSeekBackButton setContentMode:UIViewContentModeScaleAspectFill];
    //    UIImage *backButtonImage;
    //    if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
    //        backButtonImage = [UIImage imageNamed:@"seekbackquartersec.png"];
    //    }else if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
    //        backButtonImage = [UIImage imageNamed:@"seekbackonesec.png"];
    //    }else{
    //        backButtonImage = [UIImage imageNamed:@"seekbackfivesecs.png"];
    //        globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
    //    }
    //    [currentSeekBackButton setImage:backButtonImage forState:UIControlStateNormal];
    //    [currentSeekBackButton addTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
    //    //[currentSeekBackButton addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    //    [currentSeekBackButton setHidden:TRUE];
    //    [self.view insertSubview:currentSeekBackButton aboveSubview:videoControlBar];
    //    [currentSeekBackButton setHidden:TRUE];
    //
    //    //hide them for current build 1.1.7
    //    UILongPressGestureRecognizer *seekBackLongpressgesture = [[UILongPressGestureRecognizer alloc]
    //                                                              initWithTarget:self action:@selector(handleLongPress:)];
    //    seekBackLongpressgesture.minimumPressDuration = 0.5; //seconds
    //    seekBackLongpressgesture.delegate = self;
    //    [currentSeekBackButton addGestureRecognizer:seekBackLongpressgesture];
    //
    //    //uiview contains three seek back modes: go back 5s, 1s, 0.25s
    //    seekBackControlView = [[UIView alloc]initWithFrame:CGRectMake(currentSeekBackButton.frame.origin.x,315,LITTLE_ICON_DIMENSIONS,4.5*currentSeekBackButton.frame.size.height)];
    //    [seekBackControlView setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.3]];
    //    seekBackControlView.hidden = TRUE;
    //    [self.view addSubview:seekBackControlView];
    //
    //    //go back 0.25s
    //    CustomButton *backQuarterSecButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    [backQuarterSecButton setFrame:CGRectMake(0, 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    //    [backQuarterSecButton setContentMode:UIViewContentModeScaleAspectFill];
    //    [backQuarterSecButton setImage:[UIImage imageNamed:@"seekbackquartersec.png"] forState:UIControlStateNormal];
    //    [backQuarterSecButton addTarget:self action:@selector(seekBackQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
    //    [backQuarterSecButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    //    [seekBackControlView addSubview:backQuarterSecButton];
    //
    //    //go back 1 s
    //    CustomButton *backOneSecButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    [backOneSecButton setFrame:CGRectMake(0, backQuarterSecButton.frame.origin.y + backQuarterSecButton.frame.size.height + 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    //    [backOneSecButton setContentMode:UIViewContentModeScaleAspectFill];
    //    [backOneSecButton setImage:[UIImage imageNamed:@"seekbackonesec.png"] forState:UIControlStateNormal];
    //    [backOneSecButton addTarget:self action:@selector(seekBackOneSecond:) forControlEvents:UIControlEventTouchUpInside];
    //    [backOneSecButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    //    [seekBackControlView addSubview:backOneSecButton];
    //
    //    //go back 5 s
    //    CustomButton *backFiveSecsButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    [backFiveSecsButton setFrame:CGRectMake(0, backOneSecButton.frame.origin.y + backOneSecButton.frame.size.height + 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    //    [backFiveSecsButton setContentMode:UIViewContentModeScaleAspectFill];
    //    [backFiveSecsButton setImage:[UIImage imageNamed:@"seekbackfivesecs.png"] forState:UIControlStateNormal];
    //    [backFiveSecsButton addTarget:self action:@selector(seekBackFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
    //    [backFiveSecsButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    //    [seekBackControlView addSubview:backFiveSecsButton];
    //
    //
    //    //add go forward button
    //    currentSeekForwardButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    currentSeekForwardButton = [[CustomButton alloc]initWithFrame:CGRectMake(COMMENTBOX_WIDTH -100, slowMoButton.frame.origin.y, slowMoButton.frame.size.height, slowMoButton.frame.size.height)];
    //    [currentSeekForwardButton setContentMode:UIViewContentModeScaleAspectFill];
    //    UIImage *forwardButtonImage;
    //    if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
    //        forwardButtonImage = [UIImage imageNamed:@"seekforwardquartersec.png"];
    //        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardQuarterSecond:);
    //    }else if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
    //        forwardButtonImage = [UIImage imageNamed:@"seekforwardonesec.png"];
    //        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardOneSecond:);
    //    }else{
    //        forwardButtonImage = [UIImage imageNamed:@"seekforwardfivesecs.png"];
    //        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
    //    }
    //
    //    [currentSeekForwardButton setImage:forwardButtonImage forState:UIControlStateNormal];
    //    [currentSeekForwardButton addTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
    //    //[currentSeekForwardButton addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    //    [currentSeekForwardButton setHidden:TRUE];
    //    [self.view insertSubview:currentSeekForwardButton aboveSubview:videoControlBar];
    //    [currentSeekForwardButton setHidden:TRUE];
    //
    //    UILongPressGestureRecognizer *seekForwardLongpressgesture = [[UILongPressGestureRecognizer alloc]
    //                                                                 initWithTarget:self action:@selector(handleLongPress:)];
    //    seekForwardLongpressgesture.minimumPressDuration = 0.5; //seconds
    //    seekForwardLongpressgesture.delegate = self;
    //    [currentSeekForwardButton addGestureRecognizer:seekForwardLongpressgesture];
    //
    //
    //    //uiview contains three seek back modes: go back 5s, 1s, 0.25s
    //    seekForwardControlView = [[UIView alloc]initWithFrame:CGRectMake(currentSeekForwardButton.frame.origin.x , 315 ,seekBackControlView.frame.size.width,seekBackControlView.frame.size.height)];
    //    [seekForwardControlView setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.3]];
    //    seekForwardControlView.hidden = TRUE;
    //    [self.view addSubview:seekForwardControlView];
    //
    //    //go back 0.25s
    //    CustomButton *forwardQuarterSecButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    [forwardQuarterSecButton setFrame:CGRectMake(0, 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    //    [forwardQuarterSecButton setContentMode:UIViewContentModeScaleAspectFill];
    //    [forwardQuarterSecButton setImage:[UIImage imageNamed:@"seekforwardquartersec.png"] forState:UIControlStateNormal];
    //    [forwardQuarterSecButton addTarget:self action:@selector(seekForwardQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
    //    [forwardQuarterSecButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    //    [seekForwardControlView addSubview:forwardQuarterSecButton];
    //
    //    //go back 1 s
    //    CustomButton *forwardOneSecButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    [forwardOneSecButton setFrame:CGRectMake(0, backQuarterSecButton.frame.origin.y + backQuarterSecButton.frame.size.height + 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    //    [forwardOneSecButton setContentMode:UIViewContentModeScaleAspectFill];
    //    [forwardOneSecButton setImage:[UIImage imageNamed:@"seekforwardonesec.png"] forState:UIControlStateNormal];
    //    [forwardOneSecButton addTarget:self action:@selector(seekForwardOneSecond:) forControlEvents:UIControlEventTouchUpInside];
    //    [forwardOneSecButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    //    [seekForwardControlView addSubview:forwardOneSecButton];
    //
    //    //go back 5 s
    //    CustomButton *forwardFiveSecsButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    [forwardFiveSecsButton setFrame:CGRectMake(0, backOneSecButton.frame.origin.y + backOneSecButton.frame.size.height + 10, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    //    [forwardFiveSecsButton setContentMode:UIViewContentModeScaleAspectFill];
    //    [forwardFiveSecsButton setImage:[UIImage imageNamed:@"seekforwardfivesecs.png"] forState:UIControlStateNormal];
    //    [forwardFiveSecsButton addTarget:self action:@selector(seekForwardFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
    //    [forwardFiveSecsButton addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
    //    [seekForwardControlView addSubview:forwardFiveSecsButton];
    //
    //
    //    startRangeModifierButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    startRangeModifierButton = [[CustomButton alloc]initWithFrame:CGRectMake(10,slowMoButton.frame.origin.y, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    //    [startRangeModifierButton setContentMode:UIViewContentModeScaleAspectFill];
    //    [startRangeModifierButton setImage:[UIImage imageNamed:@"extendstartsec.png"] forState:UIControlStateNormal];
    //    [startRangeModifierButton addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    //    [startRangeModifierButton setHidden:TRUE];
    //    [self.view insertSubview:startRangeModifierButton aboveSubview:videoControlBar];
    //    [startRangeModifierButton setAccessibilityValue:@"extend"];
    //
    //
    //
    //
    //    UILongPressGestureRecognizer *modifiedTagDurationByStartTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
    //                                                                                    initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
    //    modifiedTagDurationByStartTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
    //    modifiedTagDurationByStartTimeLongpressgesture.delegate = self;
    //    [startRangeModifierButton addGestureRecognizer:modifiedTagDurationByStartTimeLongpressgesture];
    //
    //
    //    endRangeModifierButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    endRangeModifierButton = [[CustomButton alloc]initWithFrame:CGRectMake(COMMENTBOX_WIDTH -35,startRangeModifierButton.frame.origin.y, LITTLE_ICON_DIMENSIONS, LITTLE_ICON_DIMENSIONS)];
    //    [endRangeModifierButton setContentMode:UIViewContentModeScaleAspectFit];
    //    [endRangeModifierButton setImage:[UIImage imageNamed:@"extendendsec.png"] forState:UIControlStateNormal];
    //    [endRangeModifierButton addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    //    [endRangeModifierButton setHidden:TRUE];
    //    [self.view insertSubview:endRangeModifierButton aboveSubview:videoControlBar];
    //    [endRangeModifierButton setAccessibilityValue:@"extend"];
    //
    //    UILongPressGestureRecognizer *modifiedTagDurationByEndTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
    //                                                                                  initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
    //    modifiedTagDurationByEndTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
    //    modifiedTagDurationByEndTimeLongpressgesture.delegate = self;
    //    [endRangeModifierButton addGestureRecognizer:modifiedTagDurationByEndTimeLongpressgesture];
    //
    //    //Ricahrd
    //    [startRangeModifierButton setFrame:CGRectMake(10,
    //                                                  0,
    //                                                  startRangeModifierButton.frame.size.width,
    //                                                  startRangeModifierButton.frame.size.height)];
    //    [endRangeModifierButton setFrame:CGRectMake(newVideoControlBar.view.frame.size.width-10,
    //                                                0,
    //                                                endRangeModifierButton.frame.size.width,
    //                                                endRangeModifierButton.frame.size.height)];
    //
    //    [newVideoControlBar.view addSubview:startRangeModifierButton];
    //    [newVideoControlBar.view addSubview:endRangeModifierButton];
    //    // End Richard
    //
    //    tagEventName = [[UILabel alloc] initWithFrame:CGRectMake(COMMENTBOX_WIDTH/2.0 -50, 0, 150, 30)];
    //    [tagEventName setBackgroundColor:[UIColor clearColor]];
    //    tagEventName.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    //    tagEventName.layer.borderWidth = 1;
    //    [tagEventName setText:@"Event Name"];
    //    [tagEventName setTextColor:PRIMARY_APP_COLOR];
    //    [tagEventName setTextAlignment:NSTextAlignmentCenter];
    //    [tagEventName setAlpha:1.0];
    //    [tagEventName setHidden:TRUE];
    //    [self.videoControlBar addSubview:tagEventName];
}

//swipe the screen to seek the video back/forward 5secs/1sec/0.25s
-(void)detectSwipe:(UISwipeGestureRecognizer *)gestureRecognizer{
    switch (gestureRecognizer.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            if (!fullScreenMode) {
                [_currentSeekBackButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }else{
                [_currentSeekBackButtoninFullScreen sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if (!fullScreenMode) {
                [_currentSeekForwardButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }else{
                [_currentSeekForwardButtoninFullScreen sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            break;
        default:
            break;
    }
}

//press the button for more than 2 seconds, then pop up the seek back/forward control view
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.view isEqual: _currentSeekBackButton]) {
        _seekBackControlView.hidden = FALSE;
    }else if ([gestureRecognizer.view isEqual: _currentSeekForwardButton]){
        _seekBackControlView.hidden = FALSE;
    }else if([gestureRecognizer.view isEqual:_currentSeekBackButtoninFullScreen]){
        _seekBackControlViewinFullScreen
        .hidden = FALSE;
    }else if([gestureRecognizer.view isEqual:_currentSeekForwardButtoninFullScreen]){
        _seekForwardControlViewinFullScreen.hidden = FALSE;
    }
}

#pragma mark - Seek
//hide the seek back/forward control view in both normal screen or full screen
-(void)hideSeekControlView:(id)sender{
    
    _seekBackControlView.hidden = TRUE;
    _seekBackControlView.hidden = TRUE;
    _seekBackControlViewinFullScreen.hidden = TRUE;
    _seekForwardControlViewinFullScreen.hidden = TRUE;
    
}


//swipe the pop up the seek back/forward control view
-(void)swipeOutSeekControlView:(CustomButton*)button{
    
    
    if ([button isEqual:_currentSeekBackButton]) {
        _seekBackControlView.hidden = FALSE;
    }else if ([button isEqual:_currentSeekForwardButton]){
        _seekBackControlView.hidden = FALSE;
    }else if([button isEqual:_currentSeekBackButtoninFullScreen]){
        _seekBackControlViewinFullScreen.hidden = FALSE;
    }else if([button isEqual:_currentSeekForwardButtoninFullScreen]){
        _seekForwardControlViewinFullScreen.hidden = FALSE;
    }
    
}


#pragma mark - Duration Mod
//uilongpressgestureRecongnizer is a continous event recognizer.
/*
 The gesture begins (UIGestureRecognizerStateBegan) when the number of allowable fingers (numberOfTouchesRequired) have been pressed for the specified period (minimumPressDuration) and the touches do not move beyond the allowable range of movement (allowableMovement).
 The gesture recognizer transitions to the Change state whenever a finger moves, and it ends (UIGestureRecognizerStateEnded) when any of the fingers are lifted.
 */
-(void)changeDurationModifierButtonIcon:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"begain");
        CustomButton *button = (CustomButton*)gestureRecognizer.view;
        if ([button isEqual:startRangeModifierButton] || [button isEqual:startRangeModifierButtonFullScreen]) {
            if ([button.accessibilityValue isEqualToString:@"extend"]) {
                [button setImage:[UIImage imageNamed:@"subtractstartsec"] forState:UIControlStateNormal];
                [button setAccessibilityValue:@"subtract"];
            }else{
                [button setImage:[UIImage imageNamed:@"extendstartsec.png"] forState:UIControlStateNormal];
                [button setAccessibilityValue:@"extend"];
            }
            
        }else{
            if ([button.accessibilityValue isEqualToString:@"extend"]) {
                [button setImage:[UIImage imageNamed:@"subtractendsec"] forState:UIControlStateNormal];
                [button setAccessibilityValue:@"subtract"];
            }else{
                [button setImage:[UIImage imageNamed:@"extendendsec.png"] forState:UIControlStateNormal];
                [button setAccessibilityValue:@"extend"];
            }
        }
        
    }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        //NSLog(@"changed");
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        //NSLog(@"ended");
    }
}


//extend the tag duration by adding five secs at the beginning of the tag
-(void)startRangeBeenModified:(CustomButton*)button{
    //    if (!currentPlayingTag || [[currentPlayingTag objectForKey:@"type"]intValue] == 4){
    //
    //        return;
    //    }
    //
    //
    //    float newStartTime = 0;
    //
    //    float endTime = [[currentPlayingTag objectForKey:@"starttime"]floatValue] + [[currentPlayingTag objectForKey:@"duration"]floatValue];
    //    if ([button.accessibilityValue isEqualToString:@"extend"]) {
    //
    //        //extend the duration 5 seconds by decreasing the start time 5 seconds
    //        newStartTime = [[currentPlayingTag objectForKey:@"starttime"]floatValue] -5;
    //        //if the new start time is smaller than 0, set it to 0
    //        if (newStartTime <0) {
    //            newStartTime = 0;
    //        }
    //
    //    }else{
    //        //subtract the duration 5 seconds by increasing the start time 5 seconds
    //        newStartTime = [[currentPlayingTag objectForKey:@"starttime"]floatValue] + 5;
    //
    //        //if the start time is greater than the endtime, it will cause a problem for tag looping. So set it to endtime minus one
    //        if (newStartTime > endTime) {
    //            newStartTime = endTime -1;
    //        }
    //
    //    }
    //
    //    //set the new duration to tag end time minus new start time
    //    int newDuration = endTime - newStartTime;
    //
    //    globals.HOME_START_TIME = newStartTime;
    //    globals.HOME_END_TIME = endTime;
    //
    //    NSString *startTimeString = [NSString stringWithFormat:@"%f",newStartTime];
    //    NSString *duration = [NSString stringWithFormat:@"%d",newDuration];
    //    [currentPlayingTag setValue:startTimeString forKey:@"starttime"];
    //    [currentPlayingTag setValue:duration forKey:@"duration"];
    //
    //    [globals.CURRENT_EVENT_THUMBNAILS setObject:currentPlayingTag forKey:[NSString stringWithFormat:@"%@",[currentPlayingTag objectForKey:@"id"]]];
    //
    //    if ([[currentPlayingTag objectForKey:@"bookmark"]integerValue] ==1) {
    //        [[globals.BOOKMARK_TAGS objectForKey:[currentPlayingTag objectForKey:@"event"]] setObject:currentPlayingTag forKey:[NSString stringWithFormat:@"%@",[currentPlayingTag objectForKey:@"id"]]];
    //        [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    //    }
    //
    //    //Offline mode
    //    if (!globals.HAS_MIN|| (globals.HAS_MIN && !globals.eventExistsOnServer))
    //    {
    //        NSMutableDictionary *dict = [globals.CURRENT_EVENT_THUMBNAILS objectForKey:[currentPlayingTag objectForKey:@"id"]];
    //        [dict setObject:@"1" forKey:@"edited"];
    //        [dict setObject: duration forKey:@"duration"];
    //        [dict setObject: startTimeString forKey: @"starttime"];
    //        currentPlayingTag = dict;
    //    } else {
    //    //online mode, send the request to the server
    //
    //        tagId = [currentPlayingTag objectForKey:@"id"];
    //
    //        //current absolute time in seconds
    //        double currentSystemTime = CACurrentMediaTime();
    //        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:startTimeString,@"starttime",duration,@"duration",globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",userId,@"user",tagId,@"id", nil];
    //        NSError *error;
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    //        NSString *jsonString;
    //        if (! jsonData) {
    //
    //        } else {
    //            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        }
    //
    //
    //        NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    //
    //        //NSLog(@"startRangeBeenModified; url: %@",url);
    //        NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
    //        NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
    //        NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //
    //        [globals.APP_QUEUE enqueue:url dict:instObj];
    //    }
    //    [self.videoPlayer setTime: globals.HOME_START_TIME];
    //    [self.videoPlayer pause];
    //    [self fetchedData];
}

//extend the tag duration by adding five secs at the end of the tag
-(void)endRangeBeenModified:(CustomButton*)button{
    //    if (!currentPlayingTag || [[currentPlayingTag objectForKey:@"type"]intValue] == 4){
    //
    //        return;
    //    }
    //
    //    //int newDuration = [[currentPlayingTag objectForKey:@"duration"]integerValue] + 5;
    //    int newDuration = 0;
    //    float startTime = [[currentPlayingTag objectForKey:@"starttime"]floatValue];
    //    float endTime = startTime + [[currentPlayingTag objectForKey:@"duration"]floatValue];
    //    if ([button.accessibilityValue isEqualToString:@"extend"]) {
    //        //increase end time by 5 seconds
    //        endTime = endTime + 5;
    //        //if new end time is greater the duration of video, set it to the video's duration
    //        if (endTime > self.videoPlayer.durationInSeconds) {
    //            endTime = self.videoPlayer.duration;
    //        }
    //
    //    }else{
    //        //subtract end time by 5 seconds
    //        endTime = endTime - 5;
    //        //if the new end time is smaller than the start time,it will cause a problem for tag looping. So set it to start time plus one.
    //        if (endTime < startTime) {
    //            endTime = startTime + 1;
    //        }
    //
    //    }
    //    //get the new duration
    //    newDuration = endTime - startTime;
    //
    //    NSString *duration = [NSString stringWithFormat:@"%d",newDuration];
    //    [currentPlayingTag setValue:duration forKey:@"duration"];
    //
    //    //handle offline mode, save comment information in local storage
    //    [globals.CURRENT_EVENT_THUMBNAILS setObject:currentPlayingTag forKey:[NSString stringWithFormat:@"%@",[currentPlayingTag objectForKey:@"id"]]];
    //
    //    if ([[currentPlayingTag objectForKey:@"bookmark"]integerValue] ==1) {
    //        [[globals.BOOKMARK_TAGS objectForKey:[currentPlayingTag objectForKey:@"event"]] setObject:currentPlayingTag forKey:[NSString stringWithFormat:@"%@",[currentPlayingTag objectForKey:@"id"]]];
    //        [globals.BOOKMARK_TAGS writeToFile:globals.BOOKMARK_TAGS_PATH atomically:YES];
    //    }
    //    globals.HOME_START_TIME=[[currentPlayingTag objectForKey:@"starttime"] floatValue];
    //    globals.HOME_END_TIME = [[currentPlayingTag objectForKey:@"starttime"]floatValue] + newDuration;
    //    if (globals.HOME_END_TIME>self.videoPlayer.durationInSeconds){
    //        globals.HOME_END_TIME = self.videoPlayer.durationInSeconds;
    //    }
    //    tagId = [currentPlayingTag objectForKey:@"id"];
    //
    //    if (!globals.HAS_MIN|| (globals.HAS_MIN && !globals.eventExistsOnServer))
    //    {
    //        NSMutableDictionary *dict = [globals.CURRENT_EVENT_THUMBNAILS objectForKey:[currentPlayingTag objectForKey:@"id"]];
    //
    //        //So we know tags in this list need to be synced with server
    //        //[globals.CURRENT_EVENT_THUMBNAILS setObject:@"1" forKey:@"edited"];
    //        [dict setObject:@"1" forKey:@"edited"];
    //        [dict setObject: duration forKey:@"duration"];
    //        currentPlayingTag = dict;
    //    } else {
    //        //current absolute time in seconds
    //        double currentSystemTime = CACurrentMediaTime();
    //        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:duration,@"duration",globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",userId,@"user",tagId,@"id", nil];
    //
    //        NSError *error;
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    //        NSString *jsonString;
    //        if (! jsonData) {
    //
    //        } else {
    //            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        }
    //
    //
    //        NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    //
    //        // NSLog(@"addFiveSecInLoopEnd; url: %@",url);
    //        NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
    //        NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
    //        NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //
    //        [globals.APP_QUEUE enqueue:url dict:instObj];
    //    }
    //
    //    //the end loop time is changed, needs to update the looptagobserver
    //
    //    //remove the old time observer before adding the new one
    //    if (loopTagObserver) {
    //        [videoPlayer.avPlayer removeTimeObserver:loopTagObserver];
    //        loopTagObserver = nil;
    //    }
    //
    //    /*
    //     * Use addBoundaryTimeObserverForTimes: to loop the tag instread of timer;
    //     * When avplayer plays to the tag end time, the block will be invoked and will call loopTag method;
    //     *
    //     * When the user tries to extend/subtract the tag duration by adding/reducing 5 seconds to the tag end time, the video will be paused at the new tag end time(globals.HOME_END_TIME).
    //     * And it will also start playing from the new tag end time(globals.HOME_END_TIME) if the user presses the video player's play button.
    //     * In this case, if we set the boundary timer observer for time globals.HOME_END_TIME, the time observer block may never be triggered.
    //     * So we set the boundary time observer for time (globals.HOME_END_TIME + 1), when the video resumes playing from globals.HOME_END_TIME, after one seconds the block
    //     * will be triggered and loopTag will be called. Then the tag starts looping.
    //     *
    //     */
    //
    //    NSArray *times = [NSArray arrayWithObjects:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(globals.HOME_END_TIME + 1, 600)], nil];
    //    __weak ListViewController *weakRef = self;
    //    //set queue: NULL will use the default queue which is the main queue
    //    loopTagObserver = [videoPlayer.avPlayer addBoundaryTimeObserverForTimes:times queue:NULL usingBlock:^{
    //        // if the video plays to the tag end time, seek back to the start time for looping
    //        [weakRef loopTag];
    //
    //    }];
    //
    //    [videoPlayer play];
    //    [self.videoPlayer setTime: globals.HOME_END_TIME];
    //    [self.videoPlayer pause];
    //    [self fetchedData];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [componentFilter close:YES];
    [self.dismissFilterButton removeFromSuperview];
    //    [teleView removeFromSuperview];
    //    teleView=nil;
    //
    //    [self.blurView removeFromSuperview];
    //    self.blurView=nil;
    //    [self.edgeSwipeButtons deselectButtonAtIndex:1];
    //
    //    //will leaving live2bench view,pause video
    //    if (globals.CURRENT_PLAYBACK_EVENT && ![globals.CURRENT_PLAYBACK_EVENT isEqualToString:@""]) {
    //        [videoPlayer pause];
    //        //remove timeobserver
    //        if (videoPlayer.timeObserver) {
    //            //NSLog(@"remove time observer");
    //            [videoPlayer removePlayerItemTimeObserver];
    //        }
    //
    //    }
    //
    //    //remove loop tag observer
    //    //remove the observer for looping tag
    //    if (loopTagObserver) {
    //        [videoPlayer.avPlayer removeTimeObserver:loopTagObserver];
    //        loopTagObserver = nil;
    //    }
    //
    //    //if navigating to other view while video player is still in fullscreen mode, call the exit fullscreen method
    //    if (videoPlayer.isFullScreen) {
    //        [videoPlayer exitFullScreen];
    //    }
    //    ////NSLog(@"globals.CURRENT_EVENT_THUMBNAILS count in listview  will disappear %d",globals.CURRENT_EVENT_THUMBNAILS.count);
    //    globals.IS_LOOP_MODE = FALSE;
    //    globals.SHOW_TOASTS = TRUE;
    //    //we will remove the filtertoolbox to deallocate mem -- makes sure app does not freeze up
    //    [typesOfTags removeAllObjects];
    //    //[self invalidateTimer];
    //    [selectedCellRows removeAllObjects];
    //
    //    [self.tagsToDisplay removeAllObjects];
    //    //we will remove the filtertoolbox to deallocate mem -- makes sure app does not freeze up
    //    [filterToolBoxListViewController.view removeFromSuperview];
    //    filterToolBoxListViewController=nil;
    //
    //    currentPlayingTag = nil;
    //    if(!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer)){
    //        [uController writeTagsToPlist];
    //    }
    //    noVideoURLAlert = nil;
    //    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeAllObjects];
    //    [CustomAlertView removeAll];
    //    //Edge Swipe Buttons
    //    [self.edgeSwipeButtons deselectAllButtons];
    //    [componentFilter close:NO];
}


//-(void)receiveFilteredArray:(NSArray*)filteredArray
//{
//
//    NSMutableArray *tempArr = [[self sortArrayByTime: [NSMutableArray arrayWithArray:filteredArray]]mutableCopy];
//    self.tagsToDisplay = [tempArr mutableCopy];
//    for(NSDictionary *tag in tempArr){
//        if ([[tag objectForKey:@"type"]integerValue ] ==7 ||[[tag objectForKey:@"type"]integerValue ] ==8 ) {
//            [self.tagsToDisplay removeObject:tag];
//        }
//    }
//    [self.myTableView reloadData];
//    globals.THUMBNAIL_COUNT_REF_ARRAY = self.tagsToDisplay;
//    @try {
//        downloadedTagIds = [globals.DOWNLOADED_THUMBNAILS_SET mutableCopy];
//    }
//    @catch (NSException *exception) {
//        NSLog(@"downloadedTagIds: %@",exception.reason);
//    }
//}

//new tags received from the server while the user is in list view
-(void)getNewTags:(NSNotification*)notification{
    //
    //    NSDictionary *newTag;
    //    if(globals.TAGGED_ATTS_DICT_SHIFT.count >0){
    //        if([filterToolBoxListViewController sortClipsBySelectingforShiftFiltering:notification.object].count > 0){
    //            //socket only send one tag a time
    //            newTag = [[[filterToolBoxListViewController sortClipsBySelectingforShiftFiltering:notification.object] objectAtIndex:0] copy];
    //
    //            if ([[newTag objectForKey:@"modified"]intValue] != 1) {
    //                [self.tagsToDisplay addObject:newTag];
    //            }else{
    //                //NSLog(@"getNewTags  reload data!");
    //                [self.myTableView reloadData];
    //                return;
    //            }
    //        }else{
    //            return;
    //        }
    //
    //    }else{
    //        if ([filterToolBoxListViewController sortClipsWithAttributes:notification.object].count > 0) {
    //            //socket only send one tag a time
    //            newTag = [[[filterToolBoxListViewController sortClipsWithAttributes:notification.object] objectAtIndex:0]copy];
    //
    //            //if this tag is tagmod tag, donot update the list view.
    //            if ([[newTag objectForKey:@"modified"]intValue] != 1) {
    //                [self.tagsToDisplay addObject:newTag];
    //            }else{
    //                //NSLog(@"getNewTags  reload data!");
    //                [self.myTableView reloadData];
    //                return;
    //            }
    //
    //        }else{
    //            return;
    //        }
    //    }
    //
    //    if (globals.CURRENT_EVENT_THUMBNAILS.count > 0) {
    //        self.edgeSwipeButtons.hidden = NO;
    //    }
    //    else
    //    {
    //        self.edgeSwipeButtons.hidden = YES;
    //    }
    //
    //
    //    [self updateTagTypes:notification.object];
    //    globals.THUMBNAIL_COUNT_REF_ARRAY = self.tagsToDisplay;
    //    //NSLog(@"getNewTags  reload data!");
    //    [self.myTableView reloadData];
}


//update update globals.TYPES_OF_TAGS which is used to update filter view's event buttons, user buttons and player buttons
-(void)updateTagTypes:(NSArray*)tagsArr{
    
    //    NSMutableArray *tempAllTags = [tagsArr mutableCopy];
    //    allTags = [tempAllTags mutableCopy];
    //    //"type" value: #default = 0; #stop line/zone = 2;#telestration = 4;#player end shift = 6;#period/half end = 8/18; #strength end  = 10
    //    for(NSDictionary *tag in tempAllTags){
    //
    //        if([[tag objectForKey:@"type"] intValue]==8 || [[tag objectForKey:@"type"] intValue]==18 || ([[tag objectForKey:@"type"] intValue]&1)||[[tag objectForKey:@"type"]integerValue] == 20|| [[tag objectForKey:@"type"]integerValue] == 22 ){
    //            [allTags removeObject:tag];
    //        }
    //    }
    //
    //
    //    NSMutableArray *openEndStrings = [[NSMutableArray alloc] init]; //will use this array for open and end types of different sports -- soccer will be 17,18 hockey will be 7,8
    //    if([globals.WHICH_SPORT isEqualToString:@"hockey"])
    //    {
    //        [openEndStrings addObject:@"7"];
    //        [openEndStrings addObject:@"8"];
    //    }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
    //    {
    //        [openEndStrings addObject:@"17"];
    //        [openEndStrings addObject:@"18"];
    //    }else{
    //        //for testing
    //        [openEndStrings addObject:@"100"];
    //        [openEndStrings addObject:@"101"];
    //    }
    //
    //    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    //    for(NSDictionary *tag in allTags){
    //
    //        globals.IS_TAG_TYPES_UPDATED = TRUE;
    //
    //        if(![globals.ARRAY_OF_COLOURS containsObject:[tag objectForKey:@"colour"]]&&[tag objectForKey:@"colour"]!=nil)
    //        {
    //            [globals.ARRAY_OF_COLOURS  addObject:[tag objectForKey:@"colour"]];
    //        }
    //        //type == 2, line tag;type == 0 normal tag;type ==100, duration tag; if the tag was deleted, type value will be 3 and "deleted" value will be 1
    //        if(([[tag objectForKey:@"type"] intValue]==0 || [[tag objectForKey:@"type"] intValue]==100) && [[tag objectForKey:@"type"]integerValue]!=3&& [tag  objectForKey:@"name"]!=nil)
    //        {
    //            [tempArray addObject:tag];
    //
    //            if(![[globals.TYPES_OF_TAGS objectAtIndex:0] containsObject:[tag  objectForKey:@"name"]] && [tag  objectForKey:@"name"]!=nil && [[tag objectForKey:@"name"] rangeOfString:@"Pl. "].location == NSNotFound)
    //            {
    //                [[globals.TYPES_OF_TAGS objectAtIndex:0] addObject:[tag  objectForKey:@"name"]];
    //            }
    //
    //            if ([[tag  objectForKey:@"player"]count]>0 && ![[[tag  objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""] ) {
    //                NSMutableSet* set1 = [NSMutableSet setWithArray:[globals.TYPES_OF_TAGS objectAtIndex:3]];
    //                NSMutableSet* set2 = [NSMutableSet setWithArray:[tag  objectForKey:@"player"]];
    //                [set1 intersectSet:set2]; //this will give you only the obejcts that are in both sets
    //                NSArray* intersectArray = [set1 allObjects];
    //                if (intersectArray.count < [[tag objectForKey:@"player"]count]) {
    //                    NSMutableArray *tempPlayerArr = [[tag objectForKey:@"player"]mutableCopy];
    //                    //new players which are not included in the array typesoftags
    //                    [tempPlayerArr removeObjectsInArray:intersectArray];
    //                    [[globals.TYPES_OF_TAGS objectAtIndex:3] addObjectsFromArray:tempPlayerArr];
    //                }
    //            }
    //
    //
    //        }else if([[tag objectForKey:@"type"] intValue]==10 && [[tag objectForKey:@"type"]integerValue]!=3 && [tag  objectForKey:@"name"]!=nil){
    //            [tempArray addObject:tag];
    //            //strength tags
    //            if(![[globals.TYPES_OF_TAGS objectAtIndex:2] containsObject:[tag  objectForKey:@"name"]])
    //            {
    //                [[globals.TYPES_OF_TAGS objectAtIndex:2] addObject:[tag  objectForKey:@"name"]];
    //            }
    //
    //        }else if(!([[tag objectForKey:@"type"] intValue]&1) && [[tag objectForKey:@"type"]integerValue]!=3 && [tag  objectForKey:@"name"]!=nil && ![openEndStrings containsObject:[NSString stringWithFormat:@"%@",[tag objectForKey:@"type"]]]){
    //            [tempArray addObject:tag];
    //            //normal tag
    //            if(![[globals.TYPES_OF_TAGS objectAtIndex:1] containsObject:[tag  objectForKey:@"name"]])
    //            {
    //                [[globals.TYPES_OF_TAGS objectAtIndex:1] addObject:[tag  objectForKey:@"name"]];
    //            }
    //        }
    //    }
    //
    
}

//create the scroll view to display the current filtering information
-(void)createBreadCrumbsView{
    return;
    //    [breadCrumbsView removeFromSuperview];
    //    breadCrumbsView  = nil;
    //
    //    breadCrumbsView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.f,70.f, self.view.bounds.size.width, 40.f)];
    //
    //    [self.view addSubview:breadCrumbsView];
    //
    //
    //    NSDictionary *currentCrumbDict;
    //    NSMutableArray *currentBreadCrumbs=[[NSMutableArray alloc] init];
    //
    //    if(globals.TAGGED_ATTS_DICT_SHIFT.count>0)
    //    {
    //        currentCrumbDict = [[NSDictionary alloc] initWithDictionary:globals.TAGGED_ATTS_DICT_SHIFT];
    //    }
    //    if(globals.TAGGED_ATTS_DICT.count>0){
    //        currentCrumbDict = [[NSDictionary alloc] initWithDictionary:globals.TAGGED_ATTS_DICT];
    //    }
    //    if(currentCrumbDict.count>0)
    //    {
    //        for(NSString *keyValue in [currentCrumbDict allKeys])
    //        {
    //            //currentBreadCrumbs = (NSMutableArray*)[currentBreadCrumbs arrayByAddingObjectsFromArray:arr];
    //
    //            NSString *crumbKeyValue = [NSString stringWithFormat:@"%@|%@",keyValue,[[currentCrumbDict objectForKey:keyValue] componentsJoinedByString:@","]];
    //            [currentBreadCrumbs addObject:crumbKeyValue];
    //        }
    //    }
    //    if (currentBreadCrumbs.count>0) {
    //        int i = 0;
    //        for(NSString *obj in currentBreadCrumbs)
    //        {
    //            UIImageView *crumbBG = [[UIImageView alloc] initWithFrame:CGRectMake(2+(i*113), 0, 120, 35)];
    //            NSString *imgName = i ==0 ? @"chevrect" : @"chevbothpoints";
    //            [crumbBG setImage:[UIImage imageNamed:imgName]];
    //
    //            int xFactor = i == 0 ? 5 : 13;
    //
    //            UIScrollView *crumb = [[UIScrollView alloc]initWithFrame:CGRectMake(xFactor, 0, 100 - xFactor, 35)];
    //            [crumb setBackgroundColor:[UIColor clearColor]];
    //            [crumb setScrollEnabled:TRUE];
    //            [crumbBG addSubview:crumb];
    //
    //            NSString *typeOfFilter = [[obj componentsSeparatedByString:@"|"] objectAtIndex:0];
    //
    //            if (![typeOfFilter isEqualToString:@"colours"]) {
    //
    //                UILabel *crumbName = [[UILabel alloc] initWithFrame:CGRectMake(0, crumb.bounds.origin.y, crumb.bounds.size.width - xFactor, crumb.bounds.size.height)];
    //                NSString *crumbText = obj;
    //                if([typeOfFilter isEqualToString:@"periods"])
    //                {
    //                    if ([globals.WHICH_SPORT isEqualToString:@"football"]){
    //                        crumbText = @"Quarter: ";
    //                    }else{
    //                        crumbText = @"Period: ";
    //                    }
    //
    //                    NSArray *periodNumberArr = [[[obj componentsSeparatedByString:@"|"] objectAtIndex:1] componentsSeparatedByString:@","];
    //                    for(id periodNumber in periodNumberArr){
    //                        int i = [periodNumberArr indexOfObject:periodNumber];
    //                        NSString *periodStr;
    //                        if (i==0) {
    //                            periodStr = [NSString stringWithFormat:@"%@",[globals.ARRAY_OF_PERIODS objectAtIndex:[periodNumber integerValue]]];
    //                        }else{
    //                            periodStr = [NSString stringWithFormat:@", %@",[globals.ARRAY_OF_PERIODS objectAtIndex:[periodNumber integerValue]]];
    //                        }
    //                        crumbText = [crumbText stringByAppendingString:periodStr];
    //                    }
    //                }else if([typeOfFilter isEqualToString:@"half"])
    //                {
    //                    crumbText = @"Half: ";
    //                    NSArray *periodNumberArr = [[[obj componentsSeparatedByString:@"|"] objectAtIndex:1] componentsSeparatedByString:@","];
    //                    for(id periodNumber in periodNumberArr){
    //                        int i = [periodNumberArr indexOfObject:periodNumber];
    //                        NSString *periodStr;
    //                        if (i==0) {
    //                            periodStr = [NSString stringWithFormat:@"%@",[globals.ARRAY_OF_PERIODS objectAtIndex:[periodNumber integerValue]]];
    //                        }else{
    //                            periodStr = [NSString stringWithFormat:@", %@",[globals.ARRAY_OF_PERIODS objectAtIndex:[periodNumber integerValue]]];
    //                        }
    //                        crumbText = [crumbText stringByAppendingString:periodStr];
    //                    }
    //                }else if([typeOfFilter isEqualToString:@"players"])
    //                {
    //                    crumbText =[NSString stringWithFormat:@"Player(s): %@",[[obj componentsSeparatedByString:@"|"] objectAtIndex:1]]; ;
    //
    //                }else if([typeOfFilter isEqualToString:@"coachpick"])
    //                {
    //                    crumbText = @"Coach Pick";
    //
    //                }else if([typeOfFilter isEqualToString:@"homestr"])
    //                {
    //                    crumbText =[NSString stringWithFormat:@"Home strength: %@",[[obj componentsSeparatedByString:@"|"] objectAtIndex:1]]; ;
    //
    //                }else if([typeOfFilter isEqualToString:@"awaystr"])
    //                {
    //                    crumbText =[NSString stringWithFormat:@"Away strength: %@",[[obj componentsSeparatedByString:@"|"] objectAtIndex:1]]; ;
    //
    //                }else{
    //                    crumbText = [[obj componentsSeparatedByString:@"|"] objectAtIndex:1];
    //                }
    //
    //                [crumbName setText:crumbText];
    //                [crumbName setBackgroundColor:[UIColor clearColor]];
    //                [crumbName setTextColor:[UIColor darkGrayColor]];
    //                [crumbName setTextAlignment:NSTextAlignmentCenter];
    //                [crumbName setFont:[UIFont defaultFontOfSize:13]];
    //                [crumb addSubview:crumbName];
    //                //if the filtered property's text is greater than the size of the crumbName label, use uiscroll view to display all the information
    //                CGSize labelSize = [crumbText sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont defaultFontOfSize:13] forKey:NSFontAttributeName]];
    //                if (labelSize.width > crumbName.frame.size.width) {
    //                    [crumbName setFrame:CGRectMake(0, crumbName.frame.origin.y, labelSize.width+20, crumbName.frame.size.height)];
    //                    [crumb setContentSize:CGSizeMake(labelSize.width+20, 35)];
    //                    [crumb setUserInteractionEnabled:TRUE];
    //                    [crumbBG setUserInteractionEnabled:TRUE];
    //                }else{
    //                    [crumb setContentSize:CGSizeMake(100, 35)];
    //                }
    //
    //            }else{
    //                NSArray *colorArr = [[[obj componentsSeparatedByString:@"|"] objectAtIndex:1] componentsSeparatedByString:@","];
    //                int labelWidth = 80/colorArr.count;
    //                for(NSString *colorStr in colorArr){
    //                    int i = [colorArr indexOfObject:colorStr];
    //                    UILabel *colorLabel = [[UILabel alloc]initWithFrame:CGRectMake(5+i*labelWidth, crumb.bounds.origin.y+5, labelWidth, crumb.bounds.size.height - 10)];
    //                    [colorLabel setBackgroundColor:[UIColor colorWithHexString:colorStr]];
    //                    [crumb addSubview:colorLabel];
    //                }
    //            }
    //            [breadCrumbsView addSubview:crumbBG];
    //            [breadCrumbsView setContentSize:CGSizeMake(25+((i+1)*118), 35)];
    //            [breadCrumbsView scrollRectToVisible:CGRectMake(breadCrumbsView.contentSize.width-70, 0, 10, 10) animated:TRUE];
    //            [breadCrumbsView setScrollEnabled:TRUE];
    //            i++;
    //        }
    //
    //    }else{
    //        UIImageView *crumb = [[UIImageView alloc] initWithFrame:CGRectMake(2, 0, 100, 35)];
    //        NSString *imgName = @"chevrect";
    //        [crumb setImage:[UIImage imageNamed:imgName]];
    //        int xFactor = 5 ;
    //        UILabel *crumbName = [[UILabel alloc] initWithFrame:CGRectMake(crumb.bounds.origin.x+xFactor, crumb.bounds.origin.y, crumb.bounds.size.width-xFactor, crumb.bounds.size.height)];
    //        [crumbName setText:@"No filter set"];
    //        [crumbName setBackgroundColor:[UIColor clearColor]];
    //        [crumbName setTextColor:[UIColor darkGrayColor]];
    //        [crumbName setFont:[UIFont systemFontOfSize:13]];
    //        [crumb addSubview:crumbName];
    //        [breadCrumbsView addSubview:crumb];
    //        [breadCrumbsView setContentSize:CGSizeMake(10, 35)];
    //        [breadCrumbsView scrollRectToVisible:CGRectMake(breadCrumbsView.contentSize.width-70, 0, 10, 10) animated:TRUE];
    //        [breadCrumbsView setScrollEnabled:TRUE];
    //
    //    }
    //
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //    if (!fullScreenMode || !self.videoPlayer.isFullScreen) {
    //        //[videoControlBar removeFromSuperview];
    //        if(filterToolBoxListViewController.view.frame.origin.y==438)
    //        {
    //            [self slideFilterBox];
    //            self.filterToolBoxListViewController.taggedAttsDict = nil;
    //        }
    //        for(NSObject *cell in self.myTableView.subviews){
    //            if ([cell isKindOfClass:[ListViewCell class]]){
    //                [(ListViewCell*)cell removeFromSuperview];
    //            }
    //        }
    //
    //        [allTags removeAllObjects];
    //        globals.IS_IN_LIST_VIEW = FALSE;
    //    }
    
}


//-(void)checkFullScreen
//{
//    if (self.videoPlayer.isFullScreen && !fullScreenMode)
//    {
// //will enter fullscreen
//
//        fullScreenMode = TRUE;
//
//        ///going to bring the tabbar controller to the front now, we want to have access to it at all times, including fullscreen mode
//        UIView *fullScreenView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
//
//        //iterate through all the views in teh fullscreen (the tabs are there, just hidden away
//        for(id tBar in fullScreenView.subviews)
//        {
//            //if the view is a subclass of type tabbarbutton, then we will bring it to the front
//            if([tBar isKindOfClass:[TabBarButton class]])
//            {
//                [fullScreenView bringSubviewToFront:tBar];
//            }
//        }
//        /////////////////////////////////////////////////////////////////////////////////////////
//
//
//
//        //switch from normal screen to full screen,set the right slow mode button icon in full screen according to the play back rate in normal screen
////        if(globals.PLAYBACK_SPEED == 1.0f)
////        {
////            [slowMoButtonFullScreen setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];
////        }else{
////            [slowMoButtonFullScreen setImage:[UIImage imageNamed:@"slowmo.png"] forState:UIControlStateNormal];
////        }
////
//        //create all the fullscreen controls
//        [self createAllFullScreenSubviews];
//
//    }else if (!self.videoPlayer.isFullScreen && fullScreenMode){
//
////back from the fullscreen, bring all the subviews to the front;otherwise they will be hidden;
////And also set the seek forward/back button image properly
//
//        fullScreenMode = FALSE;
//
//        //remove all the fullscreen controls from superview
//        [self removeAllFullScreenSubviews];
//
//        //if the user is reviewing a tag
//        if (currentPlayingTag) {
//            //Set the startRangeModifierButton's icon according to the startRangeModifierButtoninFullScreen's accessibilityValue
//            //Make sure when switching between fullscreen and normal screen,the buttons' icons and controls are synced
//            NSString *accesibilityString = startRangeModifierButtonFullScreen.accessibilityValue;
//            NSString *imageName;
//            if ([accesibilityString isEqualToString:@"extend"]) {
//                imageName = @"extendstartsec";
//            }else{
//                imageName = @"subtractstartsec";
//            }
//            [startRangeModifierButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//            [startRangeModifierButton setAccessibilityValue:accesibilityString];
//
//            //set the endRangeModifierButton's icon according to the endRangeModifierButtoninFullScreen's accessibilityValue
//            //Make sure when switching between fullscreen and normal screen,the buttons' icons and controls are synced
//            accesibilityString = endRangeModifierButtonFullScreen.accessibilityValue;
//            if ([accesibilityString isEqualToString:@"extend"]) {
//                imageName = @"extendendsec";
//            }else{
//                imageName = @"subtractendsec";
//            }
//            [endRangeModifierButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//            [endRangeModifierButton setAccessibilityValue:accesibilityString];
//        }
//
//
//
//        //switch from full screen to normal screen,set the right slow mode button icon in normal screen according to the play back rate in full screen
////        if(globals.PLAYBACK_SPEED == 1.0f)
////        {
////            [slowMoButton setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];
////        }else{
////            [slowMoButton setImage:[UIImage imageNamed:@"slowmo.png"] forState:UIControlStateNormal];
////
////        }
//
//        //[self.view addSubview:self.videoPlayer.view];
//        [self.view bringSubviewToFront: filterToolBoxListViewController.view];
//        [self.view bringSubviewToFront:seekBackControlView];
//        [self.view bringSubviewToFront:seekForwardControlView];
//        [seekBackControlView setHidden:TRUE];
//        [seekForwardControlView setHidden:TRUE];
//        [seekBackControlViewinFullScreen setHidden:TRUE];
//        [seekForwardControlViewinFullScreen setHidden:TRUE];
//
////        if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
////            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackquartersec.png"] forState:UIControlStateNormal];
////        }else if(globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
////            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackonesec.png"] forState:UIControlStateNormal];
////        }else {
////            [currentSeekBackButton setImage:[UIImage imageNamed:@"seekbackfivesecs.png"] forState:UIControlStateNormal];
////            globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
////        }
////        [currentSeekBackButton addTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
////
////        if (globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardQuarterSecond:)) {
////            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardquartersec.png"] forState:UIControlStateNormal];
////        }else if(globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardOneSecond:)){
////            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardonesec.png"] forState:UIControlStateNormal];
////        }else {
////            [currentSeekForwardButton setImage:[UIImage imageNamed:@"seekforwardfivesecs.png"] forState:UIControlStateNormal];
////            globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
////        }
////        [currentSeekForwardButton addTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
//
////        [videoPlayer.teleBigView setFrame:CGRectMake(0, 25, self.videoPlayer.view.bounds.size.width, self.videoPlayer.view.bounds.size.height)];
//    }
//}

//-(void)willEnterFullScreen{
//
//    [self.videoPlayer setIsFullScreen:YES];
//
//    //switch from normal screen to full screen,set the right slow mode button icon in full screen according to the play back rate in normal screen
//    if(globals.PLAYBACK_SPEED == 1.0f)
//    {
//        [slowMoButtonFullScreen setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];
//    }else{
//        fullScreenMode = IS_FULLSCREEN;
//        [self.videoPlayer setIsFullScreen:YES];
//
//        //switch from normal screen to full screen,set the right slow mode button icon in full screen according to the play back rate in normal screen
//        if(globals.PLAYBACK_SPEED == 1.0f)
//        {
//            [slowMoButtonFullScreen setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];
//        }else{
//            [slowMoButtonFullScreen setImage:[UIImage imageNamed:@"slowmo.png"] forState:UIControlStateNormal];
//        }
//    }
//    [self createAllFullScreenSubviews];
//
//}


//-(void)willExitFullscreen{
//
//    [self removeAllFullScreenSubviews];
//    //switch from full screen to normal screen,set the right slow mode button icon in normal screen according to the play back rate in full screen
//    if(globals.PLAYBACK_SPEED == 1.0f)
//    {
//        [slowMoButton setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];
//    }else{
//        [slowMoButton setImage:[UIImage imageNamed:@"slowmo.png"] forState:UIControlStateNormal];
//
//    }
//}


//create all fullscreen controls
//-(void)createAllFullScreenSubviews{

//    //extend duration by minus 5 secs of the tag start time
//    startRangeModifierButtonFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
//    startRangeModifierButtonFullScreen = [[CustomButton alloc]initWithFrame:CGRectMake(20,700,50 ,50)];
//    [startRangeModifierButtonFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [startRangeModifierButtonFullScreen setTag:0];
//
//    NSString *accesibilityString = startRangeModifierButton.accessibilityValue;
//    NSString *imageName;
//    if ([accesibilityString isEqualToString:@"extend"]) {
//        imageName = @"extendstartsec";
//    }else{
//        imageName = @"subtractstartsec";
//    }
//    [startRangeModifierButtonFullScreen setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//    [startRangeModifierButtonFullScreen addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
//    [startRangeModifierButtonFullScreen setAccessibilityValue:accesibilityString];
//    //added long press gesture to switch icons between extension icon and substraction icon
//    UILongPressGestureRecognizer *modifiedTagDurationByStartTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
//                                                                                    initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
//    modifiedTagDurationByStartTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
//    modifiedTagDurationByStartTimeLongpressgesture.delegate = self;
//    [startRangeModifierButtonFullScreen addGestureRecognizer:modifiedTagDurationByStartTimeLongpressgesture];
//
//
//    //extend duration by adding 5 secs to the tag end time
//    endRangeModifierButtonFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
//    endRangeModifierButtonFullScreen = [[CustomButton alloc]initWithFrame:CGRectMake(880,startRangeModifierButtonFullScreen.frame.origin.y,50,50)];
//    [endRangeModifierButtonFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [endRangeModifierButtonFullScreen setTag:1];
//
//    accesibilityString = endRangeModifierButton.accessibilityValue;
//    if ([accesibilityString isEqualToString:@"extend"]) {
//        imageName = @"extendendsec";
//    }else{
//        imageName = @"subtractendsec";
//    }
//
//    [endRangeModifierButtonFullScreen setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//    [endRangeModifierButtonFullScreen addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
//    [endRangeModifierButtonFullScreen setAccessibilityValue:accesibilityString];
//
//    //added long press gesture to switch icons between extension icon and substraction icon
//    UILongPressGestureRecognizer *modifiedTagDurationByEndTimeLongpressgesture = [[UILongPressGestureRecognizer alloc]
//                                                                                  initWithTarget:self action:@selector(changeDurationModifierButtonIcon:)];
//    modifiedTagDurationByEndTimeLongpressgesture.minimumPressDuration = 0.5; //seconds
//    modifiedTagDurationByEndTimeLongpressgesture.delegate = self;
//    [endRangeModifierButtonFullScreen addGestureRecognizer:modifiedTagDurationByEndTimeLongpressgesture];
//
//
//    //seek back
//    currentSeekBackButtoninFullScreen = [[CustomButton alloc]initWithFrame:CGRectMake(startRangeModifierButtonFullScreen.frame.origin.x + startRangeModifierButtonFullScreen.frame.size.width + 30,startRangeModifierButtonFullScreen.frame.origin.y-10, 65, 65)];
//    [currentSeekBackButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [currentSeekBackButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
//    UIImage *backButtonImage;
//    if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackQuarterSecond:)) {
//        backButtonImage = [UIImage imageNamed:@"seekbackquarterseclarge.png"];
//    }else if (globals.CURRENT_SEEK_BACK_ACTION == @selector(seekBackOneSecond:)){
//        backButtonImage = [UIImage imageNamed:@"seekbackoneseclarge.png"];
//    }else{
//        backButtonImage = [UIImage imageNamed:@"seekbackfivesecslarge.png"];
//        globals.CURRENT_SEEK_BACK_ACTION = @selector(seekBackFiveSeconds:);
//    }
//
//    [currentSeekBackButtoninFullScreen setImage:backButtonImage forState:UIControlStateNormal];
//    [currentSeekBackButtoninFullScreen addTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
//    //[currentSeekBackButtoninFullScreen addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
//    [currentSeekBackButton removeTarget:self action:globals.CURRENT_SEEK_BACK_ACTION forControlEvents:UIControlEventTouchUpInside];
//    UILongPressGestureRecognizer *seekBackLongpressgesture = [[UILongPressGestureRecognizer alloc]
//                                                              initWithTarget:self action:@selector(handleLongPress:)];
//    seekBackLongpressgesture.minimumPressDuration = 0.5; //seconds
//    seekBackLongpressgesture.delegate = self;
//    [currentSeekBackButtoninFullScreen addGestureRecognizer:seekBackLongpressgesture];
//
//    //uiview contains three seek back modes: go back 5s, 1s, 0.25s
//    seekBackControlViewinFullScreen = [[UIView alloc]initWithFrame:CGRectMake(currentSeekBackButtoninFullScreen.frame.origin.x , 460,currentSeekBackButtoninFullScreen.frame.size.width +6,3.5*currentSeekBackButtoninFullScreen.frame.size.height)];
//    [seekBackControlViewinFullScreen setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.1]];
//    seekBackControlViewinFullScreen.hidden = TRUE;
//
//    //go back 0.25s
//    CustomButton *backQuarterSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
//    [backQuarterSecButtoninFullScreen setFrame:CGRectMake(0, 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
//    [backQuarterSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [backQuarterSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
//    [backQuarterSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackquarterseclarge.png"] forState:UIControlStateNormal];
//    [backQuarterSecButtoninFullScreen addTarget:self action:@selector(seekBackQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
//    [backQuarterSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
//    [seekBackControlViewinFullScreen addSubview:backQuarterSecButtoninFullScreen];
//
//    //go back 1 s
//    CustomButton *backOneSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
//    [backOneSecButtoninFullScreen setFrame:CGRectMake(0, backQuarterSecButtoninFullScreen.frame.origin.y + backQuarterSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
//    [backOneSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [backOneSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
//    [backOneSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackoneseclarge.png"] forState:UIControlStateNormal];
//    [backOneSecButtoninFullScreen addTarget:self action:@selector(seekBackOneSecond:) forControlEvents:UIControlEventTouchUpInside];
//     [backOneSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
//    [seekBackControlViewinFullScreen addSubview:backOneSecButtoninFullScreen];
//
//    //go back 5 s
//    CustomButton *backFiveSecsButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
//    [backFiveSecsButtoninFullScreen setFrame:CGRectMake(0, backOneSecButtoninFullScreen.frame.origin.y + backOneSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
//    [backFiveSecsButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [backFiveSecsButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
//    [backFiveSecsButtoninFullScreen setImage:[UIImage imageNamed:@"seekbackfivesecslarge.png"] forState:UIControlStateNormal];
//    [backFiveSecsButtoninFullScreen addTarget:self action:@selector(seekBackFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
//    [backFiveSecsButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
//    [seekBackControlViewinFullScreen addSubview:backFiveSecsButtoninFullScreen];
//
//
//    //seek forward 5 seconds button
//    currentSeekForwardButtoninFullScreen = [[CustomButton alloc]initWithFrame:CGRectMake(endRangeModifierButtonFullScreen.frame.origin.x - 80,currentSeekBackButtoninFullScreen.frame.origin.y, 65, 65)];
//    [currentSeekForwardButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [currentSeekForwardButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
//    UIImage *forwardButtonImage;
//    if (globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardQuarterSecond:)) {
//        forwardButtonImage = [UIImage imageNamed:@"seekforwardquarterseclarge.png"];
//    }else if (globals.CURRENT_SEEK_FORWARD_ACTION == @selector(seekForwardOneSecond:)){
//        forwardButtonImage = [UIImage imageNamed:@"seekforwardoneseclarge.png"];
//    }else{
//        forwardButtonImage = [UIImage imageNamed:@"seekforwardfivesecslarge.png"];
//        globals.CURRENT_SEEK_FORWARD_ACTION = @selector(seekForwardFiveSeconds:);
//    }
//
//    [currentSeekForwardButtoninFullScreen setImage:forwardButtonImage forState:UIControlStateNormal];
//    [currentSeekForwardButtoninFullScreen addTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
//    //[currentSeekForwardButtoninFullScreen addTarget:self action:@selector(swipeOutSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
//    [currentSeekForwardButton removeTarget:self action:globals.CURRENT_SEEK_FORWARD_ACTION forControlEvents:UIControlEventTouchUpInside];
//    UILongPressGestureRecognizer *seekForwardLongpressgesture = [[UILongPressGestureRecognizer alloc]
//                                                                 initWithTarget:self action:@selector(handleLongPress:)];
//    seekForwardLongpressgesture.minimumPressDuration = 0.5; //seconds
//    seekForwardLongpressgesture.delegate = self;
//    [currentSeekForwardButtoninFullScreen addGestureRecognizer:seekForwardLongpressgesture];
//
//    //uiview contains three seek back modes: go forward 5s, 1s, 0.25s
//    seekForwardControlViewinFullScreen = [[UIView alloc]initWithFrame:CGRectMake(currentSeekForwardButtoninFullScreen.frame.origin.x , 460,currentSeekBackButtoninFullScreen.frame.size.width +6,3.5*currentSeekBackButtoninFullScreen.frame.size.height)];
//    [seekForwardControlViewinFullScreen setBackgroundColor:[UIColor colorWithRed:(195/255.0) green:(207/255.0) blue:(216/255.0) alpha:0.1]];
//    seekForwardControlViewinFullScreen.hidden = TRUE;
//
//    //go back 0.25s
//    CustomButton *forwardQuarterSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
//    [forwardQuarterSecButtoninFullScreen setFrame:CGRectMake(0, 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
//    [forwardQuarterSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [forwardQuarterSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
//    [forwardQuarterSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardquarterseclarge.png"] forState:UIControlStateNormal];
//    [forwardQuarterSecButtoninFullScreen addTarget:self action:@selector(seekForwardQuarterSecond:) forControlEvents:UIControlEventTouchUpInside];
//    [forwardQuarterSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
//    [seekForwardControlViewinFullScreen addSubview:forwardQuarterSecButtoninFullScreen];
//
//    //go back 1 s
//    CustomButton *forwardOneSecButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
//    [forwardOneSecButtoninFullScreen setFrame:CGRectMake(0, forwardQuarterSecButtoninFullScreen.frame.origin.y + forwardQuarterSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
//    [forwardOneSecButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [forwardOneSecButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
//    [forwardOneSecButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardoneseclarge.png"] forState:UIControlStateNormal];
//    [forwardOneSecButtoninFullScreen addTarget:self action:@selector(seekForwardOneSecond:) forControlEvents:UIControlEventTouchUpInside];
//    [forwardOneSecButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
//    [seekForwardControlViewinFullScreen addSubview:forwardOneSecButtoninFullScreen];
//
//    //go back 5 s
//    CustomButton *forwardFiveSecsButtoninFullScreen = [CustomButton buttonWithType:UIButtonTypeCustom];
//    [forwardFiveSecsButtoninFullScreen setFrame:CGRectMake(0, forwardOneSecButtoninFullScreen.frame.origin.y + forwardOneSecButtoninFullScreen.frame.size.height + 10, currentSeekBackButtoninFullScreen.frame.size.width, currentSeekBackButtoninFullScreen.frame.size.height)];
//    [forwardFiveSecsButtoninFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//    [forwardFiveSecsButtoninFullScreen setAccessibilityLabel:@"fullscreen"];
//    [forwardFiveSecsButtoninFullScreen setImage:[UIImage imageNamed:@"seekforwardfivesecslarge.png"] forState:UIControlStateNormal];
//    [forwardFiveSecsButtoninFullScreen addTarget:self action:@selector(seekForwardFiveSeconds:) forControlEvents:UIControlEventTouchUpInside];
//    [forwardFiveSecsButtoninFullScreen addTarget:self action:@selector(hideSeekControlView:) forControlEvents:UIControlEventTouchDragInside];
//    [seekForwardControlViewinFullScreen addSubview:forwardFiveSecsButtoninFullScreen];
//
//
//    //slow mode button
//    slowMoButtonFullScreen =  [CustomButton buttonWithType:UIButtonTypeCustom];
//    slowMoButtonFullScreen = [[CustomButton alloc]initWithFrame:CGRectMake(currentSeekBackButtoninFullScreen.frame.origin.x + currentSeekBackButtoninFullScreen.frame.size.width + 20,currentSeekBackButtoninFullScreen.frame.origin.y + 10,65 ,50)];
//    [slowMoButtonFullScreen setContentMode:UIViewContentModeScaleAspectFill];
//
//    if(globals.PLAYBACK_SPEED == 1.0f)
//    {
//        [slowMoButtonFullScreen setImage:[UIImage imageNamed:@"normalsp.png"] forState:UIControlStateNormal];
//
//    }else {
//        [slowMoButtonFullScreen setImage:[UIImage imageNamed:@"slowmo.png"] forState:UIControlStateNormal];
//
//    }
//    [slowMoButtonFullScreen addTarget:self action:@selector(slowMoController:) forControlEvents:UIControlEventTouchUpInside];
//
//
//    //play previous tag in the uitableview
//    playPreTagFullScreen =[[BorderButton alloc]init];
//    //[playPreTagFullScreen setBackgroundImage:[UIImage imageNamed:@"tab-bar.png"] forState:UIControlStateNormal];
//    [playPreTagFullScreen setTitle:@"PREVIOUS" forState:UIControlStateNormal];
//    [playPreTagFullScreen.titleLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
//    [playPreTagFullScreen.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [playPreTagFullScreen addTarget:self action:@selector(playPreTag:) forControlEvents:UIControlEventTouchUpInside];
//    playPreTagFullScreen.alpha = 1.0;
//    playPreTagFullScreen.frame = CGRectMake(currentSeekBackButtoninFullScreen.frame.origin.x + currentSeekBackButtoninFullScreen.frame.size.width + 100,startRangeModifierButtonFullScreen.frame.origin.y + 10,100 ,30);
//
//    //play next tag in the uitableview
//    playNextTagFullScreen =[[BorderButton alloc]init];
//    //[playNextTagFullScreen setBackgroundImage:[UIImage imageNamed:@"tab-bar.png"] forState:UIControlStateNormal];
//    [playNextTagFullScreen setTitle:@"NEXT" forState:UIControlStateNormal];
//    [playNextTagFullScreen.titleLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
//    [playNextTagFullScreen.titleLabel setTextAlignment:NSTextAlignmentCenter];
//    [playNextTagFullScreen addTarget:self action:@selector(playNextTag:) forControlEvents:UIControlEventTouchUpInside];
//    playNextTagFullScreen.alpha = 1.0;
//    playNextTagFullScreen.frame = CGRectMake(currentSeekForwardButtoninFullScreen.frame.origin.x - 150,playPreTagFullScreen.frame.origin.y,100 ,30);
//
//    //download clip
//    ListViewCell *cell;
//    if (wasPlayingIndexPath) {
//        cell = (ListViewCell*)[myTableView cellForRowAtIndexPath:wasPlayingIndexPath];
//    }
//    downloadTagFullScreen =[[DownloadButton alloc]init];
//    if (![[[globals.BOOKMARK_TAGS objectForKey:[currentPlayingTag objectForKey:@"event"]] allKeys] containsObject:[NSString stringWithFormat:@"%@",[currentPlayingTag objectForKey:@"id"]]]) {
//        if ([[downloadingTagsDict objectForKey:[currentPlayingTag objectForKey:@"event"]] containsObject:[currentPlayingTag objectForKey:@"id"]]) {
//            [downloadTagFullScreen setState:DBDownloading];
//            if (cell) {
//                [cell.bookmarkButton setState:DBDownloading];
//            }
//        }else{
//            [downloadTagFullScreen setState:DBDefault];
//            if (cell) {
//                [cell.bookmarkButton setState:DBDefault];
//            }
//        }
//    }else{
//        [downloadTagFullScreen setState:DBDownloaded];
//        if (cell) {
//            [cell.bookmarkButton setState:DBDownloaded];
//        }
//    }
//    [downloadTagFullScreen addTarget:self action:@selector(bookmarkSelected:event:) forControlEvents:UIControlEventTouchUpInside];
//    downloadTagFullScreen.alpha = 1.0;
//    downloadTagFullScreen.frame = CGRectMake(954,startRangeModifierButtonFullScreen.frame.origin.y+10,35 ,32);
//
//    //current playing tag name
//    tagEventNameFullScreen =[[UILabel alloc]init];
//    [tagEventNameFullScreen setBackgroundColor:[UIColor clearColor]];
//    tagEventNameFullScreen.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
//    tagEventNameFullScreen.layer.borderWidth = 1;
//    [tagEventNameFullScreen setText:[currentPlayingTag objectForKey:@"name"]];
//    [tagEventNameFullScreen setTextColor:PRIMARY_APP_COLOR];
//    [tagEventNameFullScreen setFont:[UIFont boldFontOfSize:20.f]];
//    [tagEventNameFullScreen setTextAlignment:NSTextAlignmentCenter];
//    tagEventNameFullScreen.alpha = 1.0f;
//    tagEventNameFullScreen.frame = CGRectMake(430,startRangeModifierButtonFullScreen.frame.origin.y,140 ,50);
//
//
//
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:startRangeModifierButtonFullScreen];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:endRangeModifierButtonFullScreen];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:tagEventNameFullScreen];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:slowMoButtonFullScreen];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playNextTagFullScreen];
//     [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:downloadTagFullScreen];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playPreTagFullScreen];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:currentSeekBackButtoninFullScreen];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view  addSubview:currentSeekForwardButtoninFullScreen];
//    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:currentSeekForwardButtoninFullScreen];
//     [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:seekForwardControlViewinFullScreen];
//     [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:seekBackControlViewinFullScreen];
//
//
//
//    if (!wasPlayingIndexPath) {
//        //if no tag is selected, hide all the controls for tag looping
//        [tagEventNameFullScreen setHidden: TRUE];
//        [playNextTagFullScreen setHidden:TRUE];
//        [downloadTagFullScreen setHidden:TRUE];
//        [playPreTagFullScreen setHidden:TRUE];
//        [startRangeModifierButtonFullScreen setHidden:TRUE];
//        [endRangeModifierButtonFullScreen setHidden:TRUE];
//    }else{
//        //looping tags, show all the controls
//        [tagEventNameFullScreen setHidden: FALSE];
//        [playNextTagFullScreen setHidden:FALSE];
//        [downloadTagFullScreen setHidden:FALSE];
//        [playPreTagFullScreen setHidden:FALSE];
//        [startRangeModifierButtonFullScreen setHidden:FALSE];
//        [endRangeModifierButtonFullScreen setHidden:FALSE];
//    }
//    if ([[currentPlayingTag objectForKey:@"type"]intValue] != 4) {
//        //show telestration button
//        [self showTeleButton];
//        //when it is local playback
//        if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@"mp4"].location != NSNotFound) {
//            [self showPlaybackRateControls];
//        }
//
//    }
//
//}

////remove all the controls in fullscreen
//-(void)removeAllFullScreenSubviews{
//    //[self.moviePlayer setFullscreen:YES animated:YES];
//    [startRangeModifierButtonFullScreen removeFromSuperview];
//    [endRangeModifierButtonFullScreen removeFromSuperview];
//    [tagEventNameFullScreen removeFromSuperview];
//    [slowMoButtonFullScreen removeFromSuperview];
//    [playNextTagFullScreen removeFromSuperview];
//    [downloadTagFullScreen removeFromSuperview];
//    [playPreTagFullScreen removeFromSuperview];
//    [teleButton removeFromSuperview];
//    [playbackRateForwardButton removeFromSuperview];
//    [playbackRateForwardGuide removeFromSuperview];
//    [playbackRateForwardLabel removeFromSuperview];
//    [playbackRateBackButton removeFromSuperview];
//    [playbackRateBackGuide removeFromSuperview];
//    [playbackRateBackLabel removeFromSuperview];
//    [currentSeekForwardButtoninFullScreen removeFromSuperview];
//    [currentSeekBackButtoninFullScreen removeFromSuperview];
//    [seekBackControlViewinFullScreen removeFromSuperview];
//    [seekForwardControlViewinFullScreen removeFromSuperview];
//}
//
////hide all the controls in fullscreen
//-(void)hideFullScreenOverlayButtonsinLoopMode{
//    [slowMoButtonFullScreen setHidden:TRUE];
//    [playNextTagFullScreen setHidden:TRUE];
//    [downloadTagFullScreen setHidden:TRUE];
//    [playPreTagFullScreen setHidden:TRUE];
//    [currentSeekForwardButtoninFullScreen setHidden:TRUE];
//    [currentSeekBackButtoninFullScreen setHidden:TRUE];
//    [seekForwardControlViewinFullScreen setHidden:TRUE];
//    [seekBackControlViewinFullScreen setHidden:TRUE];
//    [tagEventNameFullScreen setHidden:TRUE];
//    [startRangeModifierButtonFullScreen setHidden:TRUE];
//    [endRangeModifierButtonFullScreen setHidden:TRUE];
//}
//
////display all the controls in fullscreen
//-(void)showFullScreenOverlayButtons{
//    [slowMoButtonFullScreen setHidden:FALSE];
//    [currentSeekForwardButtoninFullScreen setHidden:FALSE];
//    [currentSeekBackButtoninFullScreen setHidden:FALSE];
//}
//
////display all the controls in fullscreen in loop mode
//-(void)showFullScreenOverlayButtonsinLoopMode{
//    [slowMoButtonFullScreen setHidden:FALSE];
//    [playNextTagFullScreen setHidden:FALSE];
//    [downloadTagFullScreen setHidden:FALSE];
//    [playPreTagFullScreen setHidden:FALSE];
//    [currentSeekForwardButtoninFullScreen setHidden:FALSE];
//    [currentSeekBackButtoninFullScreen setHidden:FALSE];
//    [tagEventNameFullScreen setHidden:FALSE];
//    [startRangeModifierButtonFullScreen setHidden:FALSE];
//    [endRangeModifierButtonFullScreen setHidden:FALSE];
//}
//
////play the next tag in the list view table
//-(void)playNextTag:(id)sender{
//    if(wasPlayingIndexPath.row + 1 > self.tagsToDisplay.count -1){
//        return;
//    }
////    globals.PLAYBACK_SPEED = 1.0f;
//    NSIndexPath *nextPath = [NSIndexPath indexPathForRow:wasPlayingIndexPath.row + 1 inSection:wasPlayingIndexPath.section];
//    [_tableViewController tableView:_tableViewController.tableView didSelectRowAtIndexPath:nextPath];
//    //ListViewCell *cell = (ListViewCell*)[myTableView cellForRowAtIndexPath:nextPath];
//    NSDictionary *tag = [self.tagsToDisplay objectAtIndex: nextPath.row];
////    if (![[[globals.BOOKMARK_TAGS objectForKey:[tag objectForKey:@"event"]] allKeys] containsObject:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]]) {
////        if ([[downloadingTagsDict objectForKey:[currentPlayingTag objectForKey:@"event"]]  containsObject:[tag objectForKey:@"id"]]) {
////            [downloadTagFullScreen setState:DBDownloading];
////            [cell.bookmarkButton setState:DBDownloading];
////        }else{
////            [downloadTagFullScreen setState:DBDefault];
////            [cell.bookmarkButton setState:DBDefault];
////        }
////    }else{
////        [downloadTagFullScreen setState:DBDownloaded];
////        [cell.bookmarkButton setState:DBDownloading];
////    }
//    [tagEventNameFullScreen setText:[tag objectForKey:@"name"]];
//
//}

//play the previous tag in the list view table
-(void)playPreTag:(id)sender{
    if(wasPlayingIndexPath.row - 1 < 0){
        return;
    }
    //    globals.PLAYBACK_SPEED = 1.0f;
    NSIndexPath *prePath = [NSIndexPath indexPathForRow:wasPlayingIndexPath.row - 1 inSection:wasPlayingIndexPath.section];
    [_tableViewController tableView:_tableViewController.tableView didSelectRowAtIndexPath: prePath];
    //ListViewCell *cell = (ListViewCell*)[myTableView cellForRowAtIndexPath:prePath];
    NSDictionary *tag = [self.tagsToDisplay objectAtIndex:prePath.row];
    //    if (![[[globals.BOOKMARK_TAGS objectForKey:[tag objectForKey:@"event"]] allKeys] containsObject:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]]) {
    //        if ([[downloadingTagsDict objectForKey:[currentPlayingTag objectForKey:@"event"]]  containsObject:[tag objectForKey:@"id"]]) {
    //            [downloadTagFullScreen setState:DBDownloading];
    //            [cell.bookmarkButton setState:DBDownloading];
    //        }else{
    //            [downloadTagFullScreen setState:DBDefault];
    //            [cell.bookmarkButton setState:DBDefault];
    //        }
    //    }else{
    //        [downloadTagFullScreen setState:DBDownloaded];
    //        [cell.bookmarkButton setState:DBDownloaded];
    //    }
    [tagEventNameFullScreen setText:[tag objectForKey:@"name"]];
    
}

//show the telestration button
-(void)showTeleButton
{
    if (_teleButton) {
        [_teleButton removeFromSuperview];
        _teleButton = nil;
    }
    _teleButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    [_teleButton setFrame:CGRectMake(939.0f, 400.0f, 64.0f, 64.0f)];
    [_teleButton setContentMode:UIViewContentModeScaleAspectFill];
    [_teleButton setImage:[UIImage imageNamed:@"teleButton"] forState:UIControlStateNormal];
    [_teleButton setImage:[UIImage imageNamed:@"teleButtonSelect"] forState:UIControlStateHighlighted];
    //teleButton.transform=CGAffineTransformMakeRotation(M_PI/2);
    [_teleButton addTarget:self action:@selector(initTele:) forControlEvents:UIControlEventTouchUpInside];
    //need to be modified later
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:_teleButton];
}
-(void)showPlaybackRateControls
{
    //    if (globals.CURRENT_PLAYBACK_EVENT && globals.CURRENT_PLAYBACK_EVENT.length > 4) {
    //        if (!globals.IS_LOCAL_PLAYBACK && [[globals.CURRENT_PLAYBACK_EVENT substringWithRange:NSMakeRange(globals.CURRENT_PLAYBACK_EVENT.length - 4, 3)] isEqualToString:@"mp4"]) {
    //            NSLog(@"Is not local playback, but is an mp4");
    //        } else if (globals.IS_LOCAL_PLAYBACK && ![[globals.CURRENT_PLAYBACK_EVENT substringWithRange:NSMakeRange(globals.CURRENT_PLAYBACK_EVENT.length - 4, 3)] isEqualToString:@"mp4"]) {
    //            NSLog(@"Is local playback, but is not an mp4");
    //        }
    //    }
    //    if (!globals.IS_LOCAL_PLAYBACK) {
    //        return;
    //    }
    //    if (playbackRateBackButton){
    //        [playbackRateBackButton removeFromSuperview];
    //        playbackRateBackButton = nil;
    //        [playbackRateBackGuide removeFromSuperview];
    //        playbackRateBackGuide = nil;
    //        [playbackRateBackLabel removeFromSuperview];
    //        playbackRateBackLabel = nil;
    //    }
    //    if (playbackRateForwardButton){
    //        [playbackRateForwardButton removeFromSuperview];
    //        playbackRateForwardButton = nil;
    //        [playbackRateForwardGuide removeFromSuperview];
    //        playbackRateForwardGuide = nil;
    //        [playbackRateForwardLabel removeFromSuperview];
    //        playbackRateForwardLabel = nil;
    //    }
    //
    //    //Playback rate controls
    //    playbackRateBackButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    [playbackRateBackButton setFrame:CGRectMake(165, 585, 70.0f, 70.0f)];
    //    [playbackRateBackButton setContentMode:UIViewContentModeScaleAspectFit];
    //    [playbackRateBackButton setTag:0];
    //    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBack"] forState:UIControlStateNormal];
    //    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateHighlighted];
    //    [playbackRateBackButton setImage:[UIImage imageNamed:@"playbackRateButtonBackSelected"] forState:UIControlStateSelected];
    ////    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonDown:) forControlEvents:UIControlEventTouchDown];
    //    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    ////    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpOutside];
    ////    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragInside];
    ////    [playbackRateBackButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragOutside];
    //    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateBackButton];
    //
    //    playbackRateBackGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playbackRateTrackBack"]];
    //    [playbackRateBackGuide setFrame:CGRectMake(playbackRateBackButton.frame.origin.x - 148, playbackRateBackButton.frame.origin.y - 146, playbackRateBackGuide.bounds.size.width, playbackRateBackGuide.bounds.size.height)];
    //    [playbackRateBackGuide setContentMode:UIViewContentModeScaleAspectFit];
    //    [playbackRateBackGuide setAlpha:0.0f];
    ////    [[UIApplication sharedApplication].keyWindow.rootViewController.view insertSubview:playbackRateBackGuide belowSubview:playbackRateBackButton];
    //
    //    playbackRateBackLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    //    [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(playbackRateBackButton.frame), playbackRateBackButton.frame.origin.y, 60.0f, 30.0f)];
    //    [playbackRateBackLabel setText:@"-2x"];
    //    [playbackRateBackLabel setTextAlignment:NSTextAlignmentCenter];
    //    [playbackRateBackLabel.layer setCornerRadius:4.0f];
    //    [playbackRateBackLabel setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f]];
    //    [playbackRateBackLabel setAlpha:0.0f];
    //    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateBackLabel];
    //
    //    playbackRateForwardButton = [CustomButton buttonWithType:UIButtonTypeCustom];
    //    [playbackRateForwardButton setFrame:CGRectMake(playbackRateBackButton.superview.bounds.size.width - playbackRateBackButton.frame.origin.x - playbackRateBackButton.bounds.size.width, playbackRateBackButton.frame.origin.y, playbackRateBackButton.bounds.size.width, playbackRateBackButton.bounds.size.height)];
    //    [playbackRateForwardButton setContentMode:UIViewContentModeScaleAspectFit];
    //    [playbackRateForwardButton setTag:1];
    //    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForward"] forState:UIControlStateNormal];
    //    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForwardSelected"] forState:UIControlStateHighlighted];
    //    [playbackRateForwardButton setImage:[UIImage imageNamed:@"playbackRateButtonForwardSelected"] forState:UIControlStateSelected];
    ////    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonDown:) forControlEvents:UIControlEventTouchDown];
    //    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    ////    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonUp:) forControlEvents:UIControlEventTouchUpOutside];
    ////    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragInside];
    ////    [playbackRateForwardButton addTarget:self action:@selector(playbackRateButtonDrag:forEvent:) forControlEvents:UIControlEventTouchDragOutside];
    //    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateForwardButton];
    //
    //    playbackRateForwardGuide = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playbackRateTrackForward"]];
    //    [playbackRateForwardGuide setFrame:CGRectMake(playbackRateForwardButton.superview.bounds.size.width - playbackRateBackGuide.bounds.size.width - (playbackRateBackButton.frame.origin.x - 148), playbackRateBackGuide.frame.origin.y, playbackRateBackGuide.bounds.size.width, playbackRateBackGuide.bounds.size.height)];
    //    [playbackRateForwardGuide setContentMode:UIViewContentModeScaleAspectFit];
    //    [playbackRateForwardGuide setAlpha:0.0f];
    ////    [[UIApplication sharedApplication].keyWindow.rootViewController.view insertSubview:playbackRateForwardGuide belowSubview:playbackRateForwardButton];
    //
    //    playbackRateForwardLabel = [CustomLabel labelWithStyle:CLStyleWhite];
    //    [playbackRateForwardLabel setFrame:CGRectMake(playbackRateForwardButton.frame.origin.x - playbackRateBackLabel.bounds.size.width, playbackRateForwardButton.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
    //    [playbackRateForwardLabel setText:@"2x"];
    //    [playbackRateForwardLabel setTextAlignment:NSTextAlignmentCenter];
    //    [playbackRateForwardLabel.layer setCornerRadius:4.0f];
    //    [playbackRateForwardLabel setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f]];
    //    [playbackRateForwardLabel setAlpha:0.0f];
    //    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:playbackRateForwardLabel];
}

-(void)playbackRateButtonDown:(id)sender{
    isModifyingPlaybackRate = YES;
    if ([sender tag] == 0) {
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateBackGuide setAlpha:1.0f];
            [playbackRateBackLabel setAlpha:1.0f];
        }];
        [self startFrameByFrameScrollingAtInterval:0.5f goingForward:NO];
    } else if ([sender tag] == 1){
        [UIView animateWithDuration:0.3f animations:^{
            [playbackRateForwardGuide setAlpha:1.0f];
            [playbackRateForwardLabel setAlpha:1.0f];
        }];
        [self startFrameByFrameScrollingAtInterval:0.5f goingForward:YES];
    }
    // [videoPlayer pause];
}

-(void)playbackRateButtonUp:(id)sender{
    
    /* Uncomment for cool sliding speed control
     isModifyingPlaybackRate = NO;
     isFrameByFrame = NO;
     if ([sender tag] == 0) {
     [UIView animateWithDuration:0.3f animations:^{
     [playbackRateBackGuide setAlpha:0.0f];
     [playbackRateBackButton setFrame:CGRectMake(165, 535, 70.0f, 70.0f)];
     [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(playbackRateBackButton.frame), playbackRateBackButton.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
     [playbackRateBackLabel setAlpha:0.0f];
     }];
     } else if ([sender tag] == 1){
     [UIView animateWithDuration:0.3f animations:^{
     [playbackRateForwardGuide setAlpha:0.0f];
     [playbackRateForwardButton setFrame:CGRectMake(playbackRateBackButton.superview.bounds.size.width - playbackRateBackButton.frame.origin.x - playbackRateBackButton.bounds.size.width, playbackRateBackButton.frame.origin.y, playbackRateBackButton.bounds.size.width, playbackRateBackButton.bounds.size.height)];
     [playbackRateForwardLabel setFrame:CGRectMake(playbackRateForwardButton.frame.origin.x - playbackRateForwardLabel.bounds.size.width, playbackRateForwardButton.frame.origin.y, playbackRateForwardLabel.bounds.size.width, playbackRateForwardLabel.bounds.size.height)];
     [playbackRateForwardLabel setAlpha:0.0f];
     
     }];
     }
     [videoPlayer pause];
     */
    //    if ([sender isSelected]) {
    //        [sender setSelected:NO];
    //        globals.PLAYBACK_SPEED = 0.0f;
    //        [videoPlayer.avPlayer setRate:globals.PLAYBACK_SPEED];
    //    } else {
    //        if ([sender tag] == 0) {
    //            globals.PLAYBACK_SPEED = -2.0f;
    //        } else {
    //            globals.PLAYBACK_SPEED = 2.0f;
    //        }
    //        [sender setSelected:YES];
    //        [videoPlayer.avPlayer setRate:globals.PLAYBACK_SPEED];
    //    }
}

-(void)playbackRateButtonDrag:(id)sender forEvent:(UIEvent*)event{
    //    UIButton* button = sender;
    //    UITouch *touch = [[event touchesForView:button] anyObject];
    //    CGPoint touchPoint = [touch locationInView:button.superview];
    //    CGPoint buttonPosition = [self coordForPosition:touchPoint onGuide:[button tag]];
    //    [button setCenter:buttonPosition];
    //    if ([button tag] == 0) {
    //        [playbackRateBackLabel setFrame:CGRectMake(CGRectGetMaxX(button.frame), button.frame.origin.y, playbackRateBackLabel.bounds.size.width, playbackRateBackLabel.bounds.size.height)];
    //        if (isFrameByFrame) {
    //            [playbackRateBackLabel setText:[NSString stringWithFormat:@"-%.0ffps",1/frameByFrameInterval]];
    //        } else {
    //            [playbackRateBackLabel setText:[NSString stringWithFormat:@"%.2fx",globals.PLAYBACK_SPEED]];
    //        }
    //    } else if ([button tag] == 1){
    //        [playbackRateForwardLabel setFrame:CGRectMake(button.frame.origin.x - playbackRateForwardLabel.bounds.size.width, button.frame.origin.y, playbackRateForwardLabel.bounds.size.width, playbackRateForwardLabel.bounds.size.height)];
    //        if (isFrameByFrame) {
    //            [playbackRateForwardLabel setText:[NSString stringWithFormat:@"%.0ffps",1/frameByFrameInterval]];
    //        } else {
    //            [playbackRateForwardLabel setText:[NSString stringWithFormat:@"%.2fx",globals.PLAYBACK_SPEED]];
    //        }
    //    }
    //    if (videoPlayer.avPlayer.rate != globals.PLAYBACK_SPEED) {
    //        videoPlayer.avPlayer.rate = globals.PLAYBACK_SPEED;
    //    }
}

-(CGPoint)coordForPosition:(CGPoint)point onGuide:(int)tag{
    float yPos = 0.0f;
    float xPos = 0.0f;
    CGPoint guidePivot;
    float theta = 0.0f;
    float degrees = 0.0f;
    playbackRateRadius = 118.0f + _playbackRateBackButton.bounds.size.width/2;
    if (tag == 0){
        guidePivot = CGPointMake(playbackRateBackGuide.frame.origin.x + 30.0f, CGRectGetMaxY(playbackRateBackGuide.frame) - 25.0f);
        theta = atan2f(point.y - guidePivot.y, point.x - guidePivot.x);
        if (theta*180/M_PI < -87){
            theta = -87*M_PI/180;
        } else if (theta*180/M_PI > -3){
            theta = -3*M_PI/180;
        }
        degrees = -(theta*180.0f/M_PI);
        float degRange = 84.0f;
        float increment = degRange/6;
        
        if (degrees <= 3){
            [self startFrameByFrameScrollingAtInterval:0.5f goingForward:FALSE];
        } else if (degrees > 3 && degrees < increment*2){
            [self startFrameByFrameScrollingAtInterval:0.2f goingForward:FALSE];
        } else {
            isFrameByFrame = NO;
            //            if (degrees >= increment*2 && degrees < increment*3){
            //                globals.PLAYBACK_SPEED = 0.25f;
            //            } else if (degrees >= increment*3 && degrees < increment*4){
            //                globals.PLAYBACK_SPEED = 0.5f;
            //            } else if (degrees >= increment*4 && degrees < increment*5){
            //                globals.PLAYBACK_SPEED = 1.0f;
            //            } else if (degrees >= increment*5 && degrees < (increment*6 - 1)){
            //                globals.PLAYBACK_SPEED = 2.0f;
            //            } else if (degrees >= (increment*6 - 3)){
            //                globals.PLAYBACK_SPEED = 4.0f;
            //            }
        }
        //        globals.PLAYBACK_SPEED = -globals.PLAYBACK_SPEED;
        
        yPos = sinf(theta)*playbackRateRadius;
        xPos = cosf(theta)*playbackRateRadius;
        yPos += guidePivot.y;
        xPos += guidePivot.x;
    } else if (tag == 1){
        guidePivot = CGPointMake(CGRectGetMaxX(playbackRateForwardGuide.frame) - 30.0f, CGRectGetMaxY(playbackRateForwardGuide.frame) - 25.0f);
        theta = atan2f(point.y - guidePivot.y, guidePivot.x - point.x);
        if (theta*180/M_PI < -87){
            theta = -87*M_PI/180;
        } else if (theta*180/M_PI > -3){
            theta = -3*M_PI/180;
        }
        degrees = -(theta*180.0f/M_PI);
        float degRange = 84.0f;
        float increment = degRange/6;
        
        if (degrees <= 3){
            [self startFrameByFrameScrollingAtInterval:0.5f goingForward:TRUE];
        } else if (degrees > 3 && degrees < increment*2){
            [self startFrameByFrameScrollingAtInterval:0.2f goingForward:TRUE];
        } else {
            //            isFrameByFrame = NO;
            //            if (degrees >= increment*2 && degrees < increment*3){
            //                globals.PLAYBACK_SPEED = 0.25f;
            //            } else if (degrees >= increment*3 && degrees < increment*4){
            //                globals.PLAYBACK_SPEED = 0.5f;
            //            } else if (degrees >= increment*4 && degrees < increment*5){
            //                globals.PLAYBACK_SPEED = 1.0f;
            //            } else if (degrees >= increment*5 && degrees < (increment*6 - 1)){
            //                globals.PLAYBACK_SPEED = 2.0f;
            //            } else if (degrees >= (increment*6 - 3)){
            //                globals.PLAYBACK_SPEED = 4.0f;
            //            }
        }
        
        
        yPos = sinf(theta)*playbackRateRadius;
        xPos = cosf(theta)*playbackRateRadius;
        yPos += guidePivot.y;
        xPos -= guidePivot.x;
        xPos = -xPos;
    }
    return CGPointMake(xPos, yPos);
}

- (void)startFrameByFrameScrollingAtInterval:(float)interval goingForward:(BOOL)forward{
    frameByFrameInterval = interval;
    if (isFrameByFrame) {
        return;
    } else {
        isFrameByFrame = YES;
    }
    if (forward){
        [self frameByFrameForward];
    } else {
        [self frameByFrameBackward];
    }
    
}
- (void)frameByFrameForward{
    if (isFrameByFrame) {
        //  [videoPlayer.avPlayer.currentItem stepByCount:1];
        [NSTimer scheduledTimerWithTimeInterval:frameByFrameInterval target:self selector:@selector(frameByFrameForward) userInfo:nil repeats:NO];
    }
}
- (void)frameByFrameBackward{
    if (isFrameByFrame) {
        // [videoPlayer.avPlayer.currentItem stepByCount:-1];
        [NSTimer scheduledTimerWithTimeInterval:frameByFrameInterval target:self selector:@selector(frameByFrameBackward) userInfo:nil repeats:NO];
    }
}


/*
 *--------------------
 *After updating to iOS7.1, avplayer might gives us negative video start time(this value randomly changes while the video plays) and video's current time is also based on this start time.
 *For example: Start time is -2 sec and current time is 50 sec which could be mapped to start time is 0 sec, the current time value is 52 sec or start time is -3 sec current time is 49 sec;
 *When user pauses the video, get the current tele time and the current video's start time.
 *After finishing telestartion, send the tag information dictionary to the server and the tag time in the dictionary will be: (tele time) - (start time), which is "52" in our example;
 *The time sent to the server is always based on start time is 0;
 *When reviewing the telestration, the avplayer will seek to is right tele time base on the video's new start time which is (tag time) + (new start time).
 *--------------------
 */
//create telestration screen
-(void)initTele:(id)sender
{
    //when show the telestration screen, hide all the buttons in full screen and only diaplay save button and clear button for telestration
    //[self hideFullScreenOverlayButtonsinLoopMode];
    //pause the video
    // [videoPlayer pause];
    //get the current time for telestartion time but round it into integer; Otherwise playback telestration will be off a lot
    //CMTime currentCMTime = videoPlayer.avPlayer.currentTime;
    //    globals.TELE_TIME = (float)[self roundValue:CMTimeGetSeconds(currentCMTime)];
    
    //resize the video player
    //videoPlayer.playerFrame = CGRectMake(0, 0, 748, 1024);
    
    //if the mp4 file is played right now
    //    if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location != NSNotFound) {
    //
    //        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    //
    //        saveTeleButton = [BorderButton buttonWithType:UIButtonTypeCustom];
    //        [saveTeleButton setFrame:CGRectMake(377.0f, 700.0f, 123.0f, 33.0f)];
    //        [saveTeleButton setTitle:@"Save" forState:UIControlStateNormal];
    //        [saveTeleButton addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    //        [rootView addSubview:saveTeleButton];
    //
    //        clearTeleButton = [BorderButton buttonWithType:UIButtonTypeCustom];
    //        [clearTeleButton setFrame:CGRectMake(CGRectGetMaxX(saveTeleButton.frame) + 15.0f, saveTeleButton.frame.origin.y, saveTeleButton.frame.size.width, saveTeleButton.frame.size.height)];
    //        [clearTeleButton setTitle:@"Close" forState:UIControlStateNormal];
    //        [clearTeleButton addTarget:self action:@selector(clearButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    //        [rootView addSubview:clearTeleButton];
    //
    //
    //        //add televiewcontroller
    //        self.teleViewController= [[TeleViewController alloc] initWithController:self];
    //        [self.teleViewController.view setFrame:CGRectMake(0, 45, self.view.frame.size.width,self.view.frame.size.width * 9/16 + 10)];
    //        [self.teleViewController.view setBackgroundColor:[UIColor magentaColor]];
    //        self.teleViewController.clearButton = clearTeleButton;
    //        [teleButton setHidden:TRUE];
    //        [rootView addSubview:self.teleViewController.view];
    //
    //        [rootView bringSubviewToFront:saveTeleButton];
    //        [rootView bringSubviewToFront:clearTeleButton];
    //
    //
    //        NSURL *videoURL = globals.VIDEO_PLAYER_LIVE2BENCH.videoURL;
    //        AVAsset *asset = [AVAsset assetWithURL:videoURL];
    //        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    //        [imageGenerator setMaximumSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.width * 9/16 + 10)];
    //        CMTime time = currentCMTime;//CMTimeMake([[dict objectForKey:@"time"]floatValue],1);//CMTimeMake(30, 1);
    //        ////////NSLog(@"%f", [[dict objectForKey:@"time"]floatValue]);
    //        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    //        UIImage *currentImage = [UIImage imageWithCGImage:imageRef];
    //        CGImageRelease(imageRef);
    //
    //        self.teleViewController.currentImage = currentImage;//[self imageWithImage:currentImage convertToSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.width * 9/16)];//currentImage;
    //        self.teleViewController.thumbImageView = [[UIImageView alloc] initWithImage:currentImage];//[UIImage imageNamed:@"test.jpg"]];
    //        [self.teleViewController.thumbImageView setFrame:self.teleViewController.view.frame];//CGRectMake(0, -10, 1024,768)];
    //        [self.teleViewController.thumbImageView setBackgroundColor:[UIColor blackColor]];
    //        [self.teleViewController.view insertSubview:self.teleViewController.thumbImageView atIndex:0];
    //
    //    }else{
    //
    //        //if the mp4 video file not exist
    //
    //        //add televiewcontroller
    //        self.teleViewController= [[TeleViewController alloc] initWithController:self];
    //
    //        globals.TELE_TIME = [videoPlayer currentTimeInSeconds];
    //        self.teleViewController.offsetTime = videoPlayer.startTime;
    //        [self.teleViewController.view setFrame:CGRectMake(0, 10, 1024, 768)];
    //        [self.teleButton setHidden:TRUE];
    //        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.teleViewController.view];
    //
    //
    //    }
    
}


//save button clicked, send notification to the teleview controller
-(void)saveButtonClicked{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Save Tele" object:nil];
}

//clear button clicked, send notification to the teleview controller
-(void)clearButtonClicked{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Clear Tele" object:nil];
}


////round the float value to int
//-(int)roundValue:(float)numberToRound{
//    numberToRound = numberToRound;
//    if (self.videoPlayer.duration - numberToRound < 2) {
//        return (int)numberToRound;
//    }
//
//    return  (int)(numberToRound + 0.5);
//
//}

//set the right text for tag name label in fullscreen
-(void)setTagEventNameLabelText:(NSString*)name{
    [tagEventNameFullScreen setText:name];
}


//after finish commenting, touch any other part of the view except commentTextView, will resign the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //    UITouch *touch = [[event allTouches] anyObject];
    //    if ([commentTextView isFirstResponder] && [touch view] != commentTextView) {
    //        [commentTextView resignFirstResponder];
    //    }
    [super touchesBegan:touches withEvent:event];
}

//download tags which were not finished before
-(void)sendBookmarkRequest{
    
    //    //NSLog(@"download unfinished tags");
    //    //command this because ceci's one event makes the whole downloading not working
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:globals.BOOKMARK_QUEUE_PATH])
    //    {
    //        globals.BOOKMARK_TAGS_UNFINISHED = [[NSMutableArray alloc] initWithContentsOfFile:globals.BOOKMARK_QUEUE_PATH];
    //
    //        [[NSFileManager defaultManager]removeItemAtPath:globals.BOOKMARK_QUEUE_PATH error:nil];
    //    }else{
    //        return;
    //    }
    //    if ([globals.BOOKMARK_TAGS_UNFINISHED count] > 0 && (!globals.BOOKMARK_QUEUE || globals.BOOKMARK_QUEUE.count == 0)){
    //       //NSLog(@"BOOKMARK_TAGS_UNFINISHED count = %d",globals.BOOKMARK_TAGS_UNFINISHED.count);
    ////        if (!convertNextBookmarkVideoTimer) {
    ////            convertNextBookmarkVideoTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(checkRequestStatus:) userInfo:nil repeats:YES];
    ////            [[NSRunLoop mainRunLoop] addTimer:convertNextBookmarkVideoTimer forMode:NSDefaultRunLoopMode];
    ////            //[convertNextBookmarkVideoTimer fire];
    ////        }
    //
    //        aCopyOfUnfinishedTags = [globals.BOOKMARK_TAGS_UNFINISHED mutableCopy];
    //        [self sendOneRequest];
    //    }
    
}

//this method is for bookmarking tags which were not finished from other events
//In this method, we will check if the tag is belongs to this event or not. If it is, download the video clip, else do nothing.
-(void)sendOneRequest{
    if (_aCopyOfUnfinishedTags.count < 1) {
        return;
    }
    NSDictionary *tag = [_aCopyOfUnfinishedTags objectAtIndex:0];
    //this version changed the type of tag info in globals.BOOKMARK_QUEUE_PATH file(Now: array of dictionaries, old: array of arrays);
    //After the user updated the app,the app may crash at the first time when the user launch the app.
    //So here, check if the tag info is an array, just return.
    if ([tag isKindOfClass:[NSArray class]]) {
        return;
    }
//    BOOL isEventInCurrentServer = FALSE;
//    NSString *eventNameStr;
    //check if the tag from live event or not. If it is, the event value is the request url will be @"live", else it will be [tag objectForKey:@"event"].
    //    if ([globals.EVENT_NAME isEqualToString:@"live"]) {
    //        if (globals.CURRENT_EVENT_THUMBNAILS.count > 0) {
    //            NSString *event = [[globals.CURRENT_EVENT_THUMBNAILS objectForKey:[[globals.CURRENT_EVENT_THUMBNAILS allKeys] objectAtIndex:0]] objectForKey:@"event"];
    //            if ([event isEqual:[tag objectForKey:@"event"]]) {
    //                eventNameStr = @"live";
    //                isEventInCurrentServer = TRUE;
    //            }else{
    //                eventNameStr = [tag objectForKey:@"event"];
    //            }
    //        }else{
    //            eventNameStr = [tag objectForKey:@"event"];
    //        }
    //    }else{
    //        eventNameStr = [tag objectForKey:@"event"];
    //    }
    
    //if tag is not from live event, check the event it belongs to is from current encoder or not. If it is not, we could not download anything
    //    if (!isEventInCurrentServer) {
    //        for(NSDictionary *event in globals.EVENTS_ON_SERVER){
    //            if ([[event objectForKey:@"name"] isEqualToString: [tag objectForKey:@"event"]] && ![[event objectForKey:@"deleted"] boolValue]){
    //                isEventInCurrentServer = TRUE;
    //            }
    //        }
    //    }
    //    [aCopyOfUnfinishedTags removeObject:tag];
    //
    //    //if the event the tag belongs to is from current encoder, send the bookmark request
    //    if (isEventInCurrentServer) {
    //        [globals.BOOKMARK_TAGS_UNFINISHED removeObject:tag];
    //        double currentSystemTime = CACurrentMediaTime();
    //        //Find path to accountInformation plist
    //        //array of file paths
    //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //        NSString *documentsDirectory = [paths objectAtIndex:0];
    //        NSString *accountInformationPath = [documentsDirectory stringByAppendingPathComponent:@"accountInformation.plist"];
    //        NSMutableDictionary *accountInfo = [[NSMutableDictionary alloc] initWithContentsOfFile: accountInformationPath];
    //        userId = [accountInfo objectForKey:@"hid"];
    //        NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",1],@"bookmark",eventNameStr,@"event",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",userId,@"user",[tag objectForKey:@"id"],@"id", nil];
    //        NSError *error;
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    //        NSString *jsonString;
    //        if (! jsonData) {
    //
    //        } else {
    //            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        }
    //
    //        NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
    //
    //        //callback method and parent view controller reference for the appqueue
    //        NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(tagModCallback:)],self,@"60", nil];
    //        NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller",@"timeout", nil];
    //        NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //
    //        NSMutableDictionary *dictionaryOfObj = [[NSMutableDictionary alloc]init];
    //        [dictionaryOfObj setObject:instObj forKey:url];
    //        //[tag setObject:[NSString stringWithFormat:@"%.0f",[[tag objectForKey:@"duration"]floatValue]+10] forKey:@"duration"];
    //        [dictionaryOfObj setObject:tag forKey:@"tag"];
    //
    //        if (!globals.BOOKMARK_QUEUE){
    //            globals.BOOKMARK_QUEUE = [NSMutableArray arrayWithObject:dictionaryOfObj];
    //        } else {
    //            [globals.BOOKMARK_QUEUE addObject:dictionaryOfObj];
    //        }
    //        [self sendTheNextRequest];
    //    }else{
    //
    //        //this the tag is from event in different encoder, then send the next tag
    //        [self sendOneRequest];
    //    }
    
    
}


-(BOOL)redownloadImageFromtheServer:(NSDictionary*)dict{
    //    //if thumbnail folder not exist, create a new one
    //    if(![fileManager fileExistsAtPath:globals.THUMBNAILS_PATH])
    //    {
    //        NSError *cError;
    //        [fileManager createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:TRUE attributes:nil error:&cError];
    //    }
    //
    //    NSURL *jurl = [[NSURL alloc]initWithString:[[dict objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //    NSString *imageName = [[dict objectForKey:@"url"] lastPathComponent];
    //    //thumbnail data
    //    NSData *imgData= [NSData dataWithContentsOfURL:jurl options:0 error:nil];
    //
    //    //image file path for current image
    //    NSString *filePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
    //
    //    NSData *imgTData;
    //    NSString *teleImageFilePath;
    //    //save telesteration thumb
    //    if([[dict objectForKey:@"type"]intValue]==4)
    //    {
    //        //tele image datat
    //        imgTData= [NSData dataWithContentsOfURL:[NSURL URLWithString:[[dict objectForKey:@"teleurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:0 error:nil];
    //        NSString *teleImageName = [[dict objectForKey:@"teleurl"] lastPathComponent];
    //        //image file path for telestration
    //        teleImageFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
    //
    //    }
    //
    //    if (([[dict objectForKey:@"type"]intValue]!=4 && imgData != nil )||([[dict objectForKey:@"type"]intValue]==4 && imgData != nil && imgTData != nil) ) {
    //
    //        [imgData writeToFile:filePath atomically:YES];
    //
    //        if ([[dict objectForKey:@"type"]intValue]==4) {
    //            [imgTData writeToFile:teleImageFilePath atomically:YES ];
    //        }
    //
    //        if (!globals.DOWNLOADED_THUMBNAILS_SET){
    //            globals.DOWNLOADED_THUMBNAILS_SET = [NSMutableArray arrayWithObject:[dict objectForKey:@"id"]];
    //        } else {
    //            [globals.DOWNLOADED_THUMBNAILS_SET addObject:[dict objectForKey:@"id"]];
    //        }
    //
    //        return TRUE;
    //    }else{
    return FALSE;
    //    }
    
}


////when scrubbing the slider, need to remove telestration
//-(void)scrubbingDestroyLoopMode{
//
//    //remove looptagobserver
//    if (loopTagObserver) {
//        [videoPlayer.avPlayer removeTimeObserver:loopTagObserver];
//        loopTagObserver = nil;
//    }
//    [tagEventName setHidden:TRUE];
////    globals.IS_LOOP_MODE = FALSE;
//
//    if(self.videoPlayer.teleBigView)
//    {
//        [self.videoPlayer.teleBigView removeFromSuperview];
//        self.videoPlayer.teleBigView=nil;
//    }
//
//}


//-(void)removeCurrentTimeObserver{
//    if (loopTagObserver) {
//        loopTagObserver = nil;
//    }
//}



- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
}

-(NSMutableArray *)filterAndSortTags:(NSArray *)tags {
    NSMutableArray *tagsToSort = [NSMutableArray arrayWithArray:tags];
    
    if (componentFilter) {
        componentFilter.rawTagArray = tagsToSort;
        tagsToSort = [NSMutableArray arrayWithArray:componentFilter.processedList];
    }
    
    return [self sortArrayFromHeaderBar:tagsToSort headerBarState:headerBar.headerBarSortType];
}

- (void)liveEventStopped:(NSNotification *)note {
    self.tagsToDisplay = nil;
    _tableViewController.tableData = [NSMutableArray array];
    [_tableViewController reloadData];
    
    selectedTag = nil;
    
    [commentingField clear];
    commentingField.enabled             = NO;
    [newVideoControlBar setTagName: nil];
}

@end