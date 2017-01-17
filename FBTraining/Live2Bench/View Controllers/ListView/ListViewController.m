
//
//  ListViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-02-13.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "ListViewController.h"

#import "CommentingRatingField.h"
#import "HeaderBarForListView.h"
#import "VideoBarListViewController.h"
#import "FeedSwitchView.h"
#import "Feed.h"

#import "FullScreenViewController.h"
#import "PxpEventContext.h"
#import "LocalMediaManager.h"
#import "PxpTelestrationViewController.h"
#import "PxpListViewFullscreenViewController.h"
#import "PxpVideoBar.h"
#import "PxpPlayer+Tag.h"

//test
#import "PxpFilterDefaultTabViewController.h"
#import "PxpFilterHockeyTabViewController.h"
#import "PxpFilterFootballTabViewController.h"
#import "PxpFilterSoccerTabViewController.h"
#import "PxpFilterRugbyTabViewController.h"



#import "RicoPlayer.h"
#import "RicoZoomContainer.h"
#import "RicoPlayerViewController.h"
#import "RicoPlayerControlBar.h"
#import "RicoVideoBar.h"
#import "RicoBaseFullScreenViewController.h"
#import "RicoFullScreenControlBar.h"
#import "EncoderOperation.h"

#import "DownloaderQueue.h"
#import "DownloadOperation.h"
#import "DownloadClipFromTag.h"


@interface ListViewController () <RicoBaseFullScreenDelegate>

@property (strong, nonatomic, nonnull) PxpPlayerViewController *playerViewController;
@property (strong, nonatomic)          UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic)          UIButton *filterButton;
@property (strong, nonatomic, nonnull) PxpTelestrationViewController *telestrationViewController;
@property (strong, nonatomic, nonnull) PxpListViewFullscreenViewController *fullscreenViewController;
@property (strong, nonatomic, nonnull) RicoPlayer                       * mainPlayer;
@property (strong, nonatomic, nonnull) RicoVideoBar                     * videoBar;
@property (strong, nonatomic, nonnull) RicoZoomContainer                * ricoZoomContainer;
@property (strong, nonatomic, nonnull) RicoPlayerViewController         * ricoPlayerViewController;
@property (strong, nonatomic, nonnull) RicoPlayerControlBar             * ricoPlayerControlBar;
@property (strong, nonatomic, nonnull) RicoBaseFullScreenViewController * ricoFullscreenViewController;
@property (strong, nonatomic, nonnull) RicoFullScreenControlBar         * ricoFullScreenControlBar;
@property (strong, nonatomic, nonnull) UIButton                         * downloadAllButton;


@end

@implementation ListViewController{
    
    HeaderBarForListView            * headerBar;
    CommentingRatingField           * commentingField;
    
    Event                           * _currentEvent;
    id <EncoderProtocol>                _observedEncoder;
}

@synthesize selectedCellRows;


-(instancetype)initWithAppDelegate:(AppDelegate *)appDel{
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"List View", nil) imageName:@"tabListView"];
        
        _videoBar                           = [[RicoVideoBar alloc] init];
        _fullscreenViewController           = [[PxpListViewFullscreenViewController alloc] initWithPlayerViewController:_playerViewController];
        self.allTags                        = [[NSMutableArray alloc]init];
        self.tagsToDisplay                  = [[NSMutableArray alloc]init];
        _tableViewController                = [[ListTableViewController alloc]init];
        _tableViewController.contextString  = @"TAG";
        _tableViewController.tableData      = self.tagsToDisplay;
        
        [self addChildViewController:_tableViewController];
        [_videoBar.forwardSeekButton    addTarget:self action:@selector(seekPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_videoBar.backwardSeekButton   addTarget:self action:@selector(seekPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_videoBar.slomoButton          addTarget:self action:@selector(slomoPressed:) forControlEvents:UIControlEventTouchUpInside];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedSelected:) name:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTagHasBeenHighlighted:) name:NOTIF_LIST_VIEW_TAG_HIGHLIGHTED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipCanceledHandler:) name:NOTIF_CLIP_CANCELED object:self.videoPlayer];
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_LIST_VIEW_TAG object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (!selectedTag) {
                [commentingField clear];
                commentingField.enabled             = YES;
                commentingField.text                = selectedTag.comment;
                commentingField.ratingScale.rating  = selectedTag.rating;
            }
        }];
        self.pxpFilter = appDel.sharedFilter;
    }
    return self;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CLIP_CANCELED object:self.videoPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_PLAYER_BAR_CANCEL object:nil];
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
    
    if ([[note.object event].name isEqualToString:_currentEvent.name]) {
        return;
    }
    
    if (_currentEvent != nil) {
        [[TabView sharedFilterTabBar] dismissViewControllerAnimated:NO completion:nil];// remove filter if up
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_MODIFIED object:_currentEvent];
    }
    [self clear];
    
    if (_currentEvent.live && _appDel.encoderManager.liveEvent == nil) {
        _currentEvent = nil;
        selectedTag = nil;
        _videoBar.selectedTag = nil;
        
        [commentingField clear];
        commentingField.enabled             = NO;
        
        _fullscreenViewController.selectedTag = nil;
        _fullscreenViewController.fullscreen = NO;
        
        [self.videoPlayer playFeed:nil];
    }else{
        _currentEvent = [((id <EncoderProtocol>) note.object) event];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
    }
    
    // update the context
    PxpPlayerContext *context = _appDel.encoderManager.primaryEncoder.eventContext;
    self.playerViewController.playerView.context = context;
    self.fullscreenViewController.playerViewController.playerView.context = context;
    
}

