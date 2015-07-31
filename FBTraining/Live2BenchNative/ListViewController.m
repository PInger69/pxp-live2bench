
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
#import "RJLVideoPlayer.h"
#import "FullScreenViewController.h"
#import "ListViewFullScreenViewController.h"
#import "PxpEventContext.h"
#import "PxpPlayerMultiViewController.h"
#import "LocalMediaManager.h"
#import "PxpTelestrationViewController.h"
#import "PxpVideoBar.h"
// Debug

#import "SamplePxpFilterModule.h"
#import "PxpFilterButtonScrollView.h"
//End debug



@interface ListViewController ()

@property (strong, nonatomic, nullable)     PxpPlayerContext *context;
@property (strong, nonatomic, nonnull)      PxpPlayerMultiViewController *playerViewController;
@property (strong, nonatomic)               UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic)               ListViewFullScreenViewController *listViewFullScreenViewController;
@property (strong, nonatomic)               UIButton *filterButton;
@property (strong, nonatomic, nonnull)      PxpTelestrationViewController *telestrationViewController;

@end

@implementation ListViewController{
    
    HeaderBarForListView            * headerBar;
    CommentingRatingField           * commentingField;
    
    Event                           * _currentEvent;
    id <EncoderProtocol>                _observedEncoder;

    // for debug
    SamplePxpFilterModule       * sample;
    PxpFilterButtonScrollView * test;
    
    PxpVideoBar *_videoBar;
}

@synthesize selectedCellRows;


-(instancetype)initWithAppDelegate:(AppDelegate *)appDel{
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"List View", nil) imageName:@"listTab"];
        
        _context = nil;
        _videoBar = [[PxpVideoBar alloc] init];
        _telestrationViewController = [[PxpTelestrationViewController alloc] init];
        [self addChildViewController:_telestrationViewController];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(feedSelected:) name:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil];
        
        
        self.allTags = [[NSMutableArray alloc]init];
        self.tagsToDisplay = [[NSMutableArray alloc]init];
        _tableViewController = [[ListTableViewController alloc]init];
        _tableViewController.contextString = @"TAG";
        [self addChildViewController:_tableViewController];
        //_tableViewController.listViewControllerView = self.view;
        _tableViewController.tableData = self.tagsToDisplay;
 
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];
        
        CGFloat playerWidth = 530 + 10;
        CGFloat playerHeight = playerWidth / (16.0 / 9.0);

        self.videoPlayer = [[RJLVideoPlayer alloc]initWithFrame:CGRectMake(0.0, 55.0, playerWidth , playerHeight )];
        self.videoPlayer.playerContext = STRING_LISTVIEW_CONTEXT;

        [self.view addSubview:self.videoPlayer.view];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_LIST_VIEW_TAG object:nil queue:nil usingBlock:^(NSNotification *note) {
            selectedTag = note.object;
            [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_CLIP];
            
            _videoBar.selectedTag = selectedTag;
        
            [commentingField clear];
            commentingField.enabled             = YES;
            commentingField.text                = selectedTag.comment;
            commentingField.ratingScale.rating  = selectedTag.rating;
            [self.listViewFullScreenViewController setTagName:selectedTag.name];
        }];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipCanceledHandler:) name:NOTIF_CLIP_CANCELED object:self.videoPlayer];
        
        
        
        _pxpFilter = [[PxpFilter alloc]init];
        _pxpFilter.delegate = self;
        
    //    sample = [[SamplePxpFilterModule alloc]initWithArray:@[@"PP",@"COACH CALL",@"PK"]];
