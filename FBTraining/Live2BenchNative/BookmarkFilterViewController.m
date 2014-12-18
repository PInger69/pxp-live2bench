//
//  BookmarkFilterViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-04-05.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "BookmarkFilterViewController.h"

#define ROWS_IN_EVENTS                 6
#define PADDING                        3

@interface BookmarkFilterViewController ()

@end


@implementation BookmarkFilterViewController

@synthesize allEvents, finishedSwipe;

- (id)initWithArgs:filterArgs
{
    self = [super init];
    superArgs=filterArgs;
    bkViewController = [superArgs objectForKey:@"controller"];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
    taggedButtonArr = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
}

-(void)setupView
{
    UIView *bgview = [[UIView alloc] init];
    [bgview setBackgroundColor:[UIColor colorWithHexString:@"#e6e6e6"]];
    [bgview setFrame:CGRectMake(0.0f, 44.0f, self.view.bounds.size.width, self.view.bounds.size.height - 44.0f)];
    [bgview setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:bgview];
    
    UIImageView *eventDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
    [eventDivider setFrame:CGRectMake(300.0f, 54.0f, 3.0f, 240.0f)];
    [eventDivider setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:eventDivider];
    
    UIImageView *teamsDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
    [teamsDivider setFrame:CGRectMake(720.0f, eventDivider.frame.origin.y, 3.0f, 240.0f)];
    [teamsDivider setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:teamsDivider];
    
    UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 66.0f, 50.0f, 21.0f)];
    [eventLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [eventLabel setText:@"Event"];
    [eventLabel setTextColor:[UIColor darkGrayColor]];
    [eventLabel setBackgroundColor:[UIColor clearColor]];
    [eventLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [self.view addSubview:eventLabel];
    
    UILabel *teamsLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(eventDivider.frame) + 10.0f, eventLabel.frame.origin.y, 52.0f, eventLabel.bounds.size.height)];
    [teamsLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [teamsLabel setText:@"Teams"];
    [teamsLabel setTextColor:[UIColor darkGrayColor]];
    [teamsLabel setBackgroundColor:[UIColor clearColor]];
    [teamsLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [self.view addSubview:teamsLabel];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(teamsDivider.frame) + 10.0f, teamsLabel.frame.origin.y, 36.0f, teamsLabel.bounds.size.height)];
    [dateLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [dateLabel setText:@"Date"];
    [dateLabel setTextColor:[UIColor darkGrayColor]];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    [dateLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [self.view addSubview:dateLabel];
    
    UIImageView *eventUnderline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line"]];
    [eventUnderline setFrame:CGRectMake(eventLabel.frame.origin.x - 5.0f, CGRectGetMaxY(eventLabel.frame), 150.0f, 3.0f)];
    [eventUnderline setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:eventUnderline];
    
    UIImageView *teamsUnderline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line"]];
    [teamsUnderline setFrame:CGRectMake(teamsLabel.frame.origin.x - 5.0f, CGRectGetMaxY(teamsLabel.frame), 150.0f, 3.0f)];
    [teamsUnderline setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:teamsUnderline];
    
    UIImageView *dateUnderline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Line"]];
    [dateUnderline setFrame:CGRectMake(dateLabel.frame.origin.x - 5.0f, CGRectGetMaxY(dateLabel.frame), 150.0f, 3.0f)];
    [dateUnderline setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:dateUnderline];
    
    numTagsLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgview.bounds.size.width - 110.0f, 257.0f, 100.0f, 21.0f)];
    [numTagsLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [numTagsLabel setTextAlignment:NSTextAlignmentRight];
    [numTagsLabel setText:@"Tags"];
    [numTagsLabel setTextColor:[UIColor darkGrayColor]];
    [numTagsLabel setBackgroundColor:[UIColor clearColor]];
    [numTagsLabel setFont:[UIFont systemFontOfSize:17.0f]];
    [self.view addSubview:numTagsLabel];
    
    bookMarkFilterTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bookMarkFilterTitleButton setBackgroundImage:[UIImage imageNamed:@"myclipfilter"] forState:UIControlStateNormal];
    [bookMarkFilterTitleButton setFrame:CGRectMake(bgview.bounds.size.width - 200.0f, 10.0f, 180.0f, 44.0f)];
    [bookMarkFilterTitleButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [bookMarkFilterTitleButton addTarget:self action:@selector(swipeFilter:) forControlEvents:UIControlEventTouchDragInside];
    [bookMarkFilterTitleButton addTarget:self action:@selector(finishedSwipe:) forControlEvents:UIControlEventTouchUpInside];
    [bookMarkFilterTitleButton addTarget:self action:@selector(finishedSwipeOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:bookMarkFilterTitleButton];
    
    eventScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 90.0f, 295.0f, 190.0f)];
    [eventScrollView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [eventScrollView setDelegate:self];
    [self.view addSubview:eventScrollView];
    
    dateScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 200.0f, eventScrollView.frame.origin.y, 295.0f, eventScrollView.bounds.size.height)];
    [dateScrollView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [dateScrollView setDelegate:self];
    [self.view addSubview:dateScrollView];
    
    oppScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(eventDivider.frame), eventScrollView.frame.origin.y, dateScrollView.frame.origin.x - CGRectGetMaxX(eventScrollView.frame) - 15.0f, eventScrollView.bounds.size.height)];
    [oppScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [oppScrollView setDelegate:self];
    [self.view addSubview:oppScrollView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!globals)
    {
        globals=[Globals instance];
    }
    [self prepArraysForDisplay];
    [self createOppTags];
    [self createDateTags];
    [self createEventTags];
    [self createClearAll];
    [self sortClipsBySelecting];
    
}

