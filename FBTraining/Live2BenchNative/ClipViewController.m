//
//  ClipViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-29.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "ClipViewController.h"
#import "AbstractFilterViewController.h"
#import "FBTFilterViewController.h"
#import "BreadCrumbsViewController.h"
#import "ListPopoverController.h"
#import "EncoderManager.h"

#define CELLS_ON_SCREEN         12
#define TOTAL_WIDTH             1024
#define TOTAL_HEIGHT                600
@interface ClipViewController ()

@end

@implementation ClipViewController
{
    AbstractFilterViewController    * componentFilter;
    BreadCrumbsViewController       * breadCrumbVC;
    ListPopoverController           * sourceSelectPopover;
    NSString                        * eventType;
    EncoderManager                  * _encoderManager;
    id                              clipViewTagObserver;
}

//@synthesize thumbnails=_thumbnails;
@synthesize collectionView=_collectionView;
@synthesize typesOfTags;
@synthesize tagsToDisplay=_tagsToDisplay;
@synthesize thumbRatingArray;
@synthesize thumbnailsLoaded;

static const NSInteger kDeleteAlertTag = 423;
static void * masterEncoderContext = &masterEncoderContext;

- (id)init //controller:(Live2BenchViewController *)lbv
{
    self = [super init];
    
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Clip View", nil) imageName:@"clipTab"];
        _encoderManager = _appDel.encoderManager;
    }
    return self;
}


-(id)initWithAppDelegate:(AppDelegate *)appDel
{
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Clip View", nil) imageName:@"clipTab"];
        _encoderManager = _appDel.encoderManager;
        
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clipViewTagReceived:) name:NOTIF_CLIPVIEW_TAG_RECEIVED object:nil];
        [_encoderManager addObserver:self forKeyPath:@"hasLive" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&masterEncoderContext];
    }
    return self;
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &masterEncoderContext) {
        if ([change objectForKey:@"new"]){
            
            BOOL n = [[change objectForKey:@"new"]boolValue];
            BOOL o = [[change objectForKey:@"old"]boolValue];
            
            if (!n && n != o){
                _tagsToDisplay = [[NSMutableArray alloc]init];
                [_collectionView reloadData];
            }
        }
    }

}

-(void)clipViewTagReceived:(NSNotification*)note
{
    NSString * event = ([_encoderManager.currentEvent isEqualToString:_encoderManager.liveEventName])?@"live":_encoderManager.currentEvent;
    //
    NSMutableArray * tags = [NSMutableArray arrayWithArray:[_encoderManager.eventTags allValues]];
    _tagsToDisplay = tags;
    [_collectionView reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
    sourceSelectPopover = [[ListPopoverController alloc]initWithMessage:@"Select Source:" buttonListNames:@[]];
    sourceSelectPopover.contentViewController.modalInPopover = NO; // this lets you tap out to dismiss

    uController = [[UtilitiesController alloc]init];
    typesOfTags = [[NSMutableArray alloc]init];
    downloadedTagIds = [[NSMutableArray alloc] init];
    [self setupView];
    
    
    //instantiate uicollection cell
    [self.collectionView registerClass:[thumbnailCell class] forCellWithReuseIdentifier:@"thumbnailCell"];
    //set the collectionview's properties
    [self.collectionView setAllowsSelection:TRUE];
    [self.collectionView setAllowsMultipleSelection:TRUE];
    uController = [[UtilitiesController alloc]init];
    typesOfTags = [[NSMutableArray alloc]init];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:@"NewClip" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewTags:) name:@"updateClipView" object:nil];
    breadCrumbVC = [[BreadCrumbsViewController alloc]initWithPoint:CGPointMake(25, 64)];
    [self.view addSubview:breadCrumbVC.view];
    


}