//        [_pxpFilter addModules:@[sample]];
//        [_pxpFilter.filtersOwnPredicates addObject:[NSPredicate predicateWithFormat:@"name != %@", @"PP"]];
//        [_pxpFilter.filtersOwnPredicates addObject:[NSPredicate predicateWithFormat:@"type != %ld", (long)TagTypeNormal]];
//        [NSString stringWithFormat:@"type != %ld", (long)TagTypeNormal ];
    }
    return self;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_CLIP_CANCELED object:self.videoPlayer];
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
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_MODIFIED object:_currentEvent];
    }
    [self clear];
    
    if (_currentEvent.live && _appDel.encoderManager.liveEvent == nil) {
        _currentEvent = nil;
        [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_DISABLE];
        [self.videoPlayer playFeed:nil];
    }else{
        _currentEvent = [((id <EncoderProtocol>) note.object) event];
        [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_REGULAR];
        //[self.videoPlayer playFeed:[[_currentEvent.feeds allValues]firstObject] ];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
    }
    
    // update the context
    
    //self.context = [PxpEventContext contextWithEvent:_currentEvent];
    //self.playerViewController.multiView.context = self.context;
    
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
            if (tag.type == TagTypeCloseDuration && ![self.tagsToDisplay containsObject:tag]) {
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
    

    [_tableViewController reloadData];
    
}

//this method will be triggered if user pinches the video view. Based on the pinch velocity, will enter full screen or back to normal screen
- (void)handlePinchGuesture:(UIGestureRecognizer *)recognizer{
    
    if((self.pinchGesture.velocity > 0.5 || self.pinchGesture.velocity < -0.5) && self.pinchGesture.numberOfTouches == 2){
        if (CGRectContainsPoint(self.view.bounds, [self.pinchGesture locationInView:self.view]))
        {
            
            
            if (self.pinchGesture.scale >1) {
                //self.fullScreenViewController.enable = YES;
                self.listViewFullScreenViewController.enable = YES;
                [self.view bringSubviewToFront:_listViewFullScreenViewController.view];
                //                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_FULLSCREEN object:self userInfo:@{@"context":_context,@"animated":[NSNumber numberWithBool:YES]}];
            }else if (self.pinchGesture.scale < 1){
                //self.fullScreenViewController.enable = NO;
                self.listViewFullScreenViewController.enable = NO;
                [self.view bringSubviewToFront:_videoBar];
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

    [self setupView];

     _tableViewController.tableView.delaysContentTouches = NO;
    
    headerBar = [[HeaderBarForListView alloc]initWithFrame:CGRectMake(540,55,1024, LABEL_HEIGHT) defaultSort:TIME_FIELD | DESCEND];
    [headerBar onTapPerformSelector:@selector(sortFromHeaderBar:) addTarget:self];
    [self.view addSubview:headerBar];


    
    
#pragma mark- VIDEO PLAYER INITIALIZATION HERE

    self.videoPlayer.playerContext = STRING_LISTVIEW_CONTEXT;
    
    [self.view addSubview:self.videoPlayer.view];
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

    _tableViewController.tableData = self.tagsToDisplay;
    
    self.telestrationViewController.view.frame = CGRectMake(0.0, 0.0, self.videoPlayer.view.bounds.size.width, self.videoPlayer.view.bounds.size.height - 44.0);
    
    [self.videoPlayer.view addSubview:self.telestrationViewController.view];
    
    self.telestrationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.telestrationViewController.timeProvider = self.videoPlayer;
    self.telestrationViewController.showsControls = NO;
    
    _videoBar.frame = CGRectMake(_videoPlayer.view.frame.origin.x, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height, _videoPlayer.view.frame.size.width, 40.0);
    _videoBar.player = _videoPlayer.avPlayer;
    
    [self.view addSubview:_videoBar];
}

-(void)getNextTag
{
    NSUInteger index = [_tableViewController.tableData indexOfObject:selectedTag];
    
    if (index == _tableViewController.tableData.count - 1) {
        return;
    }
    
    NSUInteger newIndex = index + 1;

    
    
    selectedTag = [_tableViewController.tableData objectAtIndex:newIndex];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{@"context":STRING_LISTVIEW_CONTEXT,
                                                                                                                                   @"feed":[[selectedTag.event.feeds allValues] firstObject],
                                                                                                                                   @"time": [NSString stringWithFormat:@"%f",selectedTag.startTime],
                                                                                                                                   @"duration": [NSString stringWithFormat:@"%d",selectedTag.duration],
                                                                                                                                   @"comment": selectedTag.comment,
                                                                                                                                   @"forWhole":selectedTag,
                                                                                                                                   @"state":[NSNumber numberWithInteger:RJLPS_Play]
                                                                                                                                   }}];
    
    
    [commentingField clear];
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    [self.listViewFullScreenViewController setTagName:selectedTag.name];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:_videoBar];
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
                                                                                                                                    @"feed":[[selectedTag.event.feeds allValues] firstObject],
                                                                                                                                    @"time": [NSString stringWithFormat:@"%f",selectedTag.startTime],
                                                                                                                                    @"duration": [NSString stringWithFormat:@"%d",selectedTag.duration],
                                                                                                                                    @"comment": selectedTag.comment,
                                                                                                                                    @"forWhole":selectedTag,
                                                                                                                                    @"state":[NSNumber numberWithInteger:RJLPS_Play]
                                                                                                                                    }}];

    
    [commentingField clear];
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    [self.listViewFullScreenViewController setTagName:selectedTag.name];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
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
    
    NSDictionary *userInfo = [notification.userInfo objectForKey:@"forFeed"];
    
    float time              = [[userInfo objectForKey:@"time"] floatValue];
    float dur               = [[userInfo objectForKey:@"duration"] floatValue];
    CMTime cmtime           = CMTimeMake(time, 1);
    CMTime cmDur            = CMTimeMake(dur, 1);
    
    CMTimeRange timeRange   = CMTimeRangeMake(cmtime, cmDur);
    Feed *feed = [userInfo objectForKey:@"feed"];
    
    selectedTag = userInfo[@"forWhole"];
    
 
    [self.videoPlayer playClipWithFeed:feed andTimeRange:timeRange];
    
    // only show the telestration on the correct source.
    self.telestrationViewController.telestration = selectedTag.telestration.sourceName == feed.sourceName || [selectedTag.telestration.sourceName isEqualToString:feed.sourceName] ? selectedTag.telestration : nil;;
    
    [commentingField clear];
    commentingField.enabled             = YES;
    commentingField.text                = selectedTag.comment;
    commentingField.ratingScale.rating  = selectedTag.rating;
    
    // find the first player with the source name we are looking for
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", userInfo[@"name"]];
    PxpPlayer *player = [self.context.players filteredArrayUsingPredicate:predicate].firstObject;
    
    // put the player in focus.
    if (player) {
        self.playerViewController.multiView.player = player;
    }
    
    // update the loop range.
    self.context.mainPlayer.range = timeRange;
    
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
}



