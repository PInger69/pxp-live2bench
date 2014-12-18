
//
//  CustomTabBar.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-21.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "CustomTabBar.h"
#import "StatsTabViewController.h"
#import "EncoderClasses/EncoderManager.h"

#define SHOW_STATS_TAB              YES

#define TAB_WIDTH                   171//1024/6.0
#define HORIZANTAL_TAB_SPACING      0
#define TIMER_PERIOD                0.1
#define NUM_STEPS                   7

#import "CustomTabViewController.h"
#import "DebuggingTabViewController.h"
static NSArray *tabBarItems = nil;
static NSMutableArray *tabButtonItems=nil;

@implementation CustomTabBar
{
    NSMutableDictionary * tabNameReferenceDict;

}
@synthesize spinnerView;
@synthesize progressViewTextLabel;
@synthesize loadingProgressView;
@synthesize uploadLocalTagsLabel;
@synthesize loginViewController;
@synthesize updateAppStateTimer;
@synthesize waitingEncoderSelection;
@synthesize tabBar;
@synthesize uploadLocalTagButton;
@synthesize popoverController;
@synthesize tBar = _tBar;


-(void)viewDidLoad
{
    [super viewDidLoad];
    if(!globals)
    {
        globals=[Globals instance];
    }
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppStateChange:)        name:NOTIF_APST_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationSelectTab:)   name:NOTIF_SELECT_TAB object:nil];
    //init utilities
    if(!uController)
    {
        uController=[[UtilitiesController alloc]init];
    }
    
    
    //resize window so that there is no black strip at bottom, (black strip from native tab bar) move native tab bar off screen.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.0];
     UIView *nativeTabView = [self.view.subviews objectAtIndex:1];
    [nativeTabView setFrame:CGRectMake(-1024, -1024, nativeTabView.frame.size.width, nativeTabView.frame.size.height)];
    [UIView commitAnimations];
    
    toastAnimationDidStart = FALSE;
    if(!toastTimer)
    {
        toastTimer=[NSTimer scheduledTimerWithTimeInterval:1
                                                             target:self
                                                           selector:@selector(createToastsFromQueue)
                                                           userInfo:nil
                                                            repeats:YES];
        [toastTimer fire];
    }
    
    //create toast view and hide it for now
    if(![self.view.subviews containsObject:toast])
    {
        toast=[[Toast alloc] init];
        [toast setFrame:CGRectMake(5, 768, 200, 50)];
        [toast setBackgroundColor:[UIColor whiteColor]];//[uController colorWithHexString:@"bec7d6"]];
        [toast setAlpha:1];
        
        toast.opaque = YES;
        [self.view setClipsToBounds:FALSE];
        [self.view addSubview:toast];
       
    }
    
    
    firstLoadGoToCalendar = FALSE;
    globals.CURRENT_APP_STATE = apstNotInited ;// set app status to 0 so we can initialise variables;
    
    //flash button indicating local tags uploading
    uploadLocalTagButton = [[UploadButton alloc]init];
    [uploadLocalTagButton setHidden:TRUE];
    [uploadLocalTagButton addTarget:self action:@selector(showUploadLocalTagsLabel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadLocalTagButton];
    

}

