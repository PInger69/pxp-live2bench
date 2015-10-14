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
#import "Tag.h"
#import "RatingOutput.h"

#import "AVAsset+Image.h"


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
    BreadCrumbsViewController       * breadCrumbVC;
    ListPopoverControllerWithImages * sourceSelectPopover;
    NSString                        * eventType;
    EncoderManager                  * _encoderManager;
    id                              clipViewTagObserver;
    //ImageAssetManager               * _imageAssetManager;
    Event                           * _currentEvent;
    id <EncoderProtocol>                _observedEncoder;
    UIButton                        *deSelectButton;
    
}

@synthesize collectionView=_collectionView;
@synthesize tagsToDisplay=_tagsToDisplay;


static const NSInteger kDeleteAlertTag = 423;
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
        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];
        
        
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clipViewTagReceived:) name:NOTIF_TAG_RECEIVED object:nil];
        //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clear) name:NOTIF_EVENT_CHANGE object:nil];
        
        
        //_imageAssetManager = appDel.imageAssetManager;
        self.setOfSelectedCells = [[NSMutableSet alloc] init];
        self.contextString = @"TAG";
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTag:) name:@"NOTIF_DELETE_TAG" object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTag:) name:@"NOTIF_DELETE_SYNCED_TAG" object:nil];
        
        /*[NSNotificationCenter defaultCenter] addObserverForName:NOTIF_TAGS_ARE_READY object:nil queue:nil usingBlock:^(NSNotification *note) {
            if (appDel.encoderManager.primaryEncoder == appDel.encoderManager.masterEncoder) {
                    self.tagsToDisplay  = [NSMutableArray arrayWithArray:[appDel.encoderManager.eventTags allValues]];
                    self.allTagsArray   = [NSMutableArray arrayWithArray:[appDel.encoderManager.eventTags allValues]];
                    [_collectionView reloadData];
            }
            if (!componentFilter.rawTagArray) {
                componentFilter.rawTagArray = self.tagsToDisplay;
            };
        }];*/
            
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveEventStopped:) name:NOTIF_LIVE_EVENT_STOPPED object:nil];
        
        self.allTagsArray   = [NSMutableArray array];
        self.tagsToDisplay  = [NSMutableArray array];
    }
    return self;
    
}

// encoderOberver
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
        [self clear];
    }

    if (_currentEvent.live && _appDel.encoderManager.liveEvent == nil) {
        _currentEvent = nil;
    }else{
        _currentEvent = [((id <EncoderProtocol>) note.object) event];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:_currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:_currentEvent];
    }
}

-(void)onTagChanged:(NSNotification *)note{

    self.allTagsArray = [NSMutableArray arrayWithArray:[_currentEvent.tags copy]];
//    self.tagsToDisplay =[ NSMutableArray arrayWithArray:[_currentEvent.tags copy]];

    
    [_pxpFilter filterTags:self.allTagsArray];
    [_tagsToDisplay removeAllObjects];
    [_tagsToDisplay addObjectsFromArray:self.pxpFilter.filteredTags];
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"displayTime" ascending:NO selector:@selector(compare:)];
    _tagsToDisplay = [NSMutableArray arrayWithArray:[_tagsToDisplay sortedArrayUsingDescriptors:@[sorter]]];

    [self.collectionView reloadData];

}


