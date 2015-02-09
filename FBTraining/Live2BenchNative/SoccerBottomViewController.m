  //
//  SoccerBottomViewController.m
//  Live2BenchNative
//
//  Created by dev on 13-02-28.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "SoccerBottomViewController.h"
#define PLAYERBUTTON_X              190
#define PLAYERBUTTON_Y              100
#define PLAYERBUTTON_WIDTH           42
#define PADDING                      10
#define SUBSBUTTON_Y                160
#define SUBSLABEL_WIDTH              50

@interface SoccerBottomViewController ()

@end

@implementation SoccerBottomViewController

@synthesize live2BenchViewController;
@synthesize periodSegmentedControl;
@synthesize zoneSegmentedControl;
@synthesize playerbuttonWasSelected;
@synthesize responseData;

- (id)initWithController:(Live2BenchViewController *)l2b
{
    self = [super init];
     live2BenchViewController = l2b;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateControlInfo) name:@"EventInformationUpdated" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateControlInfo) name:@"UpdateSoccerBottomViewControInfo" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(restartUpdateTimer) name:@"RestartUpdate" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopUpdateTimer) name:@"StopUpdate" object:nil];

    
//    globals = [Globals instance];
    
     updateSeekInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                    target:self
                                                                  selector:@selector(updateControlInfoWhileSeeking)
                                                                  userInfo:nil
                                                                   repeats:YES];
    isUpdatingSeek=FALSE;
    [self setupView];
    [self initLayout];
    uController = [[UtilitiesController alloc]init];
    [self updateControlInfo];
    
    // Do any additional setup after loading the view from its nib.
}


-(void)setupView
{
//    self.zoneSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"OFF.3RD",@"MID.3RD",@"DEF.3RD"]];
//    if ([globals.WHICH_SPORT isEqualToString:@"soccer"]) {
//        self.periodSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"1",@"2",@"EXTRA",@"PS"]];
//    }else if ([globals.WHICH_SPORT isEqualToString:@"rugby"]){
//        self.periodSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"1",@"2",@"EXTRA"]];
//    }
//    
//    UIView *segmentControlView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - (self.zoneSegmentedControl.numberOfSegments + self.periodSegmentedControl.numberOfSegments + 1)*80.0f)/2, 20.0f, (self.zoneSegmentedControl.numberOfSegments + self.periodSegmentedControl.numberOfSegments + 1)*80.0f, 70.0f)];
//    segmentControlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    
//    if ([globals.WHICH_SPORT isEqualToString:@"soccer"]) {
//        self.zoneLabel = [CustomLabel labelWithStyle:CLStyleBlack];
//        self.zoneLabel.frame = CGRectMake(0, 0, 80.0f, 30.0f);
//        [self.zoneLabel setText:@"Zone"];
//        [segmentControlView addSubview:self.zoneLabel];
//        
//        [self.zoneSegmentedControl setFrame:CGRectMake(self.zoneLabel.frame.origin.x, CGRectGetMaxY(self.zoneLabel.frame), self.zoneSegmentedControl.numberOfSegments*80.0f, 30.0f)];
//        [self.zoneSegmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
//        [self.zoneSegmentedControl addTarget:self action:@selector(zoneValueChanged:) forControlEvents:UIControlEventValueChanged];
//        [segmentControlView addSubview:self.zoneSegmentedControl];
//    }
//    float halfLabelX = 0;
//    float periodSegmentY = 0;
//    if ([globals.WHICH_SPORT isEqualToString:@"soccer"]) {
//        halfLabelX = CGRectGetMaxX(self.zoneSegmentedControl.frame) + 80.0f;
//        periodSegmentY = self.zoneSegmentedControl.frame.origin.y;
//    }else if([globals.WHICH_SPORT isEqualToString:@"rugby"]){
//        halfLabelX = 260.0f;
//        periodSegmentY = 30;
//    }
//    
//    self.halfLabel = [CustomLabel labelWithStyle:CLStyleBlack];
//    self.halfLabel.frame = CGRectMake(halfLabelX, 0, 80.0f, 30.0f);
//    [self.halfLabel setText:@"Half"];
//    [segmentControlView addSubview:self.halfLabel];
//    
//    [self.periodSegmentedControl setFrame:CGRectMake(self.halfLabel.frame.origin.x, periodSegmentY, self.periodSegmentedControl.numberOfSegments*80.0f, 30.0f)];
//    [self.periodSegmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
//    [self.periodSegmentedControl addTarget:self action:@selector(halfValueChanged:) forControlEvents:UIControlEventValueChanged];
//    [segmentControlView addSubview:self.periodSegmentedControl];
//    
//    [self.view addSubview:segmentControlView];
//    
}