-(void)setupView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    isEditingClips=FALSE;
    UICollectionViewFlowLayout *thumbLayout = [[UICollectionViewFlowLayout alloc] init];
    [thumbLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [thumbLayout setMinimumInteritemSpacing:5];
    [thumbLayout setMinimumLineSpacing:40];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 88.0f, self.view.bounds.size.width-60, 720.0f) collectionViewLayout:thumbLayout];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setPagingEnabled:FALSE];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.allowsMultipleSelection = TRUE;
    [self.view addSubview:self.collectionView];
    
    filterContainer = [[UIView alloc] initWithFrame:CGRectMake(TOTAL_WIDTH, 450, self.view.bounds.size.width-100, 370.0f)];
    [filterContainer setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:filterContainer];
    
    self.edgeSwipeButtons = [[EdgeSwipeEditButtonsView alloc] initWithFrame:CGRectMake(1024-44, 55, 44, 768-55)];
    self.edgeSwipeButtons.delegate = self;
    [self.view addSubview:self.edgeSwipeButtons];
    
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
    //clean the image cache to make sure each thumbnail displays the right image ;
    //otherwise the images from the old event will stay there
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
    [imageCache cleanDisk];
    
    //pause the video palyer in live2bench view and my clip view
    
    
    // MUTE THE VIDEOS
    //Richard
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:self userInfo:@{@"context":@"Live2Bench Tab"}];
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:self userInfo:@{@"context":@"ListView Tab"}];
//    [globals.VIDEO_PLAYER_LIST_VIEW pause];
//    [globals.VIDEO_PLAYER_LIVE2BENCH pause];

    //if no filter tool box, initialize filter tool box // This is dead code now
    if(!_filterToolBoxView)
    {
        NSArray *argObjs =[[NSArray alloc]initWithObjects:self,self.collectionView, nil];
        NSArray *argKeys = [[NSArray alloc]initWithObjects:@"controller",@"displayArch", nil];
        NSDictionary *filterArgs = [[NSDictionary alloc]initWithObjects:argObjs forKeys:argKeys];
        
        _filterToolBoxView = [[FilterToolboxViewController alloc]initWithArgs:filterArgs];
        [_filterToolBoxView.view setUserInteractionEnabled:TRUE];
        //_filterToolBoxView.showTelestration = TRUE;
        _filterToolBoxView.view.layer.masksToBounds = NO;
        _filterToolBoxView.view.layer.cornerRadius = 1; // if you like rounded corners
        _filterToolBoxView.view.layer.shadowOffset = CGSizeMake(1, 1);
        _filterToolBoxView.view.layer.shadowRadius = 2;
        _filterToolBoxView.view.layer.shadowOpacity = 0.4;
        [_filterToolBoxView.view setAlpha:0.95f];
        
    }

    /* TODO This was disabled for Demo
    // Richard
    if(!componentFilter || eventType != globals.WHICH_SPORT) {
        eventType   = globals.WHICH_SPORT;

        NSMutableDictionary * tagData      = globals.CURRENT_EVENT_THUMBNAILS;
        if ([eventType isEqualToString:SPORT_HOCKEY]){
            componentFilter = [[FBTFilterViewController alloc]initWithTagData:tagData];
        }
        else if ([eventType isEqualToString:SPORT_FOOTBALL]){
            componentFilter = [[FBTFilterViewController alloc]initWithTagData:tagData];
        }
        else if ([eventType isEqualToString:SPORT_SOCCER]){
            componentFilter = [[FBTFilterViewController alloc]initWithTagData:tagData];
        }
        else if ([eventType isEqualToString:SPORT_RUGBY]){
            componentFilter = [[FBTFilterViewController alloc]initWithTagData:tagData];
        }
        else if ([eventType isEqualToString:SPORT_FOOTBALL_TRAINING]){
            componentFilter = [[FBTFilterViewController alloc]initWithTagData:tagData];
        }
        else {
            componentFilter = [[FBTFilterViewController alloc]initWithTagData:tagData];
        }
        
        [componentFilter onSelectPerformSelector:@selector(receiveFilteredArrayFromFilter:) addTarget:self];
        [componentFilter onSwipePerformSelector:@selector(slideFilterBox) addTarget:self];
        componentFilter.finishedSwipe = TRUE;
     
        [self.view addSubview:componentFilter.view];
        [componentFilter setOrigin:CGPointMake(60, 190)];
        [componentFilter close:NO];
            [componentFilter viewDidAppear:TRUE];


    } else if ([componentFilter rawDataEmpty]) {
        // fix this
        [componentFilter.view removeFromSuperview];
        componentFilter = [[FBTFilterViewController alloc]initWithTagData:globals.CURRENT_EVENT_THUMBNAILS];
        [self.view addSubview:componentFilter.view];
        [componentFilter setOrigin:CGPointMake(60, 190)];
        [componentFilter close:NO];
        [componentFilter viewDidAppear:TRUE];
    }
    
    */
    // End Richard
    
//    self.tagsToDisplay = [NSMutableArray arrayWithArray:@[@"test"]];

//    [self.tagsToDisplay addObjectsFromArray:[[_encoderManager.eventTags objectForKey:_encoderManager.liveEventName] allValues]];
    
//    self.tagsToDisplay = [[_encoderManager.eventTags objectForKey:event] allValues];
    return;