-(void)clear{
    [self.tagsToDisplay removeAllObjects];
    [self.allTagsArray removeAllObjects];
    [_collectionView reloadData];
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



- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
   
    _pxpFilter = [TabView sharedFilterTabBar].pxpFilter;
    _pxpFilter.delegate = self;
    [_pxpFilter removeAllPredicates];
    
    
    Profession * profession = [ProfessionMap data][SPORT_HOCKEY];// should be the events sport // 


    
    
    
    NSPredicate *allowThese = [NSCompoundPredicate orPredicateWithSubpredicates:@[
                                                                                   [NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeNormal]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeCloseDuration]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeCloseDurationOLD]
                                                                                   ,profession.filterPredicate
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeFootballDownTags]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeSoccerZoneStop]
                                                                                   ,[NSPredicate predicateWithFormat:@"type = %ld", (long)TagTypeTele ]
                                                                                   ]];
    
    [_pxpFilter addPredicates:@[allowThese]];
    
    [_collectionView reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sourceSelectPopover = [[ListPopoverControllerWithImages alloc]initWithMessage:@"Select Source:" buttonListNames:@[]];
    sourceSelectPopover.contentViewController.modalInPopover = NO; // this lets you tap out to dismiss
    downloadedTagIds = [[NSMutableArray alloc] init];
    [self setupView];
    
    
    //instantiate uicollection cell
    [self.collectionView registerClass:[thumbnailCell class] forCellWithReuseIdentifier:@"thumbnailCell"];
    //set the collectionview's properties
    [self.collectionView setAllowsSelection:TRUE];
    [self.collectionView setAllowsMultipleSelection:TRUE];
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
    
    self.deleteButton = [[UIButton alloc] init];
    self.deleteButton.backgroundColor = [UIColor redColor];
    [self.deleteButton addTarget:self action:@selector(deleteAllButtonTarget) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton setTitle: NSLocalizedString(@"Delete All", nil) forState: UIControlStateNormal];
    [self.deleteButton.titleLabel setTextColor:[UIColor whiteColor]];
    [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton setFrame:CGRectMake(self.collectionView.frame.origin.x , 768, self.collectionView.frame.size.width, 0)];
    
    [self.view addSubview: self.deleteButton];
    
    self.filterButton = [[UIButton alloc] initWithFrame:CGRectMake(950, 710, 74, 58)];
    [self.filterButton setTitle:NSLocalizedString(@"Filter", nil) forState:UIControlStateNormal];
    [self.filterButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [self.filterButton addTarget:self action:@selector(pressFilterButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.filterButton];
    
    deSelectButton = [[UIButton alloc]initWithFrame:CGRectMake(900, 65, 80, 30)];
    [deSelectButton setTitle:@"Deselect" forState:UIControlStateNormal];
    [deSelectButton setBackgroundColor:[UIColor grayColor]];
    deSelectButton.titleLabel.adjustsFontSizeToFitWidth = true;
    [deSelectButton addTarget:self action:@selector(deselectAllCell) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deSelectButton];
    

}

-(void)deleteAllButtonTarget{
    CustomAlertView *alert = [[CustomAlertView alloc] init];
    alert.type = AlertImportant;
    [alert setTitle:NSLocalizedString(@"myplayXplay",nil)];
    [alert setMessage:NSLocalizedString(@"Are you sure you want to delete all these clips?",nil)];
    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert showView];
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
            [self.collectionView reloadData];
        }
    }}];
    
    
    //pause the video palyer in live2bench view and my clip view
    for (thumbnailCell *cell in _collectionView.visibleCells) {
        [cell setDeletingMode: self.isEditing];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:self userInfo:@{@"context":STRING_LIVE2BENCH_CONTEXT}];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:self userInfo:@{@"context":@"ListView Tab"}];
}

-(void)receiveFilteredArrayFromFilter:(id)filter
{
    AbstractFilterViewController * checkFilter = (AbstractFilterViewController *)filter;
    NSMutableArray *filteredArray = (NSMutableArray *)[checkFilter processedList]; //checkFilter.displayArray;
    self.tagsToDisplay = [filteredArray mutableCopy];
    [self.collectionView reloadData];
    [breadCrumbVC inputList: [checkFilter.tabManager invokedComponentNames]];
}