-(void)initLayout
{
//    //players' buttons
//    int playerCount=1;
//    playerButtons = nil;
//    playerButtons  = [[NSMutableArray alloc] init];
//    //get all the non sub players count which will be used to center all the player buttons
//    int notSubPlayersCount = 0;
//    
//    for(NSObject *obj in globals.TEAM_SETUP){
//        if ([[obj valueForKey:@"role"] intValue]!=8) {
//            notSubPlayersCount++;
//        }
//    }
//    float buttonWidth = 800/(notSubPlayersCount+5);
//    for(NSObject *obj in globals.TEAM_SETUP)
//    {
//        NSString *jerseyNumber = [[obj valueForKey:@"jersey"] stringValue];
//        if([[obj valueForKey:@"role"] intValue]!=8)
//        {
//            BorderButton *playerButton = [BorderButton buttonWithType:UIButtonTypeCustom];
//            float playerButtonY = (notSubPlayersCount == globals.TEAM_SETUP.count) ? PLAYERBUTTON_Y + 25.0f : PLAYERBUTTON_Y;
//            [playerButton setFrame:CGRectMake((playerCount-1)*(buttonWidth+10)+(1024 - notSubPlayersCount*(buttonWidth+10) +10)/2.0, playerButtonY, buttonWidth, PLAYERBUTTON_WIDTH)];
//            [playerButton setTitle:jerseyNumber forState:UIControlStateNormal];
//            [playerButton addTarget:self action:@selector(playerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
//            [playerButton setTag:playerCount];
//            [self.view addSubview:playerButton];
//            [playerButtons addObject:playerButton];
//            playerCount++;
//        }
//    }
//    
//    if(!subsLabel)
//    {
//        subsLabel = [CustomLabel labelWithStyle:CLStyleGrey];
//    }
//    [subsLabel setFrame:CGRectMake(((BorderButton*)[playerButtons firstObject]).frame.origin.x -SUBSLABEL_WIDTH, SUBSBUTTON_Y, SUBSLABEL_WIDTH, PLAYERBUTTON_WIDTH)];
//    [subsLabel setText:@"Subs:"];
//    [self.view addSubview:subsLabel];
//    [playerButtons addObject:subsLabel];
//    if (notSubPlayersCount == globals.TEAM_SETUP.count) {
//        //no subs player, hide the subslabel
//        [subsLabel setHidden:TRUE];
//    }else{
//        //have subs player,display the subslabel
//        [subsLabel setHidden:FALSE];
//    }
//    int count=1;
//    for(NSObject *obj in globals.TEAM_SETUP){
//        
//        NSString *jerseyNumber = [[obj valueForKey:@"jersey"] stringValue];
//        if([[obj valueForKey:@"role"] intValue]==8)
//        {
//            BorderButton *subsButton = [BorderButton buttonWithType:UIButtonTypeCustom];
//            [subsButton setFrame:CGRectMake(((count-1)*(buttonWidth+PADDING))+CGRectGetMaxX(subsLabel.frame), SUBSBUTTON_Y, buttonWidth, PLAYERBUTTON_WIDTH)];
//            [subsButton setTitle:jerseyNumber forState:UIControlStateNormal];
//            [subsButton addTarget:self action:@selector(playerButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
//            [subsButton setTag:count];
//            [playerButtons addObject:subsButton];
//            [self.view addSubview:subsButton];
//             count++;
//        }
//       
//    }
    
}

-(void) updatePlayers
{
    for(UIButton *button in playerButtons)
    {
        [button removeFromSuperview];
    }
    for(UILabel *label in playerButtons)
    {
        [label removeFromSuperview];
    }
    [self initLayout];
}

-(void)updateControlInfo{
    
//
//    //1. if current playig event is not soccer or rugby event 2. if the current event is live but the the event is not started completed yet (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]), just return.
//    if (!([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]) || (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && [globals.EVENT_NAME isEqual:@"live"])) {
//        return;
//    }
//     //highlight the button of the current forward line
//    
//    //highlight current period, globals.CURRENT_PERIOD is the int value of segment control index
//    if (globals.CURRENT_PERIOD>=0) {
//        [self.periodSegmentedControl setSelectedSegmentIndex:globals.CURRENT_PERIOD];
//    }else {
//        [self.periodSegmentedControl setSelectedSegmentIndex:0];
//        [self.periodSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];  
//    }
//    
//    if ([globals.WHICH_SPORT isEqualToString:@"soccer"]) {
//        if(globals.CURRENT_ZONE.length)
//        {
//            [self.zoneSegmentedControl setSelectedSegmentIndex:[globals.ARRAY_OF_ZONES indexOfObject:globals.CURRENT_ZONE]];
//        }else{
//            [self.zoneSegmentedControl setSelectedSegmentIndex:1];
//            [self.zoneSegmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
//            
//        }
//
//    }
//    
}




