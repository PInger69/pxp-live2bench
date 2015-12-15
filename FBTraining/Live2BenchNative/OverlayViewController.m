//
//  OverlayViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-23.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "OverlayViewController.h"

@interface OverlayViewController ()

@end

@implementation OverlayViewController


- (id)initWithSide:(NSString*)side
{
    self = [super init];
    swipeSide = side;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //register left swipe
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(oneFingerSwipeLeft:)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [oneFingerSwipeLeft setCancelsTouchesInView:YES];
    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
    
    //register right swipe
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeRight:)] ;
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [oneFingerSwipeLeft setCancelsTouchesInView:YES];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];
    
    //key "left" represents the tag name buttons on the left side, and key value equals to 0 means, the buttons are not swiped out, 1 means, the buttons are swiped out; same for the right  buttons
    swipeControlDict = [[NSMutableDictionary alloc]initWithObjects:[NSArray arrayWithObjects:@"0",@"0", nil] forKeys:[NSArray arrayWithObjects:@"left",@"right", nil]];
    
    // Do any additional setup after loading the view from its nib.
    
}


- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer
{
    
    //remember x and y are reversed in fullscreen
    CGPoint tempCenter = self.view.center;
    [UIView animateWithDuration:0.3
                     animations:^{
                         if ([swipeSide isEqualToString:@"left"]) {
                             //if left buttons have already swiped out,then swipe back to left
                             if ([[swipeControlDict objectForKey:@"left"]integerValue]) {
                                 [self.view setCenter:CGPointMake(tempCenter.x-self.view.frame.size.width/2, tempCenter.y)];
                                 for(BorderButton *button in self.view.subviews)
                                 {
                                     [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3+self.view.frame.size.width/2, 3, 3)];
                                     [button changeBackgroundColor:[UIColor clearColor] :1.0];
                                 }
                                 [swipeControlDict setValue:@"0" forKey:@"left"];
                             }

                         }else{
                            //if right buttons have not been swiped out, then swipe out to left
                            if (![[swipeControlDict objectForKey:@"right"]integerValue]) {
                                [self.view setCenter:CGPointMake(tempCenter.x-self.view.frame.size.width/2, tempCenter.y)];
                                for(BorderButton *button in self.view.subviews)
                                {
                                    [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
                                    [button changeBackgroundColor:[UIColor whiteColor] :0.8];
                                }
                                [swipeControlDict setValue:@"1" forKey:@"right"];
                            }
                         }
                     }completion:^(BOOL finished){[self.view setUserInteractionEnabled:TRUE];
                         
                     }];
}


- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer
{
    
    //remember x and y are reversed in fullscreen check to see if the current touched view is on the left side(-15.5) or on the right side (930.5).
    //if it is on the left side and it's current position is 81.5 meaning that it is swiped out, set it back to 81.5. if it is on the right side and its current
    //position is less then 930.5 meaning the right side has not been swiped in, we set the position to its default position(don't move)
    
    //NOTE: use view.center.y because the ys and xs are reversed in fullscreen (fs is always in portrait) 
    CGPoint tempCenter = self.view.center;
       
    [UIView animateWithDuration:0.3
                     animations:^{
                         if ([swipeSide isEqualToString:@"left"]) {
                             //if left buttons have not been swiped out, swipe out to right
                             if (![[swipeControlDict objectForKey:@"left"]integerValue]) {
                                 [self.view setCenter:CGPointMake(tempCenter.x+self.view.frame.size.width/2, tempCenter.y)];
                                 for(BorderButton *button in self.view.subviews)
                                 {
                                     [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
                                     [button changeBackgroundColor:[UIColor whiteColor] :0.8];
                                 }
                                 [swipeControlDict setValue:@"1" forKey:@"left"];
                                 //////NSLog(@"overlay:%@",NSStringFromCGRect(self.view.frame));
                             }
                             
                         }else{
                             //if right buttons have been swiped out, swipe back to right
                             if ([[swipeControlDict objectForKey:@"right"]integerValue]) {
                                 [self.view setCenter:CGPointMake(tempCenter.x+self.view.frame.size.width/2, tempCenter.y)];
                                 for(BorderButton *button in self.view.subviews)
                                 {
                                     [button setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3+self.view.frame.size.width/2)];
                                     [button changeBackgroundColor:[UIColor clearColor] :1.0];
                                 }
                                 [swipeControlDict setValue:@"0" forKey:@"right"];
                             }
                         }
                     }completion:^(BOOL finished){[self.view setUserInteractionEnabled:TRUE];
                                             }];

    
}


- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end