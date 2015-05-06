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
#import "ListViewCell.h"
#import "Live2BenchViewController.h"
#import "TeleViewController.h"
#import "UIFont+Default.h"
#import "BorderButton.h"
#import "ImageAssetManager.h"
#import "ListTableViewController.h"
#import "PxpVideoPlayerProtocol.h"
#import "TestFilterViewController.h"
#import "Tag.h"

@class TeleViewController, ExportPlayersPopoverController;

@interface ListViewController : CustomTabViewController<UITextViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,UIGestureRecognizerDelegate, UIPopoverControllerDelegate>{
    BOOL fullScreenMode;
    int cellCounter;            //number of cells created in list view
    int coachPickMode;          //if it is a coach pick tag, this value is equal to 1; else is 0
    int cellSelectedNumber;     //number of list view cell has been selected (0 or 1), used for enabling the comment box
    NSString                    *tagId;                              //tag's id
    NSIndexPath                 *wasPlayingIndexPath;                //the index path of the cell which was just selected
    NSMutableData               *_responseData;                      //data received from the server when try to download a tag
    NSMutableArray              *typesOfTags;
    NSDictionary                *currentPlayingTag;                  //dictionary of current playing tag
    Tag                         *selectedTag;                        //the tag currently selected playing
    UILabel                     *tagEventName;                       //UILabel for the name of the current playing tag
    UILabel                     *tagEventNameFullScreen;             //lable for current playing tag's name in fullscreen
    UIPopoverController         * _popover;
    ListTableViewController     *_tableViewController;
    UIView                      *filterContainer;                    //UIView used for positioning filter view
    CustomButton                *startRangeModifierButton;           //duration extension button which adding 5 secs at the beginning of the tag
    CustomButton                *endRangeModifierButton;             //duration extension button which adding 5 secs at the end of the tag
    CustomButton                *startRangeModifierButtonFullScreen; //duration extension button in fullscreen
    CustomButton                *endRangeModifierButtonFullScreen;   //duration extension button in fullscreen
    CustomButton                *slowMoButtonFullScreen;             //slow mode button in fullscreen
}


@property (nonatomic,strong) NSMutableArray              * tagsToDisplay; //array of tags which used for create table view's cells
@property (nonatomic,strong) NSMutableArray              * allTags;
@property (nonatomic,strong) UIViewController <PxpVideoPlayerProtocol>    * videoPlayer;
@property (nonatomic,strong) NSDictionary                * feeds;

@property (nonatomic,strong) NSMutableDictionary         * selectedCellRows; //dictionary of all the information of the cells which have been viewed
@property (nonatomic,strong) CustomButton                * teleButton;
//@property (nonatomic,strong) TeleViewController          * teleViewController;
@property (nonatomic,strong) CustomButton                * playbackRateBackButton;

@property (nonatomic,strong) CustomButton                * currentSeekBackButton; //button used to control the video seeks back 5secs/1sec/0.25s
@property (nonatomic,strong) CustomButton                * currentSeekForwardButton; //button used to control the video seeks forward 5secs/1sec/0.25s
@property (nonatomic,strong) CustomButton                * currentSeekBackButtoninFullScreen;
@property (nonatomic,strong) CustomButton                * currentSeekForwardButtoninFullScreen;
@property (nonatomic,strong) UIView                      * seekBackControlView; //uiview which contains three buttons for controlling the video seeks back 5secs/1sec/0.25s
@property (nonatomic,strong) UIView                      * seekBackControlViewinFullScreen;
@property (nonatomic,strong) UIView                      * seekForwardControlViewinFullScreen;
@property (nonatomic,strong) UIView                      * blurView;
@property (nonatomic,strong) UIScrollView                * breadCrumbsView; //scrollview used to show which filter elements are selected currently
@property (nonatomic,strong) NSMutableArray              * aCopyOfUnfinishedTags;



-(void)slideFilterBox; //swipe to slide out/in the filter view

-(void)showTeleButton; //show the tele button in fullscreen






@end
