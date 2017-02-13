//
//  ClipViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-29.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "ClipViewController.h"

#import <TSMessages/TSMessage.h>

#import "AbstractFilterViewController.h"
#import "FBTFilterViewController.h"
#import "BreadCrumbsViewController.h"
#import "ListPopoverControllerWithImages.h"
#import "EncoderManager.h"
#import "ImageAssetManager.h"
#import "Tag.h"
#import "RatingOutput.h"
#import "UIImageView+TagThumbnail.h"

#import "AVAsset+Image.h"
#import "CustomAlertControllerQueue.h"

#import "ListViewCell.h"
#import "thumbnailCell.h"

#define CELLS_ON_SCREEN         12
#define TOTAL_WIDTH             1024
#define TOTAL_HEIGHT            600

#define BUTTON_HEIGHT           200
#define POP_WIDTH               300

@interface ClipViewController ()

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (assign, nonatomic) BOOL isEditing;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *filterButton;
@property (strong, nonatomic) UIButton *dismissFilterButton;
@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) NSString *contextString;
@property (strong, nonatomic) UIButton *deSelectButton;

@property (nonatomic, strong) BreadCrumbsViewController* breadCrumbVC;

@property (nonatomic, strong) NSTimer* refreshTimer;
@property (nonatomic, strong, nullable) ListPopoverControllerWithImages* sourceSelectPopover;


@end

@implementation ClipViewController

- (id)init
{
    self = [super init];
    
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Clip View", nil) imageName:@"clipTab"];
    }
    return self;
}


-(id)initWithAppDelegate:(AppDelegate *)appDel
{
    self = [super initWithAppDelegate:appDel];
    if (self) {
        [self setMainSectionTab:NSLocalizedString(@"Clip View", nil) imageName:@"tabClipView"];

        self.contextString = @"TAG";
        
    }
    return self;
    
}

-(void) assignCurrentEvent:(Event*) event {
    if ([event.name isEqualToString:self.currentEvent.name]) {
        NSLog(@"ClipViewController.eventChanged called by no actual change");
        return;
    }
    NSLog(@"ClipViewController.eventChanged...");
    
    if (self.currentEvent != nil) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_RECEIVED object:self.currentEvent];
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_TAG_MODIFIED object:self.currentEvent];
        [self clear];
    }
    
    if (self.currentEvent.live && _appDel.encoderManager.liveEvent == nil) {
        self.currentEvent = nil;
    }else{
        self.currentEvent = event;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_RECEIVED object:self.currentEvent];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagChanged:) name:NOTIF_TAG_MODIFIED object:self.currentEvent];
    }
    
}

-(void)eventChanged:(NSNotification *)note
{
    [self assignCurrentEvent:[note.object event]];
}

-(void)onTagChanged:(NSNotification *)note{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadAndDisplayTags];
    });
}


-(void)clear{
    self.tagsToDisplay = [NSMutableArray new];
    [self.allTagsArray removeAllObjects];
    [self.collectionView reloadData];
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



-(void) longPressDetected: (UILongPressGestureRecognizer *) longPress{
    
    if(longPress.state == UIGestureRecognizerStateBegan){
        self.isEditing = !self.isEditing;
        
        for (thumbnailCell *cell in self.collectionView.visibleCells) {
            [cell setDeletingMode: self.isEditing];
        }
        
        if( !self.isEditing ){
            [self.deleteTagIds removeAllObjects];
            [self showOrHideDeleteAllButton];
        }
    }
    
}



-(void)setupView
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
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
    [self.deleteButton addTarget:self action:@selector(deleteAllSelectedTags) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.deSelectButton = [[UIButton alloc]initWithFrame:CGRectMake(900, 65, 80, 30)];
    [self.deSelectButton setTitle:@"Deselect" forState:UIControlStateNormal];
    [self.deSelectButton setBackgroundColor:[UIColor grayColor]];
    self.deSelectButton.titleLabel.adjustsFontSizeToFitWidth = true;
    [self.deSelectButton addTarget:self action:@selector(deselectAllCell) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deSelectButton];
    

}

/*
-(void)deleteAllButtonTarget{
    
    // Build Alert
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                    message:@"Are you sure you want to delete all these tags?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction * deleteButtons = [UIAlertAction actionWithTitle:@"Yes"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
                                         ////
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
                                         [self.deleteTagIds removeAllObjects];
                                  
                                         [self deselectAllCell];

                                         ////
                                         [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                     }];
    
    
    
    UIAlertAction * cancelButtons = [UIAlertAction actionWithTitle:@"No"
                                                             style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction * action)
                                     {
                                         [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                     }];
    
    [alert addAction:deleteButtons];
    [alert addAction:cancelButtons];
    
    BOOL isIndecisive = [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];
    
    if (!isIndecisive) {
        
        
        
        [self showOrHideDeleteAllButton];
    }

    
    
}
*/

-(void) showDeleteAllButton {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.deleteButton.frame = CGRectMake(self.collectionView.frame.origin.x, 700, self.collectionView.frame.size.width, 68);
    [UIView commitAnimations];
    
}

-(void) hideDeleteAllButton {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.deleteButton.frame = CGRectMake(self.collectionView.frame.origin.x, 768, self.collectionView.frame.size.width, 0);
    [UIView commitAnimations];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sourceSelectPopover = [[ListPopoverControllerWithImages alloc]initWithMessage:@"Select Source:" buttonListNames:@[]];
    self.sourceSelectPopover.contentViewController.modalInPopover = NO; // this lets you tap out to dismiss
    [self setupView];
    
    
    //instantiate uicollection cell
    [self.collectionView registerClass:[thumbnailCell class] forCellWithReuseIdentifier:@"thumbnailCell"];
    //set the collectionview's properties
    [self.collectionView setAllowsSelection:TRUE];
    [self.collectionView setAllowsMultipleSelection:TRUE];
    self.breadCrumbVC = [[BreadCrumbsViewController alloc]initWithPoint:CGPointMake(25, 64)];
    [self.view addSubview:self.breadCrumbVC.view];
    
    
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDetected:)];
    self.longPressRecognizer.minimumPressDuration = 0.7;
    [self.view addGestureRecognizer: self.longPressRecognizer];
    self.isEditing = NO;
    
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
    for (thumbnailCell *cell in self.collectionView.visibleCells) {
        [cell setDeletingMode: self.isEditing];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:self userInfo:@{@"context":STRING_LIVE2BENCH_CONTEXT}];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_COMMAND_VIDEO_PLAYER object:self userInfo:@{@"context":@"ListView Tab"}];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
    [self configurePxpFilter:self.currentEvent];
    [self loadAndDisplayTags];
    [self.collectionView reloadData];
}


