
//
//  CreditsViewController.h
//  Live2BenchNative
//
//  Created by Robert Lee on 2015-06-22.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "CreditsViewController.h"


@interface CreditsViewController ()
{
    BOOL hasDecided;
}


@end

@implementation CreditsViewController

@synthesize blurView;
@synthesize creditsView;


- (instancetype)initWithAppDelegate:(nonnull AppDelegate *)appDel {
    self = [super initWithAppDelegate:appDel name:NSLocalizedString(@"Credits", nil) identifier:@"Credits"];
    if (self) {
        
        hasDecided = FALSE;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(!hasDecided){
        [self creditsViewWithBlurIfAvailable];
        hasDecided = TRUE;
    }
    
}


-(void)viewWillAppear:(BOOL)animated
{

    // test
    // DELETE ME
    [PxpLog clear];
    PXPLog(@"");
}



- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_RECEIVE_MEMORY_WARNING object:self userInfo:nil];
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    
}

-(void)creditsViewWithBlurIfAvailable
{
    
    
    if([Utility isDeviceBlurSupported:[Utility platformString]]){
        // Blur-Supported = YES
        [self.blurView setHidden:FALSE];
            
    } else {
        // Blur-Supported = NO
        [self.blurView setHidden:TRUE];
        [self.blurView removeFromSuperview];
        self.blurView = nil;
    }
    
    
}

@end