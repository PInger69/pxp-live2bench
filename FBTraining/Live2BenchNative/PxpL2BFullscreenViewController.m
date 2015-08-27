//
//  PxpL2BFullscreenViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-10.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpL2BFullscreenViewController.h"

@interface PxpL2BFullscreenViewController ()

@end

@implementation PxpL2BFullscreenViewController

- (nonnull instancetype)initWithPlayerViewController:(nonnull PxpPlayerViewController *)playerViewController {
    self = [super initWithPlayerViewController:playerViewController];
    if (self) {
        _liveButton = [[LiveButton alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.bottomBar addSubview:_liveButton];
    
    [_liveButton addTarget:self action:@selector(liveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _liveButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    const CGFloat buttonSize = self.bottomBar.bounds.size.height;
    
    _liveButton.frame = CGRectMake(self.fullscreenButton.frame.origin.x - 0.5 * buttonSize - 130.0, (buttonSize - 30.0) / 2.0, 130.0, 30.0);
}

#pragma mark - Actions

- (void)liveButtonAction:(LiveButton *)sender {
    [self.playerViewController.playerView.player goToLive];
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
