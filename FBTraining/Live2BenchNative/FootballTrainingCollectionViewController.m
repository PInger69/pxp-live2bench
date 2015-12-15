//
//  FootballTrainingCollectionViewController.m
//  Live2BenchNative
//
//  Created by dev on 2014-08-12.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FootballTrainingCollectionViewController.h"

#define SUBTAG_WIDTH    90.0f
#define SUBTAG_HEIGHT   35.0f
#define PLAYER_HEIGHT   35.0f
#define SPACING         7.0f
#define MAX_TAGS_IN_ROW 4
#define MAX_PLAYERS_ROW 9

//Globals *globals;
NSMutableData *responseData;

NSString *oldTagID;
NSDictionary *currentPeriodTag;
UIView *subtagsView;
NSMutableArray *subtagButtons;
CustomLabel *noSubtagsLabel;
UIView *playersView;
NSMutableArray *playerButtons;
UIView *horizontalDivider;

@interface FootballTrainingCollectionViewController ()

@end

@implementation FootballTrainingCollectionViewController

@synthesize subtagsArray = _subtagsArray;
@synthesize selectedSubtag;
@synthesize playersArray = _playersArray;
@synthesize selectedPlayers;

- (id)init
{
    self = [super init];
    if (self) {
//        globals = [Globals instance];
        
        subtagsView = [[UIView alloc] init];
        subtagButtons = [[NSMutableArray alloc] init];
        noSubtagsLabel = [CustomLabel labelWithStyle:CLStyleGrey];
        horizontalDivider = [[UIView alloc] init];
        playersView = [[UIView alloc] init];
        playerButtons = [[NSMutableArray alloc] init];
        selectedPlayers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)clearSelections
{
    [self clearSubtags];
    [self clearPlayers];
    [self.subtagsArray removeAllObjects];
    self.selectedSubtag = @"";
    [self.playersArray removeAllObjects];
    [self.selectedPlayers removeAllObjects];
    currentPeriodTag = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view.layer setBorderColor:PRIMARY_APP_COLOR.CGColor];
    [self.view.layer setBorderWidth:1.0f];
    
    [self.view addSubview:subtagsView];
    
    [noSubtagsLabel setText:@"No Subtags Found"];
    [noSubtagsLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight];
    [noSubtagsLabel setTextAlignment:NSTextAlignmentCenter];
    [noSubtagsLabel setHidden:YES];
    [subtagsView addSubview:noSubtagsLabel];
    
    [horizontalDivider setFrame:CGRectMake(20.0f, CGRectGetMaxY(subtagsView.frame), self.view.frame.size.width - 40.0f, 1.0f)];
    [horizontalDivider setBackgroundColor:PRIMARY_APP_COLOR];
    [self.view addSubview:horizontalDivider];
    
    [self.view addSubview:playersView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifiedPlayersNotificationRecieved:) name:NOTIF_PLAYERS_MODIFIED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentPeriodTagFromNotification:) name:NOTIF_DURATION_TAG object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    const float maxTagsInRow = MAX_TAGS_IN_ROW;
    const float maxPlayersInRow = MAX_PLAYERS_ROW;
    float subtagViewWidth = 200.0f;
    float subtagViewHeight = 50.0f;
    float playerViewWidth = 0;
    float playerViewHeight = 0;
    float viewWidth;
    
    if (self.subtagsArray.count > 0) {
        [noSubtagsLabel setHidden:YES];
        if (self.subtagsArray.count > maxTagsInRow) {
            subtagViewWidth = SUBTAG_WIDTH*maxTagsInRow + SPACING*(maxTagsInRow+1);
        } else {
            subtagViewWidth = SUBTAG_WIDTH*self.subtagsArray.count + SPACING*(self.subtagsArray.count+1);
        }
        int subtagRows = ceilf(self.subtagsArray.count/maxTagsInRow);
        subtagViewHeight = SUBTAG_HEIGHT*subtagRows + SPACING*(subtagRows+1);
    } else {
        [noSubtagsLabel setHidden:NO];
        [noSubtagsLabel setFrame:CGRectMake(0.0f, 0.0f, subtagViewWidth, subtagViewHeight)];
    }
    
    if (self.playersArray.count > 0) {
        if (self.playersArray.count > maxPlayersInRow) {
            playerViewWidth = SUBTAG_HEIGHT*maxPlayersInRow + SPACING*(maxPlayersInRow+1);
        } else {
            playerViewWidth = SUBTAG_HEIGHT*self.playersArray.count + SPACING*(self.playersArray.count+1);
        }
        int playerRows = ceilf(self.playersArray.count/maxPlayersInRow);
        playerViewHeight = SUBTAG_HEIGHT*playerRows + SPACING*(playerRows+1);
    }
    viewWidth = MAX(playerViewWidth, subtagViewWidth);
    
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, viewWidth, subtagViewHeight+playerViewHeight+1.0f)];
    [subtagsView setFrame:CGRectMake(0.0f, 0.0f, subtagViewWidth, subtagViewHeight)];
    [horizontalDivider setFrame:CGRectMake(subtagsView.frame.origin.x + 20.0f, CGRectGetMaxY(subtagsView.frame), viewWidth - subtagsView.frame.origin.x - 40.0f, 1.0f)];
    [playersView setFrame:CGRectMake(subtagsView.frame.origin.x, CGRectGetMaxY(horizontalDivider.frame), playerViewWidth, playerViewHeight)];
    
    [self populateSubtags];
    [self populatePlayers];
}

