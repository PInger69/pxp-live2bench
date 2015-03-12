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
#import "MultiPip.h"
#import "EncoderManager.h"
#import "PxpVideoPlayerProtocol.h"

@interface PipViewController : UIViewController


@property (nonatomic,strong) FeedSwitchView                 * feedSwitchView;
@property (nonatomic,strong) Pip                            * selectPip;
@property (nonatomic,strong) UIViewController <PxpVideoPlayerProtocol>*    videoPlayer;
@property (nonatomic,strong) NSMutableArray                 * pips;// for when you have more then one pip
@property (nonatomic,strong) NSString                       * context;
@property (nonatomic,strong) MultiPip                       * multi;


-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)aVideoPlayer f:(FeedSwitchView *)f encoderManager:(EncoderManager*)encoderManager;
//-(id)initWithPip:(Pip *)aMainPip pip:(Pip*)aPip f:(FeedSwitchView *)f;
-(void)addPip:(Pip*)aPip;
-(void)removePip:(Pip *)aPip;
-(void)swapVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)aVideoPlayer withPip:(Pip*)aPip;
-(void)syncToPlayer;
-(void)pipsAndVideoPlayerToLive;
@end
