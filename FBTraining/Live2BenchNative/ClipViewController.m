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
#import "ListPopoverControllerWithImages.h"
#import "EncoderManager.h"
#import "ImageAssetManager.h"
#import "TestFilterViewController.h"
#import "Tag.h"


#define CELLS_ON_SCREEN         12
#define TOTAL_WIDTH             1024
#define TOTAL_HEIGHT            600

#define BUTTON_HEIGHT           125
#define POP_WIDTH               200

@interface ClipViewController ()

@property (strong, nonatomic) NSMutableSet *setOfSelectedCells;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (assign, nonatomic) BOOL isEditing;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *filterButton;
@property (strong, nonatomic) UIButton *dismissFilterButton;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) NSMutableArray *allTagsArray;
@property (strong, nonatomic) NSString *contextString;

@end

@implementation ClipViewController
{
    TestFilterViewController    * componentFilter;
    BreadCrumbsViewController       * breadCrumbVC;
    ListPopoverControllerWithImages * sourceSelectPopover;
    NSString                        * eventType;
    EncoderManager                  * _encoderManager;
    id                              clipViewTagObserver;
    ImageAssetManager               * _imageAssetManager;
    
}

//@synthesize thumbnails=_thumbnails;
@synthesize collectionView=_collectionView;
@synthesize typesOfTags;
@synthesize tagsToDisplay=_tagsToDisplay;
@synthesize thumbRatingArray;
@synthesize thumbnailsLoaded;

static const NSInteger kDeleteAlertTag = 423;
static void * masterEncoderContext = &masterEncoderContext;
static void * encoderTagContext = &encoderTagContext;

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
        
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clipViewTagReceived:) name:NOTIF_TAG_RECEIVED object:nil];
        [_encoderManager addObserver:self forKeyPath:@"hasLive" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:&masterEncoderContext];
        [_encoderManager addObserver:self forKeyPath:@"currentEventTags" options:NSKeyValueObservingOptionNew context: &encoderTagContext];
        _imageAssetManager = appDel.imageAssetManager;
        
        //_tagsToDisplay = [[NSMutableArray alloc] init];
        self.setOfSelectedCells = [[NSMutableSet alloc] init];
        self.contextString = @"TAG";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTag:) name:@"NOTIF_DELETE_TAG" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTag:) name:@"NOTIF_DELETE_SYNCED_TAG" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_TAGS_ARE_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
            self.tagsToDisplay = [NSMutableArray arrayWithArray:[appDel.encoderManager.eventTags allValues]];
            self.allTagsArray = [NSMutableArray arrayWithArray:[appDel.encoderManager.eventTags allValues]];
            [_collectionView reloadData];
            if (!componentFilter.rawTagArray) {
                componentFilter.rawTagArray = self.tagsToDisplay;
            }
        }];
        
    }
    return self;
    
}

-(void) deleteTag: (NSNotification *)note{
    [self.allTagsArray removeObject: note.object];
    [self.tagsToDisplay removeObject: note.object];
    componentFilter.rawTagArray = self.allTagsArray;
    //[componentFilter refresh];
    [_collectionView reloadData];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //    if (context == &masterEncoderContext) {
    //        if ([change objectForKey:@"new"]){
    //
    //            BOOL n = [[change objectForKey:@"new"]boolValue];
    //            BOOL o = [[change objectForKey:@"old"]boolValue];
    //
    //            if (!n && n != o){
    //                _tagsToDisplay = [[NSMutableArray alloc]init];
    //                [_collectionView reloadData];
    //            }
    //        }
    //    }else if (context == &encoderTagContext){
    //        self.allTagsArray = [change[@"new"] mutableCopy];
    //    }
    
}



-(void)clipViewTagReceived:(NSNotification*)note
{
    if (note.object && self.allTagsArray) {
        
        [self.allTagsArray insertObject:note.object atIndex:0];
        [self.tagsToDisplay insertObject:note.object atIndex:0];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
    }
}

