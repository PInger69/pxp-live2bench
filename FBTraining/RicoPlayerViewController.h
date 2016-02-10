//
//  RicoPlayerViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-11-26.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RicoPlayer.h"
#import "RicoPlayerControlBar.h"
#import "Tag.h"

@interface RicoPlayerViewController : UIViewController <RicoPlayerControlBarDelegate, RicoPlayerObserverDelegate>

@property (nonatomic, strong) NSOperationQueue      * operationQueue;
@property (nonatomic, strong) NSMutableDictionary   * players;
@property (nonatomic, strong) RicoPlayer            * primaryPlayers;
@property (nonatomic, strong) RicoPlayerControlBar  * playerControlBar;
@property (nonatomic, assign) BOOL                  syncronizePlayers;
@property (nonatomic, assign) BOOL                  slomo;
@property (nonatomic, assign) CGRect                frame;

-(void)addPlayers:(RicoPlayer *)aPlayer;
-(void)removePlayers:(RicoPlayer *)aPlayer;

-(void)play;
-(void)playAtStartWhenReady;
-(void)playTag:(Tag*)tag;
-(void)live;
-(void)seekToTime:(CMTime)seekTime toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void(^)(BOOL finished))completionHandler;
-(void)stepByCount:(NSInteger)stepCount;


-(void)cancelPressed:(RicoPlayerControlBar *)playerControlBar;

@end
