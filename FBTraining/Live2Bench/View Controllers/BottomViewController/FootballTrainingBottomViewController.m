//
//  FootballTrainingBottomViewController.m
//  Live2BenchNative
//
//  Created by dev on 2014-07-29.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FootballTrainingBottomViewController.h"
#import "BorderlessButton.h"
#import "CustomLabel.h"
#define kDEFAULT_NUM_OF_GROUPS 6


@interface FootballTrainingBottomViewController ()

@end

@implementation FootballTrainingBottomViewController{
    BorderlessButton *offenseGroupButton;
    BorderlessButton *defenseGroupButton;
}

@synthesize currentEvent = _currentEvent;
@synthesize mainView = _mainView;


#pragma mark - Init and View Setup


-(id)init{
    self = [super init];
    if (self) {
        
        self.view.frame = CGRectMake(0, 540, self.view.frame.size.width, self.view.frame.size.height);
        _mainView = self.view;
        
        offenseGroupButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
        [offenseGroupButton setTitle:@"Offense" forState:UIControlStateNormal];
        [offenseGroupButton setTitleColor:[UIColor colorWithRed:0.7f green:0.35f blue:0.0f alpha:1.0f] forState:UIControlStateSelected];
        [offenseGroupButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        [offenseGroupButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [offenseGroupButton addTarget:self action:@selector(displayOffensePlayers) forControlEvents:UIControlEventTouchUpInside];
        [offenseGroupButton setFrame:CGRectMake(10.0f, 0.0f, 80.0f, 25.0f)];
        [self.view addSubview:offenseGroupButton];
        
        defenseGroupButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
        [defenseGroupButton setTitle:@"Defense" forState:UIControlStateNormal];
        [defenseGroupButton setTitleColor:[UIColor colorWithRed:0.7f green:0.35f blue:0.0f alpha:1.0f] forState:UIControlStateSelected];
        [defenseGroupButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
        [defenseGroupButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [defenseGroupButton addTarget:self action:@selector(displayDefensePlayers) forControlEvents:UIControlEventTouchUpInside];
        [defenseGroupButton setFrame:CGRectMake(self.view.frame.size.width - kDEFAULT_NUM_OF_GROUPS*44.0f - offenseGroupButton.frame.origin.x, 0.0f, offenseGroupButton.frame.size.width, 25.0f)];
        [defenseGroupButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [self.view addSubview:defenseGroupButton];
    }
    return self;
}
- (void)viewDidLoad
{
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(update) name:NOTIF_RICO_PLAYER_VIEW_CONTROLLER_UPDATE object:nil];
    [super viewDidLoad];
    
//    [self setupView];
//    [self createPlayersDictionaryWithTeamSetup];
//    [self updateViewElements];
}




#pragma  mark - BottomViewControllerProtocol methods
-(void)update
{


}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
