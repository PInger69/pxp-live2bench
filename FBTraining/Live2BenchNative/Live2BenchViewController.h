//
//  Live2BenchViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomTabViewController.h"
#import "OverlayViewController.h"
#import "HockeyBottomViewController.h"
#import "TagMarker.h"
#import "TeleViewController.h"
#import "UtilitiesController.h"
#import "Globals.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ListViewController.h"
#import "SoccerBottomViewController.h"
#import "PlayerCollectionViewController.h"
#import "FootballTrainingCollectionViewController.h"
#import "WBImage.h"
#import "SettingsViewController.h"
#import "SpinnerView.h"
#import "CustomButton.h"
#import "BorderButton.h"
#import "PopoverButton.h"
#import "VideoPlayer.h" 
#import "FootballBottomViewController.h"
#import "FootballTrainingBottomViewController.h"
#import "CustomTabBar.h"
#import "TTSwitch.h"

@class TeleViewController;


//@class AppQueue;
@class UtilitiesController;
@class HockeyBottomViewController;
@class ListViewController;
@class SoccerBottomViewController;
@class PlayerCollectionViewController;
@class SettingsViewController;
@class FootballBottomViewController;
@class FootballTrainingBottomViewController;


@interface Live2BenchViewController : CustomTabViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    NSString                                 * tagTimeWhenSwipe;                       //string of time when the tag button is swiped
    NSString                                 * _currentEventName;                      //string of current playing tag name
    NSString                                 * userId;                                 //current account's "hid"
    NSTimer                                  * updateCurrentEventInfoTimer;            //timer for controling method updateCurrentEventInfo
    NSMutableSet                             * tagTimesColoured;                       //array of tag times; used for tagmarker's position
    NSMutableDictionary                      * accountInfo;                            //current logged in user's account information
    NSMutableArray                           * _overlayItems;                          //array of subviews(buttons and label) created for fullscreen display
    NSMutableArray                           * _tagNames;                              //array of dictionaries of tag event names, which is used for creating event tag buttons
    NSDictionary                             * currentPlayingTag;                      //dictionary of the current reviewing tag
    UIView                                   * _currentPlayingEventMarker;             //small orange triangle indicates the position of current playing tag
    
//    UILabel                                  * tagEventNameinFullScreen;               //displays the string of current playing tag name in fullscreen
    UILabel                                  * currentEventTitle;                      //displays the current playing event's name in humanreadable format
    
    CustomButton                             * teleButton;                             //click it to show telestration view controller's view
    CustomButton                             * startRangeModifierButton;               //extends duration button (old start time - 5)
    CustomButton                             * endRangeModifierButton;                 //extends duration button (old end time + 5)
    CustomButton                             * startRangeModifierButtoninFullScreen;   //extends duration button in fullscreen (old start time - 5)
    CustomButton                             * endRangeModifierButtoninFullScreen;     //extends duration button in fullscreen (old end time + 5)
//    CustomButton                             * slowMoButtoninFullScreen;               //slow motion control button in fullscreen
    CustomButton                             * swipedOutButton;                        //tag button which was swiped to show playercollectionviewcontroller
//    CustomButton                             * liveButtoninFullScreen;                 //go to live button in fullscreen
//    CustomButton                             * currentSeekBackButtoninFullScreen;      //seek back five secs button in fullscreen
//    CustomButton                             * currentSeekForwardButtoninFullScreen;   //seek forward five secs button in fullscreen
//    CustomButton                             * goBackFiveSecondsButtoninFullScreen;    //seek back five secs button in fullscreen
//    CustomButton                             * goForwardFiveSecondsButtoninFullScreen; //seek forward five secs button in fullscreen
    BorderButton                             * continuePlayButton;                     //when reviewing a tag, press continueplaybutton to destroy loop mode and continue play the video
//    BorderButton                             * continuePlayButtoninFullScreen;         //continue button in fullscreen
    UIImageView                              * telestrationOverlay;                    //displays telestration image
    UIImageView                              * leftArrow;                              //used with playercollectionviewcontroller when swiping the tag buttons in the left side of the screen
    UIImageView                              * rightArrow;                             //used with playercollectionviewcontroller when swiping the tag buttons in the right side of the screen
    UIImageView                              * recordButton;                           //red flickering button indicates there is live event playing
    UIAlertView                              * videoPlaybackFailedAlertView;           // used to alert video playback failed
    TagMarker                                * tagMarker;                              //object indicates the tag position in the total time duration
    OverlayViewController                    * _overlayLeftViewController;             //uiviewcontroller for left event buttons in fullscreen
    OverlayViewController                    * _overlayRightViewController;            //uiviewcontroller for right event buttons in fullscreen
    ListViewController                       * listViewController;
    PlayerCollectionViewController           * playerCollectionViewController;         //it will show up when swiping tag button;Its view contains all the player buttons
    UtilitiesController                      * uController;
    TeleViewController                       * _teleViewController;
    HockeyBottomViewController               * _bottomViewController;                  //hockey bottomviewcontroller
    SoccerBottomViewController               * _soccerBottomViewController;            //soccer bottomviewcontroller
    FootballBottomViewController             * footballBottomViewController;           //football bottomviewcontroller
    FootballTrainingBottomViewController     * footballTrainingBottomViewController;

}


