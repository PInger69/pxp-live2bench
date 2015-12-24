//
//  PxpL2BFullscreenViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpL2BFullscreenViewController.h"
#import "Clip.h"
#import "LocalMediaManager.h"
#import "EncoderManager.h"

@interface PxpL2BFullscreenViewController ()

@end

@implementation PxpL2BFullscreenViewController

- (nonnull instancetype)initWithPlayerViewController:(nonnull PxpPlayerViewController *)playerViewController {
    self = [super initWithPlayerViewController:playerViewController];
    if (self) {
        _liveButton                 = [[LiveButton alloc] init];
        _startRangeModifierButton   = [[PxpRangeModifierButton alloc] initWithEnd:NO];
        _endRangeModifierButton     = [[PxpRangeModifierButton alloc] initWithEnd:YES];
        _currentTagLabel            = [[PxpBorderLabel alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.bottomBar addSubview:_liveButton];
    
   [_liveButton addTarget:self action:@selector(liveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _liveButton.enabled = NO;
    
    
    _startRangeModifierButton   = [[PxpRangeModifierButton alloc] initWithEnd:NO];
    _endRangeModifierButton     = [[PxpRangeModifierButton alloc] initWithEnd:YES];
    _currentTagLabel            = [[PxpBorderLabel alloc] init];
    
    [self.bottomBar addSubview:_startRangeModifierButton];
    [self.bottomBar addSubview:_endRangeModifierButton];
    [self.bottomBar addSubview:_currentTagLabel];
    _startRangeModifierButton.hidden = YES;
    _endRangeModifierButton.hidden = YES;
    _currentTagLabel.hidden = YES;
    
    [_startRangeModifierButton  addTarget:self action:@selector(extendStartAction:) forControlEvents:UIControlEventTouchUpInside];
    [_endRangeModifierButton    addTarget:self action:@selector(extendEndAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onTagRecieved:) name:NOTIF_PLAYER_BAR_CANCEL object:nil];

    
    
}


-(void)onTagRecieved:(NSNotification*)note
{
 
    _startRangeModifierButton.hidden    = YES;
    _endRangeModifierButton.hidden      = YES;
    _currentTagLabel.hidden             = YES;
    _currentTagLabel.text               = @"";
    _selectedTag                        = nil;
}

-(void)usingTag:(Tag*)aTag
{
    if (!aTag) {
        _startRangeModifierButton.hidden    = YES;
        _endRangeModifierButton.hidden      = YES;
        _currentTagLabel.hidden             = YES;
        _currentTagLabel.text               = @"";
        _selectedTag                        = nil;
    } else {
        _startRangeModifierButton.hidden    = NO;
        _endRangeModifierButton.hidden      = NO;
        _currentTagLabel.hidden             = NO;
        _currentTagLabel.text               = aTag.name;
        _selectedTag                        = aTag;
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    const CGFloat buttonSize = self.bottomBar.bounds.size.height;
    
    _liveButton.frame = CGRectMake(self.fullscreenButton.frame.origin.x - 0.5 * buttonSize - 130.0, (buttonSize - 30.0) / 2.0, 130.0, 30.0);
    
    const CGFloat width = self.bottomBar.bounds.size.width, height = self.bottomBar.bounds.size.height;
    const CGFloat margin = 8.0;
    const CGFloat modifierHeight = height - 2.0 * margin, modifierWidth = modifierHeight * (6.0 / 5.0);
    
    _startRangeModifierButton.frame = CGRectMake(margin, margin, modifierWidth, modifierHeight);
    _endRangeModifierButton.frame = CGRectMake(width - modifierWidth - margin, margin, modifierWidth, modifierHeight);
    
    const CGFloat currentTagWidth = 150.0, currentTagHeight = 44.0;
    const CGFloat currentTagX = (width - currentTagWidth) / 2.0, currentTagY = (height - currentTagHeight) / 2.0;
    
    _currentTagLabel.frame = CGRectMake(currentTagX, currentTagY, currentTagWidth, currentTagHeight);

}


#pragma mark - Actions

// This control should have been only on the live2Bench Action is added in there
// this is just full screen clean up when pressed
- (void)liveButtonAction:(LiveButton *)sender {
    
    _startRangeModifierButton.hidden    = YES;
    _endRangeModifierButton.hidden      = YES;
    _currentTagLabel.hidden             = YES;
    _currentTagLabel.text               = @"";
    _selectedTag                        = nil;
//    PXPLog(@"Pressed Live Button in full screen");
//
//    [self.playerViewController.playerView.player goToLive];
//    
//    
//    [[EncoderManager getInstance] declareCurrentEvent:[EncoderManager getInstance].liveEvent];
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_RECEIVED object:[EncoderManager getInstance].liveEvent];
}

- (void)extendStartAction:(UIButton *)button {
    if (_selectedTag) {
        if ([[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil]){
            Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil];
            [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        }

        
        float newStartTime = 0;
        float endTime = _selectedTag.startTime + _selectedTag.duration;

        //extend the duration by decreasing the start time 5 seconds
        newStartTime = _selectedTag.startTime - 5;
        //if the new start time is smaller than 0, set it to 0
        if (newStartTime <0) {
            newStartTime = 0;
        }

        //set the new duration to tag end time minus new start time
        int newDuration = endTime - newStartTime;
        
        _selectedTag.startTime = newStartTime;
        
        if (newDuration > _selectedTag.duration) {
            _selectedTag.duration = newDuration;
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_selectedTag];
        }
    }
}

- (void)extendEndAction:(UIButton *)button {
    if (_selectedTag) {
        if ([[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil]){
            Clip * clipToSeverFromEvent = [[LocalMediaManager getInstance]getClipByTag:_selectedTag scrKey:nil];
            [[LocalMediaManager getInstance] breakTagLink:clipToSeverFromEvent];
        }
        
        float startTime = _selectedTag.startTime;
        
        float endTime = startTime + _selectedTag.duration;
        
        //increase end time by 5 seconds
        endTime = endTime + 5;
        //if new end time is greater the duration of video, set it to the video's duration
        if (endTime > [self durationOfVideoPlayer]) {
            endTime = [self durationOfVideoPlayer];
        }

        //get the new duration
        int newDuration = newDuration = endTime - startTime;
        if (newDuration > _selectedTag.duration) {
            _selectedTag.duration = newDuration;
            [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_selectedTag];
        }
        
    }
}

- (NSTimeInterval)durationOfVideoPlayer {
    return CMTimeGetSeconds(self.playerViewController.playerView.player.duration);
}


@end