//display the label of uploading local tags to the server
-(void)showUploadLocalTagsLabel{
    UIViewController* popoverContent = [[UIViewController alloc] init];
    UIView *popoverView = [[UIView alloc]init];
    uploadLocalTagsLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 350, 40)];
    [uploadLocalTagsLabel setTextColor:[UIColor orangeColor]];
    [uploadLocalTagsLabel setBackgroundColor:[UIColor clearColor]];
    [popoverView addSubview:uploadLocalTagsLabel];
    //[popoverView setBackgroundColor:[UIColor whiteColor]];
    popoverContent.view = popoverView;
    popoverController = [[UIPopoverController alloc]initWithContentViewController:popoverContent];
    [popoverController setPopoverContentSize:CGSizeMake(350, 50)];
    if (globals.IS_IN_FIRST_VIEW) {
          [popoverController presentPopoverFromRect:CGRectMake(-120,60,350,50) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }else{
          [popoverController presentPopoverFromRect:CGRectMake(-290,60,350,50) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
  
}
        
-(void)setupView
{
    AppDelegate * appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
  
    
    LogoViewController          *logoVC     = [[LogoViewController alloc] init];
    CalendarViewController      *calendarVC = [[CalendarViewController alloc] initWithAppDelegate:appDel];
    Live2BenchViewController    *liveVC     = [[Live2BenchViewController alloc] initWithAppDelegate:appDel];
    ClipViewController          *clipVC     = [[ClipViewController alloc] init];
    ListViewController          *listVC     = [[ListViewController alloc] init];
    BookmarkViewController      *bookmarkVC = [[BookmarkViewController alloc] initWithAppDelegate:appDel];
    StatsTabViewController      *statsVC    = [[StatsTabViewController alloc] init];
    DebuggingTabViewController  *debugTabView  = [[DebuggingTabViewController alloc]initWithAppDelegate:appDel];
    NSMutableArray              *vcArray    = [NSMutableArray arrayWithObjects:logoVC, calendarVC, liveVC, clipVC, listVC, bookmarkVC, nil];
    if(SHOW_STATS_TAB)
        //   [vcArray addObject:statsVC];
        //    if(SHOW_STATS_TAB)
        [vcArray addObject:debugTabView];
    for (UIViewController *vc in vcArray) {
        [self addChildViewController:vc];

    }
    
    

}

-(void)createToastsFromQueue
{
    
    if(globals.TOAST_QUEUE.count <1 || toastAnimationDidStart)
    {
       // NSLog(@"inside brackets, globals.TOAST_QUEUE.count = %d, toastAnimationDidStart = %d",globals.TOAST_QUEUE.count,toastAnimationDidStart);
        return  ; // if queue has nothing, then return
    }
    //NSLog(@"outside brackets, globals.TOAST_QUEUE.count = %d, toastAnimationDidStart = %d",globals.TOAST_QUEUE.count,toastAnimationDidStart);

    if (globals.SWITCH_TO_DIFFERENT_EVENT){
        //remove all objects from toast queue which came from the old event
        [globals.TOAST_QUEUE removeAllObjects];
        //if there are lots of new tags from old event, remove them; otherwise, it will cause huge delay to receive new tags from new event
        [globals.ARRAY_OF_TAGSET removeAllObjects];
        globals.SWITCH_TO_DIFFERENT_EVENT = FALSE;
        return;
    }
    
    NSMutableDictionary *currentTag = [globals.TOAST_QUEUE objectAtIndex:0];//grab first object
    if(![currentTag objectForKey:@"name"])
    {
        if([uController extractIntFromStr:[currentTag objectForKey:@"type"]] ==7 || [uController extractIntFromStr:[currentTag objectForKey:@"type"]] == 8 || [uController extractIntFromStr:[currentTag objectForKey:@"type"]] == 17 || [uController extractIntFromStr:[currentTag objectForKey:@"type"]] == 18 ||[[currentTag objectForKey:@"type"] rangeOfString:@"enc"].location!=NSNotFound)
        {
            if ([globals.TOAST_QUEUE count] > 0){
                [globals.TOAST_QUEUE removeObjectAtIndex:0];
            }
            return;
        }
    }
    NSString *tagName;
    if([currentTag objectForKey:@"name"])
    {
        tagName=[currentTag objectForKey:@"name"];
    }else{
        tagName=[currentTag objectForKey:@"id"];
    }
    
    if ([tagName rangeOfString:@"Dropbox"].location!=NSNotFound)
    {
        globals.SHOW_TOASTS=TRUE;
    }
    
    NSString *tagColour = [currentTag objectForKey:@"colour"] ? [currentTag objectForKey:@"colour"] : @"ffffff";
    [toast setBackgroundColor:[UIColor whiteColor]];//[uController colorWithHexString:@"bec7d6"]];
    toast.alpha = globals.SHOW_TOASTS ? 1.0: 0.0;
    toast.opaque = globals.SHOW_TOASTS ? YES: NO;
    //create toast with tag name and the user's colour
    [toast setEventForColour:tagName colour:tagColour];
    if (globals.SHOW_TOASTS){
        toastAnimationDidStart = TRUE;
        [UIView animateWithDuration:.2
                              delay:0.5
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             //toast.alpha = alpha;
                             [toast setFrame:CGRectMake(5, 714, 220, 50)];
                         }
                         completion:^(BOOL finished){[UIView animateWithDuration:.2
                                                                           delay:2
                                                                         options: UIViewAnimationOptionCurveEaseOut
                                                                      animations:^{
                                                                          //toast.alpha = 0.0;
                                                                          [toast setFrame:CGRectMake(5, 768, 220, 50)];
                                                                      }
                                                      
                                                                      completion:^(BOOL finished){
                                                                          if ([globals.TOAST_QUEUE count] > 0){
                                                                              [globals.TOAST_QUEUE removeObjectAtIndex:0];
                                                                          }
                                                                          toastAnimationDidStart=FALSE;
                                                                      } ];}];
    }
    if ([tagName rangeOfString:@"Dropbox"].location!=NSNotFound)
    {
        globals.SHOW_TOASTS=FALSE;
    }
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //hide original tab bar
    [self hideExistingTabBar]; // is this dead?
    [self addCustomElements]; // add custom tab bar buttons
    
    //[uController showSpinner];
     globals.SPINNERVIEW = [SpinnerView loadSpinnerIntoView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    
    updateAppStateTimer =[NSTimer scheduledTimerWithTimeInterval:TIMER_PERIOD
                                                          target:self
                                                        selector:@selector(updateAppState)
                                                        userInfo:nil repeats:YES];
    [updateAppStateTimer fire];
    
    
    //Richard
    [SpinnerView initTheGlobalSpinner];
}


//this background is for login/eula popup
-(void)addWhiteBackground{
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:globals.WHITE_BACKGROUND];
}

// add custom tab bar buttons
-(void)addCustomElements
{
    //array of tab bar items -- this array is used to create buttons in the tab bar
    TabBarButton *welcomeTab    = [[TabBarButton alloc] initWithName:@"Welcome"     andImageName:@"logoTab"];
    TabBarButton *calendarTab   = [[TabBarButton alloc] initWithName:@"Calendar"    andImageName:@"calendarTab"];
    TabBarButton *live2BenchTab = [[TabBarButton alloc] initWithName:@"Live2Bench"  andImageName:@"live2BenchTab"];
    TabBarButton *clipTab       = [[TabBarButton alloc] initWithName:@"Clip View"   andImageName:@"clipTab"];
    TabBarButton *listTab       = [[TabBarButton alloc] initWithName:@"List View"   andImageName:@"listTab"];
    TabBarButton *myClipTab     = [[TabBarButton alloc] initWithName:@"My Clip"     andImageName:@"myClipTab"];
    TabBarButton *statsTab      = [[TabBarButton alloc] initWithName:@"Stats"       andImageName:@"statsTab"];
//    welcomeTab.accessibilityLabel = @"Welcome";
//    welcomeTab.contentMode = UIViewContentModeScaleAspectFill;
//    calendarTab.accessibilityLabel = @"Calendar";
//    live2BenchTab.accessibilityLabel = @"Live2Bench";
//    clipTab.accessibilityLabel = @"Clip View";
//    listTab.accessibilityLabel = @"List View";
    NSMutableArray* tabItems = [NSMutableArray arrayWithObjects: welcomeTab, calendarTab, live2BenchTab, clipTab, listTab, myClipTab, nil];
    if(SHOW_STATS_TAB)
        [tabItems addObject:statsTab];
    
    tabBarItems = [tabItems copy];
    
    globals.CUSTOM_TAB_ITEMS = [[NSArray alloc]initWithArray:tabBarItems];
    [self createButton:tabBarItems];
}

//this view will display the app's loading progress when just open the app
-(void)addProgressView{
    
    loadingProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(300,450,400,100)];
    loadingProgressView.progress = 0.0;
    [loadingProgressView setProgressViewStyle:UIProgressViewStyleBar];
    loadingProgressView.bounds = CGRectMake(loadingProgressView.bounds.origin.x, loadingProgressView.bounds.origin.y, 400, 30);
    [globals.SPINNERVIEW addSubview:loadingProgressView];
    
    progressViewTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(315, 455, 400, 30)];
    progressViewTextLabel.text = @"";
    progressViewTextLabel.textColor = [UIColor whiteColor];
    progressViewTextLabel.backgroundColor = [UIColor clearColor];
    progressViewTextLabel.textAlignment = NSTextAlignmentCenter;
    progressViewTextLabel.bounds = CGRectMake(progressViewTextLabel.bounds.origin.x, progressViewTextLabel.bounds.origin.y, 400, 30);
    [globals.SPINNERVIEW addSubview:progressViewTextLabel];
    [self updateProgessView:0.0/NUM_STEPS :@"checking for login and eula"];
    
}

//create custom tab buttons
-(void)createButton:(NSArray*)buttonArray
{
    
    int tabCount = [self.viewControllers count];
  tabNameReferenceDict = [[NSMutableDictionary alloc]init]; // this is so the tabs can be ref by name;
    for (int i =0; i<tabCount;i++){
    
        TabBarButton* btn = ((CustomTabViewController*)[self.viewControllers objectAtIndex:i]).sectionTab ;
        btn.frame = CGRectMake(i*(self.view.bounds.size.width/tabCount), 0, self.view.bounds.size.width/tabCount + 1, 55);
        [btn setClipsToBounds:TRUE];
        [btn setTag:i];
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];


        
        [tabNameReferenceDict setObject:[NSNumber numberWithInt:i ] forKey:btn.tabName];
        
    }
    
    return;
    