@property (nonatomic)           BOOL                                         fullscreenOverlayCreated;      //indicates have created all fullscreen control buttons or not
@property (nonatomic)           BOOL                                         didInitLayout;                 //indicates all the uiviews in live2bench view have initilized or not
@property (nonatomic)           BOOL                                         switchToLiveEvent;             //indicated wether the user switch to live event or not; if it is true, update tagmarkers
@property (nonatomic)           BOOL                                         enterFullScreen;
@property (nonatomic)           BOOL                                         isDurationTagEnabled;          //Boolean value indicates "duration tag" is enabled or not
@property (nonatomic)           double                                       currentPlayBackTime;           //double value of current play back time
@property (nonatomic)           int                                          poorSignalCounter;             //if poorSignalCounter > 10, pop up videoPlaybackFailedAlertView
@property (nonatomic)           int                                          updateTagmarkerCounter;
@property (nonatomic)           int                                          spinnerViewCounter;            //if video is not playing properly, show spinner view. But if spinnerViewCounter > 10, remove spinner view
@property (nonatomic, strong)   id                                           loopTagObserver;               //time observer for looping tag
@property (nonatomic,strong)    NSString                                     * currentEventName;
@property (nonatomic,strong)    NSMutableDictionary                          * accountInfo;
@property (nonatomic,strong)    NSMutableArray                               * tagNames;
@property (nonatomic,strong)    NSMutableArray                               * overlayItems;
@property (nonatomic,strong)    NSMutableDictionary                          * tagMarkerLeadObjDict;         //Dictionary of all the displayed tagmarkers(which are all those lead tag markers)in the tagsetview
@property (nonatomic, strong)   NSMutableArray                               * openedDurationTagButtons;     //when "duration tag" is enabled, array of buttons which have been selected but not closed yet
//@property (nonatomic,strong)    UIView                                       * seekBackControlView;
//@property (nonatomic,strong)    UIView                                       * seekForwardControlView;
//@property (nonatomic,strong)    UIView                                       * seekBackControlViewinFullScreen;
//@property (nonatomic,strong)    UIView                                       * seekForwardControlViewinFullScreen;
@property (nonatomic,strong)    UIAlertView                                  * videoPlaybackFailedAlertView;
@property (nonatomic, strong)   UILabel                                      * durationTagLabel;             //label for "duration tag"
@property (nonatomic,strong)    UILabel                                      * playerEncoderStatusLabel;     //current player and enoder status
@property (nonatomic,strong)    UIView                                       * currentPlayingEventMarker;
@property (nonatomic,strong)    UIView                                       * rightSideButtons;
@property (nonatomic,strong)    UIView                                       * leftSideButtons;
@property (nonatomic,strong)    UILabel                                      * timeLabel;                    //for testing tele accuracy
@property (nonatomic,strong)    UILabel                                      * timeLabelLoopMode;            //for testing tele accuracy
@property (nonatomic,strong)    CustomButton                                 * teleButton;
@property (nonatomic, strong)   CustomButton                                 * swipedOutButton;
@property (nonatomic,strong)    CustomButton                                 * playbackRateBackButton;
@property (nonatomic,strong)    CustomButton                                 * playbackRateForwardButton;
//@property (nonatomic,strong)    CustomButton                                 * currentSeekBackButton;
//@property (nonatomic,strong)    CustomButton                                 * currentSeekForwardButton;
@property (nonatomic,strong)    CustomButton                                 * startRangeModifierButton;
@property (nonatomic,strong)    CustomButton                                 * endRangeModifierButton;
@property (nonatomic,strong)    CustomButton                                 * continuePlayButton;
@property (nonatomic,strong)    BorderButton                                 * saveTeleButton;               //save button for telestration
@property (nonatomic,strong)    BorderButton                                 * clearTeleButton;              //clear button for telestration
@property (nonatomic,strong)    SpinnerView                                  * spinnerView;
@property (nonatomic,strong)    VideoPlayer                                  * videoPlayer;

@property (nonatomic, strong)   TagMarker                                    * currentPlayingTagMarker;
@property (nonatomic,strong)    TagMarker                                    * tagMarker;

@property (nonatomic, strong)   TTSwitch                                     * durationTagSwitch;            //uiswitch for enabling duration tag or not
@property (nonatomic,strong)    TeleViewController                           * teleViewController;
@property (nonatomic,strong)    HockeyBottomViewController                   * hockeyBottomViewController;
@property (nonatomic,strong)    OverlayViewController                        * overlayRightViewController;
@property (nonatomic,strong)    OverlayViewController                        * overlayLeftViewController;
@property (nonatomic,strong)    SoccerBottomViewController                   * soccerBottomViewController;
@property (nonatomic,strong)    PlayerCollectionViewController               * playerCollectionViewController;
@property (nonatomic,strong)    FootballTrainingCollectionViewController     * footballTrainingCollectionViewController;
@property (nonatomic,strong)    FootballBottomViewController                 * footballBottomViewController;
@property (nonatomic,strong)    FootballTrainingBottomViewController         * footballTrainingBottomViewController;


-(id)init;                                      //init function

-(void)destroyThumbLoop;                        //stop looping the tag, continue play at the current time or at live time

-(void)populateTagNames;                        //get tag events names

-(void)createTagButtons;                        //create tag buttons according to the tag events names

-(void)showTeleButton;                          //create telestration button

-(TagMarker*)markTagAtTime:(float)time colour:(UIColor*)color tagID:(NSString*)tagID;

-(void)setCurrentPlayingTag:(NSDictionary*)tag; //playing the thumbnail tag which is selected in clip view

-(NSString *)getCurrentTimeforNewTag;           //return string with the time when a new event is tagged

-(void)createFullScreenOverlayButtons;          //create fullscreen buttons

-(void)hideFullScreenOverlayButtons;            //hide fullscreen buttons in loop mode

-(void)showFullScreenOverlayButtons;            //display fullscreen buttons in loop mode

-(void)deSelectTagButton;                       //duration tag for soccer game, events tag buttons and player tag buttons are in seperated view controllers; When making duration tag in bottom view, need to deselected any event button which is highlighted
@end
