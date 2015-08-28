//
//  BookmarkViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-03-26.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CustomTabViewController.h"
#import "BookmarkViewCell.h"
#import "Live2BenchViewController.h"
//#import <Social/Social.h>
//#import <Accounts/Accounts.h>
#import "BookmarkFilterViewController.h"
#import "DeletableTableViewController.h"

#import "CustomButton.h"
#import "AMBlurView.h"
#import "BorderButton.h"
#import "TeleViewController.h"

#import "PxpFilter.h"
#import "PxpFilterDelegate.h"
#import "TabView.h"

@class TeleViewController, BookmarkFilterViewController, GDFileUploader, DPBFileUploader;
@interface BookmarkViewController : CustomTabViewController<UITextViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate, UIPopoverControllerDelegate,PxpFilterDelegate ,DeletableTableViewControllerDelegate>
{

    NSIndexPath                  * wasPlayingIndexPath;
    UIView                       * videoControlBar;
    NSDictionary                 * currentPlayingTag;
    NSArray                      * paths;
    NSString                     * documentsDirectory;
    UIView                       * blurView;
    int                          cellSelectedNumber;
    BOOL                         isEditing;
    BOOL                         hasBeenOrdered;
    BOOL                         working; //dead?
    NSInteger                    _currentSharingMethod;
    //0-none, 1-fb, 2-twitter
    
}

@property (nonatomic, strong)  NSMutableArray               * allClips;
@property (nonatomic,strong) UIViewController <PxpVideoPlayerProtocol>    * videoPlayer;
@property (nonatomic,strong)   NSMutableDictionary          * selectedTag;
@property (nonatomic,strong)   UIPopoverController          * popoverController;
@property (nonatomic)          int                          progressBarIndex;
@property (nonatomic,strong)   NSMutableDictionary          * allEvents;
@property (nonatomic,strong)   TeleViewController           * teleViewController;
@property (nonatomic,strong)   CustomButton                 * playbackRateBackButton;
@property (nonatomic,strong)   CustomButton                 * playbackRateForwardButton;

@property (nonatomic)          BOOL                         fullScreenMode;
@property (nonatomic,strong) PxpFilter                      * pxpFilter;
@property (nonatomic,strong) TabView                        * pxpFilterTab;


-(void)slideFilterBox;
-(void)dismissFilterToolbox;
-(void)createAllFullScreenSubviews;
-(void)removeAllFullScreenSubviews;

@end