-(void)receiveFilteredArrayFromFilter:(id)filter
{
    AbstractFilterViewController * checkFilter = (AbstractFilterViewController *)filter;
    NSMutableArray *filteredArray = (NSMutableArray *)[checkFilter processedList]; //checkFilter.displayArray;
    self.tagsToDisplay = [filteredArray mutableCopy];
    [self.collectionView reloadData];
    [self.breadCrumbVC inputList: [checkFilter.tabManager invokedComponentNames]];
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
    [super viewWillDisappear:animated];
    
    [self.dismissFilterButton removeFromSuperview];
    
    if (self.isEditing) {
        self.isEditing = !self.isEditing;
        
        for (thumbnailCell *cell in self.collectionView.visibleCells) {
            [cell setDeletingMode: self.isEditing];
        }
        
        if( !self.isEditing ){
            [self.deleteTagIds removeAllObjects];
            [self showOrHideDeleteAllButton];
        }
        
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
#ifdef DEBUG
    NSLog(@"ClipViewController viewDidDisappear");
#endif
}


#pragma mark - MAKE CELL
//create le thumbnail cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the data from the array
    Tag *tagSelect = [self.tagsToDisplay objectAtIndex:[indexPath indexAtPosition:1]];
    
    thumbnailCell *cell = (thumbnailCell*)[cv dequeueReusableCellWithReuseIdentifier:@"thumbnailCell" forIndexPath:indexPath];
    cell.backgroundPlaneView = nil;
    cell.data           = tagSelect;
    [cell.thumbColour changeColor:[Utility colorWithHexString: tagSelect.colour] withRect:cell.thumbColour.frame];
    
    NSString *thumbNameStr = tagSelect.name;
    
    [cell.thumbName setText:[[thumbNameStr stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"%" withString:@""]];
    [cell.thumbName setFont:[UIFont boldSystemFontOfSize:18.0f]];
    
    cell.thumbTime.text = [Utility translateTimeFormat:tagSelect.time];
    
    
    if (self.currentEvent.gameStartTag){
    
        float startTime = tagSelect.time - ([self.currentEvent.gameStartTag time]);
        cell.thumbGameTime.text = [Utility translateTimeFormat:startTime];
    }
    
    [cell.thumbDur setText:[NSString stringWithFormat:@"%.2ds",tagSelect.duration]];
    cell.ratingscale.rating = tagSelect.rating;
    cell.checkmarkOverlay.hidden = YES;
    [cell.thumbDeleteButton addTarget:self action:@selector(cellDeleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // This is used for customizing the cell based off the sport
    
    Profession * profession = [ProfessionMap getProfession:self.currentEvent.eventType];// should be the events sport //
    profession.onClipViewCellStyle(cell,tagSelect);
    
    
    [cell.imageView pxp_setTagThumbnail:tagSelect];
    [cell setDeletingMode: self.isEditing];
    
    if ([self.deleteTagIds containsObject:tagSelect.ID]) {
        cell.checkmarkOverlay.hidden = NO;
        cell.translucentEditingView.hidden = NO;
    }

    return cell;
}

-(void) deleteTagList:(NSArray*) tags {
    [super deleteTagList:tags];
    [self deselectAllCell];
    [self showOrHideDeleteAllButton];
    [self.collectionView reloadData];
}

-(void) deleteTag:(Tag*) tag {
    [self.tagsToDisplay removeObject:tag];
    if (self.editingIndexPath) {
        [self.collectionView deleteItemsAtIndexPaths:@[self.editingIndexPath]];
    }
    [super deleteTag:tag];
    [self deselectAllCell];
    [self showOrHideDeleteAllButton];
}

-(void)cellDeleteButtonPressed: (UIButton *)sender{
    thumbnailCell *cell = (thumbnailCell *)sender.superview;
    NSIndexPath *pathToDelete = [self.collectionView indexPathForCell: cell];
    self.editingIndexPath = pathToDelete;
    
    Tag *tag        = [self.tagsToDisplay objectAtIndex:self.editingIndexPath.row];
    if (![self promptUserToDeleteTag:tag]) {
        [self showOrHideDeleteAllButton];
    }
}

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    // apply custom attributes...
    [self.collectionView setNeedsDisplay]; // force drawRect:
}



#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
  
    Tag *tagSelect = [self.tagsToDisplay objectAtIndex:[indexPath indexAtPosition:1]];
    
    
    if ([tagSelect.name isEqualToString:@"telestration"]) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                        message:[NSString stringWithFormat:@"Can not view Telestartions generated from Encoders Below version %@",OLD_VERSION]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okayButton = [UIAlertAction
                                     actionWithTitle:@"Okay"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                     }];
        
        [alert addAction:okayButton];
        (void)[[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];

        return;
    }
    
    
    if (self.isEditing) {
        thumbnailCell *cell = (thumbnailCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
        cell.checkmarkOverlay.hidden = !cell.checkmarkOverlay.hidden;
        cell.translucentEditingView.hidden = !cell.translucentEditingView.hidden;
        if (!cell.checkmarkOverlay.hidden) {
            [self.deleteTagIds addObject:tagSelect.ID];
        }else{
            [self.deleteTagIds removeObject:tagSelect.ID];
        }
        [self showOrHideDeleteAllButton];
        return;
    }
    
    thumbnailCell *selectedCell =(thumbnailCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self.sourceSelectPopover clear];
    
     if (selectedCell.data.eventInstance.feeds.count >=2 && !tagSelect.isTelestration) { // if is new
        NSArray * listOfScource = [[selectedCell.data.eventInstance.feeds allKeys]sortedArrayUsingSelector:@selector(compare:)];
        
        [self.sourceSelectPopover setListOfButtonNames:listOfScource];
        
        //This is where the Thumbnail images are added to the popover
        NSDictionary *tagThumbnails = selectedCell.data.thumbnails ;
        
        int i = 0;
        for (NSString *src in listOfScource){
            //NSString *url = urls[[NSString stringWithFormat: @"s_0%i" , i +1 ]];
            
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, POP_WIDTH - 10, BUTTON_HEIGHT - 10)];
            
            PxpTelestration *tele = listOfScource.count <= 1 || [selectedCell.data.telestration.sourceName isEqualToString:src] ? selectedCell.data.telestration : nil;
            
            [[ImageAssetManager getInstance] imageForURL: tagThumbnails[src] atImageView:imageView withTelestration:tele];
            
            [(UIButton *)self.sourceSelectPopover.arrayOfButtons[i] addSubview:imageView];
            ++i;
        }
        

        
        //if ( [tagSelect count] >1 ){
            [self.sourceSelectPopover addOnCompletionBlock:^(NSString *pick) {
                
                // Get the feed
                NSDictionary *feeds = selectedCell.data.eventInstance.feeds;
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
        
            [self.sourceSelectPopover presentPopoverFromRect: CGRectMake(selectedCell.frame.size.width /2, 0, 0, 50) inView:selectedCell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
            
        
        
    } else if (tagSelect.isTelestration) {
        
        Feed *feed = selectedCell.data.eventInstance.feeds[tagSelect.telestration.sourceName];
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
    }  else {
        
        Feed *feed = [[selectedCell.data.eventInstance.feeds allValues] firstObject];
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
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    
    if ([self.view window] == nil){
        self.view = nil;
    }
    [[ImageAssetManager getInstance].arrayOfClipImages removeAllObjects];
}

- (void)liveEventStopped:(NSNotification *)note {
    [self clear];
}

-(void)deselectAllCell{
    for (thumbnailCell *cell in self.collectionView.visibleCells) {
        [cell setDeletingMode: NO];
    }
    self.isEditing = NO;
    [self.deleteTagIds removeAllObjects];
    [self showOrHideDeleteAllButton];
}

#pragma mark - Filtering Methods


// Sort tags by time index. Ensure that tags are unique
-(void) sortAndDisplayUniqueTags:(NSArray*) tags {
    [super sortAndDisplayUniqueTags:tags];
    
    if (self.refreshTimer.isValid) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(reloadCollectionView) userInfo:nil repeats:NO];
}

-(void) reloadCollectionView {
    [self.collectionView reloadData];
}

@end