//get the global oppenents and date arrays and populate them with bookmarks
-(void)prepArraysForDisplay
{
    
    //get all the events information which will be used to display home team, visit team
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"EventsHid.plist"];
    NSMutableArray *eventsData = [[NSMutableArray alloc] initWithContentsOfFile: plistPath];
    for (NSDictionary *event in eventsData) {
        if (!allEvents) {
            allEvents = [[NSMutableDictionary alloc]initWithObjects:[[NSArray alloc]initWithObjects:event, nil] forKeys:[[NSArray alloc]initWithObjects:[event objectForKey:@"name"], nil]];
        }else{
            [allEvents setObject:event forKey:[NSString stringWithFormat:@"%@",[event objectForKey:@"name"]]];
        }
    }

    
    NSMutableArray *allBookmarkTags;
    NSMutableArray *allBookmarkDictArr = [[globals.BOOKMARK_TAGS allValues]mutableCopy];
    if (!eventsArray) eventsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in allBookmarkDictArr) {
        if (allBookmarkTags) {
            [allBookmarkTags addObjectsFromArray:[dict allValues]];
        }else{
            allBookmarkTags = [[NSMutableArray alloc]initWithArray:[dict allValues]];
        }
    }
    

    for(NSDictionary *dict in allBookmarkTags) // get all bookmarks and iterate
    {
        if([dict isKindOfClass:[NSDictionary class]])
        {
            if(![[dict objectForKey:@"event"] isEqualToString:@"live"]) // for now if its a live event, we aren't going to filter -- need to fix on server
            {
                NSArray *tempArr = [[dict objectForKey:@"event" ] componentsSeparatedByString:@"_"];
                NSString *eventDate =  [NSString stringWithString:[tempArr objectAtIndex:0] ];
                NSDictionary *teamInfo = [[allEvents objectForKey:[dict objectForKey:@"event"]] copy];
                NSString *homeTeam = [teamInfo objectForKey:@"homeTeam"];
                NSString *visitTeam = [teamInfo objectForKey:@"visitTeam"];
                if (!homeTeam || !visitTeam){
                    homeTeam = [dict objectForKey:@"homeTeam"];
                    visitTeam = [dict objectForKey:@"visitTeam"];
                }
                NSString *whosPlaying = [NSString stringWithFormat:@"%@ VS. %@",homeTeam,visitTeam];
                
                if(![globals.BOOKMARK_DATES containsObject:eventDate])
                {
                    [globals.BOOKMARK_DATES addObject:eventDate];
                }
                
                if(![globals.BOOKMARK_OPPONENTS containsObject:whosPlaying] && homeTeam && visitTeam)
                {
                    [globals.BOOKMARK_OPPONENTS addObject:whosPlaying];
                }
                
                if (![eventsArray containsObject:[dict objectForKey:@"name"]]){
                    [eventsArray addObject:[dict objectForKey:@"name"]];
                }
            }
        }
    }
    if(!taggedAttsDict)
    {
        taggedAttsDict = [globals.TAGGED_ATTS_BOOKMARK mutableCopy];

        
    }
    if (!allFilters){
        allFilters = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 14, 820, 30)];

        //[allFilters setAccessibilityLabel:@"filters"];
        //[allFilters setBackgroundColor:[UIColor grayColor]];
        allFilters.scrollEnabled = YES;
        //allFilters.clipsToBounds = TRUE;
        allFilters.showsHorizontalScrollIndicator = YES;
        allFilters.showsVerticalScrollIndicator = YES;
        allFilters.delegate = self;
        [allFilters setAlwaysBounceHorizontal:TRUE];
        [self.view addSubview:allFilters];
    }
    [numTagsLabel setText:[NSString stringWithFormat:@"%d Tags", globals.BOOKMARK_TAGS.count]];
    [numTagsLabel setNeedsDisplay];
}

