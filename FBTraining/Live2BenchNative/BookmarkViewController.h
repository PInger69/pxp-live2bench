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

#import "FilterToolboxViewController.h"
#import "BookmarkViewCell.h"
#import "Live2BenchViewController.h"
#import "UtilitiesController.h"
#import "Globals.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>
#import "BookmarkFilterViewController.h"
#import "CustomButton.h"
#import "AMBlurView.h"
#import "BorderButton.h"
#import "TeleViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "EdgeSwipeEditButtonsView.h"
#import "JPReorderTableView.h"
#import "GDFileUploader.h"


@class EdgeSwipeEditButtonsView, TeleViewController, BookmarkFilterViewController, FilterToolboxViewController, GDFileUploader, DPBFileUploader;
@interface BookmarkViewController : CustomTabViewController<UITextViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,MFMailComposeViewControllerDelegate,UIGestureRecognizerDelegate, DBSessionDelegate,DBNetworkRequestDelegate,DBRestClientDelegate,UIDocumentInteractionControllerDelegate, EdgeSwipeButtonDelegate, UIPopoverControllerDelegate, JPReorderTableViewDataSource, JPReorderTableViewDelegate, GDFileUploaderDelegate>
{
    Globals                      * globals;
    NSMutableArray               * _tagsToDisplay;
    NSMutableArray               * allTags;
    NSMutableArray               * typesOfTags;
    NSTimer                      * updatePlayRateTimer;
    NSString                     * userIdd;
    NSString                     * tagId;
    NSMutableArray               * tagsDidViewed;
    NSMutableDictionary          * selectedTag;
    NSIndexPath                  * wasPlayingIndexPath;
    UIView                       * videoControlBar;
    NSDictionary                 * currentPlayingTag;
    NSArray                      * paths;
    NSString                     * documentsDirectory;
    NSFileManager                * fileManager;
    UtilitiesController          * uController;
    MFMailComposeViewController  * mailController;
    ACAccount                    * facebookAccount; // Dead?
    UIView                       * blurView;
    GDFileUploader               * _GDUploader;
    DPBFileUploader              * _DPBUploader;
    int                          cellSelectedNumber;
    BOOL                         isEditingClips;
    BOOL                         hasBeenOrdered;
    BOOL                         working; //dead?
    NSInteger                    _currentSharingMethod;
    //0-none, 1-fb, 2-twitter
    
}

@property (nonatomic,strong)   JPReorderTableView           * tableView;
@property (nonatomic,strong)   BorderButton                 * tableActionButton;
@property (nonatomic,strong)   NSMutableArray               * tagsToDisplay;
@property (nonatomic,strong)   NSMutableArray               * allTags;
@property (nonatomic,strong)   NSMutableArray               * typesOfTags;
@property (nonatomic,strong)   VideoPlayer                  * videoPlayer;
@property (nonatomic)          float                        startTime; // is dead?
@property (nonatomic,strong)   NSMutableDictionary          * selectedTag;

@property (nonatomic,strong)   UtilitiesController          * uController;

@property (nonatomic,strong)   UIPopoverController          * popoverController;
@property (nonatomic,strong)   MFMailComposeViewController  * mailController;
@property (nonatomic,strong)   NSTimer                      * updateTableViewTimer;
@property (nonatomic,strong)   NSTimer                      * facebookShareResponseTimer; // is this dead?
@property (nonatomic,strong)   UILabel                      * progressLabel;
@property (nonatomic,strong)   UIProgressView               * progressBar;
@property (nonatomic)          int                          progressBarIndex;
@property (nonatomic,strong)   ACAccount                    * facebookAccount; // is this dead
@property (nonatomic,strong)   ACAccountStore               * _accountStore;// is this dead
@property (nonatomic)          int                          selectedCellRowsIndex;// is this dead
@property (nonatomic,strong)   NSString                     * responseDataString;// is this dead
@property (nonatomic,strong)   NSString                     * errorString;// is this dead
@property (nonatomic)          BOOL                         is_FBSharing;// is this dead
@property (nonatomic,strong)   FBSession                    * fbsession;
@property (nonatomic)          BOOL                         startUploading;// is this dead
@property (nonatomic,strong)   UITextView                   * uploadFileResponse;
@property (nonatomic,strong)   UILabel                      * uploadFileResponseLabel;
@property (nonatomic,strong)   NSMutableDictionary          * allEvents;
@property (nonatomic,strong)   CustomButton                 * teleButton;
@property (nonatomic,strong)   TeleViewController           * teleViewController;
@property (nonatomic,strong)   CustomButton                 * playbackRateBackButton;
@property (nonatomic,strong)   CustomButton                 * playbackRateForwardButton;

@property (nonatomic)          BOOL                         fullScreenMode;


//array of tags which will be save to the photos album
@property (nonatomic,strong)   NSMutableArray               * savingToAlbumArray;
////dictionary of tags which failed saving to the photos album
//@property (nonatomic,strong) NSMutableDictionary * savingToAlbumFailedDict;
//array of tags which failed saving to the photos album because not compatible
@property (nonatomic,strong)   NSMutableArray               * notCompatibleArray;
//array of tags which failed saving to the photos album because of error
@property (nonatomic,strong)   NSMutableArray               * errorSavingArray;
//total number of tags which have been selected to save to the photos album
//@property (nonatomic)int totalSavingTagsNumber;

//Swipe Edit Buttons View
@property (nonatomic,strong)   EdgeSwipeEditButtonsView     * edgeSwipeButtons;


-(void)receiveFilteredArray:(NSArray*)filteredArray;
-(void)slideFilterBox;
-(void)dismissFilterToolbox;
-(void)createAllFullScreenSubviews;
-(void)removeAllFullScreenSubviews;
/*TO DELETE seek controlls-(void)setTagEventNameLabelText:(NSString*)name;*/
-(void)showFullScreenOverlayButtons;
-(void)hideFullScreenOverlayButtons;
-(void)showTeleButton;
-(void)reorderTableView:(JPReorderTableView*)jpTable accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath;
@end