-(void):(BOOL)isEditing
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
    [alert setTitle:NSLocalizedString(@"myplayXplay",nil)];
    [alert setMessage:NSLocalizedString(@"Are you sure you want to delete these tags?",nil)];
    [alert setDelegate:self];
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert showView];
    
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
    [super viewDidDisappear:animated];
    
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
    cell.ratingscale.rating = tagSelect.rating;
    cell.checkmarkOverlay.hidden = YES;
    [cell.thumbDeleteButton addTarget:self action:@selector(cellDeleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    NSString *url = [[tagSelect.thumbnails allValues]firstObject];
    
    cell.imageView.image = [UIImage imageNamed:@"live.png"];
    if ([ImageAssetManager getInstance].arrayOfClipImages[url]){
        cell.imageView.image = [ImageAssetManager getInstance].arrayOfClipImages[url];
    } else {
        [[ImageAssetManager getInstance]thumbnailsLoadedToView:cell.imageView imageURL:url];
    }

    
    
//    UIImage *thumb = [tagSelect thumbnailForSource:nil];
//    
//    if (thumb) {
//        cell.imageView.image = thumb;
//    } else {
//        NSString *src = tagSelect.thumbnails.allKeys.firstObject;
//        
//        // get the key of the source with the telestration
//        if (tagSelect.telestration) {
//            for (NSString* k in tagSelect.thumbnails.keyEnumerator) {
//                if ([tagSelect.telestration.sourceName isEqualToString:k]) {
//                    src = k;
//                    break;
//                }
//            }
//        }
//        
//        PxpTelestration *tele = tagSelect.thumbnails.count <= 1 || [tagSelect.telestration.sourceName isEqualToString:src] ? tagSelect.telestration : nil;
//        [[ImageAssetManager getInstance] imageForURL: tagSelect.thumbnails[src] atImageView: cell.imageView withTelestration:tele];
//    }
    
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
    [alert setTitle:NSLocalizedString(@"myplayXplay",nil)];
    [alert setMessage:NSLocalizedString(@"Are you sure you want to delete this tag?",nil)];
    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
    [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
    [alert showView];
    
}

- (void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
     if ([alertView.message isEqualToString:@"Are you sure you want to delete all these clips?"] && buttonIndex == 0) {
        NSMutableArray *indexPathsArray = [[NSMutableArray alloc]init];
        NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
        BOOL needCanNotDeleteTagAlertView = false;
         
        for (NSIndexPath *cellIndexPath in [self.setOfSelectedCells copy]) {
            Tag *tag = self.tagsToDisplay[cellIndexPath.row];
            if ([tag.deviceID isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]]) {
                [arrayOfTagsToRemove addObject:tag];
                [indexPathsArray addObject:cellIndexPath];
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
            }else{
                needCanNotDeleteTagAlertView = true;
            }
        }
         
         for (Tag *tag in arrayOfTagsToRemove) {
             [self.tagsToDisplay removeObject:tag];
             [self.allTagsArray removeObject: tag];
         }
         [self.collectionView deleteItemsAtIndexPaths: indexPathsArray];
         [self.setOfSelectedCells removeAllObjects];
         
        if (needCanNotDeleteTagAlertView) {
             CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"Can't Delete Tag" message:@"All of your tags are deleted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert showView];
         }
         [self deselectAllCell];


    }else if([alertView.message isEqualToString:@"Are you sure you want to delete this tag?"] && buttonIndex == 0){

        Tag *tag = [self.tagsToDisplay objectAtIndex:self.editingIndexPath.row];
        if ([tag.user isEqualToString:[UserCenter getInstance].userHID]) {
//        if ([tag.deviceID isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]]) {
            [self.tagsToDisplay removeObject:tag];
            if (self.editingIndexPath) {
                [self.collectionView deleteItemsAtIndexPaths:@[self.editingIndexPath]];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
            [self removeIndexPathFromDeletion];
        }else{
            CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"Can't Delete Tag" message:@"You can't delete someone else's tag" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert showView];
        }
        [self deselectAllCell];

        
    }
    
    [alertView viewFinished];
    [CustomAlertView removeAlert:alertView];
    
    [self checkDeleteAllButton];

   }

-(void)removeIndexPathFromDeletion{
    NSMutableSet *newIndexPathSet = [[NSMutableSet alloc]init];
    if (self.editingIndexPath) {
        [self.setOfSelectedCells removeObject:self.editingIndexPath];
    }

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
    
    if (selectedCell.data.event.feeds.count >=2) { // if is new
        NSArray * listOfScource = [[selectedCell.data.event.feeds allKeys]sortedArrayUsingSelector:@selector(compare:)];
        
        [sourceSelectPopover setListOfButtonNames:listOfScource];
        
        //This is where the Thumbnail images are added to the popover
        NSDictionary *tagThumbnails = selectedCell.data.thumbnails ;
        
        int i = 0;
        for (NSString *src in listOfScource){
            //NSString *url = urls[[NSString stringWithFormat: @"s_0%i" , i +1 ]];
            
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, POP_WIDTH - 10, BUTTON_HEIGHT - 10)];
            
            PxpTelestration *tele = listOfScource.count <= 1 || [selectedCell.data.telestration.sourceName isEqualToString:src] ? selectedCell.data.telestration : nil;
            
            [[ImageAssetManager getInstance] imageForURL: tagThumbnails[src] atImageView:imageView withTelestration:tele];
            
            [(UIButton *)sourceSelectPopover.arrayOfButtons[i] addSubview:imageView];
            ++i;
        }
        
        
        //if ( [tagSelect count] >1 ){
            [sourceSelectPopover addOnCompletionBlock:^(NSString *pick) {
                
                // Get the feed
                NSDictionary *feeds = selectedCell.data.event.feeds;
                Feed *feed = feeds[pick] ? feeds[pick] : feeds.allValues.firstObject;
                

                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB object:nil userInfo:@{@"tabName":@"Live2Bench"}];
                
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                userInfo[@"context"] = STRING_LIVE2BENCH_CONTEXT;
                userInfo[@"feed"] = feed;
                userInfo[@"time"] = [NSString stringWithFormat:@"%f", selectedCell.data.startTime ];
                userInfo[@"duration"] = [NSString stringWithFormat:@"%d", selectedCell.data.duration ];
                userInfo[@"state"] = [NSNumber numberWithInteger:RJLPS_Play];
                
                if (selectedCell.data) {
                    userInfo[@"tag"] = selectedCell.data;
                }
                
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED object:nil userInfo:userInfo];
            }];
        
            [sourceSelectPopover presentPopoverFromRect: CGRectMake(selectedCell.frame.size.width /2, 0, 0, 50) inView:selectedCell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
            
        
        
    } else {
        
        Feed *feed = [[selectedCell.data.event.feeds allValues] firstObject];
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SELECT_TAB
                                                           object:nil userInfo:@{@"tabName":@"Live2Bench"}];
        
        //NSString * key =        listOfScource[0];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"context"] = STRING_LIVE2BENCH_CONTEXT;
        userInfo[@"feed"] = feed;
        userInfo[@"time"] = [NSString stringWithFormat:@"%f", selectedCell.data.startTime ];
        userInfo[@"duration"] = [NSString stringWithFormat:@"%d", selectedCell.data.duration ];
        userInfo[@"state"] = [NSNumber numberWithInteger:RJLPS_Play];
        
        if (selectedCell.data) {
            userInfo[@"tag"] = selectedCell.data;
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED object:nil userInfo:userInfo];
    }
    
    [selectedCell setSelected:NO];
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath];
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //set padding of the section (called once)
    return UIEdgeInsetsMake(20, 25, 53, 24);
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil){
        self.view = nil;
    }
    [[ImageAssetManager getInstance].arrayOfClipImages removeAllObjects];
}