//    for(int i=0;i<4;i++)
//    {
//        NSMutableArray *sectionArray = [[NSMutableArray alloc]init];
//        [typesOfTags addObject:sectionArray];
//    }
//    
//    ////NSLog(@"globals.CURRENT_EVENT_THUMBNAILS count in clipview %d  typesOfTags %@",globals.CURRENT_EVENT_THUMBNAILS.count,typesOfTags);
//    //remove tags with type value odd or 6 or 8
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
//        //just for testing
//        [openEndStrings addObject:@"100"];
//        [openEndStrings addObject:@"101"];
//
//    }
//    
//    
//    NSMutableArray *allTagsCopy = [[globals.CURRENT_EVENT_THUMBNAILS allValues] mutableCopy];
//    for(NSDictionary *tag in [globals.CURRENT_EVENT_THUMBNAILS allValues]){
//        if(([[tag objectForKey:@"type"]integerValue]&1)){ //remove all odd tags and also all periods
//            [allTagsCopy removeObject:tag];
//        }
//    }
//    
//    //allTagsArr is array of all tags which could display in clip view
//    NSMutableArray *allTagsArr = [[NSMutableArray alloc]init];
//    //type == 2, line tag;type == 0, normal tag; type == 4, telestration tag;
//    //type == 10, strength tags; type == 3, tag was deleted
//    //seperate the tags according to its type
//    for(NSDictionary *tag in allTagsCopy){
//        
//        if ([tag objectForKey:@"colour"] != nil) {
//            
//            if(![globals.ARRAY_OF_COLOURS containsObject:[tag objectForKey:@"colour"]])
//            {
//                [globals.ARRAY_OF_COLOURS  addObject:[tag objectForKey:@"colour"]];
//            }
//            
//            if ([tag objectForKey:@"type"]){
//                
//                if([[tag objectForKey:@"type"] intValue]==0 ||[[tag objectForKey:@"type"] intValue]==100 || [[tag objectForKey:@"type"] intValue]==4) //nomarl tags & duration tag & tele tags
//                {
//                    [allTagsArr addObject:tag];
//                    ////NSLog(@"tag name %@",[tag  objectForKey:@"name"]);
//                    if(![[typesOfTags objectAtIndex:0] containsObject:[tag objectForKey:@"name"]] && [[tag objectForKey:@"name"] rangeOfString:@"Pl. "].location == NSNotFound )
//                    {
//                        [[typesOfTags objectAtIndex:0] addObject:[tag objectForKey:@"name"]];
//                    }
//                    
//                    if ([[tag  objectForKey:@"player"]count]>0 && ![[[tag  objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""] ) {
//                        NSMutableSet* set1 = [NSMutableSet setWithArray:[typesOfTags objectAtIndex:3]];
//                        NSMutableSet* set2 = [NSMutableSet setWithArray:[tag  objectForKey:@"player"]];
//                        [set1 intersectSet:set2]; //this will give you only the obejcts that are in both sets
//                        NSArray* intersectArray = [set1 allObjects];
//                        if (intersectArray.count < [[tag objectForKey:@"player"]count]) {
//                            NSMutableArray *tempPlayerArr = [[tag objectForKey:@"player"]mutableCopy];
//                            //new players which are not included in the array typesoftags
//                            [tempPlayerArr removeObjectsInArray:intersectArray];
//                            [[typesOfTags objectAtIndex:3] addObjectsFromArray:tempPlayerArr];
//                            
//                        }
//                    }
//                    
//                }else if([[tag objectForKey:@"type"] intValue]==10){  //strength tags : type == 10
//                    
//                    [allTagsArr addObject:tag];
//                    
//                    if(![[typesOfTags objectAtIndex:2] containsObject:[tag  objectForKey:@"name"]])
//                    {
//                        [[typesOfTags objectAtIndex:2] addObject:[tag  objectForKey:@"name"]];
//                    }
//                    
//                }else if(!([[tag objectForKey:@"type"] intValue]&1) && ![openEndStrings containsObject:[NSString stringWithFormat:@"%@",[tag objectForKey:@"type"]]] ){//other tags with "type" value is even
//                    
//                    [allTagsArr addObject:tag];
//                    
//                    if(![[typesOfTags objectAtIndex:1] containsObject:[tag  objectForKey:@"name"]])
//                    {
//                        [[typesOfTags objectAtIndex:1] addObject:[tag  objectForKey:@"name"]];
//                    }
//                }
//            }
//        }
//    }
//    
//    ////NSLog(@"typesOfTags in clipview: %@",typesOfTags);
//    //globals.THUMBNAIL_COUNT_REF_ARRAY = allTagsArr;
//    allTagsCopy = nil;
//    [allTagsCopy removeAllObjects];
//  
//     globals.TYPES_OF_TAGS=typesOfTags;
//    if (!globals.TAGGED_ATTS_DICT_SHIFT.count && !globals.TAGGED_ATTS_DICT.count){
//        //if no filter button is selected, the data used to diplay in the collection view is allTagsArr
//        self.tagsToDisplay=[[self sortArrayByTime:allTagsArr] mutableCopy];
//        if (!globals.FINISHED_LOADING_THUMBNAIL_IMAGES){
//            @try {
//                downloadedTagIds = [globals.DOWNLOADED_THUMBNAILS_SET mutableCopy];
//            }
//            @catch (NSException *exception){
//                NSLog(@"downloadedTagIds: %@",exception.reason);
//            }
//        }
//        thumbnailsLoaded = TRUE;
//        [self.collectionView reloadData];
//         globals.THUMBNAIL_COUNT_REF_ARRAY = self.tagsToDisplay;
//    } else {
//        //if there are filter buttons selected, display the tags which are filtered
//        if(![self.view.subviews containsObject:_filterToolBoxView.view])
//        {
//            
//            [_filterToolBoxView.view setFrame:filterContainer.frame];
//            [self.view addSubview:_filterToolBoxView.view];
//            
//            UISwipeGestureRecognizer *oneFingerSwipeUp = [[UISwipeGestureRecognizer alloc]
//                                                          initWithTarget:self
//                                                          action:@selector(oneFingerSwipeUp:)];
//            [oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
//            [_filterToolBoxView.view addGestureRecognizer:oneFingerSwipeUp];
//            
//            //register right swipe
//            UISwipeGestureRecognizer *oneFingerSwipeDown = [[UISwipeGestureRecognizer alloc]
//                                                            initWithTarget:self
//                                                            action:@selector(oneFingerSwipeDown:)] ;
//            [oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
//            [filterContainer addGestureRecognizer:oneFingerSwipeDown];
//            [_filterToolBoxView.view addGestureRecognizer:oneFingerSwipeDown];
//            
////            globals.TYPES_OF_TAGS=typesOfTags;
//            [_filterToolBoxView viewDidAppear:TRUE];
//        }
//    
//        
//        
//        // Richard
//        if(![self.view.subviews containsObject:componentFilter.view])
//        {
//            [self.view addSubview:componentFilter.view];
//        }
//        // End Richard
//        
//        
//    
//        }
//    if (allTagsArr.count > 0) {
//        [self createBreadCrumbsView];
//        self.edgeSwipeButtons.hidden = YES;
//    }else{
//        [breadCrumbsView removeFromSuperview];
//        breadCrumbsView  = nil;
//        self.edgeSwipeButtons.hidden = YES;
//    }
//    
//    
//    [componentFilter refresh]; // refresh list when View
//    [breadCrumbVC inputList: [componentFilter.tabManager invokedComponentNames]];
}






//  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  //
-(void)receiveFilteredArrayFromFilter:(id)filter
{
    AbstractFilterViewController * checkFilter = (AbstractFilterViewController *)filter;
    NSMutableArray *filteredArray = (NSMutableArray *)[checkFilter processedList]; //checkFilter.displayArray;
    self.tagsToDisplay = [filteredArray mutableCopy];
    [self.collectionView reloadData];
    [breadCrumbVC inputList: [checkFilter.tabManager invokedComponentNames]];
}
//  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  ////  //






#pragma mark - Edge Swipe Buttons Delegate Methods
- (void)slideFilterBox
{
    
    float boxXValue = _filterToolBoxView.view.frame.origin.x>=self.view.frame.size.width? 60 : self.view.frame.size.width;

    if(boxXValue == 60)
    {
        if(!self.blurView)
        {
            self.blurView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, 1024, 768-55)];
            self.blurView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
            UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFilterToolbox)];
            [self.blurView addGestureRecognizer:tapRec];
            [self.view insertSubview:self.blurView belowSubview:_filterToolBoxView.view];
        }
        self.blurView.hidden = NO;
        
//        [_filterToolBoxView updateDisplayedTagsCount];
        
        //clear the previous filter set
        [breadCrumbsView removeFromSuperview];
        breadCrumbsView  = nil;

    }
    else{
        self.blurView.hidden = YES;
        [self createBreadCrumbsView];
    }

    [componentFilter open:YES]; //Richard
}


- (void)dismissFilterToolbox
{
    self.blurView.hidden = YES;
    [self.edgeSwipeButtons deselectButtonAtIndex:1];
    [componentFilter close:YES]; //Richard
}


