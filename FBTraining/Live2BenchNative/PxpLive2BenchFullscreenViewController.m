//
//  PxpLive2BenchFullscreenViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpLive2BenchFullscreenViewController.h"

@interface PxpLive2BenchFullscreenViewController ()

@end

@implementation PxpLive2BenchFullscreenViewController

- (nonnull instancetype)initWithPlayerViewClass:(nullable Class)playerViewClass {
    self = [super initWithPlayerViewClass:playerViewClass];
    if (self) {
        _liveButton = [[LiveButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 130.0, 30.0)];
        _liveButton.enabled = NO;
        
        [_liveButton addTarget:self action:@selector(liveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.bottomBar addSubview:_liveButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    const CGFloat aspect = 130.0 / 30.0;
    
    const CGFloat
    liveButtonX = self.forwardSeekButton.frame.origin.x + 10.0,
    liveButtonWidth = self.bottomBar.bounds.size.width - liveButtonX - 10.0,
    liveButtonHeight = liveButtonWidth / aspect,
    liveButtonY =  (self.bottomBar.bounds.size.height - liveButtonHeight) / 2.0;
    
    _liveButton.frame = CGRectMake(liveButtonX, liveButtonY, liveButtonWidth, liveButtonHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)liveButtonAction:(LiveButton *)liveButton {
    self.playerViewController.playerView.player.live = YES;
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