-(void)onTagChanged:(NSNotification *)note{
    
    for (Tag *tag in _currentEvent.tags ) {
        if (![self.allTags containsObject:tag]) {
            if (tag.type == TagTypeNormal || tag.type == TagTypeCloseDuration || tag.type == TagTypeFootballDownTags) {
                [self.tagsToDisplay insertObject:tag atIndex:0];
                [self.pxpFilter addTags:@[tag]];
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_LIST_VIEW_TAG object:tag];
            }
            [self.allTags insertObject:tag atIndex:0];
        }
        if(tag.modified && [self.allTags containsObject:tag] && tag.type == TagTypeCloseDuration && ![self.tagsToDisplay containsObject:tag]){
            [self.tagsToDisplay insertObject:tag atIndex:0];
            [self.pxpFilter addTags:@[tag]];
        }
        
        // BCH: TODO: This line has crashed the app a coupl'a times. Possibly the tag is nil?
        if ((tag.type == TagTypeHockeyStrengthStop || tag.type == TagTypeHockeyStopOLine || tag.type == TagTypeHockeyStopDLine || tag.type == TagTypeSoccerZoneStop) && ![self.tagsToDisplay containsObject:tag]) {
            [self.tagsToDisplay insertObject:tag atIndex:0];
            [self.pxpFilter addTags:@[tag]];
            [self.allTags replaceObjectAtIndex:[self.allTags indexOfObject:tag] withObject:tag];
        }

    }
    
    for (Tag *tag in [self.allTags copy]) {
        if (![_currentEvent.tags containsObject:tag]) {
            [self.allTags removeObject:tag];
            [self.tagsToDisplay removeObject:tag];
            [_tableViewController collaspOpenCell];
            [self.pxpFilter removeTags:@[tag]];
        }
    }
    
    // yes this is silly when tag mod is called list view refreshes but when downloading at clip it counts at a tag mod
    // but it should not be updated because it needs to see the button that called it so updating will clear it out
    
    if (![note.name isEqualToString:NOTIF_TAG_MODIFIED]){
        [_tableViewController reloadData];
    }
    
}

//this method will be triggered if user pinches the video view. Based on the pinch velocity, will enter full screen or back to normal screen
- (void)handlePinchGuesture:(UIGestureRecognizer *)recognizer{
    
    if((self.pinchGesture.velocity > 0.5 || self.pinchGesture.velocity < -0.5) && self.pinchGesture.numberOfTouches == 2){
        if (CGRectContainsPoint(self.view.bounds, [self.pinchGesture locationInView:self.view]))
        {
            
            
            if (self.pinchGesture.scale >1) {
                //[_fullscreenViewController setHidden:NO animated:YES];
            }else if (self.pinchGesture.scale < 1){
                //[_fullscreenViewController setHidden:YES animated:YES];
            }
        }
    }
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeCurrentPlayingClip:) name:NOTIF_PLAYER_BAR_CANCEL object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clipCancelNotification:)       name:NOTIF_PLAYER_BAR_CANCEL          object:nil];
    [self setupView];// set up filter and commenting

     _tableViewController.tableView.delaysContentTouches = NO;
    
    headerBar = [[HeaderBarForListView alloc]initWithFrame:CGRectMake(540,55,1024, LABEL_HEIGHT) defaultSort:TIME_FIELD | DESCEND];
    [headerBar onTapPerformSelector:@selector(sortFromHeaderBar:) addTarget:self];
    [self.view addSubview:headerBar];

//    _playerViewController.telestrationViewController.showsControls = NO;


    
#pragma mark- VIDEO PLAYER INITIALIZATION HERE

//    self.videoPlayer.playerContext = STRING_LISTVIEW_CONTEXT;
    