-(void)editingClips:(BOOL)isEditing
{
    if (isEditing)
    {
        isEditingClips = TRUE;
        
    }
    else
    {
        isEditingClips=FALSE;
        if ([arrayToBeDeleted count])
        {//uncheck all the check box and clear the selectedCellRows array
            [arrayToBeDeleted removeAllObjects];
            [self.collectionView reloadData];
        }

    }
}


-(void)deleteCells
{
    if (!arrayToBeDeleted || !arrayToBeDeleted.count) {
        return;
    }
    
    CustomAlertView *alert = [[CustomAlertView alloc] init];
    alert.tag = kDeleteAlertTag;
    [alert setTitle:@"myplayXplay"];
    [alert setMessage:@"Are you sure you want to delete these tags?"];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert show];
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
}


//get the array from the filter
-(void)receiveFilteredArray:(NSArray*)filteredArray
{
//    if (thumbnailsLoaded) {
//        thumbnailsLoaded = FALSE;
//        return;
//    }
//    self.tagsToDisplay=[[self sortArrayByTime: [NSMutableArray arrayWithArray:filteredArray]] mutableCopy];
//    [self.collectionView reloadData];
////     globals.THUMBNAIL_COUNT_REF_ARRAY = self.tagsToDisplay;
//    @try {
//        downloadedTagIds = [globals.DOWNLOADED_THUMBNAILS_SET mutableCopy];
//    }
//    @catch (NSException *exception) {
//        NSLog(@"downloadedTagIds: %@",exception.reason);
//    }
}

//new tags received from the server while the user is in clip view
-(void)getNewTags:(NSNotification*)notification{
//    NSDictionary *newTag;
//    if(globals.TAGGED_ATTS_DICT_SHIFT.count >0){
//        if ([_filterToolBoxView sortClipsBySelectingforShiftFiltering:notification.object].count > 0) {
//            //[self.tagsToDisplay addObjectsFromArray:[_filterToolBoxView sortClipsBySelectingforShiftFiltering:notification.object]];
//            //socket only send one tag a time
//            newTag = [[[_filterToolBoxView sortClipsBySelectingforShiftFiltering:notification.object] objectAtIndex:0] copy];
//            if ([[newTag objectForKey:@"modified"]intValue] != 1) {
//                [self.tagsToDisplay addObject:newTag];
//            }else{
//                [self.collectionView reloadData];
//                return;
//            }
//            
//        }else{
//            return;
//        }
//        
//    }else{
//        if ([_filterToolBoxView sortClipsWithAttributes:notification.object].count > 0) {
//            //[self.tagsToDisplay addObjectsFromArray:[_filterToolBoxView sortClipsWithAttributes:notification.object]];
//            
//            //socket only send one tag a time
//            newTag = [[[_filterToolBoxView sortClipsWithAttributes:notification.object] objectAtIndex:0]copy];
//            
//            //if this tag is tagmod tag, donot update the list view.
//            if ([[newTag objectForKey:@"modified"]intValue] != 1) {
//                [self.tagsToDisplay addObject:newTag];
//            }else{
//                [self.collectionView reloadData];
//                return;
//            }
//            
//        }else{
//            return;
//        }
//        
//    }
    
//    if (globals.CURRENT_EVENT_THUMBNAILS.count > 0) {
//        //[self createBreadCrumbsView];
//        self.edgeSwipeButtons.hidden = YES;
//    }else{
//        self.edgeSwipeButtons.hidden = YES;
//    }
//    
//    [self updateTagTypes:notification.object];
//    globals.THUMBNAIL_COUNT_REF_ARRAY = self.tagsToDisplay;
    [self.collectionView reloadData];
}

//update update globals.TYPES_OF_TAGS which is used to update filter view's event buttons, user buttons and player buttons
-(void)updateTagTypes:(NSArray*)tagsArr{
    
//    NSMutableArray *openEndStrings = [[NSMutableArray alloc] init]; //will use this array for open and end types of different sports -- soccer will be 17,18 hockey will be 7,8
//    if([globals.WHICH_SPORT isEqualToString:@"hockey"])
//    {
//        [openEndStrings addObject:@"7"];
//        [openEndStrings addObject:@"8"];
//    }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
//    {
//        [openEndStrings addObject:@"17"];
//        [openEndStrings addObject:@"18"];
//    }
//    
//    NSMutableArray *allTagsCopy = [tagsArr mutableCopy];
//    for(NSDictionary *tag in [globals.CURRENT_EVENT_THUMBNAILS allValues]){
//        if(([[tag objectForKey:@"type"]integerValue]&1)){ //remove all odd tags and also all periods
//            [allTagsCopy removeObject:tag];
//        }
//    }
//    
//    //allTagsArr is array of all tags which could display in clip view
//    NSMutableArray *allTagsArr = [[NSMutableArray alloc]init];
//    //type == 2, line tag;type == 0, normal tag; type == 4, telestration tag;
//    //type == 10, strength tags; type == 3, tag was deleted
//    //seperate the tags according to its type
//    for(NSDictionary *tag in allTagsCopy){
//        
//        globals.IS_TAG_TYPES_UPDATED = TRUE;
//        
//        if ([tag objectForKey:@"colour"] != nil) {
//            
//            if(![globals.ARRAY_OF_COLOURS containsObject:[tag objectForKey:@"colour"]])
//            {
//                [globals.ARRAY_OF_COLOURS  addObject:[tag objectForKey:@"colour"]];
//            }
//            
//            if ([tag objectForKey:@"type"]){
//                
//                if([[tag objectForKey:@"type"] intValue]==0 ||[[tag objectForKey:@"type"] intValue]==100 || [[tag objectForKey:@"type"] intValue]==4) //nomarl tags & duration tag & tele tags
//                {
//                    [allTagsArr addObject:tag];
//                    ////NSLog(@"tag name %@",[tag  objectForKey:@"name"]);
//                    if(![[globals.TYPES_OF_TAGS objectAtIndex:0] containsObject:[tag objectForKey:@"name"]] && [[tag objectForKey:@"name"] rangeOfString:@"Pl. "].location == NSNotFound )
//                    {
//                        [[globals.TYPES_OF_TAGS objectAtIndex:0] addObject:[tag objectForKey:@"name"]];
//                    }
//                    
//                    if ([[tag  objectForKey:@"player"]count]>0 && ![[[tag  objectForKey:@"player"] objectAtIndex:0] isEqualToString: @""] ) {
//                        NSMutableSet* set1 = [NSMutableSet setWithArray:[globals.TYPES_OF_TAGS objectAtIndex:3]];
//                        NSMutableSet* set2 = [NSMutableSet setWithArray:[tag  objectForKey:@"player"]];
//                        [set1 intersectSet:set2]; //this will give you only the obejcts that are in both sets
//                        NSArray* intersectArray = [set1 allObjects];
//                        if (intersectArray.count < [[tag objectForKey:@"player"]count]) {
//                            NSMutableArray *tempPlayerArr = [[tag objectForKey:@"player"]mutableCopy];
//                            //new players which are not included in the array typesoftags
//                            [tempPlayerArr removeObjectsInArray:intersectArray];
//                            [[globals.TYPES_OF_TAGS objectAtIndex:3] addObjectsFromArray:tempPlayerArr];
//                            
//                        }
//                    }
//                    
//                }else if([[tag objectForKey:@"type"] intValue]==10){  //strength tags : type == 10
//                    
//                    [allTagsArr addObject:tag];
//                    
//                    if(![[globals.TYPES_OF_TAGS objectAtIndex:2] containsObject:[tag  objectForKey:@"name"]])
//                    {
//                        [[globals.TYPES_OF_TAGS objectAtIndex:2] addObject:[tag  objectForKey:@"name"]];
//                    }
//                    
//                }else if(!([[tag objectForKey:@"type"] intValue]&1) && ![openEndStrings containsObject:[NSString stringWithFormat:@"%@",[tag objectForKey:@"type"]]] ){//other tags with "type" value is even
//                    
//                    [allTagsArr addObject:tag];
//                    
//                    if(![[globals.TYPES_OF_TAGS objectAtIndex:1] containsObject:[tag  objectForKey:@"name"]])
//                    {
//                        [[globals.TYPES_OF_TAGS objectAtIndex:1] addObject:[tag  objectForKey:@"name"]];
//                    }
//                }
//            }
//        }
//    }

    
}

