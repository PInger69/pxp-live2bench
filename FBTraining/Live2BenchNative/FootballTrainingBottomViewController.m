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

/*NSMutableDictionary *offenseGroupDictionary;
NSMutableDictionary *defenseGroupDictionary;
NSMutableDictionary *otherGroupDictionary;
NSMutableDictionary *playersDictionary;
NSDictionary *currentPeriodTag;
NSMutableArray *offenseGroupButtons;
NSMutableArray *defenseGroupButtons;
NSMutableArray *playersButtons;
BorderlessButton *offenseGroupButton;
BorderlessButton *defenseGroupButton;
BorderlessButton *otherGroupButton;
CustomLabel *disabledLabel;
UIView *playerView;

float buttonWidth;
float buttonHeight;
float spacing;
int numOfRows;


NSString *offenseGroupTagID;
NSString *defenseGroupTagID;
NSString *otherGroupTagID;
NSMutableData *responseData;*/

@interface FootballTrainingBottomViewController ()

@end

@implementation FootballTrainingBottomViewController{
    BorderlessButton *offenseGroupButton;
    BorderlessButton *defenseGroupButton;
}

@synthesize currentEvent = _currentEvent;
@synthesize videoPlayer = _videoPlayer;
@synthesize mainView = _mainView;
//@synthesize currentOffenseGroup;
//@synthesize currentDefenseGroup;
//@synthesize currentOtherGroup;
//@synthesize currentGroupPlayers;

#pragma mark - Init and View Setup

/*- (id)initWithController:(Live2BenchViewController *)l2b
{
    self = [super init];
    if (self) {
//        globals = [Globals instance];
        self.live2BenchViewController = l2b;
        currentGroupPlayers = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewElements) name:NOTIF_UPDATED_THUMBNAILS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewElementsForNotification:) name:NOTIF_DURATION_TAG object:nil];
    }
    return self;
}*/

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