//    [self.view addSubview:self.videoPlayer.view];
   
    [_fullscreenViewController.nextTagButton addTarget:self action:@selector(getNextTag) forControlEvents:UIControlEventTouchUpInside];
    [_fullscreenViewController.previousTagButton addTarget:self action:@selector(getPrevTag) forControlEvents:UIControlEventTouchUpInside];
   
    self.pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGuesture:)];
    [self.view addGestureRecognizer: self.pinchGesture];

    _tableViewController.tableData = self.tagsToDisplay;
    
    [self.view addSubview:_videoBar];

    
    // Rico Classes build
    
    CGFloat playerWidth = 530 + 10;
    CGFloat playerHeight = playerWidth / (16.0 / 9.0);
    
    self.mainPlayer             = [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, playerWidth, playerHeight)];
    self.ricoZoomContainer      = [[RicoZoomContainer alloc]initWithFrame:CGRectMake(0, 55.0, playerWidth, playerHeight)];
    [self.ricoZoomContainer addToContainer:self.mainPlayer];
    [self.view addSubview:self.ricoZoomContainer];
    
    self.ricoPlayerViewController = [RicoPlayerViewController new];
    [self.ricoPlayerViewController addPlayers:self.mainPlayer];
    
    

    self.ricoPlayerControlBar = [[RicoPlayerControlBar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.ricoZoomContainer.frame)-40, playerWidth, 40.0)];
    [self.view addSubview:self.ricoPlayerControlBar];
    self.ricoPlayerControlBar.gestureEnabled = YES;
    self.ricoPlayerControlBar.delegate = self.ricoPlayerViewController;
    self.ricoPlayerViewController.playerControlBar = self.ricoPlayerControlBar;

    _videoBar.frame = CGRectMake(CGRectGetMinX(self.ricoZoomContainer.frame), CGRectGetMaxY(self.ricoZoomContainer.frame), playerWidth, 40.0);
    [_videoBar clear]; // just to unify the view

    
    self.ricoFullscreenViewController = [[RicoBaseFullScreenViewController alloc]initWithView:self.ricoZoomContainer];
    self.ricoFullscreenViewController.delegate = self;
    [_videoBar.fullscreenButton addTarget:self.ricoFullscreenViewController action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self addChildViewController:self.ricoFullscreenViewController];
    [self.view addSubview:self.ricoFullscreenViewController.view];
    
    
    self.ricoFullScreenControlBar = [[RicoFullScreenControlBar alloc]init];
    
    
    [self.ricoFullScreenControlBar.backwardSeekButton addTarget: self action:@selector(seekPressed:)        forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.forwardSeekButton addTarget:  self action:@selector(seekPressed:)        forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.slomoButton addTarget:        self action:@selector(slomoPressed:)       forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.liveButton addTarget:         self action:@selector(goToLive)            forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.startRangeModifierButton     addTarget:self action:@selector(extendStartAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.endRangeModifierButton       addTarget:self action:@selector(extendEndAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.ricoFullScreenControlBar.frameBackward                addTarget: self action:@selector(frameByFrame:)       forControlEvents:UIControlEventTouchUpInside];
    [self.ricoFullScreenControlBar.frameForward                 addTarget: self action:@selector(frameByFrame:)       forControlEvents:UIControlEventTouchUpInside];


    [self.ricoFullScreenControlBar.fullscreenButton addTarget:self.ricoFullscreenViewController action:@selector(fullscreenResponseHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.ricoFullscreenViewController.bottomBar addSubview:self.ricoFullScreenControlBar];

    
    CGFloat w = 200;
    CGFloat h = 35;
    self.downloadAllButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.ricoPlayerControlBar.frame) - (w / 2),
                                                                       CGRectGetMaxY(self.ricoPlayerControlBar.frame)+h+10,
                                                                       w,
                                                                       h)];
//    [self.downloadAllButton setBackgroundColor:PRIMARY_APP_COLOR ];
    [self.downloadAllButton setTitle:@"Download Whole Tag" forState:UIControlStateNormal];
    
    [self.downloadAllButton addTarget:self action:@selector(downloadWholeCurrentTag) forControlEvents:UIControlEventTouchUpInside];
    self.downloadAllButton.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    self.downloadAllButton.layer.borderWidth = 1;
    [self.downloadAllButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.downloadAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.downloadAllButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR] forState:UIControlStateHighlighted];
    [self.view addSubview:self.downloadAllButton];

}

