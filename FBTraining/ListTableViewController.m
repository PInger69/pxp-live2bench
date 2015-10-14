//
//  ListTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-02-18.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "ListTableViewController.h"
#import "ListViewCell.h"
#import "ImageAssetManager.h"
#import "ListPopoverControllerWithImages.h"
#import "FeedSelectCell.h"
#import "Tag.h"
#import "DownloadItem.h"
#import "RJLVideoPlayer.h"

#import "ListViewFullScreenViewController.h"
#import "LocalMediaManager.h"
#import "Downloader.h"

#import "AVAsset+Image.h"
#import "LeagueTeam.h"

@interface ListTableViewController ()

//@property (strong, nonatomic) NSIndexPath *editingIndexPath;
@property (strong, nonatomic) ListPopoverControllerWithImages *sourceSelectPopover;
//@property (strong, nonatomic) NSMutableSet *setOfDeletingCells;
//@property (strong, assign) UIButton *deleteButton;


@end

@implementation ListTableViewController
{
    dispatch_queue_t imageLoadQueue;

}


-(instancetype)init{
    self = [super init];
    if(self){
        self.isEditable = YES;
        //self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(1024 - (TABLE_WIDTH+1) - 85 , LABEL_HEIGHT + 60, TABLE_WIDTH, TABLE_HEIGHT) style:UITableViewStyleGrouped];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(1024 - TABLE_WIDTH, LABEL_HEIGHT + 55, TABLE_WIDTH, TABLE_HEIGHT) style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor whiteColor];
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //self.tableView.layer.borderWidth = 1.0f;
        //self.tableView.layer.borderColor = [[UIColor grayColor] CGColor];
        
        [self.tableView registerClass:[ListViewCell class] forCellReuseIdentifier:@"ListViewCell"];
        self.sourceSelectPopover = [[ListPopoverControllerWithImages alloc]initWithMessage:NSLocalizedString(@"Select Sources:", nil)  buttonListNames:@[]];
        self.sourceSelectPopover.contentViewController.modalInPopover = NO; // this lets you tap out to dismiss
        
                self.deleteButton = [[UIButton alloc] init];
                self.deleteButton.backgroundColor = [UIColor redColor];
                [self.deleteButton addTarget:self action:@selector(deleteAllButtonTarget) forControlEvents:UIControlEventTouchUpInside];
                [self.deleteButton setTitle: @"Delete Selected" forState: UIControlStateNormal];
                [self.deleteButton.titleLabel setTextColor:[UIColor whiteColor]];
                [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
                [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.deleteButton setFrame:CGRectMake(568, 768, 370, 0)];

        
        
    
                self.setOfDeletingCells = [[NSMutableSet alloc] init];
                //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDeletionCell:) name:@"AddDeletionCell" object:nil];
                //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDeletionCell:) name:@"RemoveDeletionCell" object:nil];
        
        self.originalFrame = CGRectMake(568, 768, 370, 0);
        [self.deleteButton setFrame: self.originalFrame];
        self.newFrame = CGRectMake(568, 708, 370, 60);
        
        self.arrayOfCollapsableIndexPaths = [NSMutableArray array];
        self.contextString = @"TAG";
        
        
        
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"The view will dissappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Multiple Cell Deletion Methods

/*-(void) addDeletionCell: (NSNotification *) aNotification{
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:aNotification.object];
    [self.setOfDeletingCells addObject: cellIndexPath];
    if (self.setOfDeletingCells.count >= 2){
        [self.tableView addSubview: self.deleteButton];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.deleteButton.frame = CGRectMake(568, 708, 370, 60);
    [self.deleteButton setBackgroundColor:[UIColor redColor]];
        [UIView commitAnimations];
    }
}

-(void)removeDeletionCell: (NSNotification *) aNotification{
     NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:aNotification.object];
    [self.setOfDeletingCells removeObject: cellIndexPath];
    if (self.setOfDeletingCells.count < 2){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.deleteButton.frame = CGRectMake(568, 768, 370, 0);
        [UIView commitAnimations];
    }

}*/

-(void)deleteAllButtonTarget{
    CustomAlertView *alert = [[CustomAlertView alloc] init];
    [alert setTitle:@"myplayXplay"];
    [alert setMessage:@"Are you sure you want to delete all these tags?"];
    [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert showView];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tableData count] + self.arrayOfCollapsableIndexPaths.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.arrayOfCollapsableIndexPaths containsObject: indexPath]) {
        return 44.0;
    }
    return CELL_HEIGHT;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    return [self.tagsToDisplay count];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Tag *tag;
    NSIndexPath *firstDownloadCellPath = [self.arrayOfCollapsableIndexPaths firstObject];

    
    if ([self.arrayOfCollapsableIndexPaths containsObject: indexPath]) {
        NSIndexPath *firstIndexPath = [self.arrayOfCollapsableIndexPaths firstObject];
        tag = self.tableData[(firstDownloadCellPath ? firstDownloadCellPath.row - 1:0)];
       
        NSArray *keys = [[NSMutableArray arrayWithArray:[tag.event.feeds allKeys]] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        NSString *key = keys[indexPath.row - firstIndexPath.row];
        
        FeedSelectCell *collapsableCell = [[FeedSelectCell alloc] initWithTag:tag source:key];//[tag[@"url_2"] allValues][indexPath.row - firstIndexPath.row]];
        
        

        __block FeedSelectCell *weakCell = collapsableCell;
        collapsableCell.downloadButton.downloadItem = nil;
        
        // This is checking if tag is downloaded to the device already
        NSString * tagKey;
//        tagKey  = [NSString stringWithFormat:@"%@-%@hq",tag.ID,key ];
        tagKey = key;//[NSString stringWithFormat:@"%@-%@hq",tag.ID,key ];
        
        
        if ([[Downloader defaultDownloader].keyedDownloadItems objectForKey:tagKey] != nil &&   [[[Downloader defaultDownloader].keyedDownloadItems objectForKey:tagKey] isKindOfClass:[NSString class]]) {
            // This means the place holder is found to set the button to look like its downloaded
            collapsableCell.downloadButton.isPressed    = YES;
            collapsableCell.downloadButton.progress     = 0;
        } else if ([[Downloader defaultDownloader].keyedDownloadItems objectForKey:tagKey]) {
            collapsableCell.downloadButton.downloadItem = [[Downloader defaultDownloader].keyedDownloadItems objectForKey:[NSString stringWithFormat:@"%@-%@hq",tag.ID,key ]];
            __block FeedSelectCell *weakerCell = weakCell;
            [weakCell.downloadButton.downloadItem addOnProgressBlock:^(float progress, NSInteger kbps) {
                weakerCell.downloadButton.progress = progress;
                [weakerCell.downloadButton setNeedsDisplay];
            }];
            //[key isEqualToString:@"onlySource"]
        } else if ([[LocalMediaManager getInstance]getClipByTag:tag scrKey:(tagKey)?tagKey:nil]){
            collapsableCell.downloadButton.downloadComplete = YES;
            collapsableCell.downloadButton.progress         = 1;
        }

        
        // When the download button is pressed
        collapsableCell.downloadButtonBlock = ^(){

            // this will at a place holder for the downloader so the clock will show up r 3ems anight away
            NSString * placeHolderKey = [NSString stringWithFormat:@"%@-%@hq",tag.ID,key ];
            [[Downloader defaultDownloader].keyedDownloadItems setObject:@"placeHolder" forKey:placeHolderKey];
            
            // this takes the download item and attaches it to the cell
            void(^blockName)(DownloadItem * downloadItem ) = ^(DownloadItem *downloadItem){
                //videoItem = downloadItem;
                 weakCell.downloadButton.downloadItem = downloadItem;
                 __block FeedSelectCell *weakerCell = weakCell;
                [weakCell.downloadButton.downloadItem addOnProgressBlock:^(float progress, NSInteger kbps) {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        weakerCell.downloadButton.progress = progress;
                        weakerCell.downloadButton.downloadComplete = progress == 1.0;
                        [weakerCell.downloadButton setNeedsDisplay];
                    });
                }];
            };
            
            NSString *src = [NSString stringWithFormat:@"%@hq", key];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EM_DOWNLOAD_CLIP object:nil userInfo:@{
                                                                                                                   @"block": blockName,
                                                                                                                   @"tag": tag,
                                                                                                                   @"src":src,
                                                                                                                   @"key":key}];
            
            
        };
        
        /*if (firstDownloadCellPath.row < indexPath.row) {
            tag = self.tableData[indexPath.row -self.arrayOfCollapsableIndexPaths.count];
        }else{
            tag = self.tableData[indexPath.row];
        }*/

        // Get the feed
        //NSDictionary *feeds = tag.event.feeds;
        //Feed *feed = feeds[key] ? feeds[key] :feeds.allValues.firstObject;
        
        collapsableCell.sendUserInfo = ^(){
            Feed *feed = [tag.event.feeds objectForKey:key];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{//@"context":STRING_LISTVIEW_CONTEXT,
                                                                                                                                            //@"feed":tag.feeds[key],
                                                                                                                                            //@"feed":tag.name,
                                                                                     
                                                                                                                                            @"name": key,
                                                                                                                                            @"feed":feed,
                                                                                                                                            @"time": [NSString stringWithFormat:@"%f",tag.startTime],
                                                                                                                                            @"duration": [NSString stringWithFormat:@"%d",tag.duration],
                                                                                                                                            @"comment": tag.comment ? tag.comment : @"",
                                                                                                                                            @"forWhole":tag,
                                                                                                                                            @"state":[NSNumber numberWithInteger:RJLPS_Play]
                                                                                                                                            }}];
        };
        return collapsableCell;
    }
    
    if (firstDownloadCellPath.row < indexPath.row) {
        tag = self.tableData[indexPath.row -self.arrayOfCollapsableIndexPaths.count];
    }else{
        tag = self.tableData[indexPath.row];
    }
    ListViewCell *cell = (ListViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ListViewCell"];
    [cell setFrame: CGRectMake(0, 0, TABLE_WIDTH, TABLE_HEIGHT)];
    cell.currentTag = tag;
    
    cell.swipeRecognizerLeft.enabled = self.swipeableMode;
    cell.swipeRecognizerRight.enabled = self.swipeableMode;
    
    cell.deleteBlock = ^(UITableViewCell *theCell){
        NSIndexPath *aIndexPath = [self.tableView indexPathForCell:theCell];
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:aIndexPath];
        [self checkDeleteAllButton];

    };
    
    //This condition opens up the cell if it is a deleting cell
    if ([self.setOfDeletingCells containsObject:indexPath]) {
        [cell setCellAccordingToState:cellStateDeleting];
    } else {
        [cell setCellAccordingToState:cellStateNormal];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //fixed: randomly highlight cells problem
    cell.backgroundView = nil;
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    cell.backgroundColor = [UIColor redColor];
    
    UIView* backgroundView = [ [ UIView alloc ] initWithFrame:cell.frame ];
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.layer.borderColor = [PRIMARY_APP_COLOR CGColor];
    cell.backgroundView = backgroundView;

    //This is the condition where a cell that is selected is reused
    [cell.translucentEditingView removeFromSuperview];
    cell.translucentEditingView = nil;

    // This condition is if the user is scrolling up and down and the
    // cell is selected
    if ([self.previouslySelectedIndexPath isEqual:indexPath]) {
        cell.translucentEditingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [cell.translucentEditingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [cell.translucentEditingView setBackgroundColor: [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f]];
        [cell.translucentEditingView setAlpha:0.3];
        [cell.translucentEditingView setUserInteractionEnabled:FALSE];
        [cell insertSubview:cell.translucentEditingView belowSubview:cell.tagname];
        //[cell.myContentView setBackgroundColor:[UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:0.3f]];
        
    }
    
    //ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc]init];
    NSString *src = tag.thumbnails.allKeys.firstObject;
    
    if (tag.telestration) {
        for (NSString *k in tag.thumbnails.keyEnumerator) {
            if ([tag.telestration.sourceName isEqualToString:k]) {
                src = k;
                break;
            }
        }
    }

    NSString *url = tag.thumbnails[src];
    
    cell.tagImage.image = [UIImage imageNamed:@"live.png"];
    if ([ImageAssetManager getInstance].arrayOfClipImages[url]){
        cell.tagImage.image = [ImageAssetManager getInstance].arrayOfClipImages[url];
    } else {
        [[ImageAssetManager getInstance]thumbnailsLoadedToView:cell.tagImage imageURL:url];
    }
    
    
   /*
    UIImage *thumb;
//    thumb = [tag thumbnailForSource:nil];
    [[ImageAssetManager getInstance] imageForURL:url atImageView:cell.tagImage];
    thumb = cell.tagImage.image;
    
    if (thumb && thumb.scale > 1) {
        thumb = [tag thumbnailForSource:nil];
    } else if (thumb && thumb.scale == 1) {
        cell.tagImage.image = thumb;

    } else {
        
        PxpTelestration *tele = tag.thumbnails.count <= 1 || [tag.telestration.sourceName isEqualToString:src] ? tag.telestration : nil;
        
        [[ImageAssetManager getInstance] imageForURL:url atImageView:cell.tagImage withTelestration:tele];
        thumb = cell.tagImage.image;
    }
    */
    
    



    

    
    
    
    
    [cell.tagname setText:[tag.name stringByRemovingPercentEncoding]];
    [cell.tagname setFont:[UIFont boldSystemFontOfSize:18.f]];
    
    NSString *durationString = [NSString stringWithFormat:@"%@s", [Utility translateTimeFormat:tag.duration]];
    NSString *periodString = tag.period;
    
    NSString *players;
    for (NSString *jersey in tag.players) {
        if (!players) {
            players = [NSString stringWithFormat:@"%@",jersey];
        }else{
            players = [NSString stringWithFormat:@"%@, %@",players,jersey];
        }
        [cell.tagPlayersView setHidden:false];
    }
    [cell.tagPlayersView setContentSize:CGSizeMake(players.length*8, cell.tagPlayersView.frame.size.height)];
    
    
    LeagueTeam *team = [[tag.event.teams allValues]firstObject];
    if ([team.league.sport isEqualToString:@"Rugby"] || [team.league.sport isEqualToString:@"Soccer"]) {
        [cell.tagInfoText setText:[NSString stringWithFormat:@"%@: %@ \n%@: %@", NSLocalizedString(@"Duration", nil),durationString,NSLocalizedString(@"Half", nil),periodString? periodString:@""]];
        [cell.playersLabel setText:NSLocalizedString(@"Player(s):", nil)];
        [cell.playersNumberLabel setText:players];
    }else if ([team.league.sport isEqualToString:@"Hockey"]){
        [cell.tagInfoText setText:[NSString stringWithFormat:@"%@: %@ \n%@: %@", NSLocalizedString(@"Duration", nil),durationString,NSLocalizedString(@"Period", nil),periodString? periodString:@""]];
        [cell.playersLabel setText:NSLocalizedString(@"Player(s):", nil)];
        [cell.playersNumberLabel setText:players];
    }else if ([team.league.sport isEqualToString:@"Football"]){
        [cell.tagInfoText setText:[NSString stringWithFormat:@"%@: %@ \n%@: %@", NSLocalizedString(@"Duration", nil),durationString,NSLocalizedString(@"Quarter", nil),periodString? periodString:@""]];
        [cell.playersLabel setText:NSLocalizedString(@"Player(s):", nil)];
        [cell.playersNumberLabel setText:players];
    }else{
        [cell.tagInfoText setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Duration", nil),durationString]];
    }
    
    
    
    //[cell.playersLabel setText:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Player(s):", nil),players]];
    
    
    //[cell.playersNumberLabel setBackgroundColor:[UIColor greenColor]];
    
    [cell.tagtime setText: tag.displayTime];
    
    

    cell.ratingscale.rating = tag.rating;
    

    
    UIColor *thumbColour = [Utility colorWithHexString:tag.colour];
    [cell.tagcolor changeColor:thumbColour withRect:cell.tagcolor.frame];
    
    [cell removeGestureRecognizer:cell.swipeRecognizerRight];
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    Tag *tag;
    NSIndexPath *firstDownloadCellPath = [self.arrayOfCollapsableIndexPaths firstObject];
    
    if ([self.arrayOfCollapsableIndexPaths containsObject:indexPath]) {
        tag = self.tableData[firstDownloadCellPath.row -1];
    }else if (firstDownloadCellPath.row < indexPath.row) {
        tag = self.tableData[indexPath.row -self.arrayOfCollapsableIndexPaths.count];
    }else{
        tag = self.tableData[indexPath.row];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LIST_VIEW_TAG object:tag];
    if (self.setOfDeletingCells.count ) {
        return;
    }else if ([self.arrayOfCollapsableIndexPaths containsObject: indexPath]){
       // FeedSelectCell *cell = (FeedSelectCell*)[self.tableView cellForRowAtIndexPath:indexPath];
//        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_LIST_VIEW object:nil userInfo:@{@"forFeed":@{@"context":STRING_LISTVIEW_CONTEXT,
//                                                                                                                                                                                                                                                                                                @"feed":cell.feedName.text,
//                                                                                                                                                                                                                                                                                                @"time": [NSString stringWithFormat:@"%f",tag.startTime],
//                                                                                                                                                                                                                                                                                                @"duration": [NSString stringWithFormat:@"%d",tag.duration],
//                                                                                                                                                                                                                                                                                                @"comment": tag.comment,
//                                                                                                                                                                                                                                                                                   @"forWhole":tag
//                                                                                                                                        }}];

        return;
    }
    

    //ImageAssetManager *imageAssetManager = [[ImageAssetManager alloc]init];
    
    ListViewCell *cell = (ListViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.currentTag = tag;
    
    if(![indexPath isEqual:self.previouslySelectedIndexPath])
    {
        [cell setSelected: YES];
        
        ListViewCell *lastSelectedCell = (ListViewCell*)[self.tableView cellForRowAtIndexPath: self.previouslySelectedIndexPath];
        lastSelectedCell.selected = NO;
        [lastSelectedCell.myContentView setBackgroundColor:[UIColor whiteColor]];
        
        NSArray *arrayToRemove = [self.arrayOfCollapsableIndexPaths copy];
        [self.arrayOfCollapsableIndexPaths removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationRight];
        
        NSMutableArray *insertionIndexPaths = [NSMutableArray array];
        if (self.previouslySelectedIndexPath.row < indexPath.row && self.previouslySelectedIndexPath) {
            for (int i = 0; i < tag.event.feeds.count ; ++i) {
                NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row - arrayToRemove.count + i + 1 inSection:indexPath.section];
                [insertionIndexPaths addObject:insertionIndexPath];
            }
            
            self.previouslySelectedIndexPath = [NSIndexPath indexPathForRow:indexPath.row -arrayToRemove.count inSection:indexPath.section];
        }else{
            for (int i = 0; i < tag.event.feeds.count ; ++i) {
                NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row + i+1 inSection:indexPath.section];
                [insertionIndexPaths addObject:insertionIndexPath];
            }

            self.previouslySelectedIndexPath = indexPath;
        }
        self.swipeableMode = NO;
        
        [self.arrayOfCollapsableIndexPaths addObjectsFromArray: insertionIndexPaths];
        [self.tableView insertRowsAtIndexPaths: insertionIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView scrollToRowAtIndexPath:self.previouslySelectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        NSArray *arrayToRemove = [NSArray array];
//        if (self.arrayOfCollapsableIndexPaths.count) {
//            arrayToRemove = [self.arrayOfCollapsableIndexPaths copy];
//        }
//        
//        NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
//        [self.arrayOfCollapsableIndexPaths addObject: insertionIndexPath];
//        [self.tableView insertRowsAtIndexPaths:@[insertionIndexPath ] withRowAnimation:UITableViewRowAnimationBottom];
//        [self.arrayOfCollapsableIndexPaths removeObjectsInArray:arrayToRemove];
//        [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationTop];
        
    }else{
        [cell setSelected: NO];
        
        //NSIndexPath *insertionIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
        //[self.arrayOfCollapsableIndexPaths removeObject: insertionIndexPath];
        NSArray *arrayToRemove = [self.arrayOfCollapsableIndexPaths copy];
        [self.arrayOfCollapsableIndexPaths removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationRight];
        self.previouslySelectedIndexPath = nil;
        self.swipeableMode = YES;
        //self.previouslySelectedIndexPath = indexPath;

    }
}



-(void)collaspOpenCell
{
    if (self.arrayOfCollapsableIndexPaths.count > 0) {
        NSArray *arrayToRemove = [self.arrayOfCollapsableIndexPaths copy];
        [self.arrayOfCollapsableIndexPaths removeAllObjects];
        [self.tableView deleteRowsAtIndexPaths: arrayToRemove withRowAnimation:UITableViewRowAnimationRight];
        self.previouslySelectedIndexPath = nil;
        self.swipeableMode = YES;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
    
        if (self.isEditable){
            return YES;
        } else {
            return YES;
        }
}

- (void)tableView:(UITableView *)tableView
willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView: tableView willBeginEditingRowAtIndexPath:indexPath];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.editing = NO;
    tableView.editing = NO;
}

//
//// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        self.editingIndexPath = indexPath;

        CustomAlertView *alert = [[CustomAlertView alloc] init];
        [alert setTitle:@"myplayXplay"];
        [alert setMessage:@"Are you sure you want to delete this tag?"];
        [alert setDelegate:self]; //set delegate to self so we can catch the response in a delegate method
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert showView];


    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if ([alertView.message isEqualToString:@"Are you sure you want to delete all these tags?"] && buttonIndex == 0) {
        NSMutableArray *indexPathsArray = [[NSMutableArray alloc]init];
        NSMutableArray *arrayOfTagsToRemove = [[NSMutableArray alloc]init];
        BOOL needCanNotDeleteTagAlertView = false;
        
        for (NSIndexPath *cellIndexPath in [self.setOfDeletingCells copy]) {
            Tag *tag = self.tableData[cellIndexPath.row];
            if ([tag.deviceID isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]]) {
                [arrayOfTagsToRemove addObject:tag];
                [indexPathsArray addObject:cellIndexPath];
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
            }else{
                needCanNotDeleteTagAlertView = true;
            }
        }
        
        for (Tag *tag in arrayOfTagsToRemove) {
            [self.tableData removeObject:tag];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationLeft];
        
        if (needCanNotDeleteTagAlertView) {
            CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"Can't Delete Tag" message:@"All of your tags are deleted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert showView];
        }
        
    }else if([alertView.message isEqualToString:@"Are you sure you want to delete this tag?"] && buttonIndex == 0){
        
        Tag *tag = [self.tableData objectAtIndex:self.editingIndexPath.row];
        if ([tag.user isEqualToString:[UserCenter getInstance].userHID]) {
//        if ([tag.deviceID isEqualToString:[[[UIDevice currentDevice] identifierForVendor]UUIDString]]) {
            [self.tableData removeObject:tag];
            [self.tableView deleteRowsAtIndexPaths:@[self.editingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_DELETE_TAG object:tag];
            [self removeIndexPathFromDeletion];
        }else{
            CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"Can't Delete Tag" message:@"You can't delete someone else's tag" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert showView];
        }
    }
    [CustomAlertView removeAlert:alertView];

    [self.setOfDeletingCells removeAllObjects];
    
    /*if (self.setOfDeletingCells.count < 2){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.deleteButton.frame = CGRectMake(568, 768, 370, 0);
        [UIView commitAnimations];

   }*/
    [alertView viewFinished];
    [self.tableView reloadData];
    [self checkDeleteAllButton];

}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (BOOL)playNext{
    NSIndexPath *path = self.selectedPath;
    NSInteger row = path.row;
    row ++;
    if(row >= self.tableData.count) row = 0;
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:newPath];
    [self setSelectedPath:newPath];
    return YES;
}

- (BOOL)playPrevious{
    NSIndexPath *path = self.selectedPath;
    NSInteger row = path.row;
    row --;
    if(row < 0) row = self.tableData.count - 1;
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self tableView:self.tableView didSelectRowAtIndexPath:newPath];
    [self setSelectedPath:newPath];
    return YES;
}

-(void)reloadData
{
    [super reloadData];
}
@end