// TODO dead?
-(void)createBreadCrumbsView{
    
//    [breadCrumbsView removeFromSuperview];
//    breadCrumbsView  = nil;
//    
//    breadCrumbsView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,self.collectionView.frame.origin.y-20, self.view.bounds.size.width, 40)];
//
////    [self.view addSubview:breadCrumbsView];
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
//            UIImageView *crumbBG = [[UIImageView alloc] initWithFrame:CGRectMake(25+(i*113), 0, 120, 35)];
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
//        UIImageView *crumb = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 100, 35)];
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
    
}


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

//find the thumbnail images directory and set them to a global array
-(void)retrieveImages
{
    
    // NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:globals.THUMBNAILS_PATH error:NULL];
    
    //self.thumbnails=[directoryContent mutableCopy];
}

//how many thumbnails?
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.tagsToDisplay.count;
}

//how many sections?
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}


///NOTE: when filterbox.view is all the way up, customer goes to another screen and comes back, filterbox.view cannot be interacted with
-(void)viewWillDisappear:(BOOL)animated
{
    return;
//    globals.IS_IN_CLIP_VIEW = FALSE;
//    SDImageCache *imageCache = [SDImageCache sharedImageCache];
//    [imageCache clearMemory];
//    [imageCache clearDisk];
//    [imageCache cleanDisk];
//    if(self.tagsToDisplay.count>0)
//    {
//        [self.tagsToDisplay removeAllObjects];
//    }
//    //[displayArray removeAllObjects];
//    thumbRatingArray = nil;
//    [arrayToBeDeleted removeAllObjects];
//    globals.SHOW_TOASTS = TRUE;
//    //we will remove the filtertoolbox to deallocate mem -- makes sure app does not freeze up
//    [_filterToolBoxView.view removeFromSuperview];
//    _filterToolBoxView=nil;
//
//    [typesOfTags removeAllObjects];
////    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeAllObjects];
//    [CustomAlertView removeAll];
//    isEditingClips = FALSE;
//    if(!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer)){
//        [uController writeTagsToPlist];
//    }
//    
//    [self.blurView removeFromSuperview];
//    self.blurView=nil;
//    
//    //Edge Swipe Buttons
//    [self.edgeSwipeButtons deselectAllButtons];
//    [componentFilter close:NO];

}