- (void)halfValueChanged:(id)sender {
//    
//    [[NSNotificationCenter defaultCenter ]postNotificationName:@"StopUpdate" object:nil];
//
//    
//    nameforHalf = [self.periodSegmentedControl titleForSegmentAtIndex:[self.periodSegmentedControl selectedSegmentIndex]];
//    NSString *tagTime;
//    if (globals.CURRENT_PERIOD < 0) {
//        tagTime = @"0.01";
//    } else {
//        tagTime = [live2BenchViewController getCurrentTimeforNewTag];
//    }
//    
//    //reallocating in order to start new half
//
//    dictforHalf= [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"%d",[self.periodSegmentedControl selectedSegmentIndex]],@"period",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",[NSString stringWithFormat:@"%d",[self.periodSegmentedControl selectedSegmentIndex]],@"name",tagTime,@"time",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",@"17",@"type",nil];
//    
////    [updateSeekInfoTimer fire];
//    if(!globals.HAS_MIN)
//    {
//        NSMutableDictionary *d = [[NSMutableDictionary alloc]initWithDictionary:dictforHalf];
//        [d setObject:[@"half_" stringByAppendingString:tagTime] forKey:@"id"];
//        NSUInteger dTotalSeconds = [tagTime floatValue];
//        NSUInteger dHours = floor(dTotalSeconds / 3600);
//        NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
//        NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
//        NSString *displayTime = [NSString stringWithFormat:@"%01i:%02i:%02i",dHours, dMinutes, dSeconds];
//        [d setObject:displayTime forKey:@"displaytime"];
//
//        NSString *offlineType;
//        if (globals.CURRENT_PERIOD < 0) {
//            //first time press half button, create odd type tag, won't show up in clip view or list view
//            offlineType = @"17";
//        }else{
//            offlineType = @"18";
//        }
//        [d setObject:offlineType forKey:@"type"];
//        [d setObject:@"1" forKey:@"own"];
//        [d setObject:@"1" forKey:@"local"];
//        [self createOfflineDurationTagOfType:offlineType withDict:d];
//    }else{
//        if (globals.CURRENT_PERIOD < 0) {
//            [globals.ARRAY_OF_TAGSET addObject:dictforHalf];
//        }else{
//            [self sendTagInfo:dictforHalf];
//        }
//        
//    }
//        globals.CURRENT_PERIOD = [self.periodSegmentedControl selectedSegmentIndex];
}

-(void)restartUpdateTimer
{
    if(updateSeekInfoTimer==nil)
    {
        updateSeekInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(updateControlInfoWhileSeeking)
                                                             userInfo:nil
                                                              repeats:YES];
    }
}

//we need to find the length of the duration tag -- will be from the beginning of this tag to either the end of the whole game of the beginning of the next tag
-(float)findTagDurationStarting:(float)startTime withType:(NSString*)type
{
//    //check if there are any tags at all with this type -- if not, return duration of video - start time
//    //if there are, and this is the last item in the index , return duration of video -start time
//    //else return time of the tag after this one minus this tag time
//    
//    if(![globals.OFFLINE_DURATION_TAGS objectForKey:type])
//    {
//        if(live2BenchViewController.videoPlayer.durationInSeconds<startTime)
//        {
//            return 0.0f;
//        }
//        return  live2BenchViewController.videoPlayer.durationInSeconds-startTime;
//    }else {
//        int binIndex= [[globals.DURATION_TYPE_TIMES objectForKey:type] binarySearch:[NSNumber numberWithFloat:startTime]];
//        if(binIndex >= [[globals.DURATION_TYPE_TIMES objectForKey:type]count]-1)
//        {
//            return  live2BenchViewController.videoPlayer.durationInSeconds-startTime;
//        }else{
//            return [[[[globals.OFFLINE_DURATION_TAGS objectForKey:type] objectAtIndex:binIndex] objectForKey:@"time"] floatValue]-startTime;
//        }
//    }
    return 0;
}

- (void)addToGlobalDurations:(NSMutableDictionary *)nDict type:(NSString *)type
{
//    if([[nDict objectForKey:@"type" ] isEqualToString:@"0"]) //we don't care about normal tags, they don't have durations
//    {
//        return;
//    }
//    //we are going to save the duration tag to the global duration dictionary by key time
//    NSString *timeStr = [nDict objectForKey:@"time"]; //grab time
//    if(![[globals.DURATION_TAGS_TIME allKeys] containsObject:timeStr]) //if the duration dictionary doesn't already have this time then add it
//    {
//        //use the type value as the key, and the name value as the object in keyvalue pair
//        NSMutableDictionary *t = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[nDict objectForKey:@"name"],[NSString stringWithFormat:@"%@",[nDict objectForKey:@"type"] ], nil];
//        [globals.DURATION_TAGS_TIME setObject: t forKey:timeStr]; // set the new dictionary to the global duration dict
//        
//    }else{ //if for some odd reason the time already exists as a key -- will probably only happen at the beginning of the game
//        NSMutableDictionary *t = [[NSMutableDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:timeStr]];
//        int typeInt = [type intValue];
//        NSString *typeStrStart = [NSString stringWithFormat:@"%d",typeInt-1];// string reprsentation of the starting tag for whatever tag you are on ... we want to make sure that it doesn't already exist at this time, and if it does we will delete it
//        if([[t allKeys]containsObject:typeStrStart])
//        {
//            [t removeObjectForKey:typeStrStart];
//        }
//        [t setObject:[nDict objectForKey:@"name"] forKey:[NSString stringWithFormat:@"%@",[nDict objectForKey:@"type"]]];
//        [globals.DURATION_TAGS_TIME setObject:t forKey:timeStr];// replace the old dictionary with the new one.
//    }
//    
//    //// Now we put the time tagged into the global time array, but it has to be chronologically sorted
//    if([[globals.DURATION_TYPE_TIMES objectForKey:type] count]>0) // only use the sorting algorithm if there is something in the array
//    {
//        NSMutableArray *ty = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:type]];
//        if(![ty containsObject:timeStr])
//        {
//            NSInteger *index = [ty binarySearch:timeStr];
//            index = (int)index > 0 ? index : 0;
//            [ty insertObject:timeStr atIndex:index];
//            [globals.DURATION_TYPE_TIMES setObject:ty forKey:type];
//        }
//        
//    }else{//otherwise just add the time to the array
//        NSMutableArray *ty = [[NSMutableArray alloc] initWithObjects:timeStr, nil];
//        [globals.DURATION_TYPE_TIMES setObject:ty forKey:type];
//    }
}