-(void)getNextTag
{
    NSUInteger index = [_tableViewController.tableData indexOfObject:selectedTag];
    
    if (_tableViewController.tableData.count == 0 || index == _tableViewController.tableData.count - 1) {
        return;
    }
    
    NSUInteger newIndex = index + 1;

    
    
    selectedTag = [_tableViewController.tableData objectAtIndex:newIndex];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{@"context":STRING_LISTVIEW_CONTEXT,
                                                                                                                                   @"feed":[[selectedTag.eventInstance.feeds allValues] firstObject],
                                                                                                                                   @"time": [NSString stringWithFormat:@"%f",selectedTag.startTime],
                                                                                                                                   @"duration": [NSString stringWithFormat:@"%d",selectedTag.duration],
                                                                                                                                   @"comment": selectedTag.comment,
                                                                                                                                   @"forWhole":selectedTag,
                                                                                                                                   @"state":[NSNumber numberWithInteger:RJLPS_Play]
                                                                                                                                   }}];
    
    
    [commentingField clear];
    commentingField.text                    = selectedTag.comment;
    commentingField.ratingScale.rating      = selectedTag.rating;
    
    _videoBar.selectedTag                   = selectedTag;
    _fullscreenViewController.selectedTag   = selectedTag;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSLog(@"ListViewController viewDidAppear");
//    [_playerViewController viewDidAppear:animated];
    [self.view bringSubviewToFront:_videoBar];
//    [self.view bringSubviewToFront:_fullscreenViewController.view];
    
    // Set up filter for this Tab
    self.pxpFilter = [TabView sharedFilterTabBar].pxpFilter;
    self.pxpFilter.delegate = self;
    [self.pxpFilter removeAllPredicates];
    

    
    Profession * profession = [ProfessionMap getProfession:_currentEvent.eventType];// should be the events sport //
    
    NSLog(@"Current profession type %@", _currentEvent.eventType);
    if (_currentEvent) {
    if (![self.pxpFilter.ghostPredicates containsObject:profession.invisiblePredicate] && profession.invisiblePredicate){
        [self.pxpFilter.ghostPredicates addObject:profession.invisiblePredicate];
    }
    
        NSMutableArray * filters = [NSMutableArray new];
        
        
        [filters addObjectsFromArray:@[
                                       [NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeNormal]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeCloseDurationOLD]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeCloseDuration]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeFootballQuarterStop]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeFootballDownTags]
                                       ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerZoneStop]
                                       ]];
        
        if (profession && profession.filterPredicate )[filters addObject:profession.filterPredicate];
        
        
        NSPredicate *allowThese = [NSCompoundPredicate orPredicateWithSubpredicates:filters];
        
        

        
        [self.pxpFilter addPredicates:@[allowThese]];
    }
    [_tableViewController reloadData];
    
    
    
    [self.view bringSubviewToFront:self.ricoFullscreenViewController.view];
    

}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.ricoFullscreenViewController.fullscreen = NO;
    self.mainPlayer.feed=nil;
}

-(void)getPrevTag
{
    NSUInteger index = [_tableViewController.tableData indexOfObject:selectedTag];
    
    if (_tableViewController.tableData.count == 0 || index == 0) {
        return;
    }
    
    NSUInteger newIndex = index - 1;
    
    selectedTag = [_tableViewController.tableData objectAtIndex:newIndex];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{@"context":STRING_LISTVIEW_CONTEXT,
                                                                                                                                    @"feed":[[selectedTag.eventInstance.feeds allValues] firstObject],
                                                                                                                                    @"time": [NSString stringWithFormat:@"%f",selectedTag.startTime],
                                                                                                                                    @"duration": [NSString stringWithFormat:@"%d",selectedTag.duration],
                                                                                                                                    @"comment": selectedTag.comment,
                                                                                                                                    @"forWhole":selectedTag,
                                                                                                                                    @"state":[NSNumber numberWithInteger:RJLPS_Play]
                                                                                                                                    }}];

    
    [commentingField clear];
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    
    _videoBar.selectedTag = selectedTag;
    _fullscreenViewController.selectedTag = selectedTag;
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
//    _fullscreenViewController.fullscreen = NO;
    [self.view bringSubviewToFront:_videoBar];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LIST_VIEW_CONTROLLER_FEED object:nil userInfo:@{@"block" : ^(NSDictionary *feeds, NSArray *eventTags){
        if(feeds && !self.feeds){
            self.feeds = feeds;
            Feed *theFeed = [[feeds allValues] firstObject];
            [self.videoPlayer playFeed:theFeed];
        }
        

        
        if(eventTags.count > 0 && !self.tagsToDisplay){
            self.tagsToDisplay =[ NSMutableArray arrayWithArray:[eventTags copy]];
            self.allTags = [ NSMutableArray arrayWithArray:[eventTags copy]];
            [_tableViewController reloadData];
        }


        
    }}];



    _tableViewController.isEditable = FALSE;

    // Richard
    [commentingField clear];
    commentingField.ratingScale.rating = 0;
    commentingField.enabled = NO;

    
    self.videoPlayer.mute = NO;

}