//create le thumbnail cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Get the data from the array
    NSDictionary *tagSelect = [self.tagsToDisplay objectAtIndex:[indexPath indexAtPosition:1]];
    
    
    thumbnailCell *cell = (thumbnailCell*)[cv dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
    cell.backgroundView = nil;
    cell.data           = tagSelect;
    
    
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
//        [openEndStrings addObject:@"7"];
//        [openEndStrings addObject:@"8"];
//    }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
//    {
//        [openEndStrings addObject:@"17"];
//        [openEndStrings addObject:@"18"];
//    }else if ([globals.WHICH_SPORT isEqualToString:@"football"])
//    {
//        [openEndStrings addObject:@"21"];
//        [openEndStrings addObject:@"22"];
//    }else{
//        //this will happen if the there is new tag coming when the user stops the live event (globals.WHICH_SPORT is empty), then just return; Otherwise the app will crash
//        //for testing
//        [openEndStrings addObject:@"100"];
//        [openEndStrings addObject:@"101"];
//        //return cell;
//    }
    

    //updated tag dictionary from globals current event thumbnails
//    NSDictionary *thumbDict = [globals.CURRENT_EVENT_THUMBNAILS objectForKey:[NSString stringWithFormat:@"%@",[tagSelect objectForKey:@"id"]]];//[[NSDictionary alloc]initWithDictionary:[self.tagsToDisplay objectAtIndex:[indexPath indexAtPosition:1]] copyItems:TRUE];
    
//    if(![arrayToBeDeleted containsObject:tagSelect]){
//        [cell.translucentEditingView setHidden:TRUE];
//        [cell.checkmarkOverlay setHidden:TRUE];
//    }else{
//        [cell.translucentEditingView setHidden:FALSE];
//        [cell.checkmarkOverlay setHidden:FALSE];
//    }
//    
//    globals.THUMBNAILS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"thumbnails"];
//    //path of the thumb image file in the local folder
//    NSString *currentImage = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[[tagSelect objectForKey:@"url"] lastPathComponent]];
//    //if the image file is not downloaded to the local folder, redownloaded
//    if (![[NSFileManager defaultManager] fileExistsAtPath:currentImage]) {
//        cell.imageLoaded = [self redownloadImageFromtheServer:tagSelect];
//    }else{
//        //if the image file is already downloaded, set the boolean value cell.imageLoaded to TRUE
//        cell.imageLoaded = TRUE;
//    }
//    
//    if (cell.imageLoaded){
//        //if the thumb image has been downloaded, present the image
//        
//        cell.imageView.contentMode = UIViewContentModeCenter;
//        [cell.imageView setImage:[UIImage imageWithContentsOfFile:currentImage]];
//        cell.imageView.contentMode = UIViewContentModeScaleToFill;
//        //[cell.imageView setImageWithURL:[thumbDict objectForKey:@"url"] placeholderImage:[UIImage imageNamed:@"live.png"] options:nil completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {[weakCell.activityInd stopAnimating]; weakCell.imageView.contentMode = UIViewContentModeScaleToFill;}];
//    } else {
//        //if the thumb image has not been downloaded, present the default image (live.png)
//        
//        cell.imageView.contentMode = UIViewContentModeCenter;
//        [cell.imageView setImage:[UIImage imageNamed:@"live.png"]];
//    }
//    
//    UIColor *thumbColour = [uController colorWithHexString:[tagSelect objectForKey:@"colour"]];
//    NSString *thumbNameStr = [tagSelect  objectForKey:@"name"];
//    if ([_encoderManager.currentEventType isEqualToString:SPORT_FOOTBALL_TRAINING] && ([tagSelect objectForKey:@"subtag"] && ![[tagSelect objectForKey:@"subtag"] isEqualToString:@""]))
//    {
//        thumbNameStr = [NSString stringWithFormat:@"%@ - %@",[tagSelect objectForKey:@"name"],[tagSelect objectForKey:@"subtag"]];
//    }
//    
//    [cell.thumbName setText:thumbNameStr];
//    [cell.thumbName setFont:[UIFont boldSystemFontOfSize:18.0f]];
//    [cell.thumbTime setText:[tagSelect objectForKey:@"displaytime"]];
//    [cell.thumbDur setText:[NSString stringWithFormat:@"%.02fs",[[tagSelect objectForKey:@"duration"] floatValue]]];
//    [cell.thumbColour changeColor:thumbColour withRect:cell.thumbColour.frame];
//    
//    //set cells delete button title to index path of cell so we can reference later -- title is invisible -- section,row
//    [cell.thumbDeleteButton setTitle:[NSString stringWithFormat:@"%ld,%ld",(long)indexPath.section ,(long)indexPath.row] forState:UIControlStateNormal];
//    [cell.thumbDeleteButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//
    
    /*
    if ([globals.WHICH_SPORT isEqualToString:@"medical"] || [globals.WHICH_SPORT isEqualToString:@""]) {
        [cell.thumbPeriod setHidden:TRUE];
    }else{
        if(globals.ARRAY_OF_PERIODS && globals.ARRAY_OF_PERIODS.count > 0){
            
            NSString *tagTime = [NSString stringWithFormat:@"%@",[thumbDict objectForKey:@"time"] ];
            NSString *closestTagTime;
            NSDictionary *timeDictionary;
            NSMutableArray *t;
            
            
            t = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:[openEndStrings  objectAtIndex:1]]];
            if(globals.HAS_MIN)
            {
                [t addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:[openEndStrings objectAtIndex:0]]];
            }
            NSMutableArray *temp=[t mutableCopy];
            
            // force all times to be strings -- makes it easier to search for items in dictionary later
            for(NSNumber* obj in t)
            {
                int i = [t indexOfObject:obj];
                [temp replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@",obj]];
            }
            t=[temp mutableCopy];
            temp=nil;
            //sorting
            [t sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
                return [str1 compare:str2 options:(NSNumericSearch)];
            }];
            
            int periodIndex=-1;
            
            NSInteger *sortedIndex = 0;
            if (t.count >= 1) {
                int binSearchIndex =[t binarySearch:tagTime] ; // binsearch returns -1 if time not found
                
                binSearchIndex = (int)binSearchIndex <0 ? 0:binSearchIndex; // make sure the binary search index is greater then 0
                sortedIndex=(int)binSearchIndex >t.count-1 ? t.count-1 : binSearchIndex-1; // make sure index isn't greater then size of array
                sortedIndex=(int)sortedIndex < 0 ? 0:sortedIndex; //make sure index isn't less then 0
                closestTagTime = [NSString stringWithFormat:@"%@",[t objectAtIndex:sortedIndex]];
                timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey: closestTagTime]];
                
                periodIndex = [[timeDictionary objectForKey:[openEndStrings objectAtIndex:1]] integerValue];
                if(!periodIndex)
                {
                    periodIndex=[[timeDictionary objectForKey:[openEndStrings objectAtIndex:0]] integerValue];
                }
                
            }
            if (periodIndex <0) {
                periodIndex = 0;
            }
            if(periodIndex>=0)
            {
                if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                    [cell.thumbPeriod setText:[NSString stringWithFormat:@"P:%@",[globals.ARRAY_OF_PERIODS objectAtIndex:periodIndex]]];
                }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]){
                    [cell.thumbPeriod setText:[NSString stringWithFormat:@"H:%@",[globals.ARRAY_OF_PERIODS objectAtIndex:periodIndex]]];
                }else if([globals.WHICH_SPORT isEqualToString:@"football"]){
                    [cell.thumbPeriod setText:[NSString stringWithFormat:@"Q:%@",[globals.ARRAY_OF_PERIODS objectAtIndex:periodIndex]]];
                }
            }
        }else{
            [cell.thumbPeriod setText:@""];
        }
    }
*/
    
//    int ratingValue = [[thumbDict objectForKey:@"rating"]integerValue];
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
//        UIView *ratingView = [thumbRatingArray objectAtIndex:i];
//        [ratingView setHidden:TRUE];
//    }
//    
    
    //set image to cell view
    
//    [cell.imageView setIsAccessibilityElement:TRUE];
//    if(![self.view.subviews containsObject:_filterToolBoxView.view])
//    {
//        [_filterToolBoxView.view setFrame:filterContainer.frame];
//        [self.view addSubview:_filterToolBoxView.view];
//          [self.view addSubview:componentFilter.view];// RICHARD
////        globals.TYPES_OF_TAGS=typesOfTags;
//        //[_filterToolBoxView viewDidAppear:TRUE];
//    }
    //if the tag has aready been view, set the background colored
    
//    if(!cell.backgroundView)
//    {
//        cell.backgroundView = [cell.subviews objectAtIndex:1];
//    }
//    if([globals.THUMBS_WERE_SELECTED_CLIPVIEW containsObject: [thumbDict objectForKey:@"id"]]){
//        if([[thumbDict objectForKey:@"id"] isEqual: globals.THUMB_WAS_SELECTED_CLIPVIEW]){
//            [cell.backgroundView setImage:[UIImage imageNamed:@"clip-back-just"]];
//            [cell setNeedsDisplay];
//        }else{
//            cell.alpha = 0.5;
//            [cell.backgroundView setImage:[UIImage imageNamed:@"clip-back-old"]];
//            [cell setNeedsDisplay];
//        }
//    }else{
//        [cell.backgroundView setImage:[UIImage imageNamed:@"clip-back"]];
//        [cell setNeedsDisplay];
//        
//    }
//    
    return cell;
}




