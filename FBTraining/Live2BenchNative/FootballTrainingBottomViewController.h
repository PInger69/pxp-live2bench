//
//  FootballTrainingBottomViewController.h
//  Live2BenchNative
//
//  Created by dev on 2014-07-29.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Globals.h"
#import "Live2BenchViewController.h"

@class Live2BenchViewController;
@interface FootballTrainingBottomViewController : UIViewController <NSURLConnectionDataDelegate>

@property (nonatomic,strong) Live2BenchViewController *live2BenchViewController;
@property (nonatomic) int currentOffenseGroup;
@property (nonatomic) int currentDefenseGroup;
@property (nonatomic) int currentOtherGroup;
@property (nonatomic,strong) NSMutableArray *currentGroupPlayers;

- (id)initWithController: (Live2BenchViewController*)l2b;
- (BOOL)isOffenseGroup;
- (BOOL)isDefenseGroup;

@end