/*- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
    [self createPlayersDictionaryWithTeamSetup];
    [self updateViewElements];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView
{
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
    
    otherGroupButton = [BorderlessButton buttonWithType:UIButtonTypeCustom];
    [otherGroupButton setTitle:@"Other" forState:UIControlStateNormal];
    [otherGroupButton setTitleColor:[UIColor colorWithRed:0.7f green:0.35f blue:0.0f alpha:1.0f] forState:UIControlStateSelected];
    [otherGroupButton setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
    [otherGroupButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [otherGroupButton addTarget:self action:@selector(groupButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [otherGroupButton setFrame:CGRectMake((self.view.frame.size.width - offenseGroupButton.frame.size.width)/2, 0.0f, offenseGroupButton.frame.size.width, 25.0f)];
    [otherGroupButton setTag:1];
    [otherGroupButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
//    [self.view addSubview:otherGroupButton];
    
    [self setupGroups];
    
    disabledLabel = nil;
    playerView = nil;
    
    
    CGRect buttonFrame = CGRectZero;
    if (defenseGroupButtons && [defenseGroupButtons count] > 0) {
        buttonFrame = [[defenseGroupButtons firstObject] frame];
    }
    playerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(buttonFrame) + 5.0f, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(buttonFrame) - 40.0f)];
    [playerView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//    [playerView.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
//    [playerView.layer setBorderWidth:1.0f];
    [self.view addSubview:playerView];
    
    disabledLabel = [CustomLabel labelWithStyle:CLStyleGrey];
    [disabledLabel setText:@"Select a Period"];
    [disabledLabel setTextColor:[UIColor lightGrayColor]];
    [disabledLabel setTag:0];
    [disabledLabel setFrame:CGRectMake(0.0f, (playerView.frame.size.height-30.0f)/2, playerView.frame.size.width, 30.0f)];
    [disabledLabel setTextAlignment:NSTextAlignmentCenter];
    [disabledLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    [playerView addSubview:disabledLabel];
}

#pragma mark - View Updating

- (void)viewDidLayoutSubviews
{
    [self setupGroups];
    [self populateFullPlayers];
}

- (void)updateViewElements
{
//    //Determine if the app is in a state where the view should be enabled or disabled
//    BOOL containsOpenDurationTag = FALSE;
//    BOOL hasPlayers = FALSE;
//    for (NSString *key in [globals.CURRENT_EVENT_THUMBNAILS allKeys]) {
//        NSDictionary *tag = [globals.CURRENT_EVENT_THUMBNAILS objectForKey:key];
//        if ([[tag objectForKey:@"type"] intValue] == 99){
//            //If a new tag is being opened
//            currentPeriodTag = tag;
//            containsOpenDurationTag = TRUE;
//        }
//    }
//    if (globals.UNCLOSED_EVENT) {
//        containsOpenDurationTag = TRUE;
//    }
//    if (!containsOpenDurationTag) {
//        [disabledLabel setText:@"Select a Period"];
//    }
//    if (globals.TEAM_SETUP && [globals.TEAM_SETUP count] > 0) {
//        hasPlayers = YES;
//    } else {
//        [disabledLabel setText:@"No Players Found"];
//    }
//    [self updateViewElementsForEnabled:(containsOpenDurationTag&&hasPlayers)];
}

- (void)updateViewElementsForNotification:(NSNotification*)notification
{
//    //Notification to update the UI when a new duration tag is selected
//    NSDictionary *dict = [notification userInfo];
//    BOOL containsOpenDurationTag = [[dict objectForKey:@"type"] intValue] == 99;
//    BOOL hasPlayers = FALSE;
//    if (containsOpenDurationTag) {
//        if (![currentPeriodTag isEqualToDictionary:dict]) {
//            [self closeGroupTag];
//            currentPeriodTag = dict;
//        }
//    } else {
//        [disabledLabel setText:@"Select a Period"];
//    }
//    if (globals.TEAM_SETUP && [globals.TEAM_SETUP count] > 0) {
//        hasPlayers = YES;
//    } else {
//        [disabledLabel setText:@"No Players Found"];
//    }
//    [self updateViewElementsForEnabled:(containsOpenDurationTag&&hasPlayers)];
//    
}

- (void)updateViewElementsForEnabled:(BOOL)enabled
{
    if (!enabled) {
        //If the UI is to be disabled, close any existing tags
        [self closeGroupTag];
    }
    [self setUIEnabled:enabled];
}

- (void)setUIEnabled:(BOOL)enabled
{
    //Disable buttons and present a disabled label or enable all
    if (!enabled) {
        [offenseGroupButton setSelected:FALSE];
        [defenseGroupButton setSelected:FALSE];
        [otherGroupButton setSelected:FALSE];
        [self disablePlayers];
    }
    [offenseGroupButton setEnabled:enabled];
    [defenseGroupButton setEnabled:enabled];
    [otherGroupButton setEnabled:enabled];
    [disabledLabel setHidden:enabled];
    
    if (offenseGroupButtons.count <= 0 && defenseGroupButtons.count <= 0 && enabled) {
        [self enablePlayers:[playersDictionary objectForKey:@"other"]];
    } else {
        for (UIButton *button in offenseGroupButtons) {
            [button setEnabled:enabled];
        }
        for (UIButton *button in defenseGroupButtons) {
            [button setEnabled:enabled];
        }
    }
}

#pragma mark - Group Buttons

- (void)deselectGroups
{
    //Group selections are reset
    [self deselectPlayers];
//    for (UIButton *button in playersButtons) {
//        [button removeFromSuperview];
//    }
    for (UIButton *button in offenseGroupButtons) {
        [button setSelected:FALSE];
    }
    offenseGroupTagID = nil;
    self.currentOffenseGroup = 0;
    for (UIButton *button in defenseGroupButtons) {
        [button setSelected:FALSE];
    }
    defenseGroupTagID = nil;
    self.currentDefenseGroup = 0;
    
    otherGroupTagID = nil;
    self.currentOtherGroup = 0;
}

- (void)clearGroupButtons
{
    //Clears the group buttons from the UI
    if (offenseGroupButtons) {
        for (int i = 0; i < offenseGroupButtons.count; i++){
            [offenseGroupButtons[i] removeFromSuperview];
        }
    }
    offenseGroupButtons = nil;
    
    if (defenseGroupButtons) {
        for (int i = 0; i < defenseGroupButtons.count; i++) {
            [defenseGroupButtons[i] removeFromSuperview];
        }
    }
    defenseGroupButtons = nil;
}

- (void)setupGroups
{
    //Setup the UI for the groups
    [self clearGroupButtons];
    offenseGroupButtons = [[NSMutableArray alloc] init];
    defenseGroupButtons = [[NSMutableArray alloc] init];
    
    NSInteger numOfOffenseGroup = 0;
    NSInteger numOfDefenseGroup = 0;
    
    if (offenseGroupDictionary && [offenseGroupDictionary count] > 0) {
        numOfOffenseGroup = [offenseGroupDictionary count];
        [offenseGroupButton setHidden:NO];
    }
    if (defenseGroupDictionary && [defenseGroupDictionary count] > 0) {
        numOfDefenseGroup = [defenseGroupDictionary count];
        [defenseGroupButton setFrame:CGRectMake(self.view.frame.size.width - numOfDefenseGroup*44.0f - offenseGroupButton.frame.origin.x, 0.0f, defenseGroupButton.frame.size.width, 25.0f)];
        [defenseGroupButton setHidden:NO];
    }
    
    //Creates defense and offense group buttons
    for (NSInteger i = 0; i < MAX(numOfOffenseGroup, numOfDefenseGroup); i++) {
        BorderButton *offenseButton = [BorderButton buttonWithType:UIButtonTypeCustom];
        BorderButton *defenseButton = [BorderButton buttonWithType:UIButtonTypeCustom];
        [offenseButton setTitle:[NSString stringWithFormat:@"%ld",(long) i+1] forState:UIControlStateNormal];
        offenseButton.tag = i+1;
        [offenseButton addTarget:self action:@selector(groupButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [defenseButton setTitle:[NSString stringWithFormat:@"%ld",(long) numOfDefenseGroup-i] forState:UIControlStateNormal];
        defenseButton.tag = numOfDefenseGroup-i;
        [defenseButton addTarget:self action:@selector(groupButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        if (offenseGroupDictionary && i < numOfOffenseGroup) {
            NSArray *sortedArray = [[offenseGroupDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *str1 = obj1;
                NSString *str2 = obj2;
                return [str1 compare:str2];
            }];
            [offenseButton setTitle:[NSString stringWithFormat:@"%@",[sortedArray objectAtIndex:i]] forState:UIControlStateNormal];
            offenseButton.tag = [[sortedArray objectAtIndex:i] intValue];
        }
        if (defenseGroupDictionary && i < numOfDefenseGroup) {
            NSArray *sortedArray = [[defenseGroupDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *str1 = obj1;
                NSString *str2 = obj2;
                return [str2 compare:str1];
            }];
            [defenseButton setTitle:[NSString stringWithFormat:@"%@",[sortedArray objectAtIndex:i]] forState:UIControlStateNormal];
            defenseButton.tag = [[sortedArray objectAtIndex:i] intValue];
        }
        [defenseButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        if (i>0) {
            CGRect previousOffenseButtonFrame = ((UIButton*)[offenseGroupButtons objectAtIndex:i-1]).frame;
            CGRect previousDefenseButtonFrame = ((UIButton*)[defenseGroupButtons objectAtIndex:i-1]).frame;
            [offenseButton setFrame:CGRectMake(CGRectGetMaxX(previousOffenseButtonFrame)+2.0f, previousOffenseButtonFrame.origin.y, previousOffenseButtonFrame.size.width, previousOffenseButtonFrame.size.height)];
            [defenseButton setFrame:CGRectMake(previousDefenseButtonFrame.origin.x-previousDefenseButtonFrame.size.width-2.0f, previousDefenseButtonFrame.origin.y, previousDefenseButtonFrame.size.width, previousDefenseButtonFrame.size.height)];
        } else {
            [offenseButton setFrame:CGRectMake(CGRectGetMaxX(offenseGroupButton.frame), 0.0f, 44.0f, 35.0f)];
            [defenseButton setFrame:CGRectMake(self.view.frame.size.width - offenseButton.frame.origin.x - offenseButton.frame.size.width, offenseButton.frame.origin.y, offenseButton.frame.size.width, offenseButton.frame.size.height)];
        }
        if (i < numOfOffenseGroup) {
            [offenseGroupButtons addObject:offenseButton];
            [self.view addSubview:offenseButton];
        }
        if (i < numOfDefenseGroup) {
            [defenseGroupButtons addObject:defenseButton];
            [self.view addSubview:defenseButton];
        }
    }
    [self updateViewElements];
}

- (void)groupButtonSelected:(id)sender{
    if ([offenseGroupButtons containsObject:sender]) {
        for (UIButton *button in offenseGroupButtons) {
            if ([button isSelected] && ![button isEqual:sender]){
                [button setSelected:NO];
                break;
            }
        }
        [sender setSelected:YES];
        if (currentOffenseGroup > 0) {
            [self modDictForPlayers];
        }
        self.currentOffenseGroup = [sender tag];
        [self displayOffensePlayers];
        [self sendTagForCurrentOffenseGroup];
    } else if ([defenseGroupButtons containsObject:sender]) {
        for (UIButton *button in defenseGroupButtons) {
            if ([button isSelected] && ![button isEqual:sender]){
                [button setSelected:NO];
                break;
            }
        }
        [sender setSelected:YES];
        if (currentDefenseGroup > 0) {
            [self modDictForPlayers];
        }
        self.currentDefenseGroup = [sender tag];
        [self displayDefensePlayers];
        [self sendTagForCurrentDefenseGroup];
    } else {
        if (currentOtherGroup > 0) {
            [self modDictForPlayers];
        }
        self.currentOtherGroup = [sender tag];
        [self displayOtherPlayers];
        [self sendTagForCurrentOtherGroup];
    }
}

- (void)sendTagForCurrentOffenseGroup
{
//    NSString *tagTime = [self.live2BenchViewController getCurrentTimeforNewTag];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%d",currentOffenseGroup],@"23",@"1",[NSString stringWithFormat:@"Group_O_%d",currentOffenseGroup],tagTime,currentGroupPlayers] forKeys:@[@"group",@"type",@"offense",@"name",@"time",@"player"]];
//    if (currentPeriodTag) {
//        [dict setObject:[currentPeriodTag objectForKey:@"name"] forKey:@"period"];
//    }
////    [dict setObject:globals.EVENT_NAME forKey:@"event"];
////    [dict setObject:[globals.ACCOUNT_INFO objectForKey:@"hid"] forKey:@"user"];
////    [dict setObject:[globals.ACCOUNT_INFO objectForKey:@"tagColour"] forKey:@"colour"];
//    [self sendTagInfo:dict];
//    offenseGroupTagID = nil;
}

- (void)sendTagForCurrentDefenseGroup
{
//    NSString *tagTime = [self.live2BenchViewController getCurrentTimeforNewTag];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%d",currentDefenseGroup],@"23",@"1",[NSString stringWithFormat:@"Group_D_%d",currentDefenseGroup],tagTime,currentGroupPlayers] forKeys:@[@"group",@"type",@"defense",@"name",@"time",@"player"]];
//    if (currentPeriodTag) {
//        [dict setObject:[currentPeriodTag objectForKey:@"name"] forKey:@"period"];
//    }
////    [dict setObject:globals.EVENT_NAME forKey:@"event"];
////    [dict setObject:[globals.ACCOUNT_INFO objectForKey:@"hid"] forKey:@"user"];
////    [dict setObject:[globals.ACCOUNT_INFO objectForKey:@"tagColour"] forKey:@"colour"];
//    [self sendTagInfo:dict];
//    defenseGroupTagID = nil;
}


- (void)sendTagForCurrentOtherGroup
{
//    NSString *tagTime = [self.live2BenchViewController getCurrentTimeforNewTag];
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%d",currentOtherGroup],@"23",@"1",[NSString stringWithFormat:@"Other_%d",currentOtherGroup],tagTime,currentGroupPlayers] forKeys:@[@"group",@"type",@"other",@"name",@"time",@"player"]];
//    if (currentPeriodTag) {
//        [dict setObject:[currentPeriodTag objectForKey:@"name"] forKey:@"period"];
//    }
//    [dict setObject:globals.EVENT_NAME forKey:@"event"];
//    [dict setObject:[globals.ACCOUNT_INFO objectForKey:@"hid"] forKey:@"user"];
//    [dict setObject:[globals.ACCOUNT_INFO objectForKey:@"tagColour"] forKey:@"colour"];
//    [self sendTagInfo:dict];
//    otherGroupTagID = nil;
}

- (void)closeGroupTag
{
    //Send mod tags and deselect/disable players/groups
    if (currentPeriodTag) {
        NSMutableDictionary *modDict;
        modDict = [[NSMutableDictionary alloc] init];
        [modDict addEntriesFromDictionary:[self dictForPlayers]];
        [self modCurrentTagWithInfo:modDict];
        [self deselectGroups];
    }
    [self disablePlayers];
}

#pragma mark - Players View


- (void)createPlayersDictionaryWithTeamSetup
{
//    //Converts the current team setup into a more easily parseable dictionary
//    NSMutableDictionary *players = [[NSMutableDictionary alloc] init];
//    if (!globals.TEAM_SETUP || [globals.TEAM_SETUP count] <= 0) {
//        return;
//    }
//    NSMutableDictionary *allPlayersDict = [NSMutableDictionary dictionaryWithObjects:@[[[NSMutableArray alloc] init],[[NSMutableArray alloc] init],[[NSMutableArray alloc] init]] forKeys:@[@"offense",@"defense",@"other"]];
//    [players setObject:allPlayersDict forKey:@"all"];
//    for (NSDictionary *player in globals.TEAM_SETUP) {
//        BOOL isOffense = [[[player objectForKey:@"line"] substringToIndex:1] isEqualToString:@"O"];
//        BOOL isDefense = [[[player objectForKey:@"line"] substringToIndex:1] isEqualToString:@"D"];
//        NSString *type;
//        if (isOffense) {
//            type = @"offense";
//        } else if (isDefense) {
//            type = @"defense";
//        } else {
//            type = @"other";
//        }
//        NSString *groupNum = [[player objectForKey:@"line"] substringFromIndex:2];
//        if ([groupNum isEqualToString:@""]) {
//            groupNum = @"0";
//        }
//        NSString *playerNum = [player objectForKey:@"jersey"];
//        
//        if (![players objectForKey:[player objectForKey:@"line"]]) {
//            NSMutableDictionary *groupDict = [NSMutableDictionary dictionaryWithObjects:@[type,groupNum,[NSMutableArray arrayWithObject:playerNum]] forKeys:@[@"type",@"group",@"players"]];
//            [players setObject:groupDict forKey:[player objectForKey:@"line"]];
//        } else {
//            [[[players objectForKey:[player objectForKey:@"line"]] objectForKey:@"players"] addObject:playerNum];
//        }
//        [[[players objectForKey:@"all"] objectForKey:type] addObject:playerNum];
//    }
//    [self initializePlayersDictionary:players];
}

- (void)initializePlayersDictionary:(NSDictionary*)groupPlayersDictionary
{
    //Populate the data-backing dictionaries
    offenseGroupDictionary = nil;
    defenseGroupDictionary = nil;
    otherGroupDictionary = nil;
    playersDictionary = nil;
    
    offenseGroupDictionary = [[NSMutableDictionary alloc] init];
    defenseGroupDictionary = [[NSMutableDictionary alloc] init];
    otherGroupDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [groupPlayersDictionary allKeys]) {
        id groupDict = [groupPlayersDictionary objectForKey:key];
        if ([key isEqualToString:@"all"]) {
            playersDictionary = [groupDict mutableCopy];
        } else {
            if ([[groupDict objectForKey:@"type"] isEqualToString:@"offense"]) {
                [offenseGroupDictionary setObject:[groupDict objectForKey:@"players"] forKey:[groupDict objectForKey:@"group"]];
            } else if ([[groupDict objectForKey:@"type"] isEqualToString:@"defense"]){
                [defenseGroupDictionary setObject:[groupDict objectForKey:@"players"] forKey:[groupDict objectForKey:@"group"]];
            } else if ([[groupDict objectForKey:@"type"] isEqualToString:@"other"]){
                [otherGroupDictionary setObject:[groupDict objectForKey:@"players"] forKey:[groupDict objectForKey:@"group"]];
            }
        }
    }
    if (offenseGroupDictionary.count > 0 && defenseGroupDictionary.count > 0) {
        [self setupGroups];
    } else {
        [offenseGroupButton setHidden:YES];
        [defenseGroupButton setHidden:YES];
    }
}

- (void)displayOffensePlayers
{
    [offenseGroupButton setSelected:YES];
    [defenseGroupButton setSelected:NO];
    [self disablePlayers];
    [self enablePlayers:[playersDictionary objectForKey:@"offense"]];
}

- (void)displayDefensePlayers
{
    [defenseGroupButton setSelected:YES];
    [offenseGroupButton setSelected:NO];
    [self disablePlayers];
    [self enablePlayers:[playersDictionary objectForKey:@"defense"]];
}


- (void)displayOtherPlayers
{
    [defenseGroupButton setSelected:NO];
    [offenseGroupButton setSelected:NO];
    [self disablePlayers];
    [self enablePlayers:[playersDictionary objectForKey:@"other"]];
}

- (void)disablePlayers
{
    [self deselectPlayers];
    for (UIButton *button in playersButtons) {
        [button setEnabled:NO];
        [button setAlpha:0.1f];
    }
}

- (void)enablePlayers:(NSArray*)players
{
    [self disablePlayers];
    for (int i = 0; i < [players count]; i++) {
        [[playersButtons objectAtIndex: [[players objectAtIndex:i] intValue]] setEnabled:YES];
        [[playersButtons objectAtIndex: [[players objectAtIndex:i] intValue]] setAlpha:1.0f];
    }
}

- (void)selectPlayer:(NSInteger)player{
    for (UIButton* button in playersButtons) {
        if (button.tag == player) {
            [button setSelected:YES];
            [currentGroupPlayers addObject:[NSString stringWithFormat:@"%ld",(long)button.tag]];
            break;
        }
    }
//    [self dispatchPlayersModifiedNotification];
}

- (void)deselectPlayer:(NSInteger)player{
    for (UIButton* button in playersButtons) {
        if (button.tag == player) {
            [button setSelected:NO];
            for (NSString *player in currentGroupPlayers){
                if ([player isEqualToString:[NSString stringWithFormat:@"%ld",(long)button.tag]]) {
                    [currentGroupPlayers removeObject:player];
                    break;
                }
            }
            break;
        }
    }
//    [self dispatchPlayersModifiedNotification];
}

- (void)deselectPlayers
{
    NSMutableArray *playersCopy = [currentGroupPlayers mutableCopy];
    for (NSString *player in playersCopy) {
        [self deselectPlayer:[player intValue]];
    }
    [self dispatchPlayersModifiedNotification];
}

-(void)clearPlayers
{
    //Clear player buttons
    if (currentGroupPlayers) {
        currentGroupPlayers = nil;
        currentGroupPlayers = [[NSMutableArray alloc] init];
    }
    if (playersButtons) {
        for (UIButton *button in playersButtons) {
            [button removeFromSuperview];
        }
    }
    playersButtons = nil;
}

- (void)populateFullPlayers
{
    //Buttons up to 100 are populate the UI
    buttonWidth = 40.0f;
    buttonHeight = 30.0f;
    if (offenseGroupButtons.count <= 0 && defenseGroupButtons.count <= 0) {
        buttonHeight += 10.0f;
    }
    spacing = 2.0f;
    if (playersButtons) {
        [self clearPlayers];
    }
    playersButtons = [[NSMutableArray alloc] init];
    for (int group = 0; group < 10; group ++)
    {
        for (int i = 0; i < 10; i ++) {
            int buttonNum = group*10 + i;
            float groupOriginX = group*(2*buttonWidth + 12*spacing) + spacing;
            float groupOriginY = 0.0f;
            if (i%5 == 0)
            {
                groupOriginY = spacing;
            }
            BorderButton *playerButton = [BorderButton buttonWithType:UIButtonTypeCustom];
            [playerButton setTitle:[NSString stringWithFormat:@"%d",buttonNum] forState:UIControlStateNormal];
            [playerButton setTag:buttonNum];
            [playerButton setEnabled:NO];
            [playerButton setAlpha:0.1f];
            [playerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            [playerButton setFrame:CGRectMake(groupOriginX + (i%2)*(buttonWidth+spacing), (i/2)*(buttonHeight+spacing)+2*spacing, buttonWidth, buttonHeight)];
            [playerButton addTarget:self action:@selector(playerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [playersButtons addObject:playerButton];
            [playerView addSubview:playerButton];
        }
    }
}

- (void)playerButtonSelected:(id)sender
{
    if ([sender isSelected]) {
        [self deselectPlayer:[sender tag]];
    } else {
        [self selectPlayer:[sender tag]];
    }
    [self dispatchPlayersModifiedNotification];
}

- (NSMutableDictionary*)dictForPlayers
{
    NSMutableDictionary *modDict = [NSMutableDictionary dictionaryWithObjects:@[currentGroupPlayers] forKeys:@[@"player"]];
    return modDict;
}

- (void)modDictForPlayers
{
    //Modify the currentPeriodTag for the players
    NSMutableDictionary *modDict = [self dictForPlayers];
    [self modCurrentTagWithInfo:modDict];
}

- (void)modCurrentTagWithInfo:(NSDictionary *)dict
{
//    NSMutableDictionary *modDict = [NSMutableDictionary dictionaryWithDictionary:dict];
////    if ([self isOffenseGroup] && offenseGroupTagID > 0) {
////        [modDict setObject:offenseGroupTagID forKey:@"id"];
////    } else if ([self isDefenseGroup] && defenseGroupTagID > 0) {
////        [modDict setObject:defenseGroupTagID forKey:@"id"];
////    } else if (otherGroupTagID > 0){
////        [modDict setObject:otherGroupTagID forKey:@"id"];
////    }
//    if (currentPeriodTag) {
//        id tagId = [globals.OPENED_DURATION_TAGS objectForKey:[currentPeriodTag objectForKey:@"name"]];
//        if (tagId) {
//            [modDict setObject:tagId forKey:@"id"];
//        }
//    } else {
//        NSLog(@"No CurrentPeriodTag to mod");
//    }
//    [modDict setObject:globals.EVENT_NAME forKey:@"event"];
//    [modDict setObject:[globals.ACCOUNT_INFO objectForKey:@"hid"] forKey:@"user"];
//    [self modTagInfo:modDict];
}

- (void)sortCurrentPlayers
{
    //Sort the current selected players by decreasing order
    [currentGroupPlayers sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}

- (void)dispatchPlayersModifiedNotification {
    //Dispatch a notification for when the currentPeriodTag is modified with new players
    [self sortCurrentPlayers];
    NSDictionary *playersDict = [[NSDictionary alloc] initWithObjects:@[currentGroupPlayers] forKeys:@[@"players"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PLAYERS_MODIFIED object:self userInfo:playersDict];
}

#pragma mark - Accessor Methods

- (BOOL)isOffenseGroup
{
    return [offenseGroupButton isSelected];
}

- (BOOL)isDefenseGroup
{
    return [defenseGroupButton isSelected];
}

#pragma mark - Server Calls

- (void)sendTagInfo:(NSMutableDictionary *)dict
{
    //    NSLog(@"sendingDict: %@", dict);
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
//    NSString *jsonString;
//    if (! jsonData) {
//        
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    }
//    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self]; //[NSURLConnection connectionWithRequest:urlRequest delegate:self];
//    [connection start];
//    
//    if (!globals.HAS_MIN) {
//        NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
//        NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[dict objectForKey:@"id"]];
//        NSString *imagePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
//        
//        //save tag information in global dictionary
//        [globals.CURRENT_EVENT_THUMBNAILS setObject:dict forKey:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
//        
//        [dict setObject:imagePath forKey:@"url"];
//        //create tagmarker
//        //        [self markTag:[[dict valueForKey:@"time"] floatValue] name:button.titleLabel.text colour:[uController colorWithHexString:[globals.ACCOUNT_INFO objectForKey:@"tagColour"]] tagID: [[@"temp_" stringByAppendingString:tagTime] doubleValue]];
//        //save the thumbnail image in local storage. This is running in the background thread
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                                 (unsigned long)NULL), ^(void) {
//            BOOL isDir;
//            if(![[NSFileManager defaultManager] fileExistsAtPath:globals.THUMBNAILS_PATH isDirectory:&isDir])
//            {
//                [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
//            }
//            
//            //create thumbnail using avfoundation and save it in the local dir
//            NSURL *videoURL = self.live2BenchViewController.videoPlayer.videoURL;
//            AVAsset *asset = [AVAsset assetWithURL:videoURL];
//            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
//            [imageGenerator setMaximumSize:CGSizeMake(190, 106)];
//            [imageGenerator setApertureMode:AVAssetImageGeneratorApertureModeProductionAperture];
//            //CMTime time = [[dict objectForKey:@"cmtime"] CMTimeValue];//CMTimeMake(30, 1);
//            CMTime time = CMTimeMakeWithSeconds([[dict objectForKey:@"time"] floatValue], 1);
//            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
//            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
//            CGImageRelease(imageRef);
//            
//            NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
//            if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir])
//            {
//                [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
//            }
//            //add image to directory
//            [imageData writeToFile:imagePath atomically:YES ];
//            
//        });
//        
//    }
}

- (void)modTagInfo:(NSDictionary *)dict
{
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
//    NSString *jsonString;
//    if (! jsonData) {
//        
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    }
//    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
//    
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    
//    NSLog(@"mod: %@",dict);
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self]; //[NSURLConnection connectionWithRequest:urlRequest delegate:self];
//    [connection start];
}

#pragma mark - Connection Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (data != nil) {
        if (responseData == nil){
            //            initialize responseData with first packet
            responseData = [NSMutableData dataWithData:data];
        }
        else{
            //            for multiple packets, the data should be appended
            [responseData appendData:data];
        }
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"DualView: %@",error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (responseData) {
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if ([json objectForKey:@"success"] && [[json objectForKey:@"success"] intValue] == 0) {
            NSLog(@"DualView Unsuccessful: %@",[json objectForKey:@"msg"]);
        } else {
            if ([json objectForKey:@"type"]) {
                if ([[json objectForKey:@"type"] intValue] == 23) {
                    if ([json objectForKey:@"offense"]) {
                        offenseGroupTagID = [json objectForKey:@"id"];
                    } else if ([json objectForKey:@"defense"]) {
                        defenseGroupTagID = [json objectForKey:@"id"];
                    } else {
                        otherGroupTagID = [json objectForKey:@"id"];
                    }
                }
            } else if ([json objectForKey:@"players"]) {
            }
        }
        if (error){
            NSLog(@"PlayersError: %@",error);
        }
        responseData = nil;
    }
}

#pragma mark - Older Code (Philly Eagles Early August)

//Code that is no longer used
- (void)selectDefaultPlayers
{
    //Set selected players based on default group
    if ([self isOffenseGroup]) {
        for (NSString *player in [offenseGroupDictionary objectForKey:[NSString stringWithFormat:@"%ld",(long)self.currentOffenseGroup]]){
            [self selectPlayer:[player intValue]];
        }
    } else if ([self isDefenseGroup]) {
        for (NSString *player in [defenseGroupDictionary objectForKey:[NSString stringWithFormat:@"%ld",(long)self.currentDefenseGroup]]){
            [self selectPlayer:[player intValue]];
        }
    }
    [self dispatchPlayersModifiedNotification];
}

- (void)populatePlayersViewWithPlayers:(NSArray*)players
{
    //Populate the playersView with the provided players array
    if  (!players || [players count] <= 0){
        return;
    }
    [self setUIEnabled:YES];
    if (playersButtons) {
        [self clearPlayers];
    }
    playersButtons = [[NSMutableArray alloc] init];
    
    buttonWidth = 44.0f;
    buttonHeight = buttonWidth;
    spacing = 2.0f;
    numOfRows = 1;
    NSArray *playersArray = [self arrangedPlayersArrayWithPlayers:players];
    
    UIView *playerAlignmentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[playersArray firstObject] count]*buttonWidth + ([[playersArray firstObject] count] - 1)*spacing, [playersArray count]*buttonHeight + ([playersArray count]-1)*spacing)];
    for (int row=0; row < numOfRows; row++) {
        for (int col=0; col < [[playersArray objectAtIndex:row] count]; col++) {
            BorderButton *playerButton = [BorderButton buttonWithType:UIButtonTypeCustom];
            float buffer = 0.0f;
            if (row > 0 && [[playersArray objectAtIndex:row] count] < [[playersArray objectAtIndex:row-1] count]) {
                buffer = buttonWidth/2;
            }
            [playerButton setFrame:CGRectMake(col*buttonWidth + col*spacing + buffer, row*buttonHeight + row*spacing, buttonWidth, buttonHeight)];
            [playerButton setTitle:[NSString stringWithFormat:@"%@",[[playersArray objectAtIndex:row] objectAtIndex:col]] forState:UIControlStateNormal];
            [playerButton setTag:[playerButton.titleLabel.text intValue]];
            [playerButton addTarget:self action:@selector(playerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [playersButtons addObject:playerButton];
            [playerAlignmentView addSubview:playerButton];
        }
    }
    playerAlignmentView.center = CGPointMake(playerView.bounds.size.width/2, playerView.bounds.size.height/2);
    [playerView addSubview:playerAlignmentView];
}

- (NSArray*)arrangedPlayersArrayWithPlayers:(NSArray*)players{
    //Arrange the player buttons with the provided players array
    NSArray *playersArray = [players sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *num1 = [NSNumber numberWithInt:[obj1 intValue]];
        NSNumber *num2 = [NSNumber numberWithInt:[obj2 intValue]];
        return [num1 compare:num2];
    }];
    
    if ([players count] > 66) {
        if ([players count] > 96) {
            buttonWidth -=6;
        }else if ([players count] > 92) {
            buttonWidth -=5;
        } else if ([players count] > 88) {
            buttonWidth -=3;
        }else if ([players count] > 84) {
            buttonWidth --;
        }
        numOfRows = 4;
        buttonHeight = 32;
        NSInteger rowCount0, rowCount1, rowCount2, rowCount3;
        rowCount0 = [playersArray count]/2;
        rowCount2 = [playersArray count] - rowCount0;
        rowCount1 = rowCount0/2;
        rowCount0 = rowCount0 - rowCount1;
        rowCount3 = rowCount2/2;
        rowCount2 = rowCount2 - rowCount3;
        NSArray *row0 = [playersArray subarrayWithRange:NSMakeRange(0, rowCount0)];
        NSArray *row1 = [playersArray subarrayWithRange:NSMakeRange(rowCount0, rowCount1)];
        NSArray *row2 = [playersArray subarrayWithRange:NSMakeRange(rowCount0+rowCount1, rowCount2)];
        NSArray *row3 = [playersArray subarrayWithRange:NSMakeRange(rowCount0+rowCount1+rowCount2, rowCount3)];
        playersArray = [NSArray arrayWithObjects:row0,row1,row2,row3, nil];
    } else if ([players count] > 44) {
        if ([players count] > 63) {
            buttonWidth --;
        }
        numOfRows = 3;
        NSInteger rowCount0, rowCount1, rowCount2;
        rowCount0 = [playersArray count]/3;
        rowCount1 = [playersArray count] - rowCount0;
        rowCount1 = rowCount1/2;
        rowCount2 = [playersArray count] - rowCount0 - rowCount1;
        NSArray *row0 = [playersArray subarrayWithRange:NSMakeRange(0, rowCount0)];
        NSArray *row1 = [playersArray subarrayWithRange:NSMakeRange(rowCount0, rowCount1)];
        NSArray *row2 = [playersArray subarrayWithRange:NSMakeRange(rowCount0+rowCount1, rowCount2)];
        playersArray = [NSArray arrayWithObjects:row0,row1,row2, nil];
    } else if ([players count] > 22) {
        if ([players count] > 42) {
            buttonWidth --;
        }
        numOfRows = 2;
        NSInteger rowCount0, rowCount1;
        rowCount1 = [playersArray count]/2;
        rowCount0 = [playersArray count] - rowCount1;
        NSArray *row0 = [playersArray subarrayWithRange:NSMakeRange(0, rowCount0)];
        NSArray *row1 = [playersArray subarrayWithRange:NSMakeRange(rowCount0, rowCount1)];
        playersArray = [NSArray arrayWithObjects:row0,row1, nil];
    } else {
        if ([players count] > 21){
            buttonWidth --;
        }
        playersArray = [NSArray arrayWithObject:playersArray];
    }
    return playersArray;
}*/


@end
