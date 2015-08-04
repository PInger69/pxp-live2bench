
//
//  CreditsViewController.h
//  Live2BenchNative
//
//  Created by Robert Lee on 2015-06-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "CreditsViewController.h"

@implementation CreditsViewController


- (instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
    return [super initWithAppDelegate:appDel name:NSLocalizedString(@"Credits", nil) identifier:@"Credits"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    
    blurView.frame = self.view.frame;
    
    [self.view insertSubview:blurView belowSubview:self.creditsView];
    
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [PxpLog clear];
}

@end