//    contains actual buttons - added from the list (tabBarItems)
//    use this array to access tabs (i.e. change tabs, backgrounds, etc)
    if (tabButtonItems) return;
    tabButtonItems=[[NSMutableArray alloc]init];
    
    //we are going to go into each dict item in the button array and create a custom button with each object
    for(TabBarButton* btn in buttonArray)
    {
        int currIndex = [buttonArray indexOfObject:btn];
        
        //different images for if the tab bar is on or off
        
        btn.frame = CGRectMake(currIndex*(self.view.bounds.size.width/[buttonArray count]), 0, self.view.bounds.size.width/[buttonArray count] + 1, 55); // Set the frame (size and position) of the button)
        [btn setClipsToBounds:TRUE];
        
//        [btn setBackgroundImage:btnImageSelected forState:UIControlStateSelected]; // Set the image for the selected state of the button
        [btn setTag:currIndex]; // Assign the button a "tag" so when our "click" event is called we know which button was pressed.
       
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [tabButtonItems addObject:btn];
    }
    if(!self.tBar)
    {
        self.tBar=(UITabBar*)self.tabBarController.tabBar;
    }
}


-(void)updateProgessView:(float)loadingPercentComplete :(NSString*)currentProcessString{
    [loadingProgressView setProgress:loadingPercentComplete animated:YES] ;
    
    //progressViewTextLabel.accessibilityLabel = @"checking for wifi";
    [progressViewTextLabel setText:currentProcessString];
}


-(void)onAppStateChange:(NSNotification*)note
{
    globals.CURRENT_APP_STATE = [[note.userInfo objectForKey:@"state"]intValue];
}

