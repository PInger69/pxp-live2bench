//
//  ListViewController.h
//  Live2BenchNative
//
//  Created by dev on 13-02-13.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CustomTabViewController.h"
#import "FilterToolboxViewController.h"
#import "ListViewCell.h"
#import "Live2BenchViewController.h"
#import "UtilitiesController.h"
//#import "Globals.h"
#import "TeleViewController.h"
#import "UIFont+Default.h"
#import "BorderButton.h"
#import "EdgeSwipeEditButtonsView.h"
#import "VideoPlayer.h"


@class FilterToolboxViewController;
@class TeleViewController, ExportPlayersPopoverController;

@interface ListViewController : CustomTabViewController<UITableViewDelegate, UITableViewDataSource,UITextViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,UIGestureRecognizerDelegate, EdgeSwipeButtonDelegate, UIPopoverControllerDelegate>{
    BOOL fullScreenMode;
    int cellCounter;            //number of cells created in list view
    int coachPickMode;          //if it is a coach pick tag, this value is equal to 1; else is 0
    int cellSelectedNumber;     //number of list view cell has been selected (0 or 1), used for enabling the comment box
//    Globals                     *globals;
    NSString                    *userId;                             // user's hid
    NSString                    *tagId;                              //tag's id
    NSFileManager               *fileManager;
    NSIndexPath                 *wasPlayingIndexPath;                //the index path of the cell which was just selected
    NSMutableData               *_responseData;                      //data received from the server when try to download a tag
    NSMutableArray              *allTags;                            //array of all the tags from current event
    NSMutableArray              *typesOfTags;
    NSDictionary                *currentPlayingTag;                  //dictionary of current playing tag
    NSMutableDictionary         *selectedTag;                        //the tag currently selected playing
    NSMutableDictionary         *newTagInfoDict;                     //dictionary for new generated bookmark tag
    NSMutableDictionary         *downloadingTagsDict;                //array of tags which have selected to download
    UtilitiesController         *uController;
    UILabel                     *tagEventName;                       //UILabel for the name of the current playing tag
    UILabel                     *tagEventNameFullScreen;             //lable for current playing tag's name in fullscreen
    UIPopoverController         * _popover;
    AVAssetExportSession        *exportSession;                      //export session used for downloading tags in offline mode
    UITableView                 *myTableView;
    UIView                      *filterContainer;                    //UIView used for positioning filter view
    UIView                      *videoControlBar;                    //UIView for all the video control buttons
    FilterToolboxViewController *filterToolBoxListViewController;
    CustomButton                *slowMoButton;                       //slow mode button which controls the speed of the video player
    CustomButton                *teleButton;                         //telestration button
    CustomButton                *startRangeModifierButton;           //duration extension button which adding 5 secs at the beginning of the tag
    CustomButton                *endRangeModifierButton;             //duration extension button which adding 5 secs at the end of the tag
    CustomButton                *startRangeModifierButtonFullScreen; //duration extension button in fullscreen
    CustomButton                *endRangeModifierButtonFullScreen;   //duration extension button in fullscreen
    CustomButton                *slowMoButtonFullScreen;             //slow mode button in fullscreen
}