//create tags in the format HTeamA Vs. VTeamB wherein H means home and V means visiting
-(void)createOppTags
{
    //NSMutableArray *typeofTagsArr = [[globals.TYPES_OF_TAGS objectAtIndex:0] mutableCopy];
    NSArray *sortedArray = [globals.BOOKMARK_OPPONENTS sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for(NSString *eventName in sortedArray)
    {
        int i = [sortedArray indexOfObject:eventName];
        //int i = [typeofTagsArr indexOfObject:eventName];
        int colNum = ceil(i/ROWS_IN_EVENTS);
        
        int rowNum = (i+1)%ROWS_IN_EVENTS>0 ? (i+1)%ROWS_IN_EVENTS : ROWS_IN_EVENTS;
        // //
        CustomButton  *eventButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
        //[eventButton setFrame:CGRectMake((colNum * 83)-60, (rowNum*28)+2, 80, 25)];
        [eventButton setFrame:CGRectMake((colNum * 223)+10, (rowNum*28)-20, 220, 25)];
        //[eventButton setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        [eventButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [eventButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [eventButton setTitle:eventName forState:UIControlStateNormal];
        [eventButton setAccessibilityLabel:@"teams"];
        [eventButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [eventButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        eventButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [oppScrollView addSubview:eventButton];
        
        BOOL doesContainTeams = ([[taggedAttsDict objectForKey:@"teams"] containsObject:eventName]);
        
        if(doesContainTeams)
        {
            [taggedButtonArr addObject:eventButton];
            [eventButton setSelected:TRUE];
        }
    }
    
    if ([[taggedAttsDict objectForKey:@"teams"] count] > 0){
        NSArray *teamsArray = [[taggedAttsDict objectForKey:@"teams"] copy];
        for (NSString *team in teamsArray){
            if (![sortedArray containsObject:team]){
                [[taggedAttsDict objectForKey:@"teams"] removeObject:team];
            }
        }
        if ([[taggedAttsDict objectForKey:@"teams"] count] == 0){
            [taggedAttsDict removeObjectForKey:@"teams"];
        }
    }
    
    if(ceil((float)globals.BOOKMARK_OPPONENTS.count/ROWS_IN_EVENTS) <2){
        [oppScrollView setContentSize:CGSizeMake(oppScrollView.frame.size.width, oppScrollView.frame.size.height)];
    }else{
        [oppScrollView setContentSize:CGSizeMake( ceil((float)globals.BOOKMARK_OPPONENTS.count/ROWS_IN_EVENTS)*223 + 10, oppScrollView.frame.size.height)];
    }
    
}

-(void)createEventTags
{
    //NSMutableArray *typeofTagsArr = [[globals.TYPES_OF_TAGS objectAtIndex:0] mutableCopy];
    NSArray *sortedArray = [eventsArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for(NSString *eventName in sortedArray)
    {
        int i = [sortedArray indexOfObject:eventName];
        //int i = [typeofTagsArr indexOfObject:eventName];
        int colNum = ceil(i/ROWS_IN_EVENTS);
        
        int rowNum = (i+1)%ROWS_IN_EVENTS>0 ? (i+1)%ROWS_IN_EVENTS : ROWS_IN_EVENTS;
        // //
        CustomButton  *eventButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
        //[eventButton setFrame:CGRectMake((colNum * 83)-60, (rowNum*28)+2, 80, 25)];
        [eventButton setFrame:CGRectMake((colNum * 123)+10, (rowNum*28)-20, 120, 25)];
        //[eventButton setContentEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        [eventButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [eventButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [eventButton setTitle:eventName forState:UIControlStateNormal];
        [eventButton setAccessibilityLabel:@"names"];
        [eventButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [eventButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        eventButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [eventScrollView addSubview:eventButton];
        
        BOOL doesContainName = ([[taggedAttsDict objectForKey:@"names"] containsObject:eventName]);
        
        if(doesContainName)
        {
            [taggedButtonArr addObject:eventButton];
            [eventButton setSelected:TRUE];
        }
    }
    
    if ([[taggedAttsDict objectForKey:@"names"] count] > 0){
        NSArray *nameArray = [[taggedAttsDict objectForKey:@"names"] copy];
        for (NSString *name in nameArray){
            if (![sortedArray containsObject:name]){
                [[taggedAttsDict objectForKey:@"names"] removeObject:name];
            }
        }
        if ([[taggedAttsDict objectForKey:@"names"] count] == 0){
            [taggedAttsDict removeObjectForKey:@"names"];
        }
    }
    
    if(ceil((float)eventsArray.count/ROWS_IN_EVENTS) <3){
        [eventScrollView setContentSize:CGSizeMake(eventScrollView.frame.size.width, eventScrollView.frame.size.height)];
    }else{
        [eventScrollView setContentSize:CGSizeMake(ceil((float)eventsArray.count/ROWS_IN_EVENTS)*123 + 10, eventScrollView.frame.size.height)];
    }
    
}
-(void)createClearAll
{
    CustomButton *clearAll = [CustomButton buttonWithType:UIButtonTypeCustom];
    [clearAll setFrame:CGRectMake(numTagsLabel.frame.origin.x - 60.0f, numTagsLabel.frame.origin.y, 60, 25)];
    clearAll.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    [clearAll setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [clearAll setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
    [clearAll setAccessibilityLabel:@"allclear"];
    [clearAll addTarget:self action:@selector(clearAllTags:) forControlEvents:UIControlEventTouchUpInside];
    [clearAll setTitle:@"clear all" forState:UIControlStateNormal];
    [clearAll setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearAll setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    clearAll.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    //[shiftButtons addObject:clearAll];
    //[clearAll setHidden:TRUE];
    [self.view addSubview:clearAll];
}

-(void)clearAllTags:(id)sender
{
    [self clearEventFilter];
    [self sortClipsBySelecting];
}

-(void)clearEventFilter{
    
    for(CustomButton *button in taggedButtonArr)
    {
        if ([button.accessibilityLabel isEqualToString:@"colours"]){
            [button setAlpha:0.1f];
        } //else {
        [button setSelected:FALSE];
        //}
    }
    [taggedButtonArr removeAllObjects];
    [taggedAttsDict removeAllObjects];
    [globals.TAGGED_ATTS_BOOKMARK removeAllObjects];
    
}

-(void)cellSelected:(id)sender
{
    if(!taggedAttsDict)
    {
        taggedAttsDict = [[NSMutableDictionary alloc]init];
    }

    CustomButton  *button = (CustomButton *)sender;
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    if(isButtonSelected)
    {
        if (!taggedButtonArr){
            taggedButtonArr = [NSMutableArray arrayWithObject:button];
        } else {
            [taggedButtonArr addObject:button];
        }
        NSString *att = button.accessibilityLabel;
        if(![[taggedAttsDict allKeys] containsObject:att])
        {
                NSMutableArray *attValues = [[NSMutableArray alloc]initWithObjects:button.titleLabel.text, nil];
                [taggedAttsDict setObject:attValues forKey:att];
        }else{
                [[taggedAttsDict objectForKey:att] addObject:button.titleLabel.text];
        }
    }else{
        [taggedButtonArr removeObject:button];
    
        NSString *att = button.accessibilityLabel;
        [[taggedAttsDict objectForKey:att] removeObject:button.titleLabel.text];
          
        if([[taggedAttsDict objectForKey:att]count]<1)
        {
            [taggedAttsDict removeObjectForKey:att];
        }
    }
    [self sortClipsBySelecting];
}

//sorting mechanism
-(void)sortClipsBySelecting
{
    NSMutableArray *allBookmarkTags;
    NSMutableArray *allBookmarkDictArr = [[globals.BOOKMARK_TAGS allValues]mutableCopy];
    for (NSDictionary *dict in allBookmarkDictArr) {
        if (allBookmarkTags) {
            [allBookmarkTags addObjectsFromArray:[dict allValues]];
        }else{
            allBookmarkTags = [[NSMutableArray alloc]initWithArray:[dict allValues]];
        }
    }
    
    //if our display array doesn't exist, create it
    if(!displayArray)
    {
        displayArray = [[NSMutableArray alloc] init];
    }
    
    if(taggedAttsDict.count<1) //if there is nothing in the tagged attributes, then we want all bookmarks
    {
        displayArray = [NSMutableArray arrayWithArray:allBookmarkTags];
    }else{
        for(NSDictionary *obj in allBookmarkTags)
        {
            NSString *homeTeam;
            NSString *visitTeam;
            NSString *whosPlaying;
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                ////////NSLog(@"obj %@",obj);
                if(![[obj objectForKey:@"event" ]isEqualToString:@"live"]) //for now ignore live bookmarks
                {
                    NSDictionary *teamInfo = [[allEvents objectForKey:[obj objectForKey:@"event"]] copy];
                    NSArray *tempArr = [[obj objectForKey:@"event" ] componentsSeparatedByString:@"_"];
                    NSString *eventDate =  [NSString stringWithString:[tempArr objectAtIndex:0] ];
                    homeTeam = [teamInfo objectForKey:@"homeTeam"];
                    visitTeam = [teamInfo objectForKey:@"visitTeam"];
                    
                    if (!homeTeam || !visitTeam){
                        homeTeam = [obj objectForKey:@"homeTeam"];
                        visitTeam = [obj objectForKey:@"visitTeam"];
                    }
                    
                    whosPlaying = [NSString stringWithFormat:@"%@ VS. %@",homeTeam,visitTeam];
               
                    BOOL doesContainDate = !([[taggedAttsDict objectForKey:@"dates"]count]>0) || [[taggedAttsDict objectForKey:@"dates"] containsObject:eventDate] ;           
                    BOOL doesContainTeams = !([[taggedAttsDict objectForKey:@"teams"]count] >0) || [[taggedAttsDict objectForKey:@"teams"]containsObject:whosPlaying];
                    BOOL doesContainNames = !([[taggedAttsDict objectForKey:@"names"]count] >0) || [[taggedAttsDict objectForKey:@"names"]containsObject:[obj objectForKey:@"name"]];
                    if(doesContainDate && doesContainTeams && doesContainNames)
                    {
                        [displayArray addObject:obj];
                    }
                }
            }
        }
    }
    //reload tags
    [bkViewController receiveFilteredArray:displayArray];
    globals.TAGGED_ATTS_BOOKMARK = [taggedAttsDict mutableCopy];
    [numTagsLabel setText:[NSString stringWithFormat:@"%d Tags", displayArray.count]];
    [numTagsLabel setNeedsDisplay];
    [displayArray removeAllObjects];

}


- (IBAction)finishedSwipe:(id)sender {
    self.finishedSwipe = TRUE;
}

- (IBAction)finishedSwipeOutside:(id)sender {
    self.finishedSwipe = TRUE;
}

- (IBAction)swipeFilter:(id)sender {
    [[superArgs objectForKey:@"controller"] slideFilterBox];
}

//create tags for dates that games were played in the format yyyy-mm-dd
-(void)createDateTags
{
    //NSMutableArray *typeofTagsArr = [[globals.TYPES_OF_TAGS objectAtIndex:0] mutableCopy];
    NSArray *sortedArray = [globals.BOOKMARK_DATES sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for(NSString *eventName in sortedArray)
    {
        int i = [sortedArray indexOfObject:eventName];
        //int i = [typeofTagsArr indexOfObject:eventName];
        int colNum = ceil(i/ROWS_IN_EVENTS);
        
        int rowNum = (i+1)%ROWS_IN_EVENTS>0 ? (i+1)%ROWS_IN_EVENTS : ROWS_IN_EVENTS;
        // //
        CustomButton  *eventButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
        //[eventButton setFrame:CGRectMake((colNum * 83)-60, (rowNum*28)+2, 80, 25)];
        [eventButton setFrame:CGRectMake((colNum * 113)+10, (rowNum*28)-20, 110, 25)];
        [eventButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
        [eventButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
        [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
        [eventButton setTitle:eventName forState:UIControlStateNormal];
        [eventButton setAccessibilityLabel:@"dates"];
        [eventButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [eventButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        eventButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
        [dateScrollView addSubview:eventButton];
        
        BOOL doesContainDate = ([[taggedAttsDict objectForKey:@"dates"] containsObject:eventName]);
        
        if(doesContainDate)
        {
            [taggedButtonArr addObject:eventButton];
            [eventButton setSelected:TRUE];
        }
    }
    
    if ([[taggedAttsDict objectForKey:@"dates"] count] > 0){
        NSArray *datesArray = [[taggedAttsDict objectForKey:@"teams"] copy];
        for (NSString *date in datesArray){
            if (![sortedArray containsObject:date]){
                [[taggedAttsDict objectForKey:@"dates"] removeObject:date];
            }
        }
        if ([[taggedAttsDict objectForKey:@"dates"] count] == 0){
            [taggedAttsDict removeObjectForKey:@"dates"];
        }
    }
    
    if(ceil(globals.BOOKMARK_DATES.count/ROWS_IN_EVENTS) <3){
        [dateScrollView setContentSize:CGSizeMake(dateScrollView.frame.size.width, dateScrollView.frame.size.height)];
    }else{
        [dateScrollView setContentSize:CGSizeMake(ceil((float)globals.BOOKMARK_DATES.count/ROWS_IN_EVENTS)*113 + 10, dateScrollView.frame.size.height)];
    }
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.bookmarkViewController dismissFilterToolbox];
    
}






- (void)didReceiveMemoryWarning
{
    globals.DID_RECEIVE_MEMORY_WARNING = TRUE;
    [super didReceiveMemoryWarning];
    if ([self.view window] == nil) self.view = nil;
    // Dispose of any resources that can be recreated.
}

@end