-(void)updateAppState
{
    //if there are local tags uploading, show the uploadLocalTagsLabel and not in list view or my clip view (the text will overlap the tableview title);otherwise hide it
    if ((globals.ALL_LOCAL_TAGS_REQUEST_QUEUE.count > 0 && globals.NUMBER_OF_LOCAL_TAGS_UPDATED > 0) && !globals.IS_IN_BOOKMARK_VIEW && !globals.IS_IN_LIST_VIEW && !globals.IS_IN_CLIP_VIEW) {
        NSString *text = [NSString stringWithFormat:@"Uploading local tags to the server: %d/%d ",globals.NUMBER_OF_LOCAL_TAGS_UPDATED,globals.NUMBER_OF_ALL_LOCAL_TAGS];
        [uploadLocalTagsLabel setText:text];
        [uploadLocalTagButton setHidden:FALSE];
        if (globals.IS_IN_FIRST_VIEW) {
            [uploadLocalTagButton setFrame:CGRectMake(180, 60, 46.f, 36.f)];
        }else{
            [uploadLocalTagButton setFrame:CGRectMake(10, 60, 46.f, 36.f)];
        }
    }else{
        [uploadLocalTagButton setHidden:TRUE];
        [popoverController dismissPopoverAnimated:YES];
    }
    
    timerCounter ++;
    //if app state changed, reset timer counter and reset lastAppState
    if (lastAppState != globals.CURRENT_APP_STATE)
    {
        timerCounter=0;
        lastAppState = globals.CURRENT_APP_STATE;
    }
    
    ////////NSLog(@"Current app state: %i", globals.CURRENT_APP_STATE);
    switch (globals.CURRENT_APP_STATE) {
        case apstNotInited: //vars not initialised for case 0
        {
            if (!loadingProgressView) {
                [self addProgressView];
            }
            //first check user is logged in or not
            if ([[NSFileManager defaultManager] fileExistsAtPath: globals.ACCOUNT_PLIST_PATH])
            {
                //the file is only created when user is logged in
                globals.IS_LOGGED_IN =TRUE;
                //get account information,load the user's account info to a global variable
                globals.ACCOUNT_INFO = [[NSMutableDictionary alloc] initWithContentsOfFile: globals.ACCOUNT_PLIST_PATH];
                //set eula boolean value depending on whether or not user has accepted -- from the users info
                globals.IS_EULA = [[globals.ACCOUNT_INFO objectForKey:@"eula"]intValue]==1;
                
                //Richard
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_INFO_RETRIEVED object:globals.ACCOUNT_INFO];
            } //if account file exists

            firstLoadGoToCalendar = TRUE; //this is the other case when you should navigate to calendar - from live games if you're in tab 0, you should not go to calendar
            
            //check to see whether or not user has logged in
            //if they haven't then ask them to login
            if (!globals.IS_LOGGED_IN ||!globals.IS_EULA) {
                //this background is for login/eula popup
                [self addWhiteBackground];
                
                //if the user is not logged in
                if (!globals.IS_LOGGED_IN)
                {
                    BOOL hasInternetConnection = [uController checkInternetConnection];
                    //if there is no internet connection pop up the alert view
                    if (!hasInternetConnection) {
                        
                        
                        NSString * message = @"No internet connection. Please make sure the internet is successfully connected in order to log in.";
                        
                        if (![CustomAlertView alertMessageExists:message]) {
                            
                            CustomAlertView *internetConAlertView = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [internetConAlertView show];
                        }
                        
                        
                        
//                        UIAlertView *internetConAlertView = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"No internet connection. Please make sure the internet is successfully connected in order to log in." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                        BOOL *alertExists = NO;
//                        for (UIAlertView *alert in globals.ARRAY_OF_POPUP_ALERT_VIEWS){
//                            if ([alert.message isEqualToString:internetConAlertView.message]){
//                                alertExists = YES;
//                            }
//                        }
//                        if (!alertExists){
//                            [internetConAlertView show];
//                            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:internetConAlertView];
//                        }
                         globals.CURRENT_APP_STATE = apstSkipTimer;
                    }
                    //if internet is available, pop login view for the user to log in
                    loginViewController = [[LoginViewController alloc]init];
                    [loginViewController setModalPresentationStyle:UIModalPresentationFormSheet];
                    [self presentViewController:loginViewController animated:YES completion:nil];
                    
                }
                
                globals.CURRENT_APP_STATE=apstWaitLogin;
                
            }else{
                //if the user has logged in and accepted the eula, check the wifi
                
                //current loading progress: checking for wifi
                [self updateProgessView:1.0/NUM_STEPS :@"checking for wifi"];
                 globals.HAS_WIFI = [uController hasConnectivity];
                if(globals.HAS_WIFI){
                    //send ping to cloud to check has cloud or not
                    NSString *url = @"http://myplayxplay.net/max/ping/ajax";
                    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(pingServerCallback:)],self, nil];
                    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
                    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    [globals.APP_QUEUE enqueue:url dict:instObj];
                    
                    //start looking for bonjour(local encoder:min)
                    dictOfIPs = [[NSMutableDictionary alloc] initWithCapacity:1];
                    [self browseServices];
                    //reset timer counter for new app state
                    timerCounter = 0;
                    //if there is wifi
                    globals.CURRENT_APP_STATE=apstHasWifi;
                }else{
                    //if there is not wifi, then no min
                    globals.CURRENT_APP_STATE=apstNoMin;
                }
                
                //init current encoder status as empty string
                globals.CURRENT_ENC_STATUS=@""; 
            }

            break;
        }
        case apstReactiveCheck:
        {
            Reachability *internetReach = [Reachability reachabilityForInternetConnection];
            [internetReach startNotifier];
            Reachability *wifiReach = [Reachability reachabilityForLocalWiFi];
            [wifiReach startNotifier];
            
            NetworkStatus netStatus = [internetReach currentReachabilityStatus];
            NetworkStatus wifiStatus = [wifiReach currentReachabilityStatus];
            //Gives time for network to respond properly
            if (timerCounter < 0.5f/TIMER_PERIOD){
                break;
            //Checks for network connectivity for 5 seconds
            } else if ((netStatus == NotReachable || wifiStatus == NotReachable) && timerCounter < 5.0f/TIMER_PERIOD)
            {
                break;
            }
            //first check user is logged in or not
            if (!globals.IS_LOGGED_IN){
                if ([[NSFileManager defaultManager] fileExistsAtPath: globals.ACCOUNT_PLIST_PATH])
                {
                    //the file is only created when user is logged in
                    globals.IS_LOGGED_IN =TRUE;
                    //get account information,load the user's account info to a global variable
                    globals.ACCOUNT_INFO = [[NSMutableDictionary alloc] initWithContentsOfFile: globals.ACCOUNT_PLIST_PATH];
                    //set eula boolean value depending on whether or not user has accepted -- from the users info
                    globals.IS_EULA = [[globals.ACCOUNT_INFO objectForKey:@"eula"]intValue]==1;
                } //if account file exists
            }
            if (!globals.IS_EULA) {
                globals.IS_EULA = [[globals.ACCOUNT_INFO objectForKey:@"eula"]intValue]==1;
            }
            
            //check to see whether or not user has logged in
            //if they haven't then ask them to login
            if (!globals.IS_LOGGED_IN ||!globals.IS_EULA) {
                //this background is for login/eula popup
                [self addWhiteBackground];
                
                //if the user is not logged in
                if (!globals.IS_LOGGED_IN)
                {
                    BOOL hasInternetConnection = [uController checkInternetConnection];
                    //if there is no internet connection pop up the alert view
                    if (!hasInternetConnection) {
                        
                        
                        NSString * message = @"No internet connection. Please make sure the internet is successfully connected in order to log in.";
                        
                        if (![CustomAlertView alertMessageExists:message]) {
                            
                            CustomAlertView *internetConAlertView = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [internetConAlertView show];
                        }

//                        
//                        
//                        UIAlertView *internetConAlertView = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"No internet connection. Please make sure the internet is successfully connected in order to log in." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                        BOOL *alertExists = NO;
//                        for (UIAlertView *alert in globals.ARRAY_OF_POPUP_ALERT_VIEWS){
//                            if ([alert.message isEqualToString:internetConAlertView.message]){
//                                alertExists = YES;
//                            }
//                        }
//                        if (!alertExists){
//                            [internetConAlertView show];
//                            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:internetConAlertView];
//                        }
                        globals.CURRENT_APP_STATE = apstSkipTimer;
                        break;
                    }
                    //if internet is available, pop login view for the user to log in
                    loginViewController = [[LoginViewController alloc]init];
                    [loginViewController setModalPresentationStyle:UIModalPresentationFormSheet];
                    [self presentViewController:loginViewController animated:YES completion:nil];
                    
                }
                
                globals.CURRENT_APP_STATE=apstWaitLogin;
                break;
                
            }
            if (globals.IS_LOCAL_PLAYBACK){
                NSLog(@"Was watching local event");
            }
            if (!globals.HAS_WIFI) {
                //if the user has logged in and accepted the eula, check the if the app already had wifi
                
                //current loading progress: checking for wifi
                globals.HAS_WIFI = [uController hasConnectivity];
                if(globals.HAS_WIFI){
                    //send ping to cloud to check has cloud or not
                    NSString *url = @"http://myplayxplay.net/max/ping/ajax";
                    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(pingServerCallback:)],self, nil];
                    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
                    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    [globals.APP_QUEUE enqueue:url dict:instObj];
                    
                    //start looking for bonjour(local encoder:min)
                    dictOfIPs = [[NSMutableDictionary alloc] initWithCapacity:1];
                    [self browseServices];
                    //reset timer counter for new app state
                    timerCounter = 0;
                    //if there is wifi
                    globals.CURRENT_APP_STATE=apstHasWifi;
                    break;
                }
            } else {
                //If the app HAD wifi and now does not
                globals.HAS_WIFI = [uController hasConnectivity];
                if(!globals.HAS_WIFI){
                    globals.HAS_MIN = FALSE;
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSString *pathToThisEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"videos/main.mp4"];
                   //if the user was not playing downloaded event, clean all the globals dictionary
                    if (![fileManager fileExistsAtPath:pathToThisEventVid])
                    {
                        //remove all the objects in global CURRENT EVENT THUMBNAILS; Then get all the tag for the new play back event
                        [globals.CURRENT_EVENT_THUMBNAILS removeAllObjects];
                        //[globals.TAG_MARKER_ITEMS removeAllObjects];
                        [globals.TAGGED_ATTS_DICT removeAllObjects];
                        [globals.TAGGED_ATTS_DICT_SHIFT removeAllObjects];
                        [globals.ARRAY_OF_COLOURS removeAllObjects];
                        //remove all of tagset request from previoud event
                        [globals.ARRAY_OF_TAGSET removeAllObjects];
                        //empty the toast queue
                        [globals.TOAST_QUEUE removeAllObjects];
                        //empty the app_queue
                        [globals.APP_QUEUE.queue removeAllObjects];
                        
                        NSMutableArray *tempArray = [[globals.TAG_MARKER_OBJ_DICT allKeys] mutableCopy];
                        for(NSString *key in tempArray){
                            [[[globals.TAG_MARKER_OBJ_DICT objectForKey:key] markerView] removeFromSuperview];
                            
                        }
                        [globals.TAG_MARKER_OBJ_DICT removeAllObjects];
                        //stop syncme timer
                        [uController stopSyncMeTimer];
                        //when encoder status is "off", reset the player
                        globals.CURRENT_PLAYBACK_EVENT = @"";
                        NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
                        //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
                        
                        [globals.VIDEO_PLAYER_LIVE2BENCH setVideoURL:videoURL];
                        [globals.VIDEO_PLAYER_LIVE2BENCH setPlayerWithURL:videoURL];
                        
                        [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
                        [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
                        globals.VIDEO_PLAYBACK_FAILED = FALSE;
                        globals.PLAYABLE_DURATION = -1;
                        
                        if(globals.EVENT_NAME && ![globals.EVENT_NAME isEqualToString:@""]){
                            NSString *pathToLive =[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME];
                            
                            NSError *delError;
                            [fileManager removeItemAtPath:pathToLive error:&delError];

                        }
                        
                        [[NSNotificationCenter defaultCenter]postNotificationName:AVPlayerItemDidPlayToEndTimeNotification object:nil];
                        globals.WHICH_SPORT = @"";
                        [globals.TEAM_SETUP removeAllObjects];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"SportInformationUpdated" object:nil];
                        globals.EVENT_NAME=@"";
                        globals.HUMAN_READABLE_EVENT_NAME=@"";
                    }
                    globals.CURRENT_APP_STATE=apstNoWifi;
                    break;
                }
            }
            
            if (!globals.HAS_MIN){
                globals.CURRENT_APP_STATE=apstHasWifi;
                break;
            }
            
            if ([globals.CURRENT_ENC_STATUS isEqualToString:@""]){
                globals.CURRENT_APP_STATE = apstEncStatusCheck;
            }

            if (globals.CURRENT_APP_STATE == apstReactiveCheck){
                globals.CURRENT_APP_STATE = apstSkipTimer;
            }
            break;
        }
        case apstLoginCheck: //check the user has login or not
        {
            if (!globals.IS_LOGGED_IN)
            {
                //if not login, pop login view which requires user name and password
                //TODO: Should have a white background behind it, but it is being removed for some reason
                //[self addWhiteBackground];
                loginViewController = [[LoginViewController alloc]init];
                [loginViewController setModalPresentationStyle:UIModalPresentationFormSheet];
                [self presentViewController:loginViewController animated:YES completion:nil];
            }
            globals.CURRENT_APP_STATE=apstWaitLogin;
            break;
        }

            
        case apstWaitLogin: //waiting for result of the login check
        {
            if(globals.IS_LOGGED_IN)
            {
                // only time we get here is if there is internet and user just logged in
                globals.CURRENT_APP_STATE = apstEulaCheck;
            }
            break;
        }
        case apstEulaCheck: //wait the eula check
        {
            if(!globals.IS_EULA)
            {
                //if eula has not accepted, pop up eula; The user has to accepted to go into the next step
                EulaModalViewController *eulaViewController=[[EulaModalViewController   alloc]initWithController:nil];
                [eulaViewController setModalPresentationStyle:UIModalPresentationFormSheet];
                [self presentViewController:eulaViewController animated:YES completion:nil];
                
            }
            globals.CURRENT_APP_STATE=apstWaitEula;
            break;
        }
        case apstWaitEula:
        {
            if(globals.IS_EULA) //if the eula is accepted, check the wifi connection
            {
               
                globals.HAS_WIFI = [uController hasConnectivity];
                //current loading progress: checking for wifi
                [self updateProgessView:1.0/NUM_STEPS :@"checking for wifi"];
               
                if(!globals.HAS_WIFI){
                    //if there is not wifi, no min
                    globals.CURRENT_APP_STATE=apstNoMin;
                    break;
                }else{
                    //send ping to cloud to check has cloud or not
                    NSString *url = @"http://myplayxplay.net/max/ping/ajax";
                    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(pingServerCallback:)],self, nil];
                    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
                    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                    [globals.APP_QUEUE enqueue:url dict:instObj];
                    
                    //start looking for bonjour(local encoder:min)
                    dictOfIPs = [[NSMutableDictionary alloc] initWithCapacity:1];
                    [self browseServices];
                    //reset timer counter for new app state
                    timerCounter = 0;
                    //if there is wifi
                    globals.CURRENT_APP_STATE=apstHasWifi;
                    
                }
                
                //init current encoder status as empty string
                globals.CURRENT_ENC_STATUS=@"";
                
            }//if has eula
            break;
        }
        case apstNoWifi: // no wifi available
        case apstNoMin: //no min available
        {
            CustomAlertView * noWifiAlert;
            NSString        * message;
            
            if (!globals.HAS_WIFI) {
                
                message = @"OFFLINE MODE, NO ENCODER AVAILABLE. \nIf you need the encoder, please make sure the wifi is successfully connected.";
                
                //if no wifi, pop up offline mode alert
//                noWifiAlert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            }else if(!globals.HAS_MIN){
                
                message = @"NO ENCODER AVAILABLE. \nPlease check the server and wifi connection.";
                
                
                //if has wifi, but no min, pop up no encoder alert
//                noWifiAlert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            }
            
            if (![CustomAlertView alertMessageExists:message]) {
                
                CustomAlertView *noWifiAlert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [noWifiAlert show];
            }

            
//            BOOL *alertExists = NO;
//            for (UIAlertView *alert in globals.ARRAY_OF_POPUP_ALERT_VIEWS){
//                if ([alert.message isEqualToString:noWifiAlert.message]){
//                    alertExists = YES;
//                }
//            }
//            if (!alertExists){
//                [noWifiAlert show];
//                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:noWifiAlert];
//            }
            [globals.SPINNERVIEW removeSpinner];
            globals.SPINNERVIEW = nil;
            [spinnerView removeSpinner];
            NSString *pathToEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"videos/main.mp4"];
            
            //goes to calendar directly
            if ((![self.selectedViewController isKindOfClass:[LogoViewController class]] && ![self.selectedViewController isKindOfClass:[BookmarkViewController class]]) && ![[NSFileManager defaultManager] fileExistsAtPath: pathToEventVid]){
                [self selectTab:1];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCalendarData" object:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeLiveSpinner" object:self];
            }
            globals.CURRENT_APP_STATE=apstSkipTimer;
            
            break;
        }

        case apstHasWifi: //then check the encoder availability
        {
          
            if ([[dictOfIPs allKeys] count] == 1){
                //current progress view: finding possible all the encoders
                [self updateProgessView:2.0/NUM_STEPS :@"finding myplayXplay encoders"];
                //only one encoder detected
                globals.URL= [[dictOfIPs allValues] objectAtIndex:0];
                
//                //for testing wifi jumping
//                UIAlertView *urlAlert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:[NSString stringWithFormat:@"apstHasWifi, globals.URL = %@",globals.URL] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
//                [urlAlert show];
//                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:urlAlert];
                
                //NSLog(@"apstHasWifi1 globals.URL: %@",globals.URL);
                globals.CURRENT_PLAYBACK_EVENT=[NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
                //for testing
                //globals.CURRENT_PLAYBACK_EVENT= @"http://myplayxplay.net/evt-test/video/list.m3u8";
                globals.HAS_MIN=TRUE; // boolean value showing whether or not server is available
                globals.CURRENT_APP_STATE = apstEncStatusCheck;
            } else if ([[dictOfIPs allKeys] count] > 1) {
                //current progress view: finding possible all the encoders
                [self updateProgessView:2.0/NUM_STEPS :@"finding myplayXplay encoders"];
                
                waitingEncoderSelection = TRUE;
                
                //more one encoder detected, pop up a small view for the user to choose which encoder to use
                UIView *popoverView = [[UIView alloc] init];
                UIViewController* popoverContent = [[UIViewController alloc] init];
                popoverView.backgroundColor = [UIColor whiteColor];
                UILabel *messageText = [[UILabel alloc]initWithFrame:CGRectMake(40, 15, 320, 60)];
                messageText.textAlignment = NSTextAlignmentCenter;
                messageText.lineBreakMode = NSLineBreakByWordWrapping;
                messageText.numberOfLines = 0;
                messageText.text = @"There is more than one encoder available. \nPlease choose an encoder to connect to:";
                messageText.font = [UIFont defaultFontOfSize:17.0f];
                [popoverView addSubview:messageText];
                NSArray *ipAddresses = [[dictOfIPs allKeys] copy];
                NSString* ipName;
                popoverContent.view = popoverView;
                for (int i = 0; i<[ipAddresses count]; i++){
                    ipName = [ipAddresses objectAtIndex:i];
                    PopoverButton *ipButton = [PopoverButton buttonWithType:UIButtonTypeCustom];
                    [ipButton setFrame:CGRectMake(0, 70+(50*i), popoverView.bounds.size.width, 50)];
                    [ipButton setTitle:ipName forState:UIControlStateNormal];
                    [ipButton setAccessibilityLabel:[NSString stringWithFormat: @"%@",[dictOfIPs objectForKey:ipName]]];
                    [ipButton addTarget:self action:@selector(ipSelected:) forControlEvents:UIControlEventTouchUpInside];
                    [popoverView addSubview:ipButton];
                }
                
               
                //set the "modalInPopover" to prevent the popup view disappears when tap outside the popup view
                popoverContent.modalInPopover = YES;
                if (!chooseIPPopup){
                    chooseIPPopup = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
                }
                int height = 35*[ipAddresses count] + 120;
                [chooseIPPopup setPopoverContentSize:CGSizeMake(400, height) animated:NO];
                [chooseIPPopup presentPopoverFromRect:CGRectMake(300, 380 - height/2, 400, height) inView:self.view permittedArrowDirections:0 animated:NO];
                //globals.CURRENT_APP_STATE = apstSkipTimer;
            }
            if (waitingEncoderSelection) {
                timerCounter = 0;
            }

           if(timerCounter > 5/TIMER_PERIOD) // whether or not we have cloud, we want to check whether or not user has logged in
               //wait for 3 seconds to see if cloud is available;
           {
               globals.CURRENT_APP_STATE =apstEncStatusCheck;
           }
            
            break;
        }
                       
        case apstEncStatusCheck://if there is min, check current encoder status
        {
            [globals.SPINNERVIEW removeSpinner];
            globals.SPINNERVIEW = nil;
            spinnerView = [SpinnerView loadSpinnerIntoView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
            [spinnerView addSubview:progressViewTextLabel];
            [spinnerView addSubview:loadingProgressView];
            //only for apple testing
            if (!globals.HAS_MIN && [[NSString stringWithFormat:@"%@",[globals.ACCOUNT_INFO objectForKey:@"customer" ]]isEqualToString:@"356a192b7913b04c54574d18c28d46e6395428ab"] && [[NSString stringWithFormat:@"%@",[globals.ACCOUNT_INFO objectForKey:@"password"]] isEqualToString:@"9d8168f2aafcc4a53ea4e53d3881b357e459777671cea7da025a055887b93c7a"]) {
                //if no encoder is found, use the default one -> For apple demo (coach,coach)
                globals.URL= @"http://avocatec.org:8888";//[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)];//set the global url parameter to our ipstring:port -- we need to use htons to flip the bytes returned by the port
                
//                //for testing wifi jumping
//                UIAlertView *urlAlert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:[NSString stringWithFormat:@"apstEncStatusCheck, globals.URL = %@",globals.URL] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
//                [urlAlert show];
//                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:urlAlert];
                

                globals.CURRENT_PLAYBACK_EVENT=[NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
                
                globals.HAS_MIN=TRUE;
            }
            
            if (globals.HAS_MIN) {
                //If wifi available and eula is accepted, send request for current encoder status
                //current absolute time in seconds
                double currentSystemTime = CACurrentMediaTime();
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime", nil];
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
                NSString *jsonString;
                if (! jsonData) {
                } else {
                    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                
                NSString *url = [NSString stringWithFormat:@"%@/min/ajax/encoderstatjson/%@",globals.URL,jsonString];
                
                NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(encoderStatusCallback:)],self,@"10", nil];
                NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller",@"timeout", nil];
                NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                [globals.APP_QUEUE enqueue:url dict:instObj];
                globals.CURRENT_APP_STATE = apstWaitEncStatus;
            }else{
                //no min
                globals.CURRENT_APP_STATE = apstNoMin;
            }
            break;

        }
     case apstWaitEncStatus: //waiting for response from enc status
        {
            //current loading progress: waiting for encoder response
            [self updateProgessView:3.0/NUM_STEPS :@"waiting for encoder response"];
            
            //if getting encoder status response within 10 seconds and the status is live or paused, it means there is live event right now
            //else, there is no live event
            if([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] || [globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]){
                //if current encoder status is live
                 //there is min and live event
                globals.CURRENT_APP_STATE = apstMinLive;
                
            }else if(timerCounter > 10/TIMER_PERIOD){
                    //there is min, but no live game
                    globals.CURRENT_APP_STATE = apstMinNoLive;
            }
            break;
        }
            
        case apstMinNoLive://min available, no live game
        {
            //current loading progress: loading calendar
            [self updateProgessView:4.0/NUM_STEPS :@"loading calendar"];
            globals.CURRENT_PLAYBACK_EVENT = @"";
            
            if(globals.HAS_CLOUD)
            {
                //if has cloud, gettting events and tag event names
                [uController sync2Cloud];
            }
            //get all local events
            [uController getLocalEvents];
            //getting all teams
            [uController getAllTeams];
            globals.CURRENT_APP_STATE = apstWaitEvents;
            break;
        }
            

        case apstMinLive://min available, live game
        {
            //current loading progress: loading live game
            [self updateProgessView:4.0/NUM_STEPS :@"loading live game"];
            if(globals.HAS_CLOUD)
            {
                //if has cloud, send request to cloud, to get all events and tag event names
                [uController sync2Cloud];
            }
            //send request for all local events
            [uController getLocalEvents];
            
            //following is setting variables for live game
            globals.EVENT_NAME=@"live";
            globals.THUMBNAILS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"thumbnails"];
            globals.VIDEOS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"videos"];
            if(![[NSFileManager defaultManager] fileExistsAtPath:globals.THUMBNAILS_PATH])
           {
                [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
                [[NSFileManager defaultManager] createDirectoryAtPath:globals.VIDEOS_PATH withIntermediateDirectories:NO attributes:nil error:NULL];
           }
            firstLoadGoToCalendar = FALSE;
            [uController getAllTeams];
            globals.eventExistsOnServer = TRUE;
            globals.HUMAN_READABLE_EVENT_NAME =@"Live";
            globals.CURRENT_APP_STATE=apstWaitTeams;
            NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
            //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
            [globals.VIDEO_PLAYER_LIVE2BENCH setVideoURL:videoURL];
            [globals.VIDEO_PLAYER_LIVE2BENCH setPlayerWithURL:videoURL];
            [globals.VIDEO_PLAYER_LIVE2BENCH pause];
            
            [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
            [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
            [globals.VIDEO_PLAYER_LIST_VIEW pause];
            
            globals.PLAYABLE_DURATION = -1;
            globals.VIDEO_PLAYBACK_FAILED = FALSE;
            break;
        }
        
        case apstWaitEvents: // waiting for response from events when there is no live game
        {
            //current loading progress: getting all events
            [self updateProgessView:5.0/NUM_STEPS :@"getting events" ];
            if(globals.DID_RECV_NEW_CAL_EVENTS|| timerCounter >10/TIMER_PERIOD)
            {
                [globals.SPINNERVIEW removeSpinner];
                globals.SPINNERVIEW = nil;
                [spinnerView removeSpinner];
                [loadingProgressView removeFromSuperview];
                [progressViewTextLabel removeFromSuperview];
                NSString *pathToEventVid = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"videos/main.mp4"];
                
                if (((![self.selectedViewController isKindOfClass:[LogoViewController class]] && ![self.selectedViewController isKindOfClass:[BookmarkViewController class]]) && ![[NSFileManager defaultManager] fileExistsAtPath: pathToEventVid]) || firstLoadGoToCalendar){
                    //go to calendar
                    [self selectTab:1];
                    firstLoadGoToCalendar = FALSE;
                    
                    //after app finish loading and make sure encoder is available, then begin to download clips which were not finished in old games
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"sendOldBookmarkRequest" object:nil];

                }
                globals.CURRENT_APP_STATE=apstSkipTimer;
            }
            break;
        }
            
        case apstWaitTeams: //waiting for teams callback
        {
            //current loading progress: getting all teams
            [self updateProgessView:5.0/NUM_STEPS :@"getting teams" ];
            if(globals.DID_RECV_TEAMS || timerCounter >10/TIMER_PERIOD)
            {
                //if received all teams, send request for all game tags
                [uController getAllGameTags];
                //NSLog(@"********************************Request game tags!!!!!!!!!!!!!!!!!!");
                globals.DID_RECV_TEAMS=FALSE;
                globals.CURRENT_APP_STATE=apstWaitGameTags;
            }
            break;
        }

            
        case apstWaitGameTags: // waiting for response from getallgametags
        {
            if (globals.WAITING_CHOOSE_TEAM_PLAYERS) {
                //if the user hasn't chosen which team's players to tag, then wait
                timerCounter = 0;
            }
            //current loading progress: getting all game tags
            [self updateProgessView:6.0/NUM_STEPS :@"getting game tags" ];
            if(globals.DID_RECV_GAME_TAGS || timerCounter >20/TIMER_PERIOD)
            {
               //after recieving all the game tags, go to live2bench view
                [self selectTab:2];
                //remove loading progress view and spinner view
                [loadingProgressView removeFromSuperview];
                [progressViewTextLabel removeFromSuperview];
                globals.CURRENT_APP_STATE=apstSkipTimer;
                [globals.SPINNERVIEW removeSpinner];
                 globals.SPINNERVIEW = nil;
                [spinnerView removeSpinner];
                //after app finish loading and make sure encoder is available, then begin to download clips which were not finished in old games
                [[NSNotificationCenter defaultCenter]postNotificationName:@"sendOldBookmarkRequest" object:nil];
            }
            break;
        }
        
        case apstWaitPlaybackStrt: //when playing event from calendar, app state will change to this
        {
            if (globals.WAITING_CHOOSE_TEAM_PLAYERS) {
                //if the user hasn't chosen which team's players to tag, then wait
                timerCounter = 0;
            }
            
             //if received all game tags, go to live2bench view
            //timerCounter > 1/TIMER_PERIOD: if we are streaming mp4 file, hold 5 seconds for buffering 
             if(globals.DID_RECV_GAME_TAGS && timerCounter > 1/TIMER_PERIOD)
             {
                 globals.DID_RECV_GAME_TAGS=FALSE;
                 [self selectTab:2];
                 [globals.SPINNERVIEW removeSpinner];
                 globals.SPINNERVIEW = nil;
                 [loadingProgressView removeFromSuperview];
                 [progressViewTextLabel removeFromSuperview];
                 [spinnerView removeSpinner];
                 globals.CURRENT_APP_STATE=apstSkipTimer;
             }else{
                 //if there is no response in 20 seconds, remove spinner view and go to live2bench view
                 if (timerCounter > 40/TIMER_PERIOD) {
                     ////////NSLog(@"apstWaitplaybackStr timed out");
                     [globals.SPINNERVIEW removeSpinner];
                     globals.SPINNERVIEW = nil;
                     [spinnerView removeSpinner];
                     timerCounter = 0;
                     [self selectTab:2];
                     globals.CURRENT_APP_STATE = apstSkipTimer;
                 }
             }
            break;
        }
        default:
            break;
    }
}