- (void)clipCanceledHandler:(NSNotification *)notification {
    if (!self.telestrationViewController.telestrating) {
        self.telestrationViewController.telestration = nil;
    }
}


-(void) feedSelected: (NSNotification *) notification
{
// [self.downloadAllButton setEnabled:YES];
    NSDictionary *userInfo = [notification.userInfo objectForKey:@"forFeed"];
    
    Feed *feed = [userInfo objectForKey:@"feed"];
    
    selectedTag = userInfo[@"forWhole"];
    if (self.mainPlayer.feed != feed){
        [self.mainPlayer loadFeed:feed];
        self.mainPlayer.name = feed.sourceName;
    }

    [self.ricoPlayerViewController playTag:selectedTag];
    [self.ricoPlayerViewController play];
    
    [commentingField clear];
    commentingField.enabled             = YES;
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    
    self.ricoFullScreenControlBar.controlBar.range = self.ricoPlayerControlBar.range;
    self.ricoFullScreenControlBar.mode = RicoFullScreenModeList;
    self.ricoFullScreenControlBar.currentTagLabel.text =selectedTag.name;
}



#pragma mark - TextView Delegate Methods

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{

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

#pragma mark -
#pragma mark RicoBaseFullScreen Protocol Methods

-(void)onFullScreenShow:(RicoBaseFullScreenViewController*)fullscreenController
{
    self.ricoPlayerViewController.playerControlBar              = self.ricoFullScreenControlBar.controlBar;
    self.ricoFullScreenControlBar.controlBar.delegate           = self.ricoPlayerViewController;
}

-(void)onFullScreenLeave:(RicoBaseFullScreenViewController*)fullscreenController
{
    self.ricoPlayerViewController.playerControlBar  = self.ricoPlayerControlBar;
    self.ricoPlayerControlBar.delegate              = self.ricoPlayerViewController;
}




#pragma mark - ListTableViewController coupled method
-(void)onTagHasBeenHighlighted:(NSNotification*)note;
{
    
    Tag* theTag = note.object;
    if (selectedTag == theTag) return;
    
    [commentingField clear];
    selectedTag                         = theTag;
    commentingField.enabled             = YES;
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    
}

#pragma mark - Video Bar Methods

- (void)seekPressed:(SeekButton *)sender {
    CMTime  sTime = CMTimeMakeWithSeconds(sender.speed, NSEC_PER_SEC);
    CMTime  cTime = self.ricoPlayerViewController.primaryPlayer.currentTime;
//    self.ricoPlayerControlBar.state = RicoPlayerStateNormal;
   
    
    // so you get seek past bounds
    if (CMTIMERANGE_IS_VALID(self.ricoPlayerViewController.primaryPlayer.range) &&
       CMTimeRangeContainsTime(self.ricoPlayerViewController.primaryPlayer.range,CMTimeAdd(cTime, sTime))) {
        
          [self.ricoPlayerViewController seekToTime:CMTimeAdd(cTime, sTime) toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity completionHandler:nil];
    }

  
}

- (void)slomoPressed:(Slomo *)slomo {
    slomo.slomoOn = !slomo.slomoOn;
//    self.ricoPlayerControlBar.state = RicoPlayerStateNormal;
    self.ricoPlayerViewController.slomo = slomo.slomoOn;
}

#pragma mark - Download All

-(void)downloadWholeCurrentTag
{
    if (!selectedTag) return;
    
    NSArray *keys = [selectedTag.eventInstance.feeds allKeys];
    if (!_currentEvent.local){
    
        __weak ListTableViewController * tbweak = _tableViewController;
        DownloadClipFromTag * downloadClip = [[DownloadClipFromTag alloc]initWithTag:selectedTag encoder:selectedTag.eventInstance.parentEncoder sources:keys];
        
        [downloadClip setOnFail:^(NSError *e) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString * errorTitle = [NSString stringWithFormat:@"Error downloading tag %@",selectedTag.name];
                NSString * errorMessage = [NSString stringWithFormat:@"%@\n%@",e.localizedFailureReason,e.localizedRecoverySuggestion];
                
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:errorTitle
                                                                                message:errorMessage
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                // build NO button
                UIAlertAction* cancelButtons = [UIAlertAction
                                                actionWithTitle:@"OK"
                                                style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * action)
                                                {
                                                    [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                                }];
                [alert addAction:cancelButtons];
                
                [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertImportant completion:nil];
            });
        }];

        
        
        [downloadClip setOnCutComplete:^(NSData *data, NSError *error) {
         
            dispatch_async(dispatch_get_main_queue(), ^{
                [tbweak reloadData];
            });
            
        }];
        
        //
        [downloadClip setCompletionBlock:^{
            NSLog(@"%s",__FUNCTION__);
            dispatch_async(dispatch_get_main_queue(), ^{
                [tbweak reloadData];
            });
        }];
        
        
        [_tableViewController.downloadQueue addOperation:downloadClip];
    } else {

        for (NSString * key in keys) {

            // this will at a place holder for the downloader so the clock will show up r 3ems anight away
            NSString * placeHolderKey = [NSString stringWithFormat:@"%@-%@hq",selectedTag.ID,key ];
            NSString *src = [NSString stringWithFormat:@"%@hq", key];


            NSLog(@"Added Placeholder key: %@",placeHolderKey);
            [[Downloader defaultDownloader].keyedDownloadItems setObject:@"placeHolder" forKey:placeHolderKey];

            // this takes the download item and attaches it to the cell
            void(^blockName)(DownloadItem * downloadItem ) = ^(DownloadItem *downloadItem){
                    [downloadItem setOnComplete:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_tableViewController reloadData];
                        });
                    }];
                
            };




            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_DOWNLOAD_CLIP object:nil userInfo:@{@"block": blockName,
                                                                                                                   @"tag": selectedTag,
                                                                                                                   @"src":src,
                                                                                                                   @"key":key}];
            
     
        }

    }
    

}