//catch response of deletion alertview adn do thigns with it
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if(alertView.tag == kDeleteAlertTag)
//    {
//        if (buttonIndex == 0)
//        {
//            NSMutableArray *tempArr = [self.tagsToDisplay mutableCopy];
//            // Ok, delete the tags and also sender the information to the server
//            for (NSDictionary *dict in arrayToBeDeleted ) {
//                //NSIndexPath *indexPath =
//                //NSMutableDictionary *tag = [[dict objectForKey:@"tag"]mutableCopy];
//                NSMutableDictionary *tag = [dict mutableCopy];
//                
//                //tempArr will used to update displayTags array; if you remove obj directly from displayTags array , [self tagAtIndexPath:indexPath] will have error
//                [tempArr removeObject:tag];
//                
//                //remove  the tag marker
//                [[[globals.TAG_MARKER_OBJ_DICT objectForKey:[NSString stringWithFormat:@"%f",[[tag objectForKey:@"id"] doubleValue] ]] markerView] removeFromSuperview];
//                
//                if (!globals.HAS_MIN ||(globals.HAS_MIN && !globals.eventExistsOnServer)){
//                    
//                    //if the tag is created in offline mode, just delete it
//                    if ([[tag objectForKey:@"local"] intValue] == 1){
//                        
//                        //delete the tag from the global dictionary of tags
//                        
//                        [globals.CURRENT_EVENT_THUMBNAILS removeObjectForKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
//                        
//                        [self.tagsToDisplay removeObject:tag];
//                        [globals.THUMBNAIL_COUNT_REF_ARRAY removeObject:tag];
//                        
//                    }else {
//                        //if the tag is created in online mode, modified the tag dictionary; once having the server back, send request and delete it from the server
//                        [tag setObject:@"3" forKey:@"type"];
//                        [tag setObject:@"1" forKey:@"deleted"];
//                        [tag setObject:@"1" forKey:@"edited"];
//                        [globals.CURRENT_EVENT_THUMBNAILS setObject:tag forKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
//                        
//                        //Remove image
//                        NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[tag objectForKey:@"id"]];
//                        NSString *imagePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
//                        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
//                    }
//                    
//                }else{
//                    //current absolute time in seconds
//                    double currentSystemTime = CACurrentMediaTime();
//                    //now we send the deleted tag information throught the queue to the server
//                    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"1",@"delete",globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",[tag objectForKey:@"id"],@"id", nil];
//                    
//                    //Remove from global tag array
//                    [globals.CURRENT_EVENT_THUMBNAILS removeObjectForKey:[NSString stringWithFormat:@"%@",[tag objectForKey:@"id"]]];
//                    
//                    NSError *error;
//                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
//                    NSString *jsonString;
//                    if (! jsonData) {
//                        
//                    } else {
//                        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                    }
//                    
//                    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
//                    
//                    //callback method and parent view controller reference for the appqueue
//                    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(deleteThumbnailsCallback:)],self, nil];
//                    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
//                    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//                    [globals.APP_QUEUE enqueue:url dict:instObj];
//                }
//                
//            }
//            
//            
//            if (!globals.HAS_MIN ||(globals.HAS_MIN && !globals.eventExistsOnServer)){
//                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                                         (unsigned long)NULL), ^(void) {
//                    NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
//                    
//                    [globals.CURRENT_EVENT_THUMBNAILS writeToFile:filePath atomically:YES];
//                    
//                });
//            }
//            [self.tagsToDisplay removeAllObjects];
//            self.tagsToDisplay = [tempArr mutableCopy];
//            [self.collectionView reloadData];
//            globals.THUMBNAIL_COUNT_REF_ARRAY = self.tagsToDisplay;
//        }
//        else
//        {
//            //Canceled, do nothing
//        }
//        
//        [self editingClips: NO];
//    }
//    
    
}


-(void)deleteThumbnailsCallback:(id)newTagInfo
{
    //    //NSLog(@"gotback");
}

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    // apply custom attributes...
    [self.collectionView setNeedsDisplay]; // force drawRect:
}