//ping server to see if anything is there
//if there is response for ping,there is cloud
-(void)pingServerCallback:(id)response
{
    globals.HAS_CLOUD = TRUE; 

}

//response of encoder status request
-(void)encoderStatusCallback :(id)jsonResp
{
    globals.CURRENT_ENC_STATUS = [jsonResp objectForKey:@"status"]; //will either be live, paused, amera disconnected or pamera disconnected
    //NSLog(@"globals.CURRENT_ENC_STATUS : %@",globals.CURRENT_ENC_STATUS);
    NSString *msg;
    if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateNoCamera] || [globals.CURRENT_ENC_STATUS isEqualToString:encStateCameraDisconnected] || [globals.CURRENT_ENC_STATUS isEqualToString:encStateProrecorderDisconnected]) {
        msg = @"No camera is detected. Please check the camera connection.";
    }else if([globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]){
        msg = @"The encoder is paused. It can be resumed in the encoder control page.";
    }else if([globals.CURRENT_ENC_STATUS isEqualToString:@""]){
        msg = @"Error response from the server. Please check the server connection.";
    }
    if (msg){
        
        if (![CustomAlertView alertMessageExists:msg]) {
            CustomAlertView *encoderStatusAlert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [encoderStatusAlert show];
            [self performSelector:@selector(dismissAlertView:) withObject:encoderStatusAlert afterDelay:2];
        }

        
        
//        UIAlertView *encoderStatusAlert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        BOOL alertExists = NO;
//        for (UIAlertView *alert in globals.ARRAY_OF_POPUP_ALERT_VIEWS){
//            if ([alert.message isEqualToString:encoderStatusAlert.message]){
//                alertExists = YES;
//            }
//        }
//        if (!alertExists){
//            [encoderStatusAlert show];
//            [self performSelector:@selector(dismissAlertView:) withObject:encoderStatusAlert afterDelay:2];
//            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:encoderStatusAlert];
//        }
    }

}