-(void)createOfflineDurationTagOfType:(NSString*)type withDict:(NSMutableDictionary*)nDict
{
//    
//    //if no min
//    //grab the array of lines
//    //take the last one in the index
//    //update its duration
//    //create current line, set it to the current line
//    //set its duration from start time till end time
//    //add it to the big array
//    if(globals.HAS_MIN)
//    {
//        return; //dont bother if there is min, we don't need this method
//    }else{
//        //check if there is anything in the dictionary with this type, if not then create it
//        NSString* currentTime= [nDict objectForKey:@"time"];
//        if([[nDict objectForKey:@"time" ] isEqualToString:@"nan"])
//        {
//            [nDict setObject:@"0.01" forKey:@"time"];
//        }
//
//        //if tag type does not exist or type is odd, do not create thumbnails
//        if(![globals.OFFLINE_DURATION_TAGS objectForKey:type] || [type intValue]&1)
//        {
//            [nDict setObject:type forKey:@"type"];
//            [nDict setObject:[NSNumber numberWithFloat:[self findTagDurationStarting:[currentTime floatValue] withType:type]] forKey:@"duration"];
//            
//            NSMutableArray *t = [[NSMutableArray alloc] initWithObjects:nDict, nil];
//            [globals.OFFLINE_DURATION_TAGS setObject:t forKey:type];
//            [globals.OFFLINE_DURATION_TAGS setObject:t forKey:[NSString stringWithFormat:@"%d",[type intValue]+1]];
//    
//            [self addToGlobalDurations:nDict type:type];
//            //used to update the first zone and half info in updatecontrolinforwhileseeking method
//            [self addToGlobalDurations:nDict type:[NSString stringWithFormat:@"%d",[type intValue]+1]];
//            //save tag information in global dictionary
//            [globals.CURRENT_EVENT_THUMBNAILS setObject:nDict forKey:[NSString stringWithFormat:@"%@",[nDict objectForKey:@"id"]]];
//            return;
//        }
//        
//        NSMutableArray *allTimes = [[NSMutableArray alloc] init]; //we'll store all of the duration tagtimes here of this type
//        for(NSMutableDictionary *d in [globals.OFFLINE_DURATION_TAGS objectForKey:type])
//        {
//            int i =[[globals.OFFLINE_DURATION_TAGS objectForKey:type] indexOfObject:d];
//            if(![allTimes containsObject:[d objectForKey:@"time"]])
//            {
//                if ([[d objectForKey:@"time"] isKindOfClass:[NSNumber class]]) {
//                    
//                    [allTimes addObject:[NSString stringWithFormat:@"%@",[d objectForKey:@"time"]]];
//                    
//                    [d setObject:[NSString stringWithFormat:@"%@",[d objectForKey:@"time"]] forKey:@"time"];
//                    [[globals.OFFLINE_DURATION_TAGS objectForKey:@"type"] replaceObjectAtIndex:i withObject:d];
//                }else{
//                    [allTimes addObject:[d objectForKey:@"time"]];//grab the tagtimes of all the tags and add them to the array
//                }
//            }
//        }
//        //sorting
//        [allTimes sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
//            return [str1 compare:str2 options:(NSNumericSearch)];
//        }];
//        
//        NSMutableArray *allTimesD = [[NSMutableArray alloc] init];
//        
//        
//        
//        NSArray *sortedArray;
//        sortedArray = [[globals.OFFLINE_DURATION_TAGS objectForKey:type] sortedArrayUsingComparator:(NSComparator)^(id a, id b) {
//            NSNumber *num1 =[ NSNumber numberWithFloat:[[a objectForKey:@"time"] floatValue]];
//            NSNumber *num2 = [ NSNumber numberWithFloat:[[b objectForKey:@"time"] floatValue]];
//            
//            return [num1 compare:num2];
//        }];
//        
//        allTimesD=(NSMutableArray*)[sortedArray mutableCopy];
//        int binIndex = [allTimes binarySearch:currentTime]; //binary search to find where this tag lies
//        
//        if(binIndex<0)
//        {
//            binIndex=0;
//        }
//        if (binIndex>allTimesD.count-1)
//        {
//            binIndex=allTimesD.count-1;
//        }
//        NSMutableDictionary *tdict = [[NSMutableDictionary alloc] initWithDictionary:[allTimesD objectAtIndex:binIndex]]; //grab dictionary for the tag previous to this one
//        
//        [tdict setObject:type forKey:@"type"];
//        NSString *duration = [NSString stringWithFormat:@"%d",(int)([currentTime floatValue] - [[tdict objectForKey:@"time" ] floatValue])];
//        [tdict setObject:duration forKey:@"duration"];
//        //save tag information in global dictionary
//        //[globals.CURRENT_EVENT_THUMBNAILS setObject:tdict forKey:[NSString stringWithFormat:@"%@",[tdict objectForKey:@"id"]]];
//        
//        //update the old dictionary
//        [[globals.OFFLINE_DURATION_TAGS objectForKey:type] replaceObjectAtIndex:binIndex withObject:tdict];
//        
//        if(!(binIndex==[[globals.OFFLINE_DURATION_TAGS objectForKey:type] count]-1))
//        {
//            [[globals.OFFLINE_DURATION_TAGS objectForKey:type] insertObject:nDict atIndex:binIndex+1];
//        }else{
//            [[globals.OFFLINE_DURATION_TAGS objectForKey:type] addObject:nDict];
//        }
//        
//        
//        [self addToGlobalDurations:nDict type:type];
//        
//        NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
//        NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[tdict objectForKey:@"id"]];
//        NSString *imagePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
//        [tdict setObject:imagePath forKey:@"url"];
//        //save tag information in global dictionary
//        [globals.CURRENT_EVENT_THUMBNAILS setObject:tdict forKey:[NSString stringWithFormat:@"%@",[tdict objectForKey:@"id"]]];
//        //save the thumbnail image in local storage. This is running in the background thread
//        [self restartUpdateTimer];
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                                 (unsigned long)NULL), ^(void) {
//            BOOL isDir;
//            if(![[NSFileManager defaultManager] fileExistsAtPath:globals.THUMBNAILS_PATH isDirectory:&isDir])
//            {
//                [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
//            }
//            
//            //create thumbnail using avfoundation and save it in the local dir
//            NSURL *videoURL = live2BenchViewController.videoPlayer.videoURL;
//            AVAsset *asset = [AVAsset assetWithURL:videoURL];
//            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
//            [imageGenerator setMaximumSize:CGSizeMake(190, 106)];
//            [imageGenerator setApertureMode:AVAssetImageGeneratorApertureModeProductionAperture];
//            //CMTime time = [[dict objectForKey:@"cmtime"] CMTimeValue];//CMTimeMake(30, 1);
//            CMTime time = CMTimeMakeWithSeconds([[tdict objectForKey:@"time"] floatValue], 1);
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
//            
//        });
//    }
}


