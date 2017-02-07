//
//  BookmarkTableViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-04.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "BookmarkTableViewController.h"
#import "BookmarkViewcell.h"
#import "Utility.h"
#import "Clip.h"
//#import "ListPopoverControllerWithImages.h"
#import "AVAsset+Image.h"
#import "CustomAlertControllerQueue.h"

#import "PxpDropboxActivity.h"
#import "PxpMailClipActivity.h"
#import "VideoUploadRecieptActivity.h"
#import "DropboxManager.h"
#import <MessageUI/MessageUI.h>

#define YES_BUTTON  0
#define NO_BUTTON   1


@interface BookmarkTableViewController () // <UIDocumentInteractionControllerDelegate>
//@property (strong, nonatomic) UIPopoverController *sharePop;
@property (strong, nonatomic) NSIndexPath *sharingIndexPath;
@property (strong, nonatomic) NSMutableArray   *sharingIndexPaths;
//@property (strong, nonatomic, nonnull) ListPopoverControllerWithImages *sourceSharePopoverViewController;
//@property (strong, nonatomic, nonnull) ListPopoverControllerWithImages *sourceSelectPopoverViewController;

@end

@implementation BookmarkTableViewController

-(instancetype)init{
    self = [super init];
    if (self){
        
        /*
        _sourceSharePopoverViewController = [[ListPopoverControllerWithImages alloc] initWithMessage:@"Select Source:" buttonListNames:@[]];
        _sourceSharePopoverViewController.contentViewController.modalInPopover = NO;
        
        _sourceSelectPopoverViewController = [[ListPopoverControllerWithImages alloc] initWithMessage:@"Select Source:" buttonListNames:@[]];
        _sourceSelectPopoverViewController.contentViewController.modalInPopover = NO;
        */
        
        [self.tableView registerClass:[BookmarkViewCell class] forCellReuseIdentifier:@"BookmarkViewCell"];
        
        //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.sharingIndexPaths = [NSMutableArray new];        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Force your tableview margins (this may be a bad idea)
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //[self.tableView setContentSize:CGSizeMake(self.tableView.frame.size.width, [self.tableData count] * 44)];
    // Return the number of rows in the section.
    return [self.tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BookmarkViewCell *selectedCell = (BookmarkViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    Clip *clip = [self.tableData objectAtIndex:indexPath.row];

    NSLog(@"Selected clip path for cell: %lu : %@", indexPath.row, clip.path);

    for (NSString* path in clip.videoFiles) {
        NSLog(@"Video path : %@", path);
    }
    
    NSString* directory = [clip.path stringByDeletingLastPathComponent];
    
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:directory];
    NSString *filename;
    
    while ((filename = [direnum nextObject] )) {
        NSLog(@"Files in resource folder: %@", filename);
    }
    
    
//    NSDictionary *videosBySourceKey = clip.videosBySrcKey;
//    NSArray *sourceKeys = [videosBySourceKey.allKeys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
//    
//    if (sourceKeys.count > 1) {
//        // multiple source, display popover.
//        [_sourceSelectPopoverViewController setListOfButtonNames:sourceKeys];
//        
//        for (NSUInteger i = 0; i < sourceKeys.count; i++) {
//            UIButton *button = _sourceSelectPopoverViewController.arrayOfButtons[i];
//            NSString *path = videosBySourceKey[sourceKeys[i]];
//            
//            // get thumbnail image
//            [button setBackgroundImage:[[AVAsset assetWithURL:[NSURL fileURLWithPath:path]] imageForTime:kCMTimeZero] forState:UIControlStateNormal];
//        }
//        
//        [_sourceSelectPopoverViewController addOnCompletionBlock:^(NSString *sourceKey) {
//            if (sourceKey) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLIP_SELECTED object:nil userInfo:@{@"clip": clip, @"source": sourceKey }];
//            }
//        }];
//        
//        [_sourceSelectPopoverViewController presentPopoverFromRect:selectedCell.bounds inView:selectedCell permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//        
//    } else {
//        // single source, just play it.
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLIP_SELECTED object:nil userInfo:@{@"clip": clip }];
//    }
    
    
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLIP_SELECTED object:nil userInfo:@{@"clip": clip }];
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_SET_PLAYER_FEED_IN_MYCLIP object:nil userInfo:@{@"forFeed":@{@"context":STRING_MYCLIP_CONTEXT,
//                                                                                                                                 @"feed": clip,
//                                                                                                                                 @"time":[clip.rawData objectForKey:@"starttime"],
//                                                                                                                                 @"duration":[clip.rawData objectForKey:@"duration"],
//                                                                                                                                 @"comment":[clip.rawData objectForKey:@"comment"]},
//                                                                                                                                 @"forWhole":clip.rawData}];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"tagSelected" object:self userInfo: clip];
    if(![indexPath isEqual:self.selectedPath])
    {
        selectedCell.translucentEditingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selectedCell.frame.size.width, selectedCell.frame.size.height)];
        [selectedCell.translucentEditingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [selectedCell.translucentEditingView setBackgroundColor: PRIMARY_APP_COLOR];
        [selectedCell.translucentEditingView setAlpha:0.3];
        [selectedCell.translucentEditingView setUserInteractionEnabled:FALSE];
        [selectedCell addSubview:selectedCell.translucentEditingView];
        
        BookmarkViewCell *lastSelectedCell = (BookmarkViewCell*)[self.tableView cellForRowAtIndexPath: self.selectedPath];
        [lastSelectedCell.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [lastSelectedCell.backgroundView setBackgroundColor:[UIColor whiteColor]];
        [lastSelectedCell.translucentEditingView removeFromSuperview];
        
        
        self.selectedPath = indexPath;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BookmarkViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookmarkViewCell" forIndexPath:indexPath];
    Clip *clip = self.tableData[indexPath.row];
    [cell.eventDate setText: [Utility dateFromEvent: clip.eventName]];
    [cell.tagTime setText: clip.displayTime];
    [cell.tagName setText: [clip.name stringByRemovingPercentEncoding] ];
    [cell.indexNum setText: [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1]];
    cell.rating = clip.rating;
//    cell.interactionController = [[UIDocumentInteractionController alloc] init];
    
    NSLog(@"Clip path for cell: %lu : %@", indexPath.row, clip.path);

    cell.deleteBlock = ^(UITableViewCell *cell){
        NSIndexPath *aIndexPath = [self.tableView indexPathForCell:cell];
        [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:aIndexPath];
    };
    
    NSDictionary *clipVideosBySourceKey = clip.videosBySrcKey;
    ////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////
    cell.shareBlock = ^(UITableViewCell *tableViewCell) {
        
        
        NSMutableArray  * clipsToShare      = [NSMutableArray new];
        NSString        * subjectLine       = @"Live2Bench Clips";
        NSArray         * clipsBeingShared  = [self.setOfSharingCells allObjects];
        
        NSMutableString * text = [NSMutableString new];
        
        for (NSIndexPath * index in clipsBeingShared) {
            Clip *aClip = [self.tableData objectAtIndex:index.row];
            
            [text appendString:@"<html><body>"];
            [text appendString:[NSString stringWithFormat:@"%@<br/>",aClip.name]];
            [text appendString:[NSString stringWithFormat:@"File Name: %@<br/>",[aClip.videoFiles[0] lastPathComponent]]];
            
            if (aClip.rating) {
                
                [text appendString:[NSString stringWithFormat:@"Rating: "]];
                
                for (NSInteger i = 0; i < aClip.rating; i++) {
                    [text appendString:@"*"];
                }
                
                [text appendString:@"<br/>"];
                
            }
            if (![aClip.comment isEqualToString:@""]) [text appendString:[NSString stringWithFormat:@"Comment: %@<br/>",aClip.comment]];
            
            [text appendString:@"---<br/>"];
            
            [clipsToShare addObject:text];
        }
        [text appendString:@"</body></html>"];
        

        NSMutableArray * clipsBeingEmailed =  [NSMutableArray new];
        
        // Add all clips
        [clipsToShare removeAllObjects];
        for (NSIndexPath * index2 in clipsBeingShared) {
            Clip *aClip2 = [self.tableData objectAtIndex:index2.row];
            [clipsToShare addObject:[NSURL fileURLWithPath:aClip2.videoFiles[0]]];
            [clipsBeingEmailed addObject:aClip2];
        }
//        clipsToShare = @[[clipsToShare firstObject]];
        ////////////////////////////////////////////////////////////

        PxpDropboxActivity * activityDropbox = [[PxpDropboxActivity alloc]init];
//
//        
        __weak BookmarkTableViewController * weakself = self;
        [activityDropbox setOnActivityStart:^(UIActivity *activity) {
            [weakself.progress setHidden:NO];
            if([[DropboxManager getInstance].session isLinked]){
                [[DropboxManager getInstance].restClient createFolder:@"/Live2BenchNative/"]; // make the folder if its not thay
            }
        }];
        
        [activityDropbox setOnActivityProgress:^(PxpDropboxActivity *activityDropbox, CGFloat cfProgress) {
            [weakself.progress setText:[NSString stringWithFormat:@"%ld of %ld files uploaded: %.2f %%",(long)activityDropbox.filesUploaded,(long)activityDropbox.fileCount,(cfProgress*100.0f)]];
        }];
        
        [activityDropbox setOnActivityComplete:^(UIActivity *activity) {
            [weakself.progress setHidden:YES];
        }];
//
        [clipsToShare removeAllObjects];
        for (NSIndexPath * index2 in clipsBeingShared) {
            Clip *aClip = [self.tableData objectAtIndex:index2.row];
            //make sure comment and rating are updated
            
            NSArray * allKeys = [aClip.videosBySrcKey allKeys];
            
            for (NSString * key in allKeys) {
                NSString *eventDate     = [aClip.eventName substringToIndex:18];
                NSString * sourceKey    = key;
                NSURL * vidUrl          = (NSURL *)[aClip.videosBySrcKey objectForKey:key];
                NSString *fileName      = [NSString stringWithFormat:@"%@_%@_%@_%@_%@_VS_%@%@.mp4",aClip.name,aClip.displayTime,eventDate,sourceKey,aClip.homeTeam,aClip.visitTeam,@""];
                fileName                = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                
                
                [activityDropbox.urlToFileName setObject:fileName forKey:vidUrl];
            }
            
            
//            for (NSURL * vidUrl in aClip.videoFiles) {
//
//                NSString *eventDate = [aClip.eventName substringToIndex:18];
//                NSString * sourceKey = @"";
//                for (NSString * val in [aClip.videosBySrcKey allValues]) {
//                    NSLog(@"%s",__FUNCTION__);
//aClip.videosBySrcKey k
//                }
//                NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@__%@_%@_VS_%@%@.mp4",aClip.name,aClip.displayTime,eventDate,sourceKey,aClip.homeTeam,aClip.visitTeam,@""];
//                fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//                
//
//                
//                [activityDropbox.urlToFileName setObject:fileName forKey:vidUrl];
//                
//            }
            
            
            
            
            
            Clip *aClip2 = [self.tableData objectAtIndex:index2.row];
//            [clipsToShare addObject:[NSURL fileURLWithPath:aClip2.videoFiles[0]]];
            for (NSString * vidfile in aClip2.videoFiles) {
                    [clipsToShare addObject:[NSURL fileURLWithPath:vidfile]];
            }
        }
        
        
        //@[gda]
        PxpMailClipActivity * mailActivity = [[PxpMailClipActivity alloc]initWithClips:clipsBeingEmailed];
        mailActivity.presetingViewController = self;
        
        
        
        VideoUploadRecieptActivity * videoUploadActivity = [[VideoUploadRecieptActivity alloc]initWithClips:clipsBeingEmailed];
        
        __weak UILabel * weakProgressLable = self.progress;
      
        
        [videoUploadActivity setOnActivityProgress:^(VideoUploadRecieptActivity * activityDropbox, CGFloat cfProgress) {
            
            if (weakself.progress.hidden){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakself.progress.hidden = NO;
                    weakself.progress.text = activityDropbox.progressMessage;
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                 [weakself.progress setText:[NSString stringWithFormat:@"Uploading Clip: %.2f %%",(cfProgress*100.0f)]];
            });
           
        }];
        
        
        [videoUploadActivity setOnRequestComplete:^(VideoUploadRecieptActivity * activity) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakProgressLable.hidden = YES;
                weakProgressLable.text = @"";
            });
        }];
        
        
        NSArray * activities = @[mailActivity,activityDropbox,videoUploadActivity];
        NSDictionary * setPref = [[PxpPreference dictionary] objectForKey:@"SettingsItems"];
        if( [setPref[@"Dropbox"] boolValue]) {
//            activities = @[activity];
        }
        
        UIActivityViewController * activityVC = [[UIActivityViewController alloc]initWithActivityItems:clipsToShare applicationActivities:activities];
        [activityVC setValue:subjectLine forKey:@"subject"];
        activityVC.excludedActivityTypes = @[UIActivityTypeMail,
                                             UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,
                                             UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToTencentWeibo
                                             ];

        
        UIPopoverController * pop = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        
        CGRect rect = [[UIScreen mainScreen] bounds];
        
        [pop
         presentPopoverFromRect:rect inView:self.view
         permittedArrowDirections:0
         animated:YES];

   
    
        
        
    };
    ////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////
    //This is the condition where a cell that is selected is reused
    if (cell.translucentEditingView) {
        [cell.translucentEditingView removeFromSuperview];
        cell.translucentEditingView = nil;
    }
    
    
    // This condition is if the user is scrolling up and down and the
    // cell is selected
    if ([self.selectedPath isEqual:indexPath]) {
        cell.translucentEditingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        [cell.translucentEditingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [cell.translucentEditingView setBackgroundColor: [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f]];
        [cell.translucentEditingView setAlpha:0.3];
        [cell.translucentEditingView setUserInteractionEnabled:FALSE];
        [cell addSubview:cell.translucentEditingView];
        
    }
    
    if ([self.setOfDeletingCells containsObject:indexPath]) {
        [cell setCellAccordingToState:cellStateDeleting];
    }else if ([self.setOfSharingCells containsObject:indexPath]){
        [cell setCellAccordingToState:cellStateSharing];
    } else {
        [cell setCellAccordingToState:cellStateNormal];
    }
    
    return cell;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    //[self setEditing:YES animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



//// Override to support editing the table view.
/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}*/



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    
    NSDictionary *trans = [self.tableData objectAtIndex:fromIndexPath.row];
    [self.tableData removeObjectAtIndex:fromIndexPath.row];
    [self.tableData insertObject:trans atIndex:toIndexPath.row];
    [self.tableView reloadData];
    
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


