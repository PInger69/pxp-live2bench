
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
#import "ListViewFullScreenViewController.h"



#define SMALL_MEDIA_PLAYER_HEIGHT   340
#define TOTAL_WIDTH                1024
#define NOTCOACHPICK                  0
#define RATINGBUTTON_NOT_SELECT       0
#define IS_FULLSCREEN                 1 // dead?
#define LITTLE_ICON_DIMENSIONS       30
#define COMMENTBOX_HEIGHT           210
#define COMMENTBOX_WIDTH            530//520

@interface ListViewController ()

//@property (strong, nonatomic) L2BVideoBarViewController *videoBarViewController;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;
//@property (strong, nonatomic) FullScreenViewController *fullScreenViewController;
@property (strong, nonatomic) ListViewFullScreenViewController *listViewFullScreenViewController;
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
    
    Event                           * _currentEvent;
    id <EncoderProtocol>                _observedEncoder;
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
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTag:) name:@"NOTIF_DELETE_TAG" object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTag:) name:@"NOTIF_DELETE_SYNCED_TAG" object:nil];
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(listViewTagReceived:) name:NOTIF_TAG_RECEIVED object:nil];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveEventStopped:) name:NOTIF_LIVE_EVENT_STOPPED object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clear) name:NOTIF_EVENT_CHANGE object:nil];
        
               self.allTags = [[NSMutableArray alloc]init];
            self.tagsToDisplay = [[NSMutableArray alloc]init];
        _tableViewController = [[ListTableViewController alloc]init];
        _tableViewController.contextString = @"TAG";
        [self addChildViewController:_tableViewController];
        //_tableViewController.listViewControllerView = self.view;
        _tableViewController.tableData = self.tagsToDisplay;
        
        
        /*[[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_TAGS_ARE_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSLog(@"READY!");
            
            if (appDel.encoderManager.primaryEncoder == appDel.encoderManager.masterEncoder) {
                self.allTags = [ NSMutableArray arrayWithArray:[appDel.encoderManager.eventTags allValues]];
                    self.tagsToDisplay = [ NSMutableArray arrayWithArray:[appDel.encoderManager.eventTags allValues]];
                    _tableViewController.tableData = self.tagsToDisplay;
                    //_tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
                    [_tableViewController reloadData];
            }
            if (!componentFilter.rawTagArray) {
                componentFilter.rawTagArray = self.tagsToDisplay;
            };
        }];*/
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];
        
        self.videoPlayer = [[RJLVideoPlayer alloc]initWithFrame:CGRectMake(0, 52, COMMENTBOX_WIDTH +10 , SMALL_MEDIA_PLAYER_HEIGHT )];
        //[self.videoPlayer initializeVideoPlayerWithFrame:CGRectMake(2, 114, COMMENTBOX_WIDTH, SMALL_MEDIA_PLAYER_HEIGHT)];
        self.videoPlayer.playerContext = STRING_LISTVIEW_CONTEXT;
        //[self.videoPlayer playFeed:_feedSwitch.primaryFeed];

         [self.view addSubview:self.videoPlayer.view];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_LIST_VIEW_TAG object:nil queue:nil usingBlock:^(NSNotification *note) {
            selectedTag = note.object;
            [newVideoControlBar setMode:LISTVIEW_MODE_CLIP];
            [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_CLIP];
        
            [commentingField clear];
            commentingField.enabled             = YES;
            commentingField.text                = selectedTag.comment;
            commentingField.ratingScale.rating  = selectedTag.rating;
            [newVideoControlBar setTagName: selectedTag.name];
            [self.listViewFullScreenViewController setTagName:selectedTag.name];
        }];
        
    }
    return self;
    
}

-(void)addEventObserver:(NSNotification *)note
{
    if (_observedEncoder != nil) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EVENT_CHANGE object:_observedEncoder];
    }

    
    if (note.object == nil) {
        _observedEncoder = nil;
    }else{
        _observedEncoder = (id <EncoderProtocol>) note.object;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:_observedEncoder];
    }
}