//we want to make sure the periods and lines are updated when the user is scrolling, the bottom view controller should always show the current
//state of the game at that specific time

//take the time thats passed in, do a binary search and find which period, line, strength, etc...

-(void)updateControlInfoWhileSeeking
{
    
//    Float64 currentTime = [live2BenchViewController.videoPlayer currentTimeInSeconds];
//    NSString *tagTime= [NSString stringWithFormat:@"%.f",currentTime];
//    NSMutableArray *h = [[NSMutableArray alloc] initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:@"18"]]; //will hold all the half times
//    if(globals.HAS_MIN &&[globals.DURATION_TYPE_TIMES objectForKey:@"17"] )
//    {
//        [h addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:@"17"]];
//    }
//    
//    
//    NSMutableArray *z =[[NSMutableArray alloc] initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:@"16"]]; //holds all the zone times
//    
//    if(globals.HAS_MIN &&[globals.DURATION_TYPE_TIMES objectForKey:@"15"] )
//    {
//        [z addObjectsFromArray:[globals.DURATION_TYPE_TIMES objectForKey:@"15"]];
//    }
//    NSString *closestHalfTagTime=[self getClosestTagTime:tagTime withArray:h];
//    NSString *closestZoneTagTime=[self getClosestTagTime:tagTime withArray:z];
//    
//    NSDictionary *timeHalfDict=[[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestHalfTagTime] ];
//    NSDictionary *timeZoneDict=[[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:closestZoneTagTime] ];
//
//    globals.CURRENT_PERIOD=[uController extractIntFromStr:[timeHalfDict objectForKey:@"18"]] ? [uController extractIntFromStr:[timeHalfDict objectForKey:@"18"]] :[uController extractIntFromStr:[timeHalfDict objectForKey:@"17"] ];
//
//    if ([globals.WHICH_SPORT isEqualToString:@"soccer"]) {
//        globals.CURRENT_ZONE=[timeZoneDict objectForKey:@"16"] ? [timeZoneDict objectForKey:@"16"] :[timeZoneDict objectForKey:@"15"];
//        [self.zoneSegmentedControl setSelectedSegmentIndex:[globals.ARRAY_OF_ZONES indexOfObject:globals.CURRENT_ZONE]];
//    }
//
//    [self.periodSegmentedControl setSelectedSegmentIndex:globals.CURRENT_PERIOD];
//    
}

-(NSString*)getClosestTagTime:(NSString*)tagTime withArray:(NSArray*)a
{
    NSMutableArray *t = [[NSMutableArray alloc] initWithArray:a];
    [t sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        return [str1 compare:str2 options:(NSNumericSearch)];
    }];

    int sortedIndex;
    NSString *closestTagTime;
    if (t.count > 1) {
        int binSearchIndex =[t binarySearch:tagTime] ; // binsearch returns -1 if time not found
        binSearchIndex = (int)binSearchIndex <0 ? 0:binSearchIndex; // make sure the binary search index is greater then 0
        
        sortedIndex=(int)binSearchIndex >t.count-1 ? t.count-1 : binSearchIndex-1;
        sortedIndex=(int)sortedIndex <0 ? 0:sortedIndex; //make sure index isn't less then 0
        
        closestTagTime = [t objectAtIndex:sortedIndex];
    }else if(t.count==1){
        closestTagTime = [t objectAtIndex:0];
    }
    return closestTagTime;
}

