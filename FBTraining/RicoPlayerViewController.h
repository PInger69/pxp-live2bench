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
#import "BottomViewTimeProviderDelegate.h"
#import "RicoPlayerControlProtocol.h"


@interface RicoPlayerViewController : UIViewController <RicoPlayerControlBarDelegate, RicoPlayerObserverDelegate,BottomViewTimeProviderDelegate,RicoPlayerControlProtocol>

@property (nonatomic, strong) NSOperationQueue      * operationQueue;
@property (nonatomic, strong) NSMutableDictionary   * players;
@property (nonatomic, strong) RicoPlayer            * primaryPlayer;
@property (nonatomic, strong) RicoPlayerControlBar  * playerControlBar;
@property (nonatomic, assign) BOOL                  syncronizePlayers;
@property (nonatomic, assign) BOOL                  slomo;
@property (nonatomic, assign) CGRect                frame;
@property (nonatomic, assign) BOOL                  isPlaying;
@property (nonatomic, strong) UITextView           * debugOutput;

@property (nonatomic, strong) NSMutableSet * depedencyPlayers; // all players in this list depend on each other
@property (nonatomic, strong) NSOperation * syncBlock;

-(void)addPlayers:(RicoPlayer *)aPlayer;
-(void)removePlayers:(RicoPlayer *)aPlayer;

-(void)play;//
-(void)pause;//
-(void)playAtStartWhenReady;//
-(void)playTag:(Tag*)tag;//
-(void)live;//
-(void)seekToTime:(CMTime)seekTime toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void(^)(BOOL finished))completionHandler;//

-(void)stepByCount:(NSInteger)stepCount;//

-(CMTime)currentTimeFromSourceName:(NSString*)feedName;//

-(void)cancelPressed:(RicoPlayerControlBar *)playerControlBar;//
-(void)setPrimaryPlayerByFeedName:(NSString*)feedName;


@end
