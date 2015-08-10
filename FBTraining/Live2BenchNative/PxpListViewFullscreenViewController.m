//
//  PxpListViewFullscreenViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpListViewFullscreenViewController.h"
#import "PxpPlayer+Tag.h"
#import "LocalMediaManager.h"

@interface PxpListViewFullscreenViewController ()

@end

@implementation PxpListViewFullscreenViewController

- (nonnull instancetype)initWithPlayerViewClass:(nullable Class)playerViewClass {
    self = [super initWithPlayerViewClass:playerViewClass];
    if (self) {
        _startRangeModifierButton = [[PxpRangeModifierButton alloc] initWithEnd:NO];
        _endRangeModifierButton = [[PxpRangeModifierButton alloc] initWithEnd:YES];
        
        _currentTagLabel = [[PxpBorderLabel alloc] init];
        
        _previousTagButton = [[PxpBorderButton alloc] init];
        _nextTagButton = [[PxpBorderButton alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.bottomBar addSubview:_startRangeModifierButton];
    [self.bottomBar addSubview:_endRangeModifierButton];
    [self.bottomBar addSubview:_currentTagLabel];
    [self.bottomBar addSubview:_previousTagButton];
    [self.bottomBar addSubview:_nextTagButton];
    
    _currentTagLabel.enabled = NO;
    _currentTagLabel.hidden = YES;
    _startRangeModifierButton.hidden = YES;
    _endRangeModifierButton.hidden = YES;
    _previousTagButton.hidden = YES;
    _nextTagButton.hidden = YES;
    
    [_previousTagButton setTitle:NSLocalizedString(@"PREVIOUS", nil) forState:UIControlStateNormal];
    [_nextTagButton setTitle:NSLocalizedString(@"NEXT", nil) forState:UIControlStateNormal];
    
    [_startRangeModifierButton addTarget:self action:@selector(extendStartAction:) forControlEvents:UIControlEventTouchUpInside];
    [_endRangeModifierButton addTarget:self action:@selector(extendEndAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    const CGFloat width = self.bottomBar.bounds.size.width, height = self.bottomBar.bounds.size.height;
    
    const CGFloat margin = 8.0;
    const CGFloat modifierHeight = height - 2.0 * margin, modifierWidth = modifierHeight * (6.0 / 5.0);
    
    _startRangeModifierButton.frame = CGRectMake(margin, margin, modifierWidth, modifierHeight);
    _endRangeModifierButton.frame = CGRectMake(width - modifierWidth - margin, margin, modifierWidth, modifierHeight);
    
    const CGFloat currentTagWidth = 150.0, currentTagHeight = 30.0;
    const CGFloat currentTagX = (width - currentTagWidth) / 2.0, currentTagY = (height - currentTagHeight) / 2.0;
    
    _currentTagLabel.frame = CGRectMake(currentTagX, currentTagY, currentTagWidth, currentTagHeight);
    
    const CGFloat tagCycleHeight = height - 2.0 * margin, tagCycleWidth = 2.0 * height - 2.0 * margin;
    
    _previousTagButton.frame = CGRectMake(4.0 * height + margin, margin, tagCycleWidth, tagCycleHeight);
    _nextTagButton.frame = CGRectMake(width - 4.0 * height - margin - tagCycleWidth, margin, tagCycleWidth, tagCycleHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters / Setters 

- (void)setSelectedTag:(nullable Tag *)selectedTag {
    _selectedTag = selectedTag;
    
    _currentTagLabel.text = selectedTag.name;
    _currentTagLabel.hidden = !selectedTag;
    _startRangeModifierButton.hidden = !selectedTag;
    _endRangeModifierButton.hidden = !selectedTag;
    _previousTagButton.hidden = !selectedTag;
    _nextTagButton.hidden = !selectedTag;
    
    self.playerViewController.playerView.player.tag = selectedTag;
}

#pragma mark - Actions

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

#pragma mark - Private Methods

- (NSTimeInterval)durationOfVideoPlayer {
    return CMTimeGetSeconds(self.playerViewController.playerView.player.duration);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