- (void)zoneValueChanged:(id)sender {
//    [[NSNotificationCenter defaultCenter ]postNotificationName:@"StopUpdate" object:nil];
//
//    nameforZone = [self.zoneSegmentedControl titleForSegmentAtIndex:[self.zoneSegmentedControl selectedSegmentIndex]];
//    NSString *tagTime;
//    if (!globals.CURRENT_ZONE) {
//        tagTime = @"0.01";
//    }else{
//        tagTime = [live2BenchViewController getCurrentTimeforNewTag];
//    }
//    
//
//    dictforZone = [[NSDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",nameforZone,@"name",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",nameforZone,@"line", @"15",@"type", nil];//,nil];
//  
//    if (globals.HAS_MIN) {
//        if (!globals.CURRENT_ZONE) {
//            [globals.ARRAY_OF_TAGSET addObject:dictforZone];
//        }else{
//            [self sendTagInfo:dictforZone];
//        }
//        
//    }else{
//        NSMutableDictionary *d = [[NSMutableDictionary alloc]initWithDictionary:dictforZone];
//        [d setObject:[@"zone_" stringByAppendingString:tagTime] forKey:@"id"];
//        NSUInteger dTotalSeconds = [tagTime floatValue];
//        NSUInteger dHours = floor(dTotalSeconds / 3600);
//        NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
//        NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
//        NSString *displayTime = [NSString stringWithFormat:@"%01i:%02i:%02i",dHours, dMinutes, dSeconds];
//        [d setObject:displayTime forKey:@"displaytime"];
//        NSString *offlineType;
//        if (!globals.CURRENT_ZONE) {
//            //if first time press zone button, make a odd type tag which won't show up in clip view or list view
//            offlineType = @"15";
//        }else{
//            offlineType = @"16";
//        }
//        [d setObject:offlineType forKey:@"type"];
//        [d setObject:@"1" forKey:@"own"];
//        [d setObject:@"1" forKey:@"local"];
//        [self createOfflineDurationTagOfType:offlineType withDict:d];
//    }
//    
//    globals.CURRENT_ZONE = [[NSMutableString alloc] initWithString:nameforZone];
}

-(void)stopUpdateTimer
{
    [updateSeekInfoTimer invalidate];
    updateSeekInfoTimer=nil;
}