#pragma mark -

//initialize the controls for list view
-(void)setupView
{
    
    // Richard
    commentingField = [[CommentingRatingField alloc]initWithFrame:CGRectMake(10,485 -50, 530, 210+60 +50) title:NSLocalizedString(@"Comment",nil)];
    commentingField.enabled = NO;
    [commentingField onPressRatePerformSelector:@selector(sendRating:) addTarget:self];
    [commentingField onPressSavePerformSelector:@selector(sendComment) addTarget:self];
    [commentingField onPressClearPerformSelector:@selector(sendComment) addTarget:self];
    [self.view addSubview:commentingField];

    [self.view addSubview: _tableViewController.tableView];
    
    self.filterButton = [[UIButton alloc] initWithFrame:CGRectMake(950, 710, 74, 58)];
    [self.filterButton setTitle:NSLocalizedString(@"Filter",nil) forState:UIControlStateNormal];
    [self.filterButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(pressFilterButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.filterButton];

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

//next/previous clip

//-(void)playNextClipButtonUp:(id)sender{
//    [_tableViewController playNext];
//}
//
//-(void)playPreviousClipButtonUp:(id)sender{
//    [_tableViewController playPrevious];
//}

//save the rating info
-(void)sendRating:(id)sender
{
    RatingInput * cmtRateField = (RatingInput *) sender;
    selectedTag.rating = cmtRateField.rating;
    [_tableViewController reloadData];
}

//save comment
-(void)sendComment
{
    NSString *comment;
    [commentingField.textField resignFirstResponder];
    comment = commentingField.textField.text;
    selectedTag.comment = comment;
}



//extend the tag duration by adding five secs at the beginning of the tag
-(void)startRangeBeenModified:(CustomButton*)button{
    Tag *tagToBeModified = selectedTag;
    
    
    if ([[LocalMediaManager getInstance]getClipByTag:tagToBeModified scrKey:nil]){
        Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:tagToBeModified scrKey:nil];
        [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        [_tableViewController reloadData];
    }
    
    if (!tagToBeModified|| tagToBeModified.type == TagTypeTele ){
        
        return;
    }
    
    
    float newStartTime = 0;
    
    float endTime = tagToBeModified.startTime + tagToBeModified.duration;
    if ([button.accessibilityValue isEqualToString:@"extend"]) {
        
        //extend the duration 5 seconds by decreasing the start time 5 seconds
        newStartTime = tagToBeModified.startTime - [_videoBar getSeekSpeed:@"backward"];
        //if the new start time is smaller than 0, set it to 0
        if (newStartTime <0) {
            newStartTime = 0;
        }
        
    }else{
        //subtract the duration 5 seconds by increasing the start time 5 seconds
        newStartTime = tagToBeModified.startTime + [_videoBar getSeekSpeed:@"backward"];
        
        //if the start time is greater than the endtime, it will cause a problem for tag looping. So set it to endtime minus one
        if (newStartTime > endTime) {
            newStartTime = endTime -1;
        }
        
    }
    
    //set the new duration to tag end time minus new start time
    int newDuration = endTime - newStartTime;

    tagToBeModified.startTime = newStartTime;
    
    if (newDuration > tagToBeModified.duration) {
        tagToBeModified.duration = newDuration;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:tagToBeModified];
    }
}

//extend the tag duration by adding five secs at the end of the tag
-(void)endRangeBeenModified:(CustomButton*)button{
    Tag *tagToBeModified = selectedTag;

    if ([[LocalMediaManager getInstance]getClipByTag:tagToBeModified scrKey:nil]){
        Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:tagToBeModified scrKey:nil];
        [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        [_tableViewController reloadData];
    }
    
    if (!selectedTag || selectedTag.type == TagTypeDeleted)
    {
        return;
    }

    float startTime = tagToBeModified.startTime;
    
    float endTime = startTime + tagToBeModified.duration;
 
    if ([button.accessibilityValue isEqualToString:@"extend"]) {
           //increase end time by 5 seconds
            endTime = endTime + [_videoBar getSeekSpeed:@"forward"];
            //if new end time is greater the duration of video, set it to the video's duration
            if (endTime > [self.videoPlayer durationInSeconds]) {
                endTime = [self.videoPlayer durationInSeconds];
            }
    
        }else{
            //subtract end time by 5 seconds
            endTime = endTime - [_videoBar getSeekSpeed:@"forward"];
            //if the new end time is smaller than the start time,it will cause a problem for tag looping. So set it to start time plus one.
            if (endTime < startTime) {
                endTime = startTime + 1;
            }
    
        }
        //get the new duration
        int newDuration = newDuration = endTime - startTime;
    if (newDuration > tagToBeModified.duration) {
        tagToBeModified.duration = newDuration;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:tagToBeModified];
    }

}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.videoPlayer.mute = YES;
    self.ricoPlayerControlBar.state = RicoPlayerStateNormal;
    [self.ricoPlayerControlBar clear];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_ENABLE_TELE_FILTER object:self];
}