-(Float64) highestTimeInTags: (NSArray *) arrayOfTags{
    Float64 highestTime = 0;
    for (Tag *tag in arrayOfTags) {
        if (tag.time > highestTime) {
            highestTime = tag.time;
        }
    }
    return highestTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    sourceSelectPopover = [[ListPopoverControllerWithImages alloc]initWithMessage:@"Select Source:" buttonListNames:@[]];
    sourceSelectPopover.contentViewController.modalInPopover = NO; // this lets you tap out to dismiss
    typesOfTags = [[NSMutableArray alloc]init];
    downloadedTagIds = [[NSMutableArray alloc] init];
    [self setupView];
    
    
    //instantiate uicollection cell
    [self.collectionView registerClass:[thumbnailCell class] forCellWithReuseIdentifier:@"thumbnailCell"];
    //set the collectionview's properties
    [self.collectionView setAllowsSelection:TRUE];
    [self.collectionView setAllowsMultipleSelection:TRUE];
    typesOfTags = [[NSMutableArray alloc]init];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self.collectionView selector:@selector(reloadData) name:@"NewClip" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewTags:) name:@"updateClipView" object:nil];
    breadCrumbVC = [[BreadCrumbsViewController alloc]initWithPoint:CGPointMake(25, 64)];
    [self.view addSubview:breadCrumbVC.view];
    
    
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDetected:)];
    self.longPressRecognizer.minimumPressDuration = 0.7;
    [self.view addGestureRecognizer: self.longPressRecognizer];
    self.isEditing = NO;
}

-(void) longPressDetected: (UILongPressGestureRecognizer *) longPress{
    
    if(longPress.state == UIGestureRecognizerStateBegan){
        self.isEditing = !self.isEditing;
        
        for (thumbnailCell *cell in _collectionView.visibleCells) {
            [cell setDeletingMode: self.isEditing];
        }
        
        if( !self.isEditing ){
            [self.setOfSelectedCells removeAllObjects];
            [self checkDeleteAllButton];
        }
    }
    
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
    
    
    self.deleteButton = [[UIButton alloc] init];
    self.deleteButton.backgroundColor = [UIColor redColor];
    [self.deleteButton addTarget:self action:@selector(deleteAllButtonTarget) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton setTitle: @"Delete All" forState: UIControlStateNormal];
    [self.deleteButton.titleLabel setTextColor:[UIColor whiteColor]];
    [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton setFrame:CGRectMake(self.collectionView.frame.origin.x , 768, self.collectionView.frame.size.width, 0)];
    
    [self.view addSubview: self.deleteButton];
    
    self.filterButton = [[UIButton alloc] initWithFrame:CGRectMake(950, 710, 74, 58)];
    [self.filterButton setTitle:@"Filter" forState:UIControlStateNormal];
    [self.filterButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(slideFilterBox) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.filterButton];
    
    componentFilter = [TestFilterViewController commonFilter];
    //componentFilter = [[TestFilterViewController alloc]initWithTagArray: self.tagsToDisplay];
    [componentFilter onSelectPerformSelector:@selector(receiveFilteredArrayFromFilter:) addTarget:self];
    [self.view addSubview:componentFilter.view];
    [componentFilter setOrigin:CGPointMake(60, 190)];
    [componentFilter close:NO];

}

-(void)deleteAllButtonTarget{
    CustomAlertView *alert = [[CustomAlertView alloc] init];
    [alert setTitle:@"myplayXplay"];
    [alert setMessage:@"Are you sure you want to delete all these clips?"];
    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert show];
}


