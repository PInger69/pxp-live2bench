//
//  ClipViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-29.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

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
#import "CustomAlertControllerQueue.h"

#import "ListViewCell.h"
#import "thumbnailCell.h"

#define CELLS_ON_SCREEN         12
#define TOTAL_WIDTH             1024
#define TOTAL_HEIGHT            600

#define BUTTON_HEIGHT           200
#define POP_WIDTH               300

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
@property (strong, nonatomic) UIButton *deSelectButton;

@property (strong, nonatomic) TabView *popupTabBar;

@property (nonatomic, strong) BreadCrumbsViewController* breadCrumbVC;
@property (nonatomic, strong) id <EncoderProtocol> observedEncoder;


@end

@implementation ClipViewController
{
    ListPopoverControllerWithImages * sourceSelectPopover;
    Event                           * _currentEvent;
    
}

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
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addEventObserver:) name:NOTIF_PRIMARY_ENCODER_CHANGE object:nil];

        self.setOfSelectedCells = [[NSMutableSet alloc] init];
        self.contextString = @"TAG";
        
        self.allTagsArray   = [NSMutableArray array];
        self.tagsToDisplay  = [NSMutableArray array];
    }
    return self;
    
}

// encoderOberver
-(void)addEventObserver:(NSNotification *)note
{
    if (self.observedEncoder != nil) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_EVENT_CHANGE object:self.observedEncoder];
    }
    
    if (note.object == nil) {
        self.observedEncoder = nil;
    } else {
        self.observedEncoder = (id <EncoderProtocol>) note.object;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventChanged:) name:NOTIF_EVENT_CHANGE object:self.observedEncoder];
        NSLog(@"Now observing encoder of type %@", [self.observedEncoder class]);
    }
}

-(void)eventChanged:(NSNotification *)note
{
    if ([[note.object event].name isEqualToString:_currentEvent.name]) {
        NSLog(@"ClipViewController.eventChanged called by no actual change");
        return;
    }
    NSLog(@"ClipViewController.eventChanged...");
    
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
    NSLog(@"ClipViewController.onTagChanged...");

    dispatch_async(dispatch_get_main_queue(), ^{
        self.allTagsArray = [NSMutableArray arrayWithArray:[_currentEvent.tags copy]];

        [self.pxpFilter filterTags:self.allTagsArray];
        [self sortAndDisplayUniqueTags:self.pxpFilter.filteredTags];
    });
}


-(void)clear{
    self.tagsToDisplay = nil;
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



- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:true];
#ifdef DEBUG
    NSLog(@"ClipViewController viewDidAppear");
#endif
   
    self.pxpFilter = [TabView sharedFilterTabBar].pxpFilter;
    self.pxpFilter.delegate = self;
    
    [self configurePxpFilter:_currentEvent];
    [self.collectionView reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sourceSelectPopover = [[ListPopoverControllerWithImages alloc]initWithMessage:@"Select Source:" buttonListNames:@[]];
    sourceSelectPopover.contentViewController.modalInPopover = NO; // this lets you tap out to dismiss
//    downloadedTagIds = [[NSMutableArray alloc] init];
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
    
    self.popupTabBar = [TabView sharedFilterTabBar];

}

-(void) longPressDetected: (UILongPressGestureRecognizer *) longPress{
    
    if(longPress.state == UIGestureRecognizerStateBegan){
        self.isEditing = !self.isEditing;
        
        for (thumbnailCell *cell in self.collectionView.visibleCells) {
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
    
    self.deSelectButton = [[UIButton alloc]initWithFrame:CGRectMake(900, 65, 80, 30)];
    [self.deSelectButton setTitle:@"Deselect" forState:UIControlStateNormal];
    [self.deSelectButton setBackgroundColor:[UIColor grayColor]];
    self.deSelectButton.titleLabel.adjustsFontSizeToFitWidth = true;
    [self.deSelectButton addTarget:self action:@selector(deselectAllCell) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deSelectButton];
    

}

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
                                         [self.setOfSelectedCells removeAllObjects];
                                  
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
        
        
        
        [self checkDeleteAllButton];
    }

    
    
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
    for (thumbnailCell *cell in self.collectionView.visibleCells) {
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
            [self.setOfSelectedCells removeAllObjects];
            [self checkDeleteAllButton];
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
    
    
    if (_currentEvent.gameStartTag){
    
        float startTime = tagSelect.time - ([_currentEvent.gameStartTag time]);
        cell.thumbGameTime.text = [Utility translateTimeFormat:startTime];
    }
    
    
    
//    [Utility translateTimeFormat:tagSelect.time]
    
    [cell.thumbDur setText:[NSString stringWithFormat:@"%.2ds",tagSelect.duration]];
    cell.ratingscale.rating = tagSelect.rating;
    cell.checkmarkOverlay.hidden = YES;
    [cell.thumbDeleteButton addTarget:self action:@selector(cellDeleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // This is used for customizing the cell based off the sport
    
    Profession * profession = [ProfessionMap getProfession:_currentEvent.eventType];// should be the events sport //
    profession.onClipViewCellStyle(cell,tagSelect);
    
    
    NSString *url = [[tagSelect.thumbnails allValues]firstObject];
    
    if (tagSelect.type == TagTypeTele) {
        PxpTelestration *tele = cell.data.telestration;
        [cell.data.thumbnails objectForKey:tele.sourceName];
        
        NSString * checkName = (!tele.sourceName)?[cell.data.thumbnails allKeys][0]:tele.sourceName;
        
        NSString * imageURL = ([cell.data.thumbnails objectForKey:checkName])?[cell.data.thumbnails objectForKey:checkName]:[NSString stringWithFormat:@"%@.png",[[NSUUID UUID]UUIDString]];
        

        __weak UIImageView* weakImageView = cell.imageView;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"live.png"] completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL) {

            if (image) {
                UIImage* imageWithTelestration = [tele renderOverImage:image view:cell.imageView];
                weakImageView.image = imageWithTelestration;
            }

        }];
        
        
    } else {
        NSLog(@"loading image: %@", url);
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"live.png"]];
    }

    [cell setDeletingMode: self.isEditing];
    
    if ([self.setOfSelectedCells containsObject: indexPath]) {
        cell.checkmarkOverlay.hidden = NO;
        cell.translucentEditingView.hidden = NO;
    }

    return cell;
}