-(void)dismissAlertView:(UIAlertView*)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alertView];
}
//---browse for services---
-(void) browseServices {
    ////////NSLog(@"browseServices");
    services = [[NSMutableArray alloc]init];
    serviceBrowser = [NSNetServiceBrowser new] ;
    serviceBrowser.delegate = self;
    [serviceBrowser searchForServicesOfType:@"_pxp._udp" inDomain:@""];
}

//---services found---
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
    // //////NSLog(@"netServiceBrowser addObject");
    [services addObject:aService];
    
    [self resolveIPAddress:aService];
}

//this method will be called when ipbutton is pressed
//user selects the encoder, then set the values for the related global variables
-(void)ipSelected:(id)sender{
    CustomButton *button = (CustomButton *)sender;
    
    globals.URL= [button accessibilityLabel];
    
//    //for testing wifi jumping
//    UIAlertView *urlAlert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:[NSString stringWithFormat:@"ipSelected, globals.URL = %@",globals.URL] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
//    [urlAlert show];
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:urlAlert];
    

    //NSLog(@"ipSelected globals.URL: %@",globals.URL);
    globals.CURRENT_PLAYBACK_EVENT=[NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
   //for testing
    // globals.CURRENT_PLAYBACK_EVENT= @"http://myplayxplay.net/evt-test/video/list.m3u8";
    globals.HAS_MIN=TRUE; // boolean value showing whether or not server is available
    globals.CURRENT_APP_STATE =apstEncStatusCheck;
    waitingEncoderSelection = FALSE;
    //dismiss the pop up window for choosing encoder
    [chooseIPPopup dismissPopoverAnimated:YES];
}

