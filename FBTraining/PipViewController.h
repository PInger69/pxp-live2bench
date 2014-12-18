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

@interface PipViewController : UIViewController


@property (nonatomic,strong) FeedSwitchView * feedSwitchView;
@property (nonatomic,strong) Pip            * selectPip;
@property (nonatomic,strong) VideoPlayer    * videoPlayer;
@property (nonatomic,strong) NSMutableArray * pips;// for when you have more then one pip

//-(id)initWithVideoPlayer:(Pip *)videoPlayer;
-(id)initWithVideoPlayer:(VideoPlayer *)aVideoPlayer pip:(Pip*)aPip f:(FeedSwitchView *)f;
//-(id)initWithPip:(Pip *)aMainPip pip:(Pip*)aPip f:(FeedSwitchView *)f;
-(void)addPip:(Pip*)aPip;
-(void)removePip:(Pip *)aPip;
-(void)swapVideoPlayer:(VideoPlayer*)aVideoPlayer withPip:(Pip*)aPip;

@end