-(void)eventChanged:(NSNotification *)note
{
    if (_currentEvent != nil) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_MODIFIED object:_currentEvent];
    }
    [self clear];
    
    if (_currentEvent.live && _appDel.encoderManager.liveEvent == nil) {
        _currentEvent = nil;
        [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_DISABLE];
        [newVideoControlBar setMode:LISTVIEW_MODE_DISABLE];
        [self.videoPlayer playFeed:nil];
    }else{
        _currentEvent = [((id <EncoderProtocol>) note.object) event];
        [newVideoControlBar setMode:LISTVIEW_MODE_REGULAR];
        [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_REGULAR];
        [self.videoPlayer playFeed:_currentEvent.feeds[@"s1"]];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
    }
}

-(void)onTagChanged:(NSNotification *)note{
    
    for (Tag *tag in _currentEvent.tags ) {
        if (![self.allTags containsObject:tag]) {
            if (tag.type == TagTypeNormal || tag.type == TagTypeTele || tag.type == TagTypeCloseDuration) {
                [self.tagsToDisplay insertObject:tag atIndex:0];
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIST_VIEW_TAG object:tag];
            }
            [self.allTags insertObject:tag atIndex:0];
        }
        if(tag.modified && [self.allTags containsObject:tag]){
            [self.allTags replaceObjectAtIndex:[self.allTags indexOfObject:tag] withObject:tag];
            if (tag.type == TagTypeNormal || tag.type == TagTypeTele) {
                [self.tagsToDisplay replaceObjectAtIndex:[self.tagsToDisplay indexOfObject:tag] withObject:tag];
            }
            if (tag.type == TagTypeCloseDuration) {
                [self.tagsToDisplay insertObject:tag atIndex:0];
            }
        }
    }
    
    Tag *toBeRemoved;
    for (Tag *tag in self.allTags ){
        
        if (![_currentEvent.tags containsObject:tag]) {
            toBeRemoved = tag;
        }
    }
    if (toBeRemoved) {
        [self.allTags removeObject:toBeRemoved];
        [self.tagsToDisplay removeObject:toBeRemoved];
    }
    
    componentFilter.rawTagArray = self.tagsToDisplay;
    [_tableViewController reloadData];
    
}


/*- (void)deleteTag: (NSNotification *)note {
    [self.tagsToDisplay removeObject: note.object];
    [self.allTags removeObject:note.object];
    //_tableViewController.tableData = self.tagsToDisplay;
    //_tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
      componentFilter.rawTagArray = self.tagsToDisplay;
    [_tableViewController reloadData];
}*/

/*- (void)listViewTagReceived:(NSNotification*)note {
    
    if (note.object) {
        [self.allTags insertObject:note.object atIndex:0];
        [self.tagsToDisplay insertObject:note.object atIndex:0];
        _tableViewController.tableData = self.tagsToDisplay;
        //_tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
        [_tableViewController reloadData];
    }
    
}*/