//after finish commenting, touch any other part of the view except commentTextView, will resign the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}


-(void)clear{
    [self.allTags removeAllObjects];
    [self.tagsToDisplay removeAllObjects];
    //_tableViewController.tableData = [NSMutableArray array];
    [_tableViewController reloadData];
}

- (void)liveEventStopped:(NSNotification *)note {

    if(_currentEvent.live){
        _currentEvent = nil;
        [self clear];
        selectedTag = nil;
        [self.listViewFullScreenViewController setMode:LISTVIEW_FULLSCREEN_MODE_DISABLE];
        
        [commentingField clear];
        commentingField.enabled             = NO;

    }
}


- (void)setTagsToDisplay:(NSMutableArray *)tagsToDisplay {
    NSMutableArray *tags = [NSMutableArray array];
    for (Tag *tag in tagsToDisplay) {
//        if (tag.type == TagTypeNormal) {
            [tags addObject:tag];
//        }
    }
    _tagsToDisplay = tags;
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


#pragma mark - Filtering Methods

- (void)pressFilterButton
{
    if (!test)test = [[PxpFilterButtonScrollView alloc]initWithFrame:CGRectMake(100, 100, 400, 400)];
    
    [self.view addSubview:test];
    [test buildButtonsWith:@[@"PP",@"PK",@"HEAD SHOT",@"COACH CALL"]];
    test.parentFilter = _pxpFilter;
    test.sortByPropertyKey = @"name";
    [_pxpFilter addModules:@[test]];
    
    [_pxpFilter filterTags:[self.allTags copy]];
    
    
}


// Pxp
-(void)onFilterComplete:(PxpFilter*)filter
{


}

-(void)onFilterChange:(PxpFilter *)filter
{
    [filter filterTags:self.allTags];
}

@end