- (void)updateCurrentPeriodTagFromNotification:(NSNotification*)notification
{
    //A notification is recieved from the UI saying a tag button was pressed meaning the currentPeriodTag is now old and to send any server calls
    [self modForSubtag];
    [self modForPlayers];
    oldTagID = [currentPeriodTag objectForKey:@"id"];
    currentPeriodTag = nil;
    [self updateCurrentDurationTag];
}

- (void)updateCurrentDurationTag
{
    currentPeriodTag = nil;
    //Check for what the current duration tag is
//    for (NSString *key in [globals.CURRENT_EVENT_THUMBNAILS allKeys]) {
//        NSDictionary *tag = [globals.CURRENT_EVENT_THUMBNAILS objectForKey:key];
//        if ([[tag objectForKey:@"type"] intValue] == 99 && [[tag objectForKey:@"user"] isEqualToString:[globals.ACCOUNT_INFO objectForKey:@"hid"]]){
//            currentPeriodTag = tag;
//        }
//    }
//    if ([[currentPeriodTag objectForKey:@"id"] isEqual:oldTagID]) {
//        //If the current duration tag is recorded as an oldTag give the server time to update before checking again
//        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(updateCurrentDurationTag) userInfo:nil repeats:NO];
//    } else {
//        oldTagID = nil;
//        [self updatePreselectedSubtag];
//        [self updatePreselectedPlayers];
//    }
}

- (void)setSubtagsArray:(NSMutableArray *)subtagsArray
{
    //setter method to update UI
    _subtagsArray = subtagsArray;
    [self.view setNeedsLayout];
    [self populateSubtags];
}

- (void)modifiedPlayersNotificationRecieved:(NSNotification*)notification
{
    //A notification from the FootballTrainingBottomViewController
    self.playersArray = [[notification userInfo] objectForKey:@"players"];
    [self.view setNeedsLayout];
}
- (void)setPlayersArray:(NSMutableArray *)playersArray
{
    _playersArray = playersArray;
    [self.view setNeedsLayout];
    [self populatePlayers];
}

#pragma mark - Subtag Collection Views

- (void)clearSubtags
{
    //Removes subtags from view
    for (UIButton *button in subtagButtons) {
        [button removeFromSuperview];
    }
    [subtagButtons removeAllObjects];
}

- (void)populateSubtags
{
    //Populate with stored subtags in the subtagsArray
    [self clearSubtags];
    int i = 0;
    for (NSString *subtag in self.subtagsArray) {
        int iForRow = i%MAX_TAGS_IN_ROW;
        const float maxTagsInRow = MAX_TAGS_IN_ROW;
        int row = floorf(i/maxTagsInRow);
        BorderButton *subtagButton = [[BorderButton alloc] initWithFrame:CGRectMake(SUBTAG_WIDTH*iForRow + SPACING*(iForRow+1), SUBTAG_HEIGHT*row + SPACING*(row+1), SUBTAG_WIDTH, SUBTAG_HEIGHT)];
        [subtagButton setTitle:subtag forState:UIControlStateNormal];
        [subtagButton addTarget:self action:@selector(selectSubtag:) forControlEvents:UIControlEventTouchUpInside];
        [subtagsView addSubview:subtagButton];
        [subtagButtons addObject:subtagButton];
        i++;
    }
    [self updatePreselectedSubtag];
}

- (void)updatePreselectedSubtag
{
    if (oldTagID){
        [self updateCurrentDurationTag];
    }
    //Update UI to reflect any subtags already selected on the currentPeriodTag
    if ([currentPeriodTag objectForKey:@"subtag"])
    {
        self.selectedSubtag = [currentPeriodTag objectForKey:@"subtag"];
        for (UIButton *button in subtagButtons) {
            if ([button.titleLabel.text isEqualToString:self.selectedSubtag]) {
                [button setSelected:YES];
            } else {
                [button setSelected:NO];
            }
            if ([self.selectedSubtag isEqualToString:@""]) {
                [button setSelected:NO];
            }
        }
    }
}