//after finish commenting, touch any other part of the view except commentTextView, will resign the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}


-(void)clear{
    [[TabView sharedFilterTabBar] dismissViewControllerAnimated:NO completion:nil];// close filter if filtering
    [self.allTags removeAllObjects];
    [self.tagsToDisplay removeAllObjects];
    [_tableViewController reloadData];
}

- (void)liveEventStopped:(NSNotification *)note {

    if(_currentEvent.live){
        _currentEvent = nil;
        [self clear];
        selectedTag = nil;
        
        _fullscreenViewController.fullscreen = NO;
        
        [commentingField clear];
        commentingField.enabled             = NO;

    }
}




#pragma mark - Sorting Methods

- (void)sortFromHeaderBar:(id)sender
{
    _tableViewController.tableData = [self sortArrayFromHeaderBar:self.tagsToDisplay headerBarState:headerBar.headerBarSortType];
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

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
    [[ImageAssetManager getInstance].arrayOfClipImages removeAllObjects];
}


#pragma mark - Filtering Methods

- (void)pressFilterButton
{
    [_tableViewController collaspOpenCell];
    
//    [self.pxpFilter filterTags:[self.allTags copy]];
    TabView *popupTabBar = [TabView sharedFilterTabBar];
    Profession * profession = [ProfessionMap getProfession:_currentEvent.eventType];
    [TabView sharedDefaultFilterTab].telestrationLabel.text = profession.telestrationTagName;
    
    
    // setFilter to this view. This is the default filtering for ListView
    // what ever is added to these predicates will be ignored in the filters raw tags
    self.pxpFilter.delegate = self;
    
    if (popupTabBar.isViewLoaded)
    {
        popupTabBar.view.frame =  CGRectMake(0, 0, popupTabBar.preferredContentSize.width,popupTabBar.preferredContentSize.height);
    }
  
    popupTabBar.modalPresentationStyle  = UIModalPresentationPopover; // Might have to make it custom if we want the fade darker
    popupTabBar.preferredContentSize    = popupTabBar.view.bounds.size;


    UIPopoverPresentationController *presentationController = [popupTabBar popoverPresentationController];
    presentationController.sourceRect               = [[UIScreen mainScreen] bounds];
    presentationController.sourceView               = self.view;
    presentationController.permittedArrowDirections = 0;

    [self presentViewController:popupTabBar animated:YES completion:nil];
 
    
    [self.pxpFilter filterTags:[self.allTags copy]];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DISABLE_TELE_FILTER object:self];

}

-(void)closeCurrentPlayingClip:(NSNotification*)note
{
    [_videoBar clear]; // this removes the tag data and controlls to extend from the light grey bar
}


// Pxp
-(void)onFilterComplete:(PxpFilter*)filter
{
    [_tagsToDisplay removeAllObjects];
    [_tagsToDisplay addObjectsFromArray:filter.filteredTags];

    _tableViewController.tableData = [self sortArrayFromHeaderBar:self.tagsToDisplay headerBarState:headerBar.headerBarSortType];
    [_tableViewController reloadData];
}

