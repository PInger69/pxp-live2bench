//
//  PipViewController.h
//  Live2BenchNative
//
//  Created by dev on 10/29/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Pip.h"
#import "FeedSwitchView.h"
#import "VideoPlayer.h"
#import "EncoderManager.h"

@interface PipViewController : UIViewController


@property (nonatomic,strong) FeedSwitchView * feedSwitchView;
@property (nonatomic,strong) Pip            * selectPip;
@property (nonatomic,strong) VideoPlayer    * videoPlayer;
@property (nonatomic,strong) NSMutableArray * pips;// for when you have more then one pip


-(id)initWithVideoPlayer:(VideoPlayer *)aVideoPlayer f:(FeedSwitchView *)f encoderManager:(EncoderManager*)encoderManager;
//-(id)initWithPip:(Pip *)aMainPip pip:(Pip*)aPip f:(FeedSwitchView *)f;
-(void)addPip:(Pip*)aPip;
-(void)removePip:(Pip *)aPip;
-(void)swapVideoPlayer:(VideoPlayer*)aVideoPlayer withPip:(Pip*)aPip;
-(void)syncToPlayer;
-(void)pipsAndVideoPlayerToLive;
@end