-(void)checkDeleteAllButton{
    if (self.setOfSelectedCells.count >= 2) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.deleteButton.frame = CGRectMake(self.collectionView.frame.origin.x, 700, self.collectionView.frame.size.width, 68);
        [UIView commitAnimations];
        
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.deleteButton.frame = CGRectMake(self.collectionView.frame.origin.x, 768, self.collectionView.frame.size.width, 0);
        [UIView commitAnimations];
    }
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LIST_VIEW_CONTROLLER_FEED object:nil userInfo:@{@"block" : ^(NSDictionary *feeds, NSArray *eventTags){
        
        if(eventTags.count > 0 && !self.tagsToDisplay){
            self.allTagsArray = [NSMutableArray arrayWithArray:[eventTags copy]];
            self.tagsToDisplay =[ NSMutableArray arrayWithArray:[eventTags copy]];
            if (!componentFilter.rawTagArray) {
                componentFilter.rawTagArray = self.tagsToDisplay;
            }
            [self.collectionView reloadData];
        }
    }}];
    
    
    //pause the video palyer in live2bench view and my clip view
    for (thumbnailCell *cell in _collectionView.visibleCells) {
        [cell setDeletingMode: self.isEditing];
    }
    
    
    //=======
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:self userInfo:@{@"context":@"Live2Bench Tab"}];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:self userInfo:@{@"context":@"ListView Tab"}];
    
    return;
    
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
    self.dismissFilterButton = [[UIButton alloc] initWithFrame: self.view.bounds];
    [self.dismissFilterButton addTarget:self action:@selector(dismissFilter:) forControlEvents:UIControlEventTouchUpInside];
    self.dismissFilterButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [self.view addSubview: self.dismissFilterButton];
    
    componentFilter.rawTagArray = self.allTagsArray;
    componentFilter.rangeSlider.highestValue = [self highestTimeInTags:self.allTagsArray];
    //componentFilter = [[TestFilterViewController alloc]initWithTagArray: self.tagsToDisplay];
    //componentFilter.rangeSlider.highestValue = [(VideoPlayer *)self.videoPlayer durationInSeconds];
    
    //[componentFilter onSelectPerformSelector:@selector(receiveFilteredArrayFromFilter:) addTarget:self];
    //[componentFilter onSwipePerformSelector:@selector(slideFilterBox) addTarget:self];
    componentFilter.finishedSwipe = TRUE;
    
    [self.view addSubview:componentFilter.view];
    //componentFilter.rangeSlider.highestValue = [(VideoPlayer *)self.videoPlayer durationInSeconds];
    [componentFilter setOrigin:CGPointMake(60, 190)];
    [componentFilter close:NO];
    [componentFilter viewDidAppear:TRUE];
    [componentFilter open:YES];
    
    if (self.isEditing) {
        self.isEditing = !self.isEditing;
        
        for (thumbnailCell *cell in _collectionView.visibleCells) {
            [cell setDeletingMode: self.isEditing];
        }
        
        if( !self.isEditing ){
            [self.setOfSelectedCells removeAllObjects];
            [self checkDeleteAllButton];
        }
        
    }
    
    //    float boxXValue = _filterToolBoxView.view.frame.origin.x>=self.view.frame.size.width? 60 : self.view.frame.size.width;
    //
    //    if(boxXValue == 60)
    //    {
    //        if(!self.blurView)
    //        {
    //            self.blurView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, 1024, 768-55)];
    //            self.blurView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    //            UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFilterToolbox)];
    //            [self.blurView addGestureRecognizer:tapRec];
    //            [self.view insertSubview:self.blurView belowSubview:_filterToolBoxView.view];
    //        }
    //        self.blurView.hidden = NO;
    //
    //        //        [_filterToolBoxView updateDisplayedTagsCount];
    //
    //        //clear the previous filter set
    //        [breadCrumbsView removeFromSuperview];
    //        breadCrumbsView  = nil;
    //
    //    }
    //    else{
    //        self.blurView.hidden = YES;
    //
    //    }
    //
    //    [componentFilter open:YES]; //Richard
}

-(void)dismissFilter: (UIButton *)dismissButton{
    [componentFilter close:YES];
    [dismissButton removeFromSuperview];
    //[self performSelector:@selector(componentNil) withObject:self afterDelay:0.3f];
    //[self.edgeSwipeButtons deselectAllButtons];
}

