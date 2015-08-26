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
#import "TagMarker.h"
#import "CustomButton.h"
#import "BorderButton.h"
#import "PopoverButton.h"
#import "CustomTabBar.h"
#import "PxpVideoPlayerProtocol.h"
#import "TeleViewController.h"
#import "Event.h"



@interface Live2BenchViewController : CustomTabViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate, TeleVCProtocol>
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
    UILabel                                  * currentEventTitle;                      //displays the current playing event's name in humanreadable format
    CustomButton                             * swipedOutButton;                        //tag button which was swiped to show playercollectionviewcontroller
    BorderButton                             * continuePlayButton;                     //when reviewing a tag, press continueplaybutton to destroy loop mode and continue play the video
    UIImageView                              * telestrationOverlay;                    //displays telestration image
    UIImageView                              * leftArrow;                              //used with playercollectionviewcontroller when swiping the tag buttons in the left side of the screen
    UIImageView                              * rightArrow;                             //used with playercollectionviewcontroller when swiping the tag buttons in the right side of the screen
    UIAlertView                              * videoPlaybackFailedAlertView;           // used to alert video playback failed
    TagMarker                                * tagMarker;                              //object indicates the tag position in the total time duration
    OverlayViewController                    * _overlayLeftViewController;             //uiviewcontroller for left event buttons in fullscreen
    OverlayViewController                    * _overlayRightViewController;            //uiviewcontroller for right event buttons in fullscreen


}

@property (nonatomic,strong)    UIViewController <PxpVideoPlayerProtocol>    * videoPlayer;
@property (nonatomic,strong)    NSString                                     * currentEventName;
@property (nonatomic,strong)    Event                                        * currentEvent;
@property (nonatomic,strong)    UIAlertView
* videoPlaybackFailedAlertView;


//@property (nonatomic, strong)   TagMarker                                    * currentPlayingTagMarker;
//@property (nonatomic,strong)    TagMarker                                    * tagMarker;


@end