- (void)playerButtonSelected:(id)sender{
//    CustomButton *button = (CustomButton*)sender;
//    NSString *tagTime = [live2BenchViewController getCurrentTimeforNewTag];
//
//    if (![tagTime isEqualToString:@"nan"]) {
//        if (!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer)) {
//            //dictionary which is generated when a duration tag is closed
//            NSMutableDictionary *closeDurationDict;
//            
//            NSUInteger dTotalSeconds = [tagTime floatValue];
//            NSUInteger dHours = floor(dTotalSeconds / 3600);
//            NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
//            NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
//            NSString *displayTime = [NSString stringWithFormat:@"%01i:%02i:%02i",dHours, dMinutes, dSeconds];
//
//            NSMutableDictionary *dict;
//           
//        
//            //If no players are selected for tag
//            if (!live2BenchViewController.isDurationTagEnabled ) {
//                dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text],@"name",[NSArray arrayWithObject:button.titleLabel.text],@"player",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", displayTime, @"displaytime",[NSString stringWithFormat:@"%f",[tagTime floatValue] - 10.0], @"starttime", @"20", @"duration", [@"temp_" stringByAppendingString:tagTime] ,@"id",@"0", @"type",  @"", @"comment", @"", @"rating", @"0", @"coachpick", @"0", @"bookmark", @"0", @"deleted", @"0",@"edited",@"1", @"local",nil];
//            }else if (live2BenchViewController.isDurationTagEnabled && !button.selected){
//                dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text],@"name",[NSArray arrayWithObject:button.titleLabel.text],@"player",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", displayTime, @"displaytime",tagTime, @"starttime", @"20", @"duration", [@"temp_" stringByAppendingString:tagTime] ,@"id",@"0", @"type",  @"", @"comment", @"", @"rating", @"0", @"coachpick", @"0", @"bookmark", @"0", @"deleted", @"0",@"edited",@"1", @"local",nil];
//            }
//   
//            //if duration-tag control enabled, create new duration tag or close an old duration tag
//            if (live2BenchViewController.isDurationTagEnabled && !button.selected) {
//                
//                if (playerbuttonWasSelected.selected) {
//                    playerbuttonWasSelected.selected = FALSE;
//                    //close the previous duration tag
//                    if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allKeys]containsObject:[NSString stringWithFormat:@"Pl. %@",playerbuttonWasSelected.titleLabel.text]]) {
//                        closeDurationDict = [[globals.OPENED_DURATION_TAGS objectForKey:[NSString stringWithFormat:@"Pl. %@",playerbuttonWasSelected.titleLabel.text]]mutableCopy];
//                        int durationNumber =(int)([tagTime floatValue] - [[[globals.OPENED_DURATION_TAGS objectForKey:[NSString stringWithFormat:@"Pl. %@",playerbuttonWasSelected.titleLabel.text]] objectForKey:@"time"] floatValue]);
//                        NSString *duration;
//                        if (durationNumber >= 0) {
//                            duration = [NSString stringWithFormat:@"%d",durationNumber];
//                        }else{
//                            durationNumber = -durationNumber;
//                            duration = [NSString stringWithFormat:@"%d",durationNumber];
//                            [closeDurationDict setObject:displayTime forKey:@"displaytime"];
//                            [closeDurationDict setObject:tagTime forKey:@"time"];
//                            [closeDurationDict setObject:tagTime forKey:@"starttime"];
//                        }
//                        
//                        [closeDurationDict setObject:duration forKey:@"duration"];
//                        [globals.OPENED_DURATION_TAGS removeObjectForKey:[NSString stringWithFormat:@"Pl. %@",playerbuttonWasSelected.titleLabel.text]];
//                    }
//                }else{
//                    [live2BenchViewController deSelectTagButton];
//                }
//                button.selected = TRUE;
//                
//                [globals.OPENED_DURATION_TAGS setObject:dict forKey:[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text]];
//                
//            }else if (live2BenchViewController.isDurationTagEnabled && button.selected){
//                //close this duration tag
//                if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allKeys]containsObject:[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text]]) {
//                    closeDurationDict = [[globals.OPENED_DURATION_TAGS objectForKey:[NSString stringWithFormat:@"Pl. %@",playerbuttonWasSelected.titleLabel.text]]mutableCopy];
//                    int durationNumber =(int)([tagTime floatValue] - [[[globals.OPENED_DURATION_TAGS objectForKey:[NSString stringWithFormat:@"Pl. %@",playerbuttonWasSelected.titleLabel.text]] objectForKey:@"time"] floatValue]);
//                    NSString *duration;
//                    if (durationNumber >= 0) {
//                        duration = [NSString stringWithFormat:@"%d",durationNumber];
//                    }else{
//                        durationNumber = -durationNumber;
//                        duration = [NSString stringWithFormat:@"%d",durationNumber];
//                        [closeDurationDict setObject:displayTime forKey:@"displaytime"];
//                        [closeDurationDict setObject:tagTime forKey:@"time"];
//                        [closeDurationDict setObject:tagTime forKey:@"starttime"];
//                    }
//                    [closeDurationDict setObject:duration forKey:@"duration"];
//                    [globals.OPENED_DURATION_TAGS removeObjectForKey:[NSString stringWithFormat:@"Pl. %@",playerbuttonWasSelected.titleLabel.text]];
//                }
//                
//                
//                button.selected = FALSE;
//            }
//            
//            if (live2BenchViewController.isDurationTagEnabled && closeDurationDict) {
//                //if one duration tag closed, generate the thumbnail and add it to the globals tags dictionary
//                dict = closeDurationDict;
//            }else if (live2BenchViewController.isDurationTagEnabled && !closeDurationDict){
//                playerbuttonWasSelected = button;
//                //if no duration tag closed, return
//                return;
//            }
//
//            
//            //save tag information in global dictionary
//            NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
//            NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[dict objectForKey:@"id"]];
//            NSString *imagePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
//            
//            [dict setObject:imagePath forKey:@"url"];
//            
//            [globals.CURRENT_EVENT_THUMBNAILS setObject:dict forKey:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
//            //[live2BenchViewController markTag:[tagTime floatValue] name:[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text] colour:[uController colorWithHexString:[globals.ACCOUNT_INFO objectForKey:@"tagColour"]] tagID: [[@"temp_" stringByAppendingString:tagTime] doubleValue]];
//            //create tag marker for the current tag
////            [live2BenchViewController markTagAtTime:[tagTime floatValue] colour:[uController colorWithHexString:[globals.ACCOUNT_INFO objectForKey:@"tagColour"]] tagID:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
//            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                                     (unsigned long)NULL), ^(void) {
//                BOOL isDir;
//                if(![[NSFileManager defaultManager] fileExistsAtPath:globals.THUMBNAILS_PATH isDirectory:&isDir])
//                {
//                    [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
//                }
//                
//                //create thumbnail using avfoundation and save it in the local dir
//                NSURL *videoURL = live2BenchViewController.videoPlayer.videoURL;
//                AVAsset *asset = [AVAsset assetWithURL:videoURL];
//                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
//                [imageGenerator setMaximumSize:CGSizeMake(190, 106)];
//                [imageGenerator setApertureMode:AVAssetImageGeneratorApertureModeProductionAperture];
//                //CMTime time = [[dict objectForKey:@"cmtime"] CMTimeValue];//CMTimeMake(30, 1);
//                CMTime time = CMTimeMakeWithSeconds([[dict objectForKey:@"time"] floatValue], 1);
//                CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
//                UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
//                CGImageRelease(imageRef);
//                
//                NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
//                if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir])
//                {
//                    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
//                }
//                //add image to directory
//                [imageData writeToFile:imagePath atomically:YES ];
//                        
//            });
//
//        }else{
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text],@"name",[NSArray arrayWithObject:button.titleLabel.text],@"player",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time",nil];
//            if (live2BenchViewController.isDurationTagEnabled) {
//                if (dict) {
//                    
//                    //if duration-tag control enabled, create new duration tag or close an old duration tag
//                    if (!button.selected) {
//                        [dict setObject:@"99" forKey:@"type"];
//                        //send device information to the server
//                        NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
//                        [dict setObject:UUID forKey:@"deviceid"];
//
//                        if (playerbuttonWasSelected.selected) {
//                            playerbuttonWasSelected.selected = FALSE;
//                        }else{
//                            [live2BenchViewController deSelectTagButton];
//                        }
//                        button.selected = TRUE;
//                        [self sendTagInfo:dict];
//                    }else if (button.selected){
//                        if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allKeys] containsObject:[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text]]) {
//                            [dict setObject:@"100" forKey:@"type"];
//                            //send device information to the server
//                            NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
//                            [dict setObject:UUID forKey:@"deviceid"];
//
//                            id tagId = [globals.OPENED_DURATION_TAGS objectForKey:[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text]];
//                            [dict setObject:tagId forKey:@"id"];
//                            [globals.OPENED_DURATION_TAGS removeObjectForKey:[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text]];
//                            
//                            [self sendTagInfo:dict];
//                        }else{
//                            [dict setObject:@"100" forKey:@"type"];
//                            
//                            [globals.PRECLOSED_DURATION_TAGS setObject:dict forKey:[NSString stringWithFormat:@"Pl. %@",button.titleLabel.text]];
//                        }
//                        
//                        button.selected = FALSE;
//                        
//                    }
//                    
//                }
//
//            }else{
//                [self sendTagInfo:dict];
//            }
//            
//        }
//
//    }
//    
//    playerbuttonWasSelected = button;
}