@property (nonatomic)        BOOL                        isEditingMode;
@property (nonatomic)        BOOL                        isTagModRequest; //to check whether request is tagmod or download video request
@property (nonatomic)        int                         coachPickMode;
@property (nonatomic)        BOOL                        fullScreenMode;
@property (nonatomic,strong) id                          loopTagObserver;//time observer for looping tag
@property (nonatomic,strong) UITableView                 * myTableView;
@property (nonatomic,strong) NSMutableArray              * tagsToDisplay; //array of tags which used for create table view's cells
@property (nonatomic,strong) NSMutableArray              * allTags;
@property (nonatomic,strong) NSMutableArray              * typesOfTags;
@property (nonatomic,strong) VideoPlayer                 * videoPlayer;
@property (nonatomic,strong) FilterToolboxViewController * filterToolBoxListViewController;
@property (nonatomic,strong) NSMutableDictionary         * selectedTag;
@property (nonatomic,strong) UIView                      * videoControlBar;
@property (nonatomic,strong) UtilitiesController         * uController;
@property (nonatomic,strong) UILabel                     * tagEventName;
@property (nonatomic,strong) UILabel                     * tagEventNameFullScreen;
@property (nonatomic,strong) BorderButton                * playNextTagFullScreen; //button used to play the next tag in the list view
@property (nonatomic,strong) BorderButton                * playPreTagFullScreen; //button used to play the previous tag in the list view
@property (nonatomic,strong) DownloadButton              * downloadTagFullScreen; //download tag button in fullscreen
@property (nonatomic,strong) NSMutableDictionary         * selectedCellRows; //dictionary of all the information of the cells which have been viewed
@property (nonatomic,strong) CustomButton                * startRangeModifierButton;
@property (nonatomic,strong) CustomButton                * endRangeModifierButton;
@property (nonatomic,strong) NSMutableArray              * receivedTagArr; //Array of tags'id which have been downloaded to Myclip view
@property (nonatomic,strong) UIButton                    * selectAllButton; //button used to select all the tags in listview
@property (nonatomic,strong) NSMutableDictionary         * downloadingTagsDict;
@property (nonatomic,strong) CustomButton                * teleButton;
@property (nonatomic,strong) TeleViewController          * teleViewController;
@property (nonatomic,strong) NSMutableArray              * downloadedTagIds; //array of tags'id and these tags' image has been downloaded from the server
@property (nonatomic,strong) NSMutableArray              * thumbRatingArray; //Array of uiviews in each thumbnail to show the rating of the tag
@property (nonatomic,strong) CustomButton                * playbackRateBackButton;
@property (nonatomic,strong) CustomButton                * playbackRateForwardButton;
@property (nonatomic,strong) CustomButton                * currentSeekBackButton; //button used to control the video seeks back 5secs/1sec/0.25s
@property (nonatomic,strong) CustomButton                * currentSeekForwardButton; //button used to control the video seeks forward 5secs/1sec/0.25s
@property (nonatomic,strong) CustomButton                * currentSeekBackButtoninFullScreen;
@property (nonatomic,strong) CustomButton                * currentSeekForwardButtoninFullScreen;
@property (nonatomic,strong) UIView                      * seekBackControlView; //uiview which contains three buttons for controlling the video seeks back 5secs/1sec/0.25s
@property (nonatomic,strong) UIView                      * seekForwardControlView; //uiview which contains three buttons for controlling the video seeks forward 5secs/1sec/0.25s
@property (nonatomic,strong) UIView                      * seekBackControlViewinFullScreen;
@property (nonatomic,strong) UIView                      * seekForwardControlViewinFullScreen;
@property (nonatomic,strong) EdgeSwipeEditButtonsView    * edgeSwipeButtons;
@property (nonatomic,strong) UIView                      * blurView;
@property (nonatomic,strong) UIScrollView                * breadCrumbsView; //scrollview used to show which filter elements are selected currently
@property (nonatomic,strong) NSMutableArray              * aCopyOfUnfinishedTags;
@property (nonatomic,strong) UIAlertView                 * noVideoURLAlert; //In bookmark tagmodcall method, if no video url is get from server, will pop up this msg
@property (nonatomic,strong) NSMutableArray              * failedBookmarkTagsArr;//Array of bookmark tags which failed when downloading videos
@property (nonatomic,strong) BorderButton                * saveTeleButton;//save button for telestration
@property (nonatomic,strong) BorderButton                * clearTeleButton;//clear button for telestration

-(void)slideFilterBox; //swipe to slide out/in the filter view
-(void)showFullScreenOverlayButtonsinLoopMode; //set all the fullscreen overlay buttons visible in loop mode
-(void)showFullScreenOverlayButtons;//set all the fullscreen overlay buttons visible
-(void)showTeleButton; //show the tele button in fullscreen






@end
