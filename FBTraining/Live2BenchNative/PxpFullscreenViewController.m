//
//  PxpFullscreenViewController.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFullscreenViewController.h"

@interface PxpFullscreenViewController ()

@end

@implementation PxpFullscreenViewController
{
    IBOutlet UIView * __nonnull _contentView;
    IBOutlet UIView * __nonnull _playerContainer;
    IBOutlet UIView * __nonnull _topBar;
    IBOutlet UIView * __nonnull _bottomBar;
    
    IBOutlet SeekButton * __nonnull _backwardSeekButton;
    IBOutlet SeekButton * __nonnull _forwardSeekButton;
}

@synthesize contentView = _contentView;
@synthesize topBar = _topBar;
@synthesize bottomBar = _bottomBar;

@synthesize backwardSeekButton = _backwardSeekButton;
@synthesize forwardSeekButton = _forwardSeekButton;

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _playerViewController = [[PxpPlayerMultiViewController alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _playerViewController.view.frame = _playerContainer.bounds;
    _playerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_playerContainer addSubview:_playerViewController.view];
    
    [_backwardSeekButton addTarget:self action:@selector(backwardSeekAction:) forControlEvents:UIControlEventTouchUpInside];
    [_forwardSeekButton addTarget:self action:@selector(forwardSeekAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backwardSeekAction:(SeekButton *)sender {
    [_playerViewController.multiView.player seekBy:CMTimeMakeWithSeconds(sender.speed, 600)];
}

- (void)forwardSeekAction:(SeekButton *)sender {
    [_playerViewController.multiView.player seekBy:CMTimeMakeWithSeconds(sender.speed, 600)];
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