- (void)sortFromHeaderBar:(id)sender
{
    //[self sortArrayFromHeaderBar:tagsToSort headerBarState:headerBar.headerBarSortType];
    _tableViewController.tableData = [self sortArrayFromHeaderBar:self.tagsToDisplay headerBarState:headerBar.headerBarSortType];
    //[self filterAndSortTags:self.tagsToDisplay];
    //_tableViewController.tableData = [self receiveFilteredArrayFromFilter:nil];
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
                //self.fullScreenViewController.enable = YES;
                self.listViewFullScreenViewController.enable = YES;
                //                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_FULLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }else if (self.pinchGesture.scale < 1){
                //self.fullScreenViewController.enable = NO;
                self.listViewFullScreenViewController.enable = NO;
                //                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SMALLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }
        }
    }
    
}

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
    
    
    newVideoControlBar = [[VideoBarListViewController alloc]initWithVideoPlayer:self.videoPlayer];
    [newVideoControlBar.startRangeModifierButton addTarget:self action:@selector(startRangeBeenModified: ) forControlEvents:UIControlEventTouchUpInside];
    [newVideoControlBar.endRangeModifierButton addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newVideoControlBar.view];
    if (_currentEvent) {
        [newVideoControlBar setMode:LISTVIEW_MODE_REGULAR];
    }
    else{
        [newVideoControlBar setMode:LISTVIEW_MODE_DISABLE];
    }
    
    //self.videoBarViewController = [[L2BVideoBarViewController alloc]initWithVideoPlayer:self.videoPlayer];
    //[_videoBarViewController.startRangeModifierButton   addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    //[_videoBarViewController.endRangeModifierButton     addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    //[self.videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_LIVE];
    //[self.videoBarViewController setBarMode:L2B_VIDEO_BAR_MODE_CLIP];
    //[self.videoBarViewController viewDidAppear: YES];
    //[self.videoBarViewController createTagMarkers];
    
    [self.view addSubview:self.videoPlayer.view];
    //[self.view addSubview:self.videoBarViewController.view];
    
    /*self.fullScreenViewController = [[FullScreenViewController alloc]initWithVideoPlayer:self.videoPlayer];
    self.fullScreenViewController.context = @"ListView Tab";
    //[self.fullScreenViewController setMode: L2B_FULLSCREEN_MODE_DEMO];
    [self.view addSubview: self.fullScreenViewController.view];*/
    
    self.listViewFullScreenViewController = [[ListViewFullScreenViewController alloc]initWithVideoPlayer:self.videoPlayer];
    self.listViewFullScreenViewController.context = @"ListView Tab";
    [self.listViewFullScreenViewController.startRangeModifierButton addTarget:self action:@selector(startRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    [self.listViewFullScreenViewController.endRangeModifierButton addTarget:self action:@selector(endRangeBeenModified:) forControlEvents:UIControlEventTouchUpInside];
    [self.listViewFullScreenViewController.next addTarget:self action:@selector(getNextTag) forControlEvents:UIControlEventTouchUpInside];
    [self.listViewFullScreenViewController.prev addTarget:self action:@selector(getPrevTag) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.listViewFullScreenViewController.view];
    if (_currentEvent) {
        [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_REGULAR];
    }else{
        [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_DISABLE];
    }
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGuesture:)];
    [self.view addGestureRecognizer: self.pinchGesture];
    
    //    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(detectSwipe:)];
    //    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    //    [self.videoPlayer.view addGestureRecognizer:swipeGestureRecognizer];
    //
    //    swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(detectSwipe:)];
    //    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    //    [self.videoPlayer.view addGestureRecognizer:swipeGestureRecognizer];
    
   //componentFilter = [TestFilterViewController commonFilter];
    
    _tableViewController.tableData = self.tagsToDisplay;
}

-(void)getNextTag
{
    NSUInteger index = [_tableViewController.tableData indexOfObject:selectedTag];
    
    if (index == _tableViewController.tableData.count - 1) {
        return;
    }
    
    NSUInteger newIndex = index + 1;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{@"context":STRING_LISTVIEW_CONTEXT,
                                                                                                                                   @"feed":selectedTag.event.feeds[@"s1"],
                                                                                                                                   @"time": [NSString stringWithFormat:@"%f",selectedTag.startTime],
                                                                                                                                   @"duration": [NSString stringWithFormat:@"%d",selectedTag.duration],
                                                                                                                                   @"comment": selectedTag.comment,
                                                                                                                                   @"forWhole":selectedTag,
                                                                                                                                   @"state":[NSNumber numberWithInteger:RJLPS_Play]
                                                                                                                                   }}];
    
    selectedTag = [_tableViewController.tableData objectAtIndex:newIndex];
    
    [commentingField clear];
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    [newVideoControlBar setTagName: selectedTag.name];
    [self.listViewFullScreenViewController setTagName:selectedTag.name];
}