- (void)selectSubtag:(id)sender
{
    //Select subtag using button
    if (self.selectedSubtag) {
        for (UIButton *button in subtagButtons) {
            if ([button isSelected]) {
                [button setSelected:NO];
            }
        }
    }
    UIButton *button = sender;
    if (![self.selectedSubtag isEqualToString:button.titleLabel.text]) {
        self.selectedSubtag = button.titleLabel.text;
        [sender setSelected:YES];
    } else {
        self.selectedSubtag = @"";
    }
    
//    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.selectedSubtag forKey:@"subtag"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SUBTAG_SELECTED object:self userInfo:dict];
    [self modForSubtag];
}

- (void)modForSubtag
{
    //Attach the subtag to the currentPeriodTag
    [self updateCurrentDurationTag];
    if (currentPeriodTag && !oldTagID) {
        NSDictionary *dict;
        if (self.selectedSubtag && ![self.selectedSubtag isEqualToString:@""]) {
            dict = [NSDictionary dictionaryWithObject:self.selectedSubtag forKey:@"subtag"];
        } else {
            dict = [NSDictionary dictionaryWithObject:@"" forKey:@"subtag"];
        }
        [self modCurrentDurationTagWithInfo:dict];
    } else {
        //If the oldTag still exists, try again
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(modForSubtag) userInfo:nil repeats:NO];
    }
}

#pragma mark - Player Collection Views

- (void)clearPlayers
{
    //clears player buttons
    for (UIButton *button in playerButtons) {
        [button removeFromSuperview];
    }
    [playerButtons removeAllObjects];
}

- (void)populatePlayers
{
    //Populate player buttons from playersArray
    [self clearPlayers];
    int i = 0;
    for (NSString *player in self.playersArray) {
        int iForRow = i%MAX_PLAYERS_ROW;
        const float maxPlayersInRow = MAX_PLAYERS_ROW;
        int row = floorf(i/maxPlayersInRow);
        BorderButton *playerButton = [[BorderButton alloc] initWithFrame:CGRectMake(SUBTAG_HEIGHT*iForRow + SPACING*(iForRow+1), SUBTAG_HEIGHT*row + SPACING*(row+1), SUBTAG_HEIGHT, SUBTAG_HEIGHT)];
        [playerButton setTitle:player forState:UIControlStateNormal];
        [playerButton addTarget:self action:@selector(playerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [playersView addSubview:playerButton];
        [playerButtons addObject:playerButton];
        i++;
    }
    [self updatePreselectedPlayers];
}

- (void)updatePreselectedPlayers
{
    //Updates the UI for the player tag attached to the currentPeriodTag
    if (oldTagID){
        [self updateCurrentDurationTag];
    }
    if ([currentPeriodTag objectForKey:@"player"] && [[currentPeriodTag objectForKey:@"player"] count] > 0)
    {
        [self.selectedPlayers addObjectsFromArray:[currentPeriodTag objectForKey:@"player"]];
        for (UIButton *button in playerButtons) {
            BOOL isInSelectedPlayers = FALSE;
            for (NSString *player in self.selectedPlayers) {
                if ([button.titleLabel.text isEqualToString:player]) {
                    isInSelectedPlayers = TRUE;
                    break;
                }
            }
            [button setSelected:isInSelectedPlayers];
        }
    }
}

- (void)playerButtonSelected:(id)sender
{
    UIButton *button = sender;
    if (button.isSelected) {
        [self deselectPlayer:button];
    } else {
        [self selectPlayer:button];
    }
//    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.selectedPlayers forKey:@"players"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_PLAYERS_SELECTED object:self userInfo:dict];
    [self modForPlayers];
}

- (void)selectPlayer:(UIButton*)sender
{
    if (![self.playersArray containsObject:sender.titleLabel.text]) {
        [self.selectedPlayers addObject:sender.titleLabel.text];
    }
    [sender setSelected:YES];
}

- (void)deselectPlayer:(UIButton*)sender
{
    [self.selectedPlayers removeObjectIdenticalTo:sender.titleLabel.text];
    [sender setSelected:NO];
}

- (void)modForPlayers
{
    //Modifies the currentPeriodTag to include the selected players
    [self updateCurrentDurationTag];
    if (currentPeriodTag && !oldTagID) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:self.selectedPlayers forKey:@"player"];
        [self modCurrentDurationTagWithInfo:dict];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(modForPlayers) userInfo:nil repeats:NO];
    }
}

#pragma mark - Server Calls
- (void)modCurrentDurationTagWithInfo:(NSDictionary *)dict
{
    NSMutableDictionary *modDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [modDict setObject:[currentPeriodTag objectForKey:@"id"] forKey:@"id"];
//    [modDict setObject:globals.EVENT_NAME forKey:@"event"];
//    [modDict setObject:[globals.ACCOUNT_INFO objectForKey:@"hid"] forKey:@"user"];
    [self modTagInfo:modDict];
}

- (void)modTagInfo:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {
        
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
//    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
//    
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self]; //[NSURLConnection connectionWithRequest:urlRequest delegate:self];
//    [connection start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
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
        }
        if (error){
            NSLog(@"PlayersError: %@",error);
        }
        responseData = nil;
    }
}


@end
