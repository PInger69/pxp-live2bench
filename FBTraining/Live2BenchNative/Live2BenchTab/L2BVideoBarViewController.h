//
//  L2BVideoBarViewController.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-16.
//  Copyright (c) 2014 DEV. All rights reserved.
//


#define L2B_VIDEO_BAR_MODE_DISABLE  0
#define L2B_VIDEO_BAR_MODE_LIVE     1
#define L2B_VIDEO_BAR_MODE_CLIP     2


#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "Slomo.h"
#import "SeekButton.h"
#import "VideoBarContainerView.h"
#import "TagFlagViewController.h"
#import "CustomButton.h"

@interface L2BVideoBarViewController : UIViewController
{
    VideoBarContainerView   * container;
    UIView                  * background;
    UILabel                 * tagLabel;
    Slomo                   * slomoButton;
    SeekButton              * forwardButton;
    SeekButton              * backwardButton;
    VideoPlayer             * videoPlayer;
    NSArray                 * activeElements;
//    TagFlagViewController   * _tagMarkerController;         // what displays the tag notches in the bar
}

@property (nonatomic,assign) int    barMode;

@property (nonatomic,strong) CustomButton * startRangeModifierButton;
@property (nonatomic,strong) CustomButton * endRangeModifierButton;
@property (nonatomic,strong) TagFlagViewController * tagMarkerController;


-(id)initWithVideoPlayer:(VideoPlayer *)vidPlayer;

-(void)setTagName:(NSString*)name;

-(void)createTagMarkers;

-(void)update;

@end