-(void)getPrevTag
{
    NSUInteger index = [_tableViewController.tableData indexOfObject:selectedTag];
    
    if (index == 0) {
        return;
    }
    
    NSUInteger newIndex = index - 1;
    
    selectedTag = [_tableViewController.tableData objectAtIndex:newIndex];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{@"context":STRING_LISTVIEW_CONTEXT,
                                                                                                                                    @"feed":selectedTag.event.feeds[@"s1"],
                                                                                                                                    @"time": [NSString stringWithFormat:@"%f",selectedTag.startTime],
                                                                                                                                    @"duration": [NSString stringWithFormat:@"%d",selectedTag.duration],
                                                                                                                                    @"comment": selectedTag.comment,
                                                                                                                                    @"forWhole":selectedTag,
                                                                                                                                    @"state":[NSNumber numberWithInteger:RJLPS_Play]
                                                                                                                                    }}];

    
    [commentingField clear];
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    [newVideoControlBar setTagName: selectedTag.name];
    [self.listViewFullScreenViewController setTagName:selectedTag.name];
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LIST_VIEW_CONTROLLER_FEED object:nil userInfo:@{@"block" : ^(NSDictionary *feeds, NSArray *eventTags){
        if(feeds && !self.feeds){
            self.feeds = feeds;
            Feed *theFeed = [[feeds allValues] firstObject];
            [self.videoPlayer playFeed:theFeed];
        }
        
        /*if (!self.tagsToDisplay) {
            self.tagsToDisplay = [NSMutableArray arrayWithArray:[eventTags copy]];
            _tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];

            [_tableViewController reloadData];
        }*/
        
        if(eventTags.count > 0 && !self.tagsToDisplay){
            self.tagsToDisplay =[ NSMutableArray arrayWithArray:[eventTags copy]];
            self.allTags = [ NSMutableArray arrayWithArray:[eventTags copy]];
            if (!componentFilter.rawTagArray) {
                self.tagsToDisplay = [NSMutableArray arrayWithArray:componentFilter.processedList];
            }
            [_tableViewController reloadData];
        }


//            self.allTagsArray = [NSMutableArray arrayWithArray:[eventTags copy]];
//            self.tagsToDisplay =[ NSMutableArray arrayWithArray:[eventTags copy]];
//            if (!componentFilter.rawTagArray) {
//                componentFilter.rawTagArray = self.tagsToDisplay;
//            }
        
        
        
    }}];
    
    
 //   _tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
 //   [_tableViewController reloadData];
    
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
    /*if(![self.view.subviews containsObject:componentFilter.view])
    {
        [self.view addSubview:componentFilter.view];
    }*/
    
    self.videoPlayer.mute = NO;
    
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

//    }
//}




//  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  //
-(void)receiveFilteredArrayFromFilter:(id)filter
{
    AbstractFilterViewController * checkFilter = (AbstractFilterViewController *)filter;
    NSMutableArray *filteredArray = (NSMutableArray *)[checkFilter processedList]; //checkFilter.displayArray;
    self.tagsToDisplay = [filteredArray mutableCopy];
    //[self.collectionView reloadData];
    _tableViewController.tableData = self.tagsToDisplay;
    [_tableViewController reloadData];
    [breadCrumbVC inputList: [checkFilter.tabManager invokedComponentNames]];

    
    //_tableViewController.tableData = [self filterAndSortTags:self.tagsToDisplay];
 
}
//  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  //

-(Float64) highestTimeInTags: (NSArray *) arrayOfTags{
    Float64 highestTime = 0;
    for (Tag *tag in arrayOfTags) {
        if (tag.time > highestTime) {
            highestTime = tag.time;
        }
    }
    return highestTime;
}


#pragma mark - Edge Swipe Buttons Delegate Methods

