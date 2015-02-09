//
//  Live2BenchTagUIViewController.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-10.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderButton.h"
#import "FullScreenViewController.h"
#import "PlayerCollectionViewController.h"
#import "OverlayViewController.h"

#define STATE_FULLSCREEN @"fullscreen"
#define STATE_SMALLSCREEN @"smallscreen"


@interface Live2BenchTagUIViewController : UIViewController
{
    NSMutableArray          * tagButtonsLeft;
    NSMutableArray          * tagButtonsRight;
    NSInteger               * tagCount;
    NSMutableDictionary     * buttons;
}

@property (assign,nonatomic) BOOL                               enabled;
@property (assign,nonatomic) BOOL                               hidden;
@property (assign,nonatomic) CGSize                             buttonSize;
@property (assign,nonatomic) CGFloat                            gap;
@property (assign,nonatomic) CGFloat                            topOffset;
@property (strong,nonatomic) NSString                           * state;
@property (strong,nonatomic) FullScreenViewController           * fullScreenViewController;
@property (strong,nonatomic) PlayerCollectionViewController     * playerCollectionViewController;         //it will show up when swiping tag button;Its view contains all the player buttons

-(id)initWithView:(UIView*)view;
-(void)inputTagData:(NSArray*)listOfDicts;
-(void)addActionToAllTagButtons:(SEL)sel addTarget:(id)target forControlEvents:(UIControlEvents)controlEvent;

-(void)clear;
-(BorderButton*)getButtonByName:(NSString*)btnName;


-(void)minimize;
-(void)maximize;
-(void)close;
-(void)open;




@end