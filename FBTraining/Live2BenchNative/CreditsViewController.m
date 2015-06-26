
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
    
}

@end

@implementation CreditsViewController

@synthesize blurView;
@synthesize creditsView;

-(id)initWithAppDelegate:(AppDelegate *)mainappDelegate
{
    self = [super initWithAppDelegate:mainappDelegate];
    if (self) {

        [self setMainSectionTab:@"Credits" imageName:@""];

    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self creditsViewWithBlurIfAvailable];
    
}


-(void)viewWillAppear:(BOOL)animated
{

    
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
    }
    
    
}

@end