- (void)slideFilterBox
{

    
    /*if (!componentFilter) {
        componentFilter = [[TestFilterViewController alloc]initWithTagArray: self.tagsToDisplay];
        componentFilter = [TestFilterViewController commonFilter];
    }*/
    
    self.dismissFilterButton = [[UIButton alloc] initWithFrame: self.view.bounds];
    [self.dismissFilterButton addTarget:self action:@selector(dismissFilter:) forControlEvents:UIControlEventTouchUpInside];
    self.dismissFilterButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [self.view addSubview: self.dismissFilterButton];
    
    
    componentFilter.rawTagArray                 = self.allTags;
    componentFilter.rangeSlider.highestValue    = [self highestTimeInTags:self.allTags];
    componentFilter.finishedSwipe               = TRUE;
    [self.view addSubview:componentFilter.view];
    [componentFilter setOrigin:CGPointMake(60, 190)];
    [componentFilter close:NO];
    [componentFilter viewDidAppear:TRUE];
    [componentFilter open:YES];

    
    
    //componentFilter.rawTagArray = self.tagsToDisplay;
    //componentFilter = [[TestFilterViewController alloc]initWithTagArray: self.tagsToDisplay];
    //componentFilter.rangeSlider.highestValue = [(UIViewController <PxpVideoPlayerProtocol> *)self.videoPlayer durationInSeconds];
    
    //[componentFilter onSelectPerformSelector:@selector(receiveFilteredArrayFromFilter:) addTarget:self];
    //[componentFilter onSwipePerformSelector:@selector(slideFilterBox) addTarget:self];
    componentFilter.finishedSwipe = TRUE;
    
    [self.view addSubview:componentFilter.view];
    
    //componentFilter.rangeSlider.highestValue = [((UIViewController <PxpVideoPlayerProtocol> *)self.videoPlayer) durationInSeconds];
    //[componentFilter setOrigin:CGPointMake(60, 190)];
    //[componentFilter close:NO];
    //[componentFilter viewDidAppear:TRUE];
    //[componentFilter open:YES];
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
        //[self.edgeSwipeButtons deselectButtonAtIndex:2];
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





-(void) feedSelected: (NSNotification *) notification
{
    
    NSDictionary *userInfo = [notification.userInfo objectForKey:@"forFeed"];
    
    float time              = [[[notification.userInfo objectForKey:@"forFeed"] objectForKey:@"time"] floatValue];
    float dur               = [[[notification.userInfo objectForKey:@"forFeed"] objectForKey:@"duration"] floatValue];
    CMTime cmtime           = CMTimeMake(time, 1);
    CMTime cmDur            = CMTimeMake(dur, 1);
    
    CMTimeRange timeRange   = CMTimeRangeMake(cmtime, cmDur);
    
   /* NSString *pick = [userInfo objectForKey:@"feed"];
    
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED object:nil userInfo:@{@"context":STRING_LISTVIEW_CONTEXT,
                                                                                                              @"feed":pick,
                                                                                                              @"time":[userInfo objectForKey:@"time"],
                                                                                                              @"duration":[userInfo objectForKey:@"duration"],
                                                                                                              //@"state":[NSNumber numberWithInteger:PS_Play]}];*/
    
    [self.videoPlayer playFeed:[userInfo objectForKey:@"feed"] withRange:timeRange];
    //self.videoPlayer.looping = NO;
    self.videoPlayer.looping = YES;
    selectedTag = userInfo[@"forWhole"];
    
    [commentingField clear];
    commentingField.enabled             = YES;
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    
    [newVideoControlBar setTagName:selectedTag.name];
}


//loop tag
-(void)loopTag
{

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
    
    
    componentFilter = [TestFilterViewController commonFilter];
    [componentFilter onSelectPerformSelector:@selector(receiveFilteredArrayFromFilter:) addTarget:self];
    [self.view addSubview:componentFilter.view];
    [componentFilter setOrigin:CGPointMake(60, 190)];
    [componentFilter close:NO];
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

}

//save comment
-(void)sendComment
{
    
    
    NSString *comment;
    //Richard
    
    [commentingField.textField resignFirstResponder];
    comment = commentingField.textField.text;
    

    selectedTag.comment = comment;

    
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
    Tag *tagToBeModified = selectedTag;
    
    
    if (!tagToBeModified|| tagToBeModified.type == TagTypeTele ){
        
        return;
    }
    
    
    float newStartTime = 0;
    
    float endTime = tagToBeModified.startTime + tagToBeModified.duration;
    if ([button.accessibilityValue isEqualToString:@"extend"]) {
        
        //extend the duration 5 seconds by decreasing the start time 5 seconds
        newStartTime = tagToBeModified.startTime - 5;
        //if the new start time is smaller than 0, set it to 0
        if (newStartTime <0) {
            newStartTime = 0;
        }
        
    }else{
        //subtract the duration 5 seconds by increasing the start time 5 seconds
        newStartTime = tagToBeModified.startTime + 5;
        
        //if the start time is greater than the endtime, it will cause a problem for tag looping. So set it to endtime minus one
        if (newStartTime > endTime) {
            newStartTime = endTime -1;
        }
        
    }
    
    //set the new duration to tag end time minus new start time
    int newDuration = endTime - newStartTime;
    
    
    //    globals.HOME_START_TIME = newStartTime;
    //    globals.HOME_END_TIME = endTime;
    //
    
    tagToBeModified.startTime = newStartTime;
    tagToBeModified.duration = newDuration;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:tagToBeModified];
    

}

