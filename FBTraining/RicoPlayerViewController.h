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

@interface RicoPlayerViewController : UIViewController <RicoPlayerControlBarDelegate, RicoPlayerObserverDelegate>

@property (nonatomic, strong) NSOperationQueue      * operationQueue;
@property (nonatomic, strong) NSMutableDictionary   * players;

@property (nonatomic, strong) RicoPlayerControlBar   * playerControlBar;
@property (nonatomic, assign) BOOL                  syncronizePlayers;

-(void)addPlayers:(RicoPlayer *)aPlayer;
-(void)removePlayers:(RicoPlayer *)aPlayer;

-(void)play;
-(void)stepByCount:(NSInteger)stepCount;

@end