//---services removed from the network---
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
    
    // NSLog(@"netServiceBrowser removeObject");
    [services removeObject:aService];
    
    
}

//---resolve the IP address of a service---
-(void) resolveIPAddress:(NSNetService *)service {
    ////////NSLog(@"resolveIPAddress");
    NSNetService *remoteService = service;
    remoteService.delegate = self;
    [remoteService resolveWithTimeout:0];
}

//---managed to resolve---
-(void)netServiceDidResolveAddress:(NSNetService *)service {
    ////////NSLog(@"netServiceDidResolveAddress");
    NSString *name = nil;
    NSData *address = nil;
    struct sockaddr_in *socketAddress = nil;
    NSString *ipString = nil;
    int port;
    BOOL isSameNetwork=TRUE;
    
    NSString *deviceIP = [uController getIPAddress];
    
    NSArray *parseLocalIP = [[NSArray alloc]initWithArray:[deviceIP componentsSeparatedByString:@"."]]; //split the local ip of the device into an array of each number -- used to compare to remote ip(test if on the same network
    //globals.HAS_MIN = FALSE;
    
    for(int i=0;i < [[service addresses] count]; i++ )
    {
        name = [service name];//retrieve unique name of bonjservice
        address = [[service addresses] objectAtIndex: i];
        socketAddress = (struct sockaddr_in *) [address bytes];
        ipString = [NSString stringWithFormat: @"%s", inet_ntoa(socketAddress->sin_addr)];
        NSArray *parseRemoteIP = [[NSArray alloc]initWithArray:[ipString componentsSeparatedByString:@"."]]; //parse remote ip into an array to compare with local ip
        
        //NSLog(@"name: %@,parseRemoteIP: %@, parselocalIP: %@",name,parseRemoteIP,parseLocalIP);

        for(NSString *subIP in parseRemoteIP)
        {
            int i = [parseRemoteIP indexOfObject:subIP];
            if(![subIP isEqualToString:[parseLocalIP objectAtIndex:i]]&&i<3)//compare only the first 3 numbers in the ip address
            {
                isSameNetwork=FALSE; // if the numbers don't equal each other then we don't want it, set the bool to false
            }
        }
        
        port = socketAddress->sin_port; // grab port
        
//        if (isSameNetwork) {
//            globals.HAS_MIN = TRUE;
//        }
        
        if(isSameNetwork)
        {
            NSArray *arrayOfStrings = [name componentsSeparatedByString:@" - "];
            [dictOfIPs setValue:[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)] forKey:[arrayOfStrings objectAtIndex:0]];
            //globals.URL=[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)];//set the global url parameter to our ipstring:port -- we need to use htons to flip the bytes returned by the port
            //globals.CURRENT_PLAYBACK_EVENT=[NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
            //for testing
            // globals.CURRENT_PLAYBACK_EVENT= @"http://myplayxplay.net/evt-test/video/list.m3u8";
            //globals.HAS_MIN=TRUE; // boolean value showing whether or not server is available
            NSString *hostName = [service hostName];
            if ([[service hostName] hasSuffix:@".local."]){
                hostName = [[service hostName] stringByReplacingOccurrencesOfString:@".local." withString:@""];
            }
            [dictOfIPs setValue:[NSString stringWithFormat:@"http://%@:%d",ipString,htons(port)] forKey:hostName];
        }
    }
    
}