-(void)onFilterChange:(PxpFilter *)filter
{
    [filter filterTags:self.allTags];
    [_tagsToDisplay removeAllObjects];
    [_tagsToDisplay addObjectsFromArray:filter.filteredTags];
    
    _tableViewController.tableData = [self sortArrayFromHeaderBar:self.tagsToDisplay headerBarState:headerBar.headerBarSortType];
    [_tableViewController reloadData];
}

- (Tag *)tagAfterTag:(nullable Tag *)tag {
    if (tag && _tagsToDisplay.count) {
        NSUInteger i = [_tagsToDisplay indexOfObject:tag] + 1;
        return _tagsToDisplay[i < _tagsToDisplay.count ? i : 0];
    } else {
        return nil;
    }
    
}

- (Tag *)tagBeforeTag:(nullable Tag *)tag {
    if (tag && _tagsToDisplay.count) {
        NSUInteger i = [_tagsToDisplay indexOfObject:tag] - 1;
        return _tagsToDisplay[i < _tagsToDisplay.count ? i : _tagsToDisplay.count];
    } else {
        return nil;
    }
}


-(void)clipCancelNotification:(NSNotification *)note {
    self.ricoFullScreenControlBar.mode = RicoFullScreenModeListNonTag;
    self.ricoPlayerControlBar.state = RicoPlayerStateNormal;
    self.ricoFullScreenControlBar.controlBar.range = kCMTimeRangeInvalid;
    self.ricoPlayerControlBar.range = kCMTimeRangeInvalid;
    
}



- (void)extendStartAction:(UIButton *)button {
    if (selectedTag) {
        [_tableViewController reloadData];
        if ([[LocalMediaManager getInstance]getClipByTag:selectedTag scrKey:nil]){
            Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:selectedTag scrKey:nil];
            [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        }
        
        
        float newStartTime = 0;
        float endTime = selectedTag.startTime + selectedTag.duration;
        
        //extend the duration by decreasing the start time 5 seconds
        newStartTime = selectedTag.startTime - 5;
        //if the new start time is smaller than 0, set it to 0
        if (newStartTime <0) {
            newStartTime = 0;
        }
        
        //set the new duration to tag end time minus new start time
        int newDuration = endTime - newStartTime;
        
        selectedTag.startTime = newStartTime;
        
        if (newDuration > selectedTag.duration) {
            selectedTag.duration = newDuration;
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:selectedTag];
        }
    }
}

- (void)extendEndAction:(UIButton *)button {
    if (selectedTag) {
        [_tableViewController reloadData];
        if ([[LocalMediaManager getInstance]getClipByTag:selectedTag scrKey:nil]){
            Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:selectedTag scrKey:nil];
            [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        }
        
        float startTime = selectedTag.startTime;
        
        float endTime = startTime + selectedTag.duration;
        
        //increase end time by 5 seconds
        endTime = endTime + 5;
        //if new end time is greater the duration of video, set it to the video's duration
        
        RicoPlayer * mainPlayer =         self.ricoPlayerViewController.primaryPlayer;
        
        if (endTime > CMTimeGetSeconds(mainPlayer.duration)) {
            endTime = CMTimeGetSeconds(mainPlayer.duration);
        }
        
        //get the new duration
        int newDuration = newDuration = endTime - startTime;
        if (newDuration > selectedTag.duration) {
            selectedTag.duration = newDuration;
            id<EncoderProtocol> encoder;
            EncoderOperation * tagMod = [[EncoderOperationModTag alloc]initEncoder:encoder data:@{} tag:selectedTag];
            [encoder runOperation:tagMod];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:selectedTag];
        }
        
    }
}


-(void)frameByFrame:(id)sender{
    
    if (self.telestrationViewController.telestration) {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_PLAYER_BAR_CANCEL object:nil];
    }
    
    [self.ricoPlayerViewController pause];
    self.ricoPlayerViewController.playerControlBar.playPauseButton.paused = YES;
    float speed = ([((UIButton*)sender).titleLabel.text isEqualToString:@"FB"] )?-0.10:0.10;
    
    CMTime  sTime = CMTimeMakeWithSeconds(speed, NSEC_PER_SEC);
    CMTime  cTime = self.ricoPlayerViewController.primaryPlayer.currentTime;
    
    
    if (_currentEvent.local) {
        [self.ricoPlayerViewController pause];
        [self.ricoPlayerViewController stepByCount:(speed>0)?1:-1];
    } else {
        
        [self.ricoPlayerViewController seekToTime:CMTimeAdd(cTime, sTime) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
    }
    
    
    
}



@end
