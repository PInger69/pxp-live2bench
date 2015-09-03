//
//  PxpMyClipViewFullscreenViewController.m
//  Live2BenchNative
//
//  Created by andrei on 2015-09-01.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpMyClipViewFullscreenViewController.h"

@interface PxpMyClipViewFullscreenViewController ()

@end

@implementation PxpMyClipViewFullscreenViewController

- (nonnull instancetype)initWithPlayerViewController:(nonnull PxpPlayerViewController *)playerViewController {
    self = [super initWithPlayerViewController:playerViewController];
    if (self) {
        
        _currentTagLabel = [[PxpBorderLabel alloc] init];
        
        _previousTagButton = [[PxpBorderButton alloc] init];
        _nextTagButton = [[PxpBorderButton alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.bottomBar addSubview:_currentTagLabel];
    [self.bottomBar addSubview:_previousTagButton];
    [self.bottomBar addSubview:_nextTagButton];
    
    _currentTagLabel.enabled = NO;
    _currentTagLabel.hidden = YES;
    _currentTagLabel.font = [UIFont systemFontOfSize:22.0 weight:1.0];    _previousTagButton.hidden = YES;
    _nextTagButton.hidden = YES;
    
    [_previousTagButton setTitle:NSLocalizedString(@"PREVIOUS", nil) forState:UIControlStateNormal];
    [_nextTagButton setTitle:NSLocalizedString(@"NEXT", nil) forState:UIControlStateNormal];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    const CGFloat width = self.bottomBar.bounds.size.width, height = self.bottomBar.bounds.size.height;
    
    const CGFloat margin = 8.0;
    const CGFloat modifierHeight = height - 2.0 * margin, modifierWidth = modifierHeight * (6.0 / 5.0);
    
    
    const CGFloat currentTagWidth = 150.0, currentTagHeight = 44.0;
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
    _previousTagButton.hidden = !selectedTag;
    _nextTagButton.hidden = !selectedTag;
    
    //self.playerViewController.playerView.player.tag = selectedTag;
}

#pragma mark - Actions

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