-(void)cellDeleteButtonPressed: (UIButton *)sender{
    thumbnailCell *cell = (thumbnailCell *)sender.superview;
    NSIndexPath *pathToDelete = [self.collectionView indexPathForCell: cell];
    self.editingIndexPath = pathToDelete;
    
    Tag *tag        = [self.tagsToDisplay objectAtIndex:self.editingIndexPath.row];
    BOOL isYourTag  = [tag.user isEqualToString:[UserCenter getInstance].userHID];

    if (!isYourTag) {
        UIAlertController * cantAlert = [UIAlertController alertControllerWithTitle:@"myplayXplay"
                                                                            message:@"You can't delete someone else's tag"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButtons = [UIAlertAction
                                        actionWithTitle:@"Ok"
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction * action)
                                        {
                                            [[CustomAlertControllerQueue getInstance] dismissViewController:cantAlert animated:YES completion:nil];
                                        }];

        [cantAlert addAction:cancelButtons];
        [[CustomAlertControllerQueue getInstance]presentViewController:cantAlert inController:self animated:YES style:AlertImportant completion:nil];
        return;
    }

    
    
    
    // Build Alert
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
                                                                    message:@"Are you sure you want to delete this tag?"
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction * deleteButtons = [UIAlertAction actionWithTitle:@"Yes"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action)
                                     {
                                         Tag *tag = [self.tagsToDisplay objectAtIndex:self.editingIndexPath.row];
                                         
                                         [self.tagsToDisplay removeObject:tag];
                                         if (self.editingIndexPath) {
                                             [self.collectionView deleteItemsAtIndexPaths:@[self.editingIndexPath]];
                                         }
                                         [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
                                         [self removeIndexPathFromDeletion];
                                         [self deselectAllCell];
                                         [self checkDeleteAllButton];
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
        
        
        
        [self checkDeleteAllButton];
    }
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
            [self.setOfSelectedCells addObject: [self.collectionView indexPathForCell: cell]];
        }else{
            [self.setOfSelectedCells removeObject: [self.collectionView indexPathForCell: cell]];
        }
        [self checkDeleteAllButton];
        return;
    }
    
    thumbnailCell *selectedCell =(thumbnailCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [sourceSelectPopover clear];
    
     if (selectedCell.data.eventInstance.feeds.count >=2 && !tagSelect.telestration) { // if is new
        NSArray * listOfScource = [[selectedCell.data.eventInstance.feeds allKeys]sortedArrayUsingSelector:@selector(compare:)];
        
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
        
            [sourceSelectPopover presentPopoverFromRect: CGRectMake(selectedCell.frame.size.width /2, 0, 0, 50) inView:selectedCell.contentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
            
        
        
    } else if (tagSelect.telestration) {
        
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
    [self.setOfSelectedCells removeAllObjects];
    [self checkDeleteAllButton];
}

#pragma mark - Filtering Methods

- (void)pressFilterButton
{
    
    
    if (self.popupTabBar.isViewLoaded)
    {
       self. popupTabBar.view.frame =  CGRectMake(0, 0, self.popupTabBar.preferredContentSize.width,self.popupTabBar.preferredContentSize.height);
    }
    
    self.popupTabBar.modalPresentationStyle  = UIModalPresentationPopover; // Might have to make it custom if we want the fade darker
    self.popupTabBar.preferredContentSize    = self.popupTabBar.view.bounds.size;
    
    UIPopoverPresentationController *presentationController = [self.popupTabBar popoverPresentationController];
    presentationController.sourceRect               = [[UIScreen mainScreen] bounds];
    presentationController.sourceView               = self.view;
    presentationController.permittedArrowDirections = 0;
    
    [self presentViewController:self.popupTabBar animated:YES completion:nil];
    
    [self.pxpFilter filterTags:self.allTagsArray];
    
    if (!self.popupTabBar.pxpFilter)          self.popupTabBar.pxpFilter = self.pxpFilter;
    
    Profession * profession = [ProfessionMap getProfession:_currentEvent.eventType];
    [TabView sharedDefaultFilterTab].telestrationLabel.text = profession.telestrationTagName;
}


// Pxp
-(void)onFilterComplete:(PxpFilter*)filter
{
    if (!filter || !filter.filteredTags ) {
        return ;
    }
    [self sortAndDisplayUniqueTags:filter.filteredTags];
}

-(void)onFilterChange:(PxpFilter *)filter
{
    [self.pxpFilter filterTags:self.allTagsArray];
    [self sortAndDisplayUniqueTags:filter.filteredTags];
}

// Sort tags by time index. Ensure that tags are unique
-(void) sortAndDisplayUniqueTags:(NSArray*) tags {
    [super sortAndDisplayUniqueTags:tags];
    [self.collectionView reloadData];
}


@end