-(void)deSelectTagButton{
    if (playerbuttonWasSelected && playerbuttonWasSelected.selected) {
        [playerbuttonWasSelected sendActionsForControlEvents:UIControlEventTouchUpInside];
        playerbuttonWasSelected.selected = FALSE;
        playerbuttonWasSelected = nil;
    }
}

-(void)sendTagInfo:(NSDictionary *)dict{
//    if (!globals.HAS_MIN) {
//        return;
//    }
    NSMutableDictionary *tempDict = [dict mutableCopy];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempDict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {

    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSString *url;
//    if ([dict objectForKey:@"type"] && [[dict objectForKey:@"type"] isEqualToString:@"100"]) {
//        //close duration tag
//        url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
//    }else{
//        //create new tags
//        url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString];
//    }
    


    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self]; //[NSURLConnection connectionWithRequest:urlRequest delegate:self];
  
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    
}

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

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //send new tag information to the server
    id json;
    if(responseData)
    {
        
        json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        if ([[json objectForKey:@"success"]intValue] == 0 && [json objectForKey:@"msg"]) {
            CustomAlertView *alert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:[json objectForKey:@"msg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
//            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
        }
        
//        if(!json){
//            NSString *foo = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
//            NSLog(@"foo %@",foo);
//        }
    }
    responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
   
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"Error in making tags." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
    
}


-(void) nullFunction{
    
}

//create thumbnail images
-(void)handleNewThumbnail:(id)jsonArray
{
   
//    
//    //extract url from jsonarray
//    NSString *url = [jsonArray objectForKey:@"url"];
//    NSURL *jurl;
//    if (url != nil) {
//        jurl = [[NSURL alloc]initWithString:[jsonArray objectForKey:@"url"]];
//        NSMutableDictionary *thumbInfoSubDict = [jsonArray mutableCopy];
//        
//        NSString *path = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
// 
//        //        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]init];
//     
//        NSString *imageName = [jurl lastPathComponent];
//        
//        [thumbInfoSubDict setObject:imageName forKey:@"imageName"];
//        
//        float tagTime = [[thumbInfoSubDict objectForKey:@"time"] floatValue];
//        //NSString *tagName = [thumbInfoSubDict objectForKey:@"name"];
//        UIColor *tagColour =[uController colorWithHexString:[thumbInfoSubDict objectForKey:@"colour"]];
//        //NSString *tagId = [thumbInfoSubDict objectForKey:@"id"];
//        //[live2BenchViewController markTag:tagTime name:tagName colour:tagColour tagID:[[thumbInfoSubDict objectForKey:@"id"] doubleValue]];
//        //create tag marker for the current tag
////        [live2BenchViewController markTagAtTime:tagTime colour:tagColour tagID:[NSString stringWithFormat:@"%@",[thumbInfoSubDict objectForKey:@"id"]]];
//        
//        //[globals.CURRENT_EVENT_THUMBNAILS addObject:thumbInfoSubDict];
//        NSString *tagId = [NSString stringWithFormat:@"%@",[thumbInfoSubDict objectForKey:@"id"]];
//        [globals.CURRENT_EVENT_THUMBNAILS setObject:thumbInfoSubDict forKey:tagId];
//        [globals.CURRENT_EVENT_THUMBNAILS writeToFile: path atomically:YES];
//        //create second thread to create the thumbnail
//        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            NSData *imgData= [NSData dataWithContentsOfURL:jurl options:0 error:nil];
//          
//            
//            //add image to directory
//            NSString *filePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
//            
//            
//            
//            [imgData writeToFile:filePath atomically:NO ];
//            
//            dispatch_async( dispatch_get_main_queue(), ^{
//                //back to main thread
//
//                
//            });
//        });
//        
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end