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

- (nonnull instancetype)initWithPlayerViewController:(nonnull PxpPlayerViewController *)playerViewController {
    self = [super initWithPlayerViewController:playerViewController];
    if (self) {
        _startRangeModifierButton   = [[PxpRangeModifierButton alloc] initWithEnd:NO];
        _endRangeModifierButton     = [[PxpRangeModifierButton alloc] initWithEnd:YES];
        _currentTagLabel            = [[PxpBorderLabel alloc] init];
        _previousTagButton          = [[PxpBorderButton alloc] init];
        _nextTagButton              = [[PxpBorderButton alloc] init];
        _liveButton                 = [[LiveButton alloc] init];
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
    [self.bottomBar addSubview:_liveButton];
    _currentTagLabel.enabled = NO;
    _currentTagLabel.hidden = YES;

    _currentTagLabel.font = (SYSTEM_VERSION_LESS_THAN(@"8.0"))?[UIFont fontWithName:@"HelveticaNeue-Light" size:22]:[UIFont systemFontOfSize:20.0];
    
    _startRangeModifierButton.hidden = YES;
    _endRangeModifierButton.hidden = YES;
    _previousTagButton.hidden = YES;
    _nextTagButton.hidden = YES;
    
    [_previousTagButton setTitle:NSLocalizedString(@"PREVIOUS", nil) forState:UIControlStateNormal];
    [_nextTagButton setTitle:NSLocalizedString(@"NEXT", nil) forState:UIControlStateNormal];
    
    [_startRangeModifierButton addTarget:self action:@selector(extendStartAction:) forControlEvents:UIControlEventTouchUpInside];
    [_endRangeModifierButton addTarget:self action:@selector(extendEndAction:) forControlEvents:UIControlEventTouchUpInside];
    [_liveButton addTarget:self action:@selector(liveButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clear) name:NOTIF_PLAYER_BAR_CANCEL object:nil];
}

- (void)liveButtonPress:(UIButton *)button
{
    
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIF_PLAYER_BAR_CANCEL object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    
    const CGFloat alignCenter  = 35;
    
    const CGFloat width = self.bottomBar.bounds.size.width, height = self.bottomBar.bounds.size.height;
    
    const CGFloat margin = 8.0;
    const CGFloat modifierHeight = height - 2.0 * margin, modifierWidth = modifierHeight * (6.0 / 5.0);
    
    _startRangeModifierButton.frame = CGRectMake(margin, margin, modifierWidth, modifierHeight);
    _endRangeModifierButton.frame = CGRectMake(width - modifierWidth - margin, margin, modifierWidth, modifierHeight);
    
    const CGFloat currentTagWidth = 150.0, currentTagHeight = 44.0;
    const CGFloat currentTagX = (width - currentTagWidth) / 2.0, currentTagY = (height - currentTagHeight) / 2.0;
    
    _currentTagLabel.frame = CGRectMake(currentTagX, currentTagY, currentTagWidth, currentTagHeight);
    
    const CGFloat tagCycleHeight = height - 2.0 * margin, tagCycleWidth = 2.0 * height - 2.0 * margin;
    
    _previousTagButton.frame    = CGRectMake(0, 0, tagCycleWidth, tagCycleHeight);
    _previousTagButton.center   = CGPointMake(CGRectGetMaxX(_currentTagLabel.frame)- 224,alignCenter);
    
    _nextTagButton.frame        = CGRectMake(0, 0, tagCycleWidth, tagCycleHeight);
    _nextTagButton.center       = CGPointMake(CGRectGetMinX(_currentTagLabel.frame)+224,alignCenter);
    
    
    const CGFloat buttonSize = self.bottomBar.bounds.size.height;
    const CGFloat buttonHeight = buttonSize-10;
    
    _liveButton.frame = CGRectMake(CGRectGetMaxX(_nextTagButton.frame)+margin, margin, 100.0, tagCycleHeight);

    self.slomoButton.frame      = CGRectMake(2.5 * buttonHeight,       margin+6,         1.5 * buttonHeight - 2.0 * margin,      buttonHeight - 2.0 * margin);
    self.slomoButton.layer.borderWidth = 1;
    self.slomoButton.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    self.fullscreenButton.frame = CGRectMake(CGRectGetMinX(self.forwardSeekButton.frame)-margin -(buttonHeight - 2.0 * margin),        margin+6,         buttonHeight - 2.0 * margin,    buttonHeight - 2.0 * margin);
    
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
// returns the ui of full screen to non tag playing style
-(void)clear
{
    _selectedTag = nil;
    _currentTagLabel.text = @"";
    _currentTagLabel.hidden = YES;
    _startRangeModifierButton.hidden = YES;
    _endRangeModifierButton.hidden = YES;
    _previousTagButton.hidden = YES;
    _nextTagButton.hidden = YES;
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