//- (void)dismissFilterToolbox
//{
//    self.blurView.hidden = YES;
//    [self.edgeSwipeButtons deselectButtonAtIndex:1];
//    [componentFilter close:YES]; //Richard
//}


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
    //    for (thumbnailCell *cell in _collectionView.visibleCells) {
    //        [cell setDeletingMode: NO];
    //    }
    [componentFilter close:YES];
    [self.dismissFilterButton removeFromSuperview];
    
    if (self.isEditing) {
        self.isEditing = !self.isEditing;
        
        for (thumbnailCell *cell in _collectionView.visibleCells) {
            [cell setDeletingMode: self.isEditing];
        }
        
        if( !self.isEditing ){
            [self.setOfSelectedCells removeAllObjects];
            [self checkDeleteAllButton];
        }
        
    }
    
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
    Tag *tagSelect = [self.tagsToDisplay objectAtIndex:[indexPath indexAtPosition:1]];
    
    
    thumbnailCell *cell = (thumbnailCell*)[cv dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
    cell.backgroundView = nil;
    cell.data           = tagSelect;
    //    cell.thumbColour.backgroundColor = [Utility colorWithHexString:[tagSelect objectForKey:@"colour"]];
    [cell.thumbColour changeColor:[Utility colorWithHexString: tagSelect.colour] withRect:cell.thumbColour.frame];
    
    NSString *thumbNameStr = tagSelect.name;
    
    [cell.thumbName setText:[[thumbNameStr stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"%" withString:@""]];
    [cell.thumbName setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [cell.thumbTime setText: tagSelect.displayTime];
    [cell.thumbDur setText:[NSString stringWithFormat:@"%.2ds",tagSelect.duration]];
    
    cell.checkmarkOverlay.hidden = YES;
    [cell.thumbDeleteButton addTarget:self action:@selector(cellDeleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_imageAssetManager imageForURL: [[tagSelect.thumbnails allValues] firstObject] atImageView: cell.imageView ];
    
    [cell setDeletingMode: self.isEditing];
    
    if ([self.setOfSelectedCells containsObject: indexPath]) {
        cell.checkmarkOverlay.hidden = NO;
        cell.translucentEditingView.hidden = NO;
    }
    
    return cell;
}


-(void)cellDeleteButtonPressed: (UIButton *)sender{
    thumbnailCell *cell = (thumbnailCell *)sender.superview;
    NSIndexPath *pathToDelete = [_collectionView indexPathForCell: cell];
    self.editingIndexPath = pathToDelete;
    CustomAlertView *alert = [[CustomAlertView alloc] init];
    [alert setTitle:@"myplayXplay"];
    [alert setMessage:@"Are you sure you want to delete this tag?"];
    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert show];
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ([alertView.message isEqualToString:@"Are you sure you want to delete all these clips?"] && buttonIndex == 0) {
        NSMutableArray *indexPathsArray = [[NSMutableArray alloc]init];
        NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
        
        for (NSIndexPath *cellIndexPath in self.setOfSelectedCells) {
            [arrayOfTagsToRemove addObject:self.tagsToDisplay[cellIndexPath.row]];
            [indexPathsArray addObject: cellIndexPath];
        }
        
        for (NSDictionary *tag in arrayOfTagsToRemove) {
            [self.tagsToDisplay removeObject:tag];
            [self.allTagsArray removeObject: tag];
            
            //            NSString *notificationName = [NSString stringWithFormat:@"NOTIF_DELETE_%@", self.contextString];
            //            NSNotification *deleteNotification =[NSNotification notificationWithName: notificationName object:nil userInfo:tag];
            //            [[NSNotificationCenter defaultCenter] postNotification: deleteNotification];
        }
        
        
        [self.setOfSelectedCells removeAllObjects];
        [self.collectionView deleteItemsAtIndexPaths: indexPathsArray];
        
        for (NSDictionary *tag in arrayOfTagsToRemove) {
            //            [self.tagsToDisplay removeObject:tag];
            //            [self.allTagsArray removeObject: tag];
            
            NSString *notificationName = [NSString stringWithFormat:@"NOTIF_DELETE_%@", self.contextString];
            NSNotification *deleteNotification =[NSNotification notificationWithName: notificationName object:nil userInfo:tag];
            [[NSNotificationCenter defaultCenter] postNotification: deleteNotification];
        }
        
        for (thumbnailCell *cell in self.collectionView.visibleCells) {
            [cell setDeletingMode: NO];
        }
        self.isEditing = NO;
        
        
        
        //[self.collectionView reloadData];
        
        
    }else{
        if (buttonIndex == 0)
        {
            NSDictionary *tag = [self.tagsToDisplay objectAtIndex: self.editingIndexPath.row];
            [self.tagsToDisplay removeObject:tag];
            
            [self.collectionView deleteItemsAtIndexPaths:@[self.editingIndexPath]];
            
            NSString *notificationName = [NSString stringWithFormat:@"NOTIF_DELETE_%@", self.contextString];
            NSNotification *deleteNotification =[NSNotification notificationWithName: notificationName object:tag userInfo:tag];
            [[NSNotificationCenter defaultCenter] postNotification: deleteNotification];
            
            [self removeIndexPathFromDeletion];
            
        }
        else if (buttonIndex == 1)
        {
            // No, cancel the action to delete tags
        }
        
    }
    [CustomAlertView removeAlert:alertView];
    
    [self checkDeleteAllButton];
    //[self.tableView reloadData];
}

-(void)removeIndexPathFromDeletion{
    NSMutableSet *newIndexPathSet = [[NSMutableSet alloc]init];
    [self.setOfSelectedCells removeObject:self.editingIndexPath];
    
    //    if ([self.selectedPath isEqual:self.editingIndexPath]) {
    //        self.selectedPath = nil;x
    //    }
    //    if (self.selectedPath && self.selectedPath.row > self.editingIndexPath.row) {
    //        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.selectedPath.row - 1 inSection: self.selectedPath.section];
    //        self.selectedPath = newIndexPath;
    //    }
    
    for (NSIndexPath *indexPath in self.setOfSelectedCells) {
        if (indexPath.row > self.editingIndexPath.row) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection: indexPath.section];
            [newIndexPathSet addObject: newIndexPath];
        }else{
            [newIndexPathSet addObject: indexPath];
        }
    }
    
    self.setOfSelectedCells = newIndexPathSet;
    [self checkDeleteAllButton];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEditing) {
        thumbnailCell *cell = (thumbnailCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
        cell.checkmarkOverlay.hidden = !cell.checkmarkOverlay.hidden;
        cell.translucentEditingView.hidden = !cell.translucentEditingView.hidden;
        if (!cell.checkmarkOverlay.hidden) {
            [self.setOfSelectedCells addObject: [self.collectionView indexPathForCell: cell]];
        }else{
            [self.setOfSelectedCells removeObject: [self.collectionView indexPathForCell: cell]];
        }
        [self checkDeleteAllButton];
        return;
    }
    
    thumbnailCell *selectedCell =(thumbnailCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [sourceSelectPopover clear];
    
    if (selectedCell.data.thumbnails.count >=2) { // if is new
        NSArray * listOfScource = [[selectedCell.data.thumbnails allKeys]sortedArrayUsingSelector:@selector(compare:)];
        
        
        
        
        [sourceSelectPopover setListOfButtonNames:listOfScource];
        
        //This is where the Thumbnail images are added to the popover
        NSDictionary *tagSelect = selectedCell.data.thumbnails ;
        
        int i = 0;
        for (NSString *url in listOfScource){
            //NSString *url = urls[[NSString stringWithFormat: @"s_0%i" , i +1 ]];
            
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, POP_WIDTH - 10, BUTTON_HEIGHT - 10)];
            
            
            [_imageAssetManager imageForURL: tagSelect[url] atImageView:imageView ];
            
            [(UIButton *)sourceSelectPopover.arrayOfButtons[i] addSubview:imageView];
            ++i;
        }
        
        
        if ( [tagSelect count] >1 ){
            [sourceSelectPopover addOnCompletionBlock:^(NSString *pick) {
                
                PXPLog(@"You Picked a feed: %@",pick);
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB object:nil userInfo:@{@"tabName":@"Live2Bench"}];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED object:nil userInfo:@{@"context":STRING_LIVE2BENCH_CONTEXT,
                                                                                                                      @"feed":pick,
                                                                                                                      @"time": [NSString stringWithFormat:@"%f", selectedCell.data.startTime ],
                                                                                                                      @"duration": [NSString stringWithFormat:@"%d", selectedCell.data.duration ],
                                                                                                                      @"state":[NSNumber numberWithInteger:RJLPS_Play]}];
            }];
            
            [sourceSelectPopover presentPopoverFromRect: CGRectMake(selectedCell.frame.size.width /2, 0, 0, 50) inView:selectedCell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
            
            
        } else {
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB object:nil userInfo:@{@"tabName":@"Live2Bench"}];
            
            NSString * key =        listOfScource[0];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED object:nil userInfo:@{@"context":STRING_LIVE2BENCH_CONTEXT,
                                                                                                                  @"feed":key,
                                                                                                                  @"time":[NSString stringWithFormat:@"%f", selectedCell.data.startTime ],
                                                                                                                  @"duration":[NSString stringWithFormat:@"%d", selectedCell.data.duration],
                                                                                                                  @"state":[NSNumber numberWithInteger:RJLPS_Play]}];
        }
        
        
    } else {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB
                                                           object:nil userInfo:@{@"tabName":@"Live2Bench"}];
        
        //NSString * key =        listOfScource[0];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED object:nil userInfo:@{@"context":STRING_LIVE2BENCH_CONTEXT,
                                                                                                              //@"feed":key,
                                                                                                              @"time":[NSString stringWithFormat:@"%f", selectedCell.data.startTime ],
                                                                                                              @"duration":[NSString stringWithFormat:@"%d", selectedCell.data.duration ],
                                                                                                              @"state":[NSNumber numberWithInteger:RJLPS_Play]}];
        
    }
    
    [selectedCell setSelected:NO];
    
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