// next/previous playing
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

#pragma mark - Deletion Methods
-(void)deleteAllButtonTarget{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"myplayXplay",nil)
message:[NSString stringWithFormat:@"%@ %@s?", NSLocalizedString(@"Are you sure you want to delete all these",nil), [self.contextString lowercaseString]]
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okayButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    NSArray *deleteOrderList = [[self.setOfDeletingCells allObjects] sortedArrayUsingSelector:@selector(compare:)];
                                    
                                    if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:indexesToBeDeleted:)]) {
                                        [self.delegate tableView:self indexesToBeDeleted:deleteOrderList];
                                    }
                                    
                                    for (NSInteger i =[deleteOrderList count]-1; i>=0 ;i--) {
                                        NSIndexPath *cellIndexPath = deleteOrderList[i];
                                        [self deleteClipAtIndex:cellIndexPath];
                                        if (cellIndexPath == self.selectedPath) { // this clears the display data on BookmarkViewController
                                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REMOVE_INFORMATION object:nil];
                                            self.selectedPath = nil;
                                        }
                                    }
                                    [self.tableView beginUpdates];
                                    [self.tableView deleteRowsAtIndexPaths:deleteOrderList withRowAnimation:UITableViewRowAnimationLeft];//UITableViewRowAnimationFade
                                    [self.tableView endUpdates];
                                    [self.setOfDeletingCells removeAllObjects];
                                    
                                    [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                     [self checkDeleteAllButton];
                                }];

    UIAlertAction* cancelButtons = [UIAlertAction
                                actionWithTitle:@"No"
                                style:UIAlertActionStyleCancel
                                handler:^(UIAlertAction * action)
                                {
                                    [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                }];

    
    [alert addAction:okayButton];
    [alert addAction:cancelButtons];
    
    
    BOOL isAllowed = [[CustomAlertControllerQueue getInstance]presentViewController:alert inController:self animated:YES style:AlertIndecisive completion:nil];
    
    if (!isAllowed) {
        NSArray *deleteOrderList = [[self.setOfDeletingCells allObjects] sortedArrayUsingSelector:@selector(compare:)];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:indexesToBeDeleted:)]) {
            [self.delegate tableView:self indexesToBeDeleted:deleteOrderList];
        }
        
        for (NSInteger i =[deleteOrderList count]-1; i>=0 ;i--) {
            NSIndexPath *cellIndexPath = deleteOrderList[i];
            [self deleteClipAtIndex:cellIndexPath];
            if (cellIndexPath == self.selectedPath) { // this clears the display data on BookmarkViewController
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_REMOVE_INFORMATION object:nil];
                self.selectedPath = nil;
            }
        }
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deleteOrderList withRowAnimation:UITableViewRowAnimationLeft];//UITableViewRowAnimationFade
        [self.tableView endUpdates];
        [self.setOfDeletingCells removeAllObjects];
    }
}

-(void)removeDeleteSelection
{

}


// let the local encoder destroy the clips, this class does not need to have blood on its hands
-(void)deleteClipAtIndex:(NSIndexPath*)indexPth
{
    if ([self.tableData count]) {
        Clip * clipToDelete = self.tableData[indexPth.row];
        [self.tableData removeObject:clipToDelete];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DELETE_CLIPS  object:clipToDelete userInfo:nil];
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