#pragma mark - UICollectionViewDelegate
//TODO create gloabal dictionary of view controllers
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    //    NSDictionary *thumbDict = [[NSDictionary alloc]initWithDictionary:[self.tagsToDisplay objectAtIndex:[indexPath indexAtPosition:1]] copyItems:TRUE];
    
    thumbnailCell *selectedCell =(thumbnailCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    

    [sourceSelectPopover clear];
    
    if ([selectedCell.data objectForKey:@"url_2"]) { // if is new
        NSArray * listOfScource = [[selectedCell.data objectForKey:@"url_2"] allKeys];
        
        [sourceSelectPopover setListOfButtonNames:listOfScource];
        [sourceSelectPopover addOnCompletionBlock:^(NSString *pick) {
            NSLog(@"You Picked a feed: %@",pick);
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB object:nil userInfo:@{@"tabName":@"Live2Bench"}];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED object:nil userInfo:@{@"context":STRING_LIVE2BENCH_CONTEXT,
                                                                                                                  @"feed":pick,
                                                                                                                  @"time":[selectedCell.data objectForKey:@"starttime"],
                                                                                                                  @"duration":[selectedCell.data objectForKey:@"duration"],
                                                                                                                  @"state":[NSNumber numberWithInteger:PS_Play]}];
        }];
        
        [sourceSelectPopover presentPopoverFromRect:selectedCell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    } else {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB object:nil userInfo:@{@"tabName":@"Live2Bench"}];
    
    }

    [selectedCell setSelected:NO];
    
    
    
    
    
    
//
//    
//    return;
//    if(!isEditingClips)
//    {
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"StopUpdate" object:nil];
//
//        globals.DID_GO_TO_LIVE = FALSE;
//        //globals.IS_LOOP_MODE = TRUE;
//        
//        
//        //is there a way to work around this?
//        customTab=[[CustomTabBar alloc]init];
//        globals.CURRENT_APP_STATE = apstSkipTimer;
//        [customTab selectTab:2];
//        
//        int indexOfBtn = 0;
//        int i=0;
//        for (UIButton *custButton in globals.CUSTOM_TAB_ITEMS) {
//            if([custButton.titleLabel.text isEqualToString:@"Live2Bench"])
//            {
//                indexOfBtn = i;
//            }
//            i++;
//        }
//        
//        Live2BenchViewController *tempFirstCont= [self.tabBarController.viewControllers objectAtIndex:indexOfBtn];
//        
//        globals.CURRENT_PLAYBACK_TAG=[[NSDictionary alloc]initWithDictionary:thumbDict];
//        globals.IS_TAG_PLAYBACK=TRUE;
//        globals.START_TAG_PLAYBACK = TRUE;
//        [self.tabBarController setSelectedViewController:tempFirstCont];
//        if ([((NSNumber*)[thumbDict valueForKey:@"type"]) intValue] == 4){
//            //tele
//            [tempFirstCont.videoPlayer enterFullscreen];
//            globals.IS_PLAYBACK_TELE = YES;
//        }
//        
//        if (![globals.THUMBS_WERE_SELECTED_CLIPVIEW containsObject:[thumbDict objectForKey:@"id"]]) {
//            [globals.THUMBS_WERE_SELECTED_CLIPVIEW addObject:[thumbDict objectForKey:@"id"]];
//        }
//        globals.THUMB_WAS_SELECTED_CLIPVIEW = [thumbDict objectForKey:@"id"];
//    }else{
//        thumbnailCell *selectedCell =(thumbnailCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//        
//        if(!arrayToBeDeleted)
//        {
//            arrayToBeDeleted =[[NSMutableArray alloc] init];
//        }
//        
//        if(![arrayToBeDeleted containsObject:thumbDict])
//        {
//            [selectedCell.translucentEditingView setHidden:FALSE];
//            [selectedCell.checkmarkOverlay setHidden:FALSE];
//            [arrayToBeDeleted addObject:thumbDict];
//        }else{
//            [arrayToBeDeleted removeObject:thumbDict];
//            [selectedCell.translucentEditingView setHidden:TRUE];
//            [selectedCell.checkmarkOverlay setHidden:TRUE];
//        }
//        if(!isEditingClips)
//        {
//            if (![globals.THUMBS_WERE_SELECTED_CLIPVIEW containsObject:[thumbDict objectForKey:@"id"]]) {
//                [globals.THUMBS_WERE_SELECTED_CLIPVIEW addObject:[thumbDict objectForKey:@"id"]];
//                
//            }
//        }
//    }
//    
//    
    
}

//
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{

    [self collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath];
    
    //    NSDictionary *thumbDict = [[NSDictionary alloc]initWithDictionary:[self.tagsToDisplay objectAtIndex:[indexPath indexAtPosition:1]] copyItems:TRUE];
//    thumbnailCell *selectedCell =(thumbnailCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//    
//    if(!arrayToBeDeleted)
//    {
//        arrayToBeDeleted =[[NSMutableArray alloc] init];
//    }
//    
//    if(![arrayToBeDeleted containsObject:thumbDict])
//    {
//        [selectedCell.translucentEditingView setHidden:FALSE];
//        [selectedCell.checkmarkOverlay setHidden:FALSE];
//        [arrayToBeDeleted addObject:thumbDict];
//    }else{
//        [arrayToBeDeleted removeObject:thumbDict];
//        [selectedCell.translucentEditingView setHidden:TRUE];
//        [selectedCell.checkmarkOverlay setHidden:TRUE];
//    }
//  if(!isEditingClips)
//  {
//        [globals.THUMBS_WERE_SELECTED_CLIPVIEW removeObject:[thumbDict objectForKey:@"id"]];
//
//  }

}

- (NSDictionary*)thumbAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tagsToDisplay objectAtIndex:indexPath.row];
}



#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //set size of cell
    CGSize retval = CGSizeMake(200,192);
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    //set padding of the section (called once)
    return UIEdgeInsetsMake(20, 25, 53, 24);
}


-(BOOL)redownloadImageFromtheServer:(NSDictionary*)dict{
//    NSFileManager *fileManager= [NSFileManager defaultManager];
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
//        return FALSE;
//    }
    return false;// added for debugg
}

- (void)didReceiveMemoryWarning
{
//    dnm
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil){
        self.view = nil;
        [typesOfTags removeAllObjects];
    }
}

@end