//---did not managed to resolve---
-(void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    
}

// This selects tab by string name like this
-(void)notificationSelectTab:(NSNotification*)note
{
    NSString * tabName = [note.userInfo objectForKey:@"tabName"];
    NSInteger tabIndex = [[tabNameReferenceDict objectForKey:tabName]integerValue];
    [self selectTab: tabIndex   ];
}

//what happens when a tab is selected
- (void)selectTab:(int)tabID
{
    self.selectedIndex = tabID;
}

//tab bar button is clicked
- (void)buttonClicked:(id)sender
{
    int tagNum = [sender tag];
//    if (self.selectedIndex != tagNum){
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_SWITCH_MAIN_TAB object:self];
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Force Fullscreen Exit" object:nil];
    
    [self selectTab:tagNum];
}

//hide the native IOS tab bar
-(void)hideExistingTabBar
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.0];
    UIView *mainWindowView = [self.view.subviews objectAtIndex:0];
    [mainWindowView setFrame:CGRectMake(mainWindowView.frame.origin.x, mainWindowView.frame.origin.y, mainWindowView.frame.size.width, 768)];
    [UIView commitAnimations];
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    
    [self changeButtonHighlightForTab:selectedIndex];
    [self.selectedViewController viewDidAppear:YES];
}


- (void)changeButtonHighlightForTab: (NSInteger)tabNum
{
    
    for(CustomTabViewController *tabs in self.viewControllers)
    {
        [((CustomTabViewController *)tabs).sectionTab setSelected:FALSE];
    }
    [((CustomTabViewController *)[self.viewControllers objectAtIndex:tabNum]).sectionTab setSelected:TRUE];
    
    
    for(CustomButton *tempbtn in tabButtonItems)
    {
        if([tabButtonItems indexOfObject:tempbtn] == tabNum)
        {
            [tempbtn setSelected:TRUE];
        }else{
            [tempbtn setSelected:FALSE];
        }
    }
    
    [self.tabBarController setSelectedIndex:tabNum];
    
    //In the event the Tele is fullscreened and the tab is changed, get rid of the tele interface
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Close Tele" object:nil];
    
}



- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    NSInteger vcIndex = [self.viewControllers indexOfObject:selectedViewController];
    [self setSelectedIndex:vcIndex];
}

@end