//extend the tag duration by adding five secs at the end of the tag
-(void)endRangeBeenModified:(CustomButton*)button{
    Tag *tagToBeModified = selectedTag;
        if (!selectedTag || selectedTag.type == TagTypeDeleted)
        {
            return;
        }


    int newDuration = tagToBeModified.duration + 5;

    float startTime = tagToBeModified.startTime;
    
    float endTime = startTime + tagToBeModified.duration;
 
    if ([button.accessibilityValue isEqualToString:@"extend"]) {
           //increase end time by 5 seconds
            endTime = endTime + 5;
            //if new end time is greater the duration of video, set it to the video's duration
            if (endTime > [self.videoPlayer durationInSeconds]) {
                endTime = [self.videoPlayer durationInSeconds];
            }
    
        }else{
            //subtract end time by 5 seconds
            endTime = endTime - 5;
            //if the new end time is smaller than the start time,it will cause a problem for tag looping. So set it to start time plus one.
            if (endTime < startTime) {
                endTime = startTime + 1;
            }
    
        }
        //get the new duration
        newDuration = endTime - startTime;
    
    tagToBeModified.duration = newDuration;
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:tagToBeModified];
    

}


-(void)viewWillDisappear:(BOOL)animated
{
    [componentFilter close:YES];
    [self.dismissFilterButton removeFromSuperview];
    
    self.videoPlayer.mute = YES;
    
  }




-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}



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



//save button clicked, send notification to the teleview controller
-(void)saveButtonClicked{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Save Tele" object:nil];
}

//clear button clicked, send notification to the teleview controller
-(void)clearButtonClicked{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Clear Tele" object:nil];
}

//set the right text for tag name label in fullscreen
-(void)setTagEventNameLabelText:(NSString*)name{
    [tagEventNameFullScreen setText:name];
}


//after finish commenting, touch any other part of the view except commentTextView, will resign the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}



- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
}

/*-(NSMutableArray *)filterAndSortTags:(NSArray *)tags {
    NSMutableArray *tagsToSort = [NSMutableArray arrayWithArray:tags];
    
    if (componentFilter) {
        componentFilter.rawTagArray = tagsToSort;
        tagsToSort = [NSMutableArray arrayWithArray:componentFilter.processedList];
    }
    //else{
       // componentFilter = [TestFilterViewController commonFilter];
    //}
    
    return [self sortArrayFromHeaderBar:tagsToSort headerBarState:headerBar.headerBarSortType];
}*/

-(void)clear{
    [self.allTags removeAllObjects];
    [self.tagsToDisplay removeAllObjects];
    //_tableViewController.tableData = [NSMutableArray array];
    [_tableViewController reloadData];
}

- (void)liveEventStopped:(NSNotification *)note {
    //self.tagsToDisplay = nil;
    //self.allTags = nil;
    //_tableViewController.tableData = [NSMutableArray array];
    //[_tableViewController reloadData];
    
    if(_currentEvent.live){
        _currentEvent = nil;
        [self clear];
        selectedTag = nil;
        [newVideoControlBar setMode:LISTVIEW_MODE_DISABLE];
        [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_DISABLE];
        
        [commentingField clear];
        commentingField.enabled             = NO;
        //[newVideoControlBar setTagName: nil];
    }
}


- (void)setTagsToDisplay:(NSMutableArray *)tagsToDisplay {
    NSMutableArray *tags = [NSMutableArray array];
    for (Tag *tag in tagsToDisplay) {
        if (tag.type == TagTypeNormal) {
            [tags addObject:tag];
        }
    }
    _tagsToDisplay = tags;
}

@end