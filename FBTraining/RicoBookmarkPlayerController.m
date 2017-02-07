//
//  RicoBookmarkPlayerController.m
//  Live2BenchNative
//
//  Created by dev on 2016-05-17.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "RicoBookmarkPlayerController.h"

@interface RicoBookmarkPlayerController ()
@property (strong, nonatomic) NSArray                    * players;
@property (strong, nonatomic) RicoPlayer                  * ricoPlayer1;
@property (strong, nonatomic) RicoPlayer                  * ricoPlayer2;
@property (strong, nonatomic) RicoPlayer                  * ricoPlayer3;
@property (strong, nonatomic) RicoPlayer                  * ricoPlayer4;
//@property (strong, nonatomic) RicoPlayerControlBar        * ricoPlayerControlBar;

@property (strong, nonatomic) RicoZoomContainer           * ricoZoomer;
@property (strong, nonatomic) RicoFullScreenControlBar    * ricoFullScreenControlBar;
@property (strong, nonatomic, nonnull) RicoPlayerGroupContainer         * ricoGroup;

@property (strong, nonatomic) UITapGestureRecognizer     * doubleTapOnGrid;

@end



@implementation RicoBookmarkPlayerController

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.players = @[
                         [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)],
                         [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)],
                         [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)],
                         [[RicoPlayer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]
                         ];
        
                // this controlls the bar
        self.ricoPlayerController               = [RicoPlayerViewController new];
        
        
        // zoooming ability
        self.ricoZoomer = [[RicoZoomContainer alloc]initWithFrame:frame];
        

        // Build Quad player
        self.ricoGroup              = [[RicoPlayerGroupContainer alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        [self.ricoGroup setBackgroundColor:[UIColor grayColor]];
        
        
        
        
        
        [self.ricoZoomer addToContainer:self.ricoGroup];
        
        _fullscreenViewController               = [[RicoBaseFullScreenViewController alloc] initWithView:self.ricoZoomer];
        
        
        _ricoFullScreenControlBar               = [[RicoFullScreenControlBar alloc]init];
        [_fullscreenViewController.bottomBar addSubview:_ricoFullScreenControlBar];
        
        self.ricoPlayerController = [RicoPlayerViewController new];
        
        for (RicoPlayer * p in self.players) {
            p.looping = YES;
            [self.ricoGroup addSubview:p];
            [self.ricoPlayerController addPlayers:p];
            [p.debugOutput removeFromSuperview];
            [p.streamStatus removeFromSuperview];
            
        }
        
//        self.ricoGroup.gridMode = YES;
        self.doubleTapOnGrid = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapOnQuad:)];
        self.doubleTapOnGrid.numberOfTapsRequired = 2;
        [self.ricoGroup addGestureRecognizer:self.doubleTapOnGrid];
    }
    return self;
}


-(void)playClip:(Clip *)clip
{

    for (RicoPlayer * p in self.players) {
        p.reliable = NO;
        p.feed = nil;
    }
    
    
    for (RicoPlayer * p in self.players) {
        p.hidden = YES;
        [p.streamStatus removeFromSuperview];
        [p.debugOutput removeFromSuperview];
        
    }

    NSMutableDictionary* videos = [NSMutableDictionary new];
    NSArray* clipSources = clip.clipSources;
    for (NSInteger i = 0; i < clipSources.count; i++) {
        PxpClipSource* clipSource = clipSources[i];
        if (clipSource.videoFileExists) {
            [videos setObject:clipSource.url forKey:clipSource.source];

            Feed* feed = [[Feed alloc] initWithFileURL:clipSource.path];
            
            RicoPlayer * p = self.players[i];
            [p loadFeed:feed];
            p.hidden = NO;
            p.reliable = YES;
            [p.streamStatus removeFromSuperview];
            [p.debugOutput removeFromSuperview];
        }
    }
    
    if (videos.count > 0) {
        [self.ricoPlayerController play];
        self.ricoGroup.gridMode = (videos.allKeys.count >1);
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:BOOKMARK_PLAYER_CONTROLLER_CHANGE object:self];
}


-(void)onTapOnQuad:(id)sender
{

    UITapGestureRecognizer * gest = sender;
    
    RicoPlayerGroupContainer * group =  (RicoPlayerGroupContainer *) gest.view;
    
    
    
    if (group.gridMode) {
        
        CGPoint loc = [gest locationInView:group];
        UIView* subview = [group hitTest:loc withEvent:nil];
        
        for (RicoPlayer * p in self.players) {
            p.hidden = YES;
        }
        
        if ([subview isKindOfClass:[RicoPlayer class]]) {
            RicoPlayer * aPlayer = (RicoPlayer *)subview;
            group.gridMode = NO;
            aPlayer.hidden = NO;
        }
        
    } else {
        
        group.gridMode = YES;
    }
}


-(UIView*)view
{
    return self.ricoZoomer;

}

-(void)clear
{
    for (RicoPlayer * p in self.players) {
        [p pause];
        p.hidden = YES;
    }

}

@end