- (void)liveEventStopped:(NSNotification *)note {
    //if (_currentEvent.live) {
         //_currentEvent = nil;
        [self clear];
    //}
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

-(void)deselectAllCell{
    for (thumbnailCell *cell in self.collectionView.visibleCells) {
        [cell setDeletingMode: NO];
    }
    self.isEditing = NO;
    [self.setOfSelectedCells removeAllObjects];
    [self checkDeleteAllButton];
}

#pragma mark - Filtering Methods

- (void)pressFilterButton
{
    

    TabView *popupTabBar = [TabView sharedFilterTabBar];
    
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
    
    
    [_pxpFilter filterTags:self.allTagsArray];
    
    if (!popupTabBar.pxpFilter)          popupTabBar.pxpFilter = _pxpFilter;
}


// Pxp
-(void)onFilterComplete:(PxpFilter*)filter
{
    [_tagsToDisplay removeAllObjects];
    [_tagsToDisplay addObjectsFromArray:filter.filteredTags];
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"displayTime" ascending:NO selector:@selector(compare:)];
    _tagsToDisplay = [NSMutableArray arrayWithArray:[_tagsToDisplay sortedArrayUsingDescriptors:@[sorter]]];
    [_collectionView reloadData];
}

-(void)onFilterChange:(PxpFilter *)filter
{
    [_pxpFilter filterTags:self.allTagsArray];
    [_tagsToDisplay removeAllObjects];
    [_tagsToDisplay addObjectsFromArray:filter.filteredTags];
    
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"displayTime" ascending:NO selector:@selector(compare:)];
    _tagsToDisplay = [NSMutableArray arrayWithArray:[_tagsToDisplay sortedArrayUsingDescriptors:@[sorter]]];
    [_collectionView reloadData];
}

@end