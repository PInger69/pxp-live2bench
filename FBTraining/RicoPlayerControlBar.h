//
//  RicoPlayerControlBar.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-02.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PxpPlayerControlSlider.h"
#import "PxpPlayerLight.h"
#import "PxpPlayPauseButton.h"
#import "PxpCancelButton.h"

typedef NS_ENUM (NSInteger, RicoPlayerState){
    RicoPlayerStateLive,           // Live means that the bar will not update the position of the head and endtime is fixed to live
    RicoPlayerStateNormal,         // The bar will update normally
    RicoPlayerStateRange,// The player will be Primarty color with cancel button
    RicoPlayerStateTelestrationStill,
    RicoPlayerStateTelestrationAnimated,
    RicoPlayerStateDisabled        // bar will not respond and will look inactive
};





@class RicoPlayerControlBar;

@protocol RicoPlayerControlBarDelegate <NSObject>

-(void)startScrubbing:(UISlider *)slider;
-(void)updateScrubbing:(UISlider *)slider;
-(void)finishScrubbing:(UISlider *)slider;

-(void)cancelPressed:(RicoPlayerControlBar*)playerControlBar;
-(void)playPausePressed:(RicoPlayerControlBar*)playerControlBar didChangeToPaused:(BOOL)paused;

@end





@interface RicoPlayerControlBar : UIView

@property (nonatomic,weak) id<RicoPlayerControlBarDelegate> delegate;
@property (readonly, strong, nonatomic, nonnull) PxpPlayPauseButton *playPauseButton;
@property (assign, nonatomic) RicoPlayerState state;
@property (strong, nonatomic, nonnull) PxpPlayerControlSlider *slider;
@property (assign, nonatomic) BOOL enabled;
@property (assign, nonatomic) BOOL scrubbing;
@property (assign, nonatomic) BOOL gestureEnabled;
@property (assign, nonatomic) BOOL delegateUpdateEnabled;




@property (assign, nonatomic) CMTimeRange range;

- (void)update:(CMTime)time duration:(CMTime)duration;


// This use to zero out the side times and puts the bar in a no controlled state
-(void)clear;

@end
