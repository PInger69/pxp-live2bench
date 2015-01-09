////
//
//  UtilitiesController.m
//  Live2BenchNative
//
//  Created by dev on 13-02-04.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "UtilitiesController.h"
//#import "AppQueue.h"
#import "Live2BenchViewController.h"

@implementation UtilitiesController

@synthesize deviceAuthorization,deviceCustomer,emailAddress,password,request,conn,syncRequest,live2BenchViewController,getLocalEventRequest;
//@synthesize isEventStopped;
@synthesize encoderStatusAlert,liveStreamEndedAlert;
@synthesize didResendGetAllTeamsRequest;
@synthesize didResendGetAllTagsRequest;
@synthesize uploadLocalTagsTimer;
@synthesize errorCount;
@synthesize chooseTeamPlayerPopup;
@synthesize encoderStatusCount;
@synthesize previousAlertView;
NSArray *eventsArray;

//get response (authorization and customer) from server after sending account information

- (int)getSuccess
{
    return isSuccess;
}

- (NSString*)getResponse{
    
//    ////// 
    return responseMsg;
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                CFRelease(reachability);
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                CFRelease(reachability);
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    CFRelease(reachability);
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                CFRelease(reachability);
                return YES;
            }
        }
    }

    CFRelease(reachability);
    return NO;
}

-(id)init
{
    if(!globals)
    {
        globals=[Globals instance];
    }
    self = [super init];
    if (self){
        encoderStatusCounter=0;
        alertSent = FALSE;
        live2BenchViewController= [[Live2BenchViewController alloc]init];
        return self;
    }
    return self;
}


-(void) writeTagsToPlist
{
    if ([globals.EVENT_NAME isEqualToString:@""] || [globals.EVENT_NAME isEqualToString:@"live"]) {
        return;
    }
   
    if(!globals.HAS_MIN || (globals.HAS_MIN && !globals.eventExistsOnServer)){
        NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
        
        NSString *localEventsPlistPath = [globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"];
        NSMutableArray *localThumbArray;
        
        //If file does not exist, create it
        BOOL isDir;
        if(![[NSFileManager defaultManager] fileExistsAtPath:localEventsPlistPath isDirectory:&isDir])
        {
            [[NSFileManager defaultManager] createFileAtPath:localEventsPlistPath contents:nil attributes:nil];
            localThumbArray = [[NSMutableArray alloc]init];
        }else{
            
            //Read plist of local event names
            localThumbArray = [[NSMutableArray alloc]initWithContentsOfFile:localEventsPlistPath];
            //if localEventsPlistPath is empty, localThumbArray will be nil
            if (!localThumbArray) {
                localThumbArray = [[NSMutableArray alloc]init];
            }

        }
        
        
        //See if current event is in said plist
        if (![localThumbArray containsObject:globals.EVENT_NAME]){
            
            //If not, add it
            [localThumbArray addObject:globals.EVENT_NAME];
            [localThumbArray writeToFile:localEventsPlistPath atomically:YES];
            ////////NSLog(@"Event name: %@", globals.EVENT_NAME);
            ////////NSLog(@"filePath: %@", localEventsPlistPath);
        }
        
        //Write thumbnails to thumbnails.plist
        BOOL isDirect;
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirect])
        {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }
        [globals.CURRENT_EVENT_THUMBNAILS writeToFile:filePath atomically:YES];
    }
    
}

-(NSString *)encodeSpecialCharacters:(NSString*)inputString
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)inputString ,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"/#%^{}|`\"\\?",
                                                                                                    kCFStringEncodingUTF8 ));
    return encodedString;
}

- (void) setAllGameTags
{
    
    //Get all files in events folder
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        if(![[NSFileManager defaultManager] fileExistsAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"]])
        {
            return;
        }
        
        NSMutableArray *modifiedLocalEventsArray = [[NSMutableArray alloc] initWithContentsOfFile:[globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"]];
        if(modifiedLocalEventsArray.count == 0){
            [[NSFileManager defaultManager] removeItemAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"] error:nil];
            return;
            
        }
        NSMutableArray *modifiedLocalEventsArrCopy = [modifiedLocalEventsArray mutableCopy];
        
        //For each event
        
        for (NSString *event_name in modifiedLocalEventsArray){
        if(event_name.length>0      )
        {
            //Go through array of past events, dont sync with deleted events
            for (NSDictionary *event in eventsArray){
                
                //Check and make sure event exists on server before syncing -> should optimize
                if ([[event objectForKey:@"name"]isEqualToString:event_name] && ![[event objectForKey:@"deleted"] boolValue]){
                    
                    //get thumbnails path
                    NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:event_name] stringByAppendingPathComponent:@"Thumbnails.plist"];
                    
                    //Read the plist of tags
                    
                    NSMutableDictionary *allTags = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath]; //Dictionary of all tags in plist
                    
                    //For each tag
                    int i = 0;
                    //for tesing
//                    int offlineTagCount = 0;
                    
                    for ( NSString *key in [allTags allKeys])
                    {
                        if([key isEqualToString:@"teams"])
                        {
                            return;
                        }
                        NSMutableDictionary *dict =[[NSMutableDictionary alloc] initWithDictionary:[allTags objectForKey:key]];
                        
                        if ([dict objectForKey:@"local"] || [dict objectForKey:@"edited"]){
                            i++;
                            if (i >= 10) {
                                sleep(1.5);
                                i = 0;
                            }
                            //Read tag in and make json
                            NSError *error;
                            NSMutableDictionary *mutableDict;
                            
                            if ([dict objectForKey:@"edited"] && ![dict objectForKey:@"local"]){
                                if ([[dict objectForKey:@"deleted"]intValue] == 1){
                                    //mutableDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[dict objectForKey:@"event"],@"event",[dict objectForKey:@"name"],@"name",[dict objectForKey:@"colour"],@"colour",[dict objectForKey:@"user"],@"user",[dict objectForKey:@"time"],@"time", [dict objectForKey:@"starttime"],@"starttime" ,[dict objectForKey:@"duration"], @"duration", [dict objectForKey:@"coachpick"], @"coachpick", [dict objectForKey:@"bookmark"],@"bookmark", [dict objectForKey:@"comment"], @"comment",[dict objectForKey:@"id"], @"id", [dict objectForKey:@"rating"],@"rating",[dict objectForKey:@"deleted"], @"deleted", nil];
                                    
                                    mutableDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:@"1",@"delete",[dict objectForKey:@"event"],@"event",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",[dict objectForKey:@"id"],@"id", nil];
                                }else{
                                    mutableDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[dict objectForKey:@"event"],@"event",[dict objectForKey:@"name"],@"name",[dict objectForKey:@"colour"],@"colour",[dict objectForKey:@"user"],@"user",[dict objectForKey:@"time"],@"time", [dict objectForKey:@"starttime"],@"starttime" ,[dict objectForKey:@"duration"], @"duration", [dict objectForKey:@"coachpick"], @"coachpick", [dict objectForKey:@"bookmark"],@"bookmark", [dict objectForKey:@"comment"], @"comment",[dict objectForKey:@"id"], @"id", [dict objectForKey:@"rating"],@"rating", nil];
                                }
                            }else if ([dict objectForKey:@"local"]){
                                mutableDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
                                [mutableDict removeObjectForKey:@"local"];
                                if ([mutableDict objectForKey:@"edited"]){
                                    [mutableDict removeObjectForKey:@"edited"];
                                }
                                if ([mutableDict objectForKey:@"url"]){
                                    [mutableDict removeObjectForKey:@"url"];
                                }
                                
                                
                            }
                            NSString *url;
                            
                            if ([[mutableDict objectForKey:@"type"] intValue] == 4){
                                
                                //donot send the tele url to the server
                                if ([mutableDict objectForKey:@"teleurl"]) {
                                    [mutableDict removeObjectForKey:@"teleurl"];
                                }
                                NSError *error;
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:&error];
                                NSString *jsonString;
                                
                                if (jsonData) {
                                    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                    //jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                }
                                NSString *url = [NSString stringWithFormat:@"%@/min/ajax/teleset/",globals.URL];
                                request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                   timeoutInterval:60];
                                //create post request
                                [request setHTTPMethod:@"POST"];
                                NSString *boundary = @"----WebKitFormBoundarycC4YiaUFwM44F6rT";
                                NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                                [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
                                NSMutableData *body = [NSMutableData data];
                                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                                [body appendData:[@"Content-Disposition: form-data; name=tag\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                                // [body appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                                [body appendData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
                                // Now we need to append the different data 'segments'. We first start by adding the boundary.
                                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                                [body appendData:[@"Content-Disposition: form-data; name=file; filename=picture.png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                                // We now need to tell the receiver what content type we have
                                // In my case it's a png image. If you have a jpg, set it to 'image/jpg'
                                [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                                // Now we append the actual image data
                                
                                NSString *imageName = [NSString stringWithFormat:@"%@.png",[dict objectForKey:@"id"]];
                                NSString *imagePath = [[[globals.EVENTS_PATH stringByAppendingPathComponent: event_name]stringByAppendingPathComponent:[NSString stringWithFormat:@"/thumbnails"]] stringByAppendingPathComponent: [NSString stringWithFormat:@"/tl%@",imageName]];
                                UIImage *teleDrawing = [[UIImage alloc] initWithContentsOfFile:imagePath];
                                [body appendData:[NSData dataWithData:UIImagePNGRepresentation(teleDrawing)]];
                                [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                                
                                [request setHTTPBody:body];
                                
                                [globals.ALL_LOCAL_TAGS_REQUEST_QUEUE addObject:request];
                                globals.NUMBER_OF_ALL_LOCAL_TAGS++;
                                
                            }else{
                                
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDict options:0 error:&error];
                                NSString *jsonString;
                                if (jsonData) {
                                    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                }
                                
                                //if ([[mutableDict objectForKey:@"id"] rangeOfString:@"temp"].location != NSNotFound){
                                if ([[dict objectForKey:@"local"] intValue]== 1){
                                    ////////NSLog(@"local tag: %@", mutableDict);
                                    url = [NSString stringWithFormat:@"%@/min/ajax/tagset/%@",globals.URL,jsonString]; //New tag -> tagset, modified tag -> tagmod
                                } else if([[dict objectForKey:@"edited"] intValue] == 1){
                                    ////////NSLog(@"Tag edited locally: %@", mutableDict);
                                    url = [NSString stringWithFormat:@"%@/min/ajax/tagmod/%@",globals.URL,jsonString];
                                }
                                
                                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                                [globals.ALL_LOCAL_TAGS_REQUEST_QUEUE addObject:urlRequest];
                                globals.NUMBER_OF_ALL_LOCAL_TAGS++;
                                
                                NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[dict objectForKey:@"id"] ];
                                NSString *imagePath = [[[globals.EVENTS_PATH stringByAppendingPathComponent: event_name]stringByAppendingPathComponent:[NSString stringWithFormat:@"/thumbnails"]] stringByAppendingPathComponent: [NSString stringWithFormat:@"/%@",imageName]];
                                [[NSFileManager defaultManager] removeItemAtPath:imagePath error: &error];
                                
//                                offlineTagCount++;
//                                //////NSLog(@"offlineTagCount: %d tag name %@, globals.ALL_LOCAL_TAGS_REQUEST_QUEUE.count %d",offlineTagCount,[dict objectForKey:@"name"],globals.ALL_LOCAL_TAGS_REQUEST_QUEUE.count);
                          }
                        }
                    }
                    
                    [modifiedLocalEventsArrCopy removeObject:event_name];
                }
            }
            
        }
            NSError *error;
            if(modifiedLocalEventsArrCopy.count > 0){
                [modifiedLocalEventsArrCopy writeToFile:[globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"] atomically:YES];
            }else{
                [[NSFileManager defaultManager] removeItemAtPath:[globals.EVENTS_PATH stringByAppendingPathComponent:@"LocalEvents.plist"] error: &error];
            }
        }
   });
    
}

//send one local tag request every one sec, otherwise tags maybe duplicated
-(void)sendLocalTagRequest{
    
    if (globals.ALL_LOCAL_TAGS_REQUEST_QUEUE.count > 0) {
        NSURLRequest *localTagRequest = [globals.ALL_LOCAL_TAGS_REQUEST_QUEUE objectAtIndex:0];
        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:localTagRequest delegate:self];
        globals.NUMBER_OF_LOCAL_TAGS_UPDATED++;
    }

}

//donot receive server response in current class
-(void) nullFunction:(id)jsonArr{
    
}



-(int) extractIntFromStr:(NSString*) originalString{
    //if nil is passed to "scannerWithString", will log the warning: "NSScanner: nil string argument"
    if (!originalString) {
        return nil;
    }
    NSMutableString *strippedString = [NSMutableString stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    return [strippedString intValue];
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wired connection on a simulator, en1 - wifi on the simulator, or lo0 - wifi on an iPad
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] ||
                   [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"] ||
                   [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"lo0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

-(void)getAllTeams
{
    if(globals.HAS_MIN ) //we only want to send a call if there is a server available
    {
        //current absolute time in seconds
        double currentSystemTime = CACurrentMediaTime();
        NSMutableDictionary *summarydict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime", nil];
        
        NSError *error;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:summarydict options:0 error:&error];
        NSString *jsonString;
        if (! jsonData) {
            
        } else {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }

        //send call to grab all teams
        NSString *teamsurl = [NSString stringWithFormat:@"%@/min/ajax/teamsget/%@",globals.URL,jsonString];
        ////////NSLog(@"gametags url %@",teamsurl);
         NSArray *teamsObjects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(getAllTeamsCallback:)],self,@"30", nil];
        NSArray *teamsKeys = [[NSArray alloc]initWithObjects:@"callback",@"controller",@"timeout", nil];
        NSDictionary *teamsInstObj = [NSDictionary dictionaryWithObjects:teamsObjects forKeys:teamsKeys];
        [globals.APP_QUEUE enqueue:teamsurl dict:teamsInstObj];
    }else{ //if no server available then grab the teams from the plist file
        NSString *pathToTeamPlist = [globals.EVENTS_PATH stringByAppendingPathComponent:@"players-setup.plist"];
        
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:pathToTeamPlist]) //we are only gonna grab it if the file actually exists on the device
        {
            NSDictionary *fileContent = [[NSDictionary alloc]initWithContentsOfFile:pathToTeamPlist];
            globals.ALL_TEAMS=[fileContent objectForKey:@"teams"];
            
            NSString *extraPlistPath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"extra.plist"];
            NSDictionary *pastTeamsThumbsDict=[[NSDictionary alloc]initWithContentsOfFile:extraPlistPath];
            globals.PLAYING_TEAMS_HIDS=[pastTeamsThumbsDict objectForKey:@"teams"];
            
            
            //pop up a small view for the user to choose which team he/she wants to tag
            UIView *teamNamePopoverView = [[UIView alloc] init];
            UIViewController* teamNamePopoverContent = [[UIViewController alloc] init];
            teamNamePopoverView.backgroundColor = [UIColor whiteColor];
            UILabel *messageText = [[UILabel alloc]initWithFrame:CGRectMake(40, 15, 320, 60)];
            messageText.lineBreakMode = NSLineBreakByWordWrapping;
            messageText.numberOfLines = 0;
            messageText.text = @"Please select the team you want to tag:";
            messageText.font = [UIFont defaultFontOfSize:17.0f];
            [teamNamePopoverView addSubview:messageText];
            
            NSMutableArray *currentPlayingTeamsName = [[NSMutableArray alloc]init];
            NSMutableArray *teamButtons = [[NSMutableArray alloc]init];
            
            for (id teamHid in globals.PLAYING_TEAMS_HIDS) {
                int i = [globals.PLAYING_TEAMS_HIDS indexOfObject:teamHid];
                if (pastTeamsThumbsDict) {
                    NSDictionary *teamDict = [globals.ALL_TEAMS objectForKey:teamHid];
                    
                    if (teamDict) {
                        [currentPlayingTeamsName addObject:[teamDict objectForKey:@"name"]];
                        PopoverButton *teamNameButton = [PopoverButton buttonWithType:UIButtonTypeCustom];
                        [teamNameButton setFrame:CGRectMake(0.0f, 70.0f+(50.0f*i), teamNamePopoverView.bounds.size.width, 50.0f)];
                        [teamNameButton setTitle:[teamDict objectForKey:@"name"] forState:UIControlStateNormal];
                        [teamNameButton setAccessibilityLabel:[NSString stringWithFormat: @"%d",i]];
                        [teamNameButton addTarget:self action:@selector(teamSelected:) forControlEvents:UIControlEventTouchUpInside];
                        [teamNamePopoverView addSubview:teamNameButton];
                        [teamButtons addObject:teamNameButton];
                    }
                    
                }
                
            }
            
            if (teamButtons.count > 0) {
                teamNamePopoverContent.view = teamNamePopoverView;
                //set "modalInPopover" property to prevent the chooseTeamPlayerPopup view disappears when tap outside the popup view
                teamNamePopoverContent.modalInPopover = YES;
                //reset chooseTeamPlayerPopup to nil and reallocate it later
                chooseTeamPlayerPopup = nil;
                chooseTeamPlayerPopup = [[UIPopoverController alloc] initWithContentViewController:teamNamePopoverContent];
                int height = 35*[globals.PLAYING_TEAMS_HIDS count] + 120;
                [chooseTeamPlayerPopup setPopoverContentSize:CGSizeMake(400, height) animated:NO];
                //if there is alertview not been dismissed, dismiss it here
                
                [CustomAlertView dismissAll];
//                if (globals.ARRAY_OF_POPUP_ALERT_VIEWS.count > 0) {
//                    NSMutableArray *tempArr = [globals.ARRAY_OF_POPUP_ALERT_VIEWS mutableCopy];
//                    for(UIAlertView *view in tempArr){
//                        [view dismissWithClickedButtonIndex:0 animated:NO];
//                        [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:view];
//                    }
//                }
                //TODO: find a better way to do this
                if ([UIApplication sharedApplication].keyWindow.rootViewController) {
                    //[UIApplication sharedApplication].keyWindow.rootViewController is not nil, popup the chooseTeamPlayerPopup
                    [chooseTeamPlayerPopup presentPopoverFromRect:CGRectMake(300, 380 - height/2, 400, height) inView:[UIApplication sharedApplication].keyWindow.rootViewController.view permittedArrowDirections:0 animated:NO];
                }else{
                    //[UIApplication sharedApplication].keyWindow.rootViewController is nil, choose the first team
                    [[teamButtons objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
                
            }else{
                //if the current playing event is not found
                //global variables properly in order to go to the live2bench view
                globals.WAITING_CHOOSE_TEAM_PLAYERS = FALSE;
                globals.DID_RECV_GAME_TAGS = TRUE;
                globals.WAITING_GAME_TAGS_RESPONSE = FALSE;
            }
            
        }
        NSString *currentSystemTime = [NSString stringWithFormat:@"%f", CACurrentMediaTime()];
        NSMutableDictionary *teamInfoDict = [[NSMutableDictionary alloc]init];
        if (globals.ALL_TEAMS) {
            [teamInfoDict setObject:globals.ALL_TEAMS forKey:@"allteamsNOmin"];
        }
        if (globals.EVENT_NAME) {
            [teamInfoDict setObject:globals.EVENT_NAME forKey:@"event_name"];
        }
        [globals.LOG_INFO setObject:teamInfoDict forKey:currentSystemTime];
        [globals.LOG_INFO writeToFile:globals.LOG_PATH atomically:YES];
        ////NSLog(@" if no min globals.ALL_TEAMS %@",globals.ALL_TEAMS);
    }

}

-(void)getAllTeamsCallback:(id)jsonArr
{
    ////////NSLog(@"getallteamscallback: %@",jsonArr);
    if ((!jsonArr || (jsonArr && (![jsonArr objectForKey:@"teams"] || ![jsonArr objectForKey:@"leagues"]))) && !didResendGetAllTeamsRequest) {
        [self getAllTeams];
        didResendGetAllTeamsRequest = TRUE;
        return;
    }else if((!jsonArr || (jsonArr && (![jsonArr objectForKey:@"teams"] || ![jsonArr objectForKey:@"leagues"]))) && didResendGetAllTeamsRequest){
        CustomAlertView *alert = [[CustomAlertView alloc]
                              initWithTitle: @"myplayXplay"
                              message: @"Corrupt response. Please check the server connection and network condition."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
//        [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alert];
        didResendGetAllTeamsRequest = FALSE;
        //return;
    }
    if([jsonArr count])
    {

        if (didResendGetAllTeamsRequest) {
            didResendGetAllTeamsRequest = FALSE;
        }
        //deal with the new teams information -- set the teams to global variable ALL_TEAMS, setup to TEAM_SETUP
        globals.ALL_TEAMS = [jsonArr objectForKey:@"teams"] ? [jsonArr objectForKey:@"teams"] : nil;
        globals.ALL_LEAGUES=[jsonArr objectForKey:@"leagues"];
        
        //Now save the teams to a plist in case the next time they don't have a server
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *pathToEvents = globals.EVENTS_PATH;
         NSString *pathToTeamPlist = [globals.EVENTS_PATH stringByAppendingPathComponent:@"players-setup.plist"];
        if(![fileManager fileExistsAtPath:pathToEvents])
        {
            NSError *cErr;
            [fileManager createDirectoryAtPath:pathToEvents withIntermediateDirectories:YES attributes:nil error:&cErr];
        }
        [jsonArr writeToFile:pathToTeamPlist atomically:YES];
        globals.DID_RECV_TEAMS=TRUE;
    }
}

-(void)getAllGameTags
{
    globals.FINISHED_LOADING_THUMBNAIL_IMAGES = FALSE;
    //if there is alertview not been dismissed, dismiss it here
    [CustomAlertView dismissAll];
//    if (globals.ARRAY_OF_POPUP_ALERT_VIEWS.count > 0) {
//        NSMutableArray *tempArr = [globals.ARRAY_OF_POPUP_ALERT_VIEWS mutableCopy];
//        for(UIAlertView *view in tempArr){
//            [view dismissWithClickedButtonIndex:0 animated:NO];
//            [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:view];
//        }
//    }

    if(globals.HAS_MIN && globals.eventExistsOnServer && [globals.EVENT_NAME length]>1)//live game or vod or local event in the sever
    {
        globals.WAITING_GAME_TAGS_RESPONSE = TRUE;
        //current absolute time in seconds
        double currentSystemTime = CACurrentMediaTime();
        NSDictionary *jsonDict = [[NSDictionary alloc]initWithObjectsAndKeys:[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[globals.ACCOUNT_INFO objectForKey:@"authorization"],@"device",globals.EVENT_NAME,@"event", nil];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                           options:0
                                                             error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // sent the game tags call
        NSString *url = [NSString stringWithFormat:@"%@/min/ajax/gametags/%@",globals.URL,jsonString];
        ////////NSLog(@"gametags url %@",url);
        //add the key "timeout" to solve the problem of loading for ever when witching to different event
        NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(getGameTagsCallBack:)],self,@"40", nil];
        NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller",@"timeout", nil];
        NSDictionary *instObj  = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [globals.APP_QUEUE enqueue:url dict:instObj];
    }else{
        if(!([globals.EVENT_NAME length]>1))
        {
            if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]) {
                globals.EVENT_NAME=@"live";
            }else{
                globals.EVENT_NAME = @"";
            }
        }
        NSString *thumbPlistPath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
        NSDictionary *pastEventsThumbsDict=[[NSDictionary alloc]initWithContentsOfFile:thumbPlistPath];
        globals.CURRENT_EVENT_THUMBNAILS = [pastEventsThumbsDict mutableCopy];
        //globals.TAG_MARKER_ITEMS = [pastEventsThumbsDict mutableCopy]; as far as I can tell, this is only for toasts
        pastEventsThumbsDict = nil;
        globals.DID_RECV_GAME_TAGS = TRUE;
        
        for(NSMutableDictionary *dict in [globals.CURRENT_EVENT_THUMBNAILS allValues])
        {
            //we are going to save the duration tag to the global duration dictionary by key time
            if([[dict objectForKey:@"type"] intValue]!=0 && [[dict objectForKey:@"type"] intValue]!=3)
            {
                NSString *timeStr =[NSString stringWithFormat:@"%@", [dict objectForKey:@"time"]]; //grab time
                if(![[globals.DURATION_TAGS_TIME allKeys] containsObject:timeStr]) //if the duration dictionary doesn't already have this time then add it
                {
                    //use the type value as the key, and the name value as the object in keyvalue pair
                    NSMutableDictionary *t = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[dict objectForKey:@"name"],[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"] ], nil];
                    [globals.DURATION_TAGS_TIME setObject:t forKey:timeStr]; // set the new dictionary to the global duration dict
                    //NSLog(@"getallgametags1 globals.DURATION_TAGS_TIME  %@",globals.DURATION_TAGS_TIME );
                }else{ //if for some odd reason the time already exists as a key -- will probably only happen at the beginning of the game
                    NSMutableDictionary *t = [[NSMutableDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:timeStr]];
                    int typeInt = [[dict objectForKey:@"type"] intValue];
                    NSString *typeStrStart = [NSString stringWithFormat:@"%d",typeInt-1];// string reprsentation of the starting tag for whatever tag you are on ... we want to make sure that it doesn't already exist at this time, and if it does we will delete it
                    if([[t allKeys]containsObject:typeStrStart])
                    {
                        [t removeObjectForKey:typeStrStart];
                    }

                    [t setObject:[dict objectForKey:@"name"] forKey:[NSString stringWithFormat:@"%@",[dict objectForKey:@"type"] ]];
                    [globals.DURATION_TAGS_TIME setObject:t forKey:timeStr];// replace the old dictionary with the new one.
                    //NSLog(@"getallgametags2 globals.DURATION_TAGS_TIME  %@",globals.DURATION_TAGS_TIME );
                }
                
                NSString *tagType;
                if([[dict objectForKey:@"type"] isKindOfClass:[NSNumber class]])
                {
                    tagType= [[dict objectForKey:@"type"] stringValue];
                }else{
                    tagType=[dict objectForKey:@"type"] ;
                }
                //// Now we put the time tagged into the global time array, but it has to be chronologically sorted
                if([[globals.DURATION_TYPE_TIMES objectForKey:tagType] count]>0) // only use the sorting algorithm if there is something in the array
                {
                    NSMutableArray *ty = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:tagType]];
                    if(![ty containsObject:timeStr])
                    {
                        NSInteger *index = [ty binarySearch:timeStr];
                        index = (int)index > 0 ? index : 0;
                        [ty insertObject:timeStr atIndex:index];
                        [globals.DURATION_TYPE_TIMES setObject:ty forKey:tagType];
                    }
                    
                }else{//otherwise just add the time to the array
                    NSMutableArray *ty = [[NSMutableArray alloc] initWithObjects:timeStr, nil];
                    [globals.DURATION_TYPE_TIMES setObject:ty forKey:tagType];
                }
                
                ///add to array of all offline tags
                //going to force all the types for all tags to be even -- we don't have to deal with starting tags in offline mode
                NSMutableArray *t;
                if([tagType isEqualToString:@"7"])
                {
                    [dict setObject:@"8" forKey:@"type"];
                }else if([tagType isEqualToString:@"1"])
                {
                    [dict setObject:@"2" forKey:@"type"];
                }else if([tagType isEqualToString:@"5"])
                {
                    [dict setObject:@"6" forKey:@"type"];
                }else if([tagType isEqualToString:@"9"])
                {
                    [dict setObject:@"10" forKey:@"type"];
                }else if([tagType isEqualToString:@"15"])
                {
                    [dict setObject:@"16" forKey:@"type"];
                }else if([tagType isEqualToString:@"17"])
                {
                    [dict setObject:@"18" forKey:@"type"];
                }
                
                
                if(![globals.OFFLINE_DURATION_TAGS objectForKey:tagType])//if the type doesn't exist in the offline duration tags dictionary we have to initialise it before addign it
                {
                    t = [[NSMutableArray alloc] initWithObjects:dict, nil];
                    [globals.OFFLINE_DURATION_TAGS setObject:t forKey:tagType];

                }else{
                    [[globals.OFFLINE_DURATION_TAGS objectForKey:tagType] addObject:dict];
                }
      
            }
        }
      //we are going to set the current period, o line, d line and strength based on what's in the thumbnail plist right now
    //for each one grab the array with that type, sort it and take the latest one.
        //we will also do other duration tags for sports that aren't hockey
        
        if([globals.WHICH_SPORT isEqualToString:@"hockey"])
        {
            //because the initial time will almost always be 0 we can just use this dictionary for all the types (don't have to repeat code)
            NSDictionary *a = [self setInitalGlobalDurationTagsOffline:@"2"];//dictionary at that time
            
            
            //check all the types if there are no offensive lines at initial time
            if(!a)
            {
                a=[self setInitalGlobalDurationTagsOffline:@"6"];
            }
            if(!a)
            {
                a=[self setInitalGlobalDurationTagsOffline:@"8"];
            }
            
            if(!a)
            {
                a=[self setInitalGlobalDurationTagsOffline:@"10"];
            }
            
            if(!a)
            {
                a=[self setInitalGlobalDurationTagsOffline:@"16"];
            }
            
            if(!a)
            {
                a=[self setInitalGlobalDurationTagsOffline:@"18"];
            }
            
            if(a)
            {
            //first offensive lines
            //have to extract the int from the line
            
            globals.CURRENT_F_LINE = [self extractIntFromStr:[a objectForKey:@"2"]]? [self extractIntFromStr:[a objectForKey:@"2"]]:1 ; // initial offensive line
            
            //defensive line
            globals.CURRENT_D_LINE = [self extractIntFromStr:[a objectForKey:@"6"]]? [self extractIntFromStr:[a objectForKey:@"6"]]:1 ; // initial defensive line
            
            //period
            //don't forget to cast as integer
                NSMutableArray *openEndStrings=[[NSMutableArray alloc] init];
                if([globals.WHICH_SPORT isEqualToString:@"hockey"])
                {
                    [openEndStrings addObject:@"7"];
                    [openEndStrings addObject:@"8"];
                }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
                {
                    [openEndStrings addObject:@"17"];
                    [openEndStrings addObject:@"18"];
                }
                globals.CURRENT_PERIOD = [self extractIntFromStr:[a objectForKey:[openEndStrings objectAtIndex:1]]] >0 ? [self extractIntFromStr:[a objectForKey:[openEndStrings objectAtIndex:1]]]:1 ;
            
            //strength
            globals.CURRENT_STRENGTH = [a objectForKey:@"10"];
            //NSLog(@"getAllgametags hockey globals.CURRENT_STRENGTH: %@",globals.CURRENT_STRENGTH);
            }else{
                //if the game doesn't have any duration tags for this type we'll set defaults
                
                globals.CURRENT_F_LINE=1;
                globals.CURRENT_D_LINE=1;
                globals.CURRENT_PERIOD=1;
                globals.CURRENT_STRENGTH=(NSMutableString*)@"5,5";

            }
        }
    }
}


//method to return the initial dictionary of the type being queried -- ex if I want the dictionary of what the initial conditions for type 2 are
-(NSDictionary*)setInitalGlobalDurationTagsOffline:(NSString*)type
{
    //grab the array of times for this type
    if([globals.DURATION_TYPE_TIMES objectForKey:type])
    {
        NSMutableArray *t = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:type]];
        
        [t sortUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) { //numerical sort
            return [str1 compare:str2 options:(NSNumericSearch)];
        }];
        
        //the initial time (will almost always be 0.0, but just in case
        //also forcing it to be a string because all times are being referenced as strings
        NSString* initTime= [NSString stringWithFormat:@"%@",[t objectAtIndex:0] ];
        NSDictionary* timeDictionary = [[NSDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey: initTime]];
        
        return timeDictionary;
    }
    return nil;
}

- (void) getGameTagsCallBack:(id)jsonArr
{
    //NSLog(@"***************************************************  getgametagscallback!!!");
    if ((!jsonArr || (jsonArr && (![jsonArr objectForKey:@"teams"] || ![jsonArr objectForKey:@"league"] || ![jsonArr objectForKey:@"events"]))) && !didResendGetAllTagsRequest) {
        [self getAllGameTags];
        didResendGetAllTagsRequest = TRUE;
        return;
    }else if((!jsonArr || (jsonArr && (![jsonArr objectForKey:@"teams"] || ![jsonArr objectForKey:@"league"] || ![jsonArr objectForKey:@"events"]))) && didResendGetAllTagsRequest){
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"myplayXplay"
                              message: @"Corrupt response. Please check the server connection and network condition."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        didResendGetAllTagsRequest = FALSE;
        //return;
    }

    if ([jsonArr count]) {
        
        globals.WAITING_CHOOSE_TEAM_PLAYERS = TRUE;
        
        if (didResendGetAllTagsRequest) {
            didResendGetAllTagsRequest = FALSE;
        }
        

        globals.SWITCH_TO_DIFFERENT_EVENT = FALSE;
        NSMutableDictionary *newTags = [[NSMutableDictionary alloc]init];
        NSArray *tagsOnServer = [[[NSMutableDictionary alloc]initWithDictionary:[jsonArr objectForKey:@"tags"]] allValues];
        NSMutableArray *tempTags = [self sortArrayByTime: [NSMutableArray arrayWithArray:tagsOnServer]];
        
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:2];
        // The same story as above, just tell here to execute the colorRotatorTask method.
        downloadTagsLeft = 0;
        if ([globals.DOWNLOADED_THUMBNAILS_SET count]) [globals.DOWNLOADED_THUMBNAILS_SET removeAllObjects];
        ////////NSLog(@"started downloading tags");
        //deal with all the new tags
        NSDictionary *dict;// = [[NSDictionary alloc] init];
        
        [globals.DURATION_TAGS_TIME removeAllObjects];
        [globals.DURATION_TYPE_TIMES removeAllObjects];
        
        for (int i = 0; i< tempTags.count; i++) {
            dict = [tempTags objectAtIndex:i];
            
            //if there is an duration tag opened before the app exited, the tag button will be highlighted when the user relaunch the app
            if([[dict objectForKey:@"type"]intValue] == 99 && [[[[UIDevice currentDevice] identifierForVendor]UUIDString] isEqualToString:[dict objectForKey:@"deviceid" ]]){
                globals.UNCLOSED_EVENT = [dict objectForKey:@"name"];
                [globals.OPENED_DURATION_TAGS setObject:[dict objectForKey:@"id"] forKey:[dict objectForKey:@"name"]];
            }
            
            //if the tag is deleted, don't add it to the global tags dictionay
            //remove all odd numbered tags - those are the line, period, strength starts
            if (!([[dict objectForKey:@"type"]integerValue]&1)) {
                NSString *tagId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                [newTags setObject:dict forKey:tagId];
                ////////NSLog(@"%@",[dict objectForKey:@"starttime"]);
                NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadTag:) object:dict];
                // Add the operation to the queue and let it to be executed.
                [operationQueue addOperation:operation];
                downloadTagsLeft++;
            }
            
            if([[dict objectForKey:@"type"]integerValue]!=0 && [[dict objectForKey:@"type"]integerValue]!=3)
            {
               
                //we are going to save the duration tag to the global duration dictionary by key time
                NSString *timeStr =[NSString stringWithFormat:@"%@", [dict objectForKey:@"time"]]; //grab time
                NSString *typeStr = [NSString stringWithFormat:@"%@", [dict objectForKey:@"type"]];
                if(![[globals.DURATION_TAGS_TIME allKeys] containsObject:timeStr]) //if the duration dictionary doesn't already have this time then add it
                {
                    //use the type value as the key, and the name value as the object in keyvalue pair
                    NSMutableDictionary *t = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[dict objectForKey:@"name"],typeStr, nil];
                    [globals.DURATION_TAGS_TIME setObject:t forKey:timeStr]; // set the new dictionary to the global duration dict
                    //NSLog(@"getgametagscallback3 globals.DURATION_TAGS_TIME  %@",globals.DURATION_TAGS_TIME );
                }else{ //if for some odd reason the time already exists as a key -- will probably only happen at the beginning of the game
                    NSMutableDictionary *t = [[NSMutableDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:timeStr]];
                    int typeInt = [[dict objectForKey:@"type"] intValue];
                    NSString *typeStrStart = [NSString stringWithFormat:@"%d",typeInt-1];// string reprsentation of the starting tag for whatever tag you are on ... we want to make sure that it doesn't already exist at this time, and if it does we will delete it
                    if([[t allKeys]containsObject:typeStrStart])
                    {
                        [t removeObjectForKey:typeStrStart];
                    }
                    

                    [t setObject:[dict objectForKey:@"name"] forKey:typeStr];
                    [globals.DURATION_TAGS_TIME setObject:t forKey:timeStr];// replace the old dictionary with the new one.
                    //NSLog(@"getgametagscallback4 globals.DURATION_TAGS_TIME  %@",globals.DURATION_TAGS_TIME );
                }
                
                //// Now we put the time tagged into the global time array, but it has to be chronologically sorted
                if([[globals.DURATION_TYPE_TIMES objectForKey:typeStr] count]>0) // only use the sorting algorithm if there is something in the array
                {
                    NSMutableArray *ty = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:typeStr]];
                    if(![ty containsObject:timeStr])
                    {
                        NSInteger *index = [ty binarySearch:timeStr];
                        index = (int)index > 0 ? index : 0;
                        [ty insertObject:timeStr atIndex:index];
                        [globals.DURATION_TYPE_TIMES setObject:ty forKey:typeStr];
                    }
                    
                }else{//otherwise just add the time to the array
                    NSMutableArray *ty = [[NSMutableArray alloc] initWithObjects:timeStr, nil];
                    [globals.DURATION_TYPE_TIMES setObject:ty forKey:typeStr];
                }
                
            }

            
        }
        
        if ([newTags count]==0)
        {
            globals.FINISHED_LOADING_THUMBNAIL_IMAGES = TRUE;
        }
        globals.CURRENT_EVENT_THUMBNAILS = [newTags mutableCopy];
        //if the event was downloaded, need to update the thumbnail.plist file. Next time, when play the events in offline mode, we will have correct tags
        if (globals.IS_LOCAL_PLAYBACK) {
            //thumbnails.plist path
            NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
            if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            }
            [globals.CURRENT_EVENT_THUMBNAILS writeToFile:filePath atomically:YES];
        }

        
        //accessed from fvc -- used to update tag markers on first launch in tagsetview
        //globals.TAG_MARKER_ITEMS = [newTags mutableCopy];//[[NSMutableDictionary alloc]initWithDictionary:[jsonArr objectForKey:@"tags"]];
        globals.NEW_EVENTS_FROM_SYNC = [[NSArray alloc] initWithArray:[jsonArr objectForKey:@"events"]];
        
        //grab current playing teams and store in global array
        if([jsonArr objectForKey:@"teams"])
        {
            globals.PLAYING_TEAMS_HIDS = [[NSMutableArray alloc] initWithArray:[jsonArr objectForKey:@"teams"]];
        }

        //first update the sport info, then update line info
        
        //get current league information
        NSString *currentLeagueHid = [jsonArr objectForKey:@"league"];
        
        //used in setting view to show the current event's home team, away team and league
        globals.ENCODER_SELECTED_HOME_TEAM = [[globals.ALL_TEAMS objectForKey:[globals.PLAYING_TEAMS_HIDS objectAtIndex:0]] objectForKey:@"name"];
        globals.ENCODER_SELECTED_AWAY_TEAM = [[globals.ALL_TEAMS objectForKey:[globals.PLAYING_TEAMS_HIDS objectAtIndex:1]] objectForKey:@"name"];
        globals.ENCODER_SELECTED_LEAGUE = [[globals.ALL_LEAGUES objectForKey:currentLeagueHid] objectForKey:@"name"];

        globals.WHICH_SPORT = [[[globals.ALL_LEAGUES objectForKey:currentLeagueHid] objectForKey:@"sport"] lowercaseString];
        if (!globals.WHICH_SPORT || [globals.WHICH_SPORT isEqual:@""]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @"myplayXplay"
                                  message: @"Corrupt response. Please check the server connection and network condition."
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
            ////////NSLog(@"globals.WHICH_SPORT %@, currentLeagueHid %@ [globals.ALL_LEAGUES objectForKey:currentLeagueHid] %@  globals.ALL_LEAGUES %@",globals.WHICH_SPORT,currentLeagueHid,[globals.ALL_LEAGUES objectForKey:currentLeagueHid],globals.ALL_LEAGUES);
        }
        // //////NSLog(@"globals.WHICH_SPORT %@, currentLeagueHid %@ [globals.ALL_LEAGUES objectForKey:currentLeagueHid] %@  globals.ALL_LEAGUES %@",globals.WHICH_SPORT,currentLeagueHid,[globals.ALL_LEAGUES objectForKey:currentLeagueHid],globals.ALL_LEAGUES);
        if ([globals.WHICH_SPORT isEqualToString:@"basketball"]) {
            globals.WHICH_SPORT = @"rugby";
        }
        
        //TODO:different football
        if ([globals.WHICH_SPORT isEqualToString:@"football (canadian)"]) {
            globals.WHICH_SPORT = @"football";
        }
        
        if ([globals.WHICH_SPORT isEqualToString:@"lacrosse"]) {
            globals.WHICH_SPORT = @"hockey";
        }
        
//        //for testing
//        if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
//            globals.WHICH_SPORT = @"soccer";
//        }
        
        if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
            [globals.ARRAY_OF_PERIODS removeAllObjects];
            [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"OT",@"PS", nil]];
        }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"basketball"]){
            [globals.ARRAY_OF_PERIODS removeAllObjects];
            [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"EXTRA",@"PS", nil]];
        }else if ([globals.WHICH_SPORT isEqualToString:@"rugby"]){
            [globals.ARRAY_OF_PERIODS removeAllObjects];
            [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"EXTRA", nil]];
        }else if([globals.WHICH_SPORT isEqual:@"football"]){
            [globals.ARRAY_OF_PERIODS removeAllObjects];
            [globals.ARRAY_OF_PERIODS addObjectsFromArray:[[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4", nil]];
        }else if ([globals.WHICH_SPORT isEqualToString:SPORT_FOOTBALL_TRAINING]){
            [globals.ARRAY_OF_PERIODS removeAllObjects];
        } else {
            [globals.ARRAY_OF_PERIODS removeAllObjects];
        }

        //reset line,strength,period and zone information
        //when playing back old event,and go to live, if this jsonArr does not return any line/strength/period/zone information of the new live event,
        //the line/strength/period/zone information in the old event will be displayed in the bottom view. So we have to reset these information before
        //go to live
        globals.CURRENT_F_LINE = -1;
        globals.CURRENT_D_LINE = -1;
        globals.CURRENT_PERIOD = -1;
        globals.CURRENT_STRENGTH = nil;
        globals.CURRENT_ZONE = nil;
        
        if([jsonArr objectForKey:@"events"])
        {
            globals.NEW_EVENTS_FROM_SYNC=[jsonArr objectForKey:@"events"];
            for (NSDictionary *syncEvent in globals.NEW_EVENTS_FROM_SYNC) {
                //update line/zone
                BOOL isLine = FALSE;
                if([self extractIntFromStr:[syncEvent objectForKey:@"type"]]==1){
                    //forward line
                    if ([globals.WHICH_SPORT isEqual:@"hockey"]) {
                        globals.CURRENT_F_LINE = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                        if ([globals.TOAST_QUEUE count]<=10){
                            [globals.TOAST_QUEUE addObject:syncEvent];
                        }
                        isLine = TRUE;
                    }else if([globals.WHICH_SPORT isEqual:@"football"]){
                        //                             globals.CURRENT_O_DOWN_FB = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                        //                             NSMutableDictionary *eventCopy = [syncEvent mutableCopy];
                        //                             [eventCopy setObject:[NSString stringWithFormat:@"Offense %d",globals.CURRENT_O_DOWN_FB] forKey:@"id"];
                        //                             if ([globals.TOAST_QUEUE count]<=10){
                        //                                 [globals.TOAST_QUEUE addObject:eventCopy];
                        //                             }
                    }
                    
                    //defense line
                } else  if ([self extractIntFromStr:[syncEvent objectForKey:@"type"]]==5) {
                    if ([globals.WHICH_SPORT isEqual:@"hockey"]) {
                        globals.CURRENT_D_LINE = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                        if ([globals.TOAST_QUEUE count]<=10){
                            [globals.TOAST_QUEUE addObject:syncEvent];
                        }
                        isLine=TRUE;
                    }else if([globals.WHICH_SPORT isEqual:@"football"]){
                        //                            globals.CURRENT_D_DOWN_FB = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                        //                            NSMutableDictionary *eventCopy = [syncEvent mutableCopy];
                        //                            [eventCopy setObject:[NSString stringWithFormat:@"Defense %d",globals.CURRENT_D_DOWN_FB] forKey:@"id"];
                        //                            if ([globals.TOAST_QUEUE count]<=10){
                        //                                [globals.TOAST_QUEUE addObject:eventCopy];
                        //                            }
                    }
                    
                }
                
                if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"])
                {
                    if(!isLine && [self extractIntFromStr:[syncEvent objectForKey:@"type"]] == 15)
                    {
                        globals.CURRENT_ZONE = [syncEvent objectForKey:@"id"];
//                        Don't need to show a toast for the zone on init
//                        if ([globals.TOAST_QUEUE count]<=10){
//                            [globals.TOAST_QUEUE addObject:syncEvent];
//                        }
                    }
                }
                //update period/half
                if([self extractIntFromStr:[syncEvent objectForKey:@"type"]]==7 || [self extractIntFromStr:[syncEvent objectForKey:@"type"]] == 17){
                    if ([globals.WHICH_SPORT isEqual:@"hockey"] || [globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]) {
                        globals.CURRENT_PERIOD = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                    }else if([globals.WHICH_SPORT isEqual:@"football"]){
                        globals.CURRENT_QUARTER_FB = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                        if([globals.WHICH_SPORT isEqual:@"football"]){
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateFBBottomViewControInfo" object:nil];
                        }
                    }
                    if ([globals.TOAST_QUEUE count]<=10){
                        [globals.TOAST_QUEUE addObject:syncEvent];
                    }
                }
                
                //update strength
                if ([self extractIntFromStr:[syncEvent objectForKey:@"type"]]==9 && [globals.WHICH_SPORT isEqual:@"hockey"]) {
                    globals.CURRENT_STRENGTH = [syncEvent objectForKey:@"id"];
                    //NSLog(@"get gametags call baack update strength globals.CURRENT_STRENGTH: %@",globals.CURRENT_STRENGTH);
                    if ([globals.TOAST_QUEUE count]<=10){
                        [globals.TOAST_QUEUE addObject:syncEvent];
                    }
                }
                
            }
            if ([globals.WHICH_SPORT isEqualToString:@"hockey"]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateBottomViewControInfo" object:nil ];
            }else if([globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]){
                [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateSoccerBottomViewControInfo" object:nil ];
            }
            //            else if([globals.WHICH_SPORT isEqual:@"football"]){
            //                [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateFBBottomViewControInfo" object:nil];
            //            }
            
        }
        
               //init team setup
        if(!globals.TEAM_SETUP)
        {
            globals.TEAM_SETUP=[[NSMutableArray alloc]init];
        }else{
            ////////NSLog(@"else globals.TEAM_SETUP: %@",globals.TEAM_SETUP);
            [globals.TEAM_SETUP removeAllObjects];
        }
        ////////NSLog(@"before first notification globals.TEAM_SETUP: %@",globals.TEAM_SETUP);
        //first time send notification to create bottomview controller
        [[NSNotificationCenter defaultCenter]postNotificationName:@"EventInformationUpdated" object:nil];
        
        //popup view for the user to choose which team's players he/she wants to tag
        if(globals.PLAYING_TEAMS_HIDS && globals.PLAYING_TEAMS_HIDS.count > 0)
        {
            NSString *pathToTeamPlist = [globals.EVENTS_PATH stringByAppendingPathComponent:@"players-setup.plist"];
            
            //TODO: if returns nil

            NSDictionary *teamsFromPlist = [[NSDictionary alloc]initWithContentsOfFile:pathToTeamPlist]; // all teams information
                       
            //pop up a small view for the user to choose which team he/she wants to tag
            UIView *teamNamePopoverView = [[UIView alloc] init];
            UIViewController* teamNamePopoverContent = [[UIViewController alloc] init];
            teamNamePopoverView.backgroundColor = [UIColor whiteColor];
            UILabel *messageText = [[UILabel alloc]initWithFrame:CGRectMake(40, 15, 320, 60)];
            messageText.lineBreakMode = NSLineBreakByWordWrapping;
            messageText.numberOfLines = 0;
            messageText.text = @"Please select the team you want to tag:";
            messageText.font = [UIFont defaultFontOfSize:17.0f];
            [teamNamePopoverView addSubview:messageText];
            
            NSMutableArray *currentPlayingTeamsName = [[NSMutableArray alloc]init];
            NSMutableArray *teamButtons = [[NSMutableArray alloc]init];
            for (id teamHid in globals.PLAYING_TEAMS_HIDS) {
                int i = [globals.PLAYING_TEAMS_HIDS indexOfObject:teamHid];
                if (teamsFromPlist) {
                      NSDictionary *teamDict = [[teamsFromPlist objectForKey:@"teams"] objectForKey:teamHid];
                    
                    if (teamDict) {
                        [currentPlayingTeamsName addObject:[teamDict objectForKey:@"name"]];
                        PopoverButton *teamNameButton = [PopoverButton buttonWithType:UIButtonTypeCustom];
                        [teamNameButton setFrame:CGRectMake(0.0f, 70.0f+(50.0f*i), teamNamePopoverView.bounds.size.width, 50.0f)];
                        [teamNameButton setTitle:[teamDict objectForKey:@"name"] forState:UIControlStateNormal];
                        [teamNameButton setAccessibilityLabel:[NSString stringWithFormat: @"%d",i]];
                        [teamNameButton addTarget:self action:@selector(teamSelected:) forControlEvents:UIControlEventTouchUpInside];
                        [teamNamePopoverView addSubview:teamNameButton];
                        [teamButtons addObject:teamNameButton];
                    }

                }
                             
            }
            
            if (teamButtons.count > 0) {
                teamNamePopoverContent.view = teamNamePopoverView;
                //set "modalInPopover" property to prevent the chooseTeamPlayerPopup view disappears when tap outside the popup view
                teamNamePopoverContent.modalInPopover = YES;
                //reset chooseTeamPlayerPopup to nil and reallocate it later
                chooseTeamPlayerPopup = nil;
                chooseTeamPlayerPopup = [[UIPopoverController alloc] initWithContentViewController:teamNamePopoverContent];
                int height = 35*[globals.PLAYING_TEAMS_HIDS count] + 120;
                [chooseTeamPlayerPopup setPopoverContentSize:CGSizeMake(400, height) animated:NO];
                //if there is alertview not been dismissed, dismiss it here
                
                [CustomAlertView dismissAll];
//                if (globals.ARRAY_OF_POPUP_ALERT_VIEWS.count > 0) {
//                    NSMutableArray *tempArr = [globals.ARRAY_OF_POPUP_ALERT_VIEWS mutableCopy];
//                    for(UIAlertView *view in tempArr){
//                        [view dismissWithClickedButtonIndex:0 animated:NO];
//                        [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:view];
//                    }
//                }
                //TODO: find a better way to do this
                if ([UIApplication sharedApplication].keyWindow.rootViewController) {
                    //[UIApplication sharedApplication].keyWindow.rootViewController is not nil, popup the chooseTeamPlayerPopup
                    [chooseTeamPlayerPopup presentPopoverFromRect:CGRectMake(300, 380 - height/2, 400, height) inView:[UIApplication sharedApplication].keyWindow.rootViewController.view permittedArrowDirections:0 animated:NO];
                }else{
                    //[UIApplication sharedApplication].keyWindow.rootViewController is nil, choose the first team
                    [[teamButtons objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
                }

            }else{
                //if the current playing event is not found 
                //global variables properly in order to go to the live2bench view
                globals.WAITING_CHOOSE_TEAM_PLAYERS = FALSE;
                globals.DID_RECV_GAME_TAGS = TRUE;
                globals.WAITING_GAME_TAGS_RESPONSE = FALSE;
            }
            
                       
        }else{
            //if no current playing teams information get from the server
            //global variables properly in order to go to the live2bench view 
            
            globals.WAITING_CHOOSE_TEAM_PLAYERS = FALSE;
            globals.DID_RECV_GAME_TAGS = TRUE;
            globals.WAITING_GAME_TAGS_RESPONSE = FALSE;
            
            if (globals.UNCLOSED_EVENT != nil && ![globals.UNCLOSED_EVENT isEqualToString:@""]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"highlightDurationTag" object:nil];
            }
            
        }
    }
}



-(void)teamSelected:(id)sender{
    CustomButton *teamButton = (CustomButton*)sender;
    NSString *pathToTeamPlist = [globals.EVENTS_PATH stringByAppendingPathComponent:@"players-setup.plist"];
    //all the teams,leagues and players information in current encoder
    NSDictionary *teamsFromPlist = [[NSDictionary alloc]initWithContentsOfFile:pathToTeamPlist]; // all teams information
    NSString *teamSelected = [globals.PLAYING_TEAMS_HIDS objectAtIndex:teamButton.accessibilityLabel.intValue];
    globals.TEAM_SETUP=[[teamsFromPlist objectForKey:@"teamsetup"] objectForKey:teamSelected];
    ////////NSLog(@"teamselected globals.TEAM_SETUP: %@",globals.TEAM_SETUP);
    globals.HUMAN_READABLE_EVENT_NAME = [globals.HUMAN_READABLE_EVENT_NAME stringByAppendingFormat:@" - Tagging team: %@",teamButton.titleLabel.text];
    
    //After the user choose which team player to display,
    //dismiss the pop up window for choosing team
    [chooseTeamPlayerPopup dismissPopoverAnimated:YES];
    chooseTeamPlayerPopup = nil;
    globals.WAITING_CHOOSE_TEAM_PLAYERS = FALSE;
    globals.DID_RECV_GAME_TAGS = TRUE;
    globals.WAITING_GAME_TAGS_RESPONSE = FALSE;
    
    //post the notification for update bottom view and player collection view for live2benchview
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EventInformationUpdated" object:nil];
    
    if (globals.UNCLOSED_EVENT != nil && ![globals.UNCLOSED_EVENT isEqualToString:@""]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"highlightDurationTag" object:nil];
    }
}

-(NSMutableArray*)sortArrayByTime:(NSMutableArray*)arr
{
    NSArray *sortedArray;
    sortedArray = [arr sortedArrayUsingComparator:(NSComparator)^(id a, id b) {
        NSNumber *num1 =[ NSNumber numberWithFloat:[[a objectForKey:@"starttime"] floatValue]];
        NSNumber *num2 = [ NSNumber numberWithFloat:[[b objectForKey:@"starttime"] floatValue]];
        
        return [num1 compare:num2];
    }];
    
    return (NSMutableArray*)sortedArray;
}


-(void)suspendTagsDownload{
    //[operationQueue setSuspended:YES];
}

-(void)downloadTag:(NSDictionary*)dict{
    if (globals.SWITCH_TO_DIFFERENT_EVENT || !dict || (dict && ![dict objectForKey:@"url"])) {
        return;
    }
    NSFileManager *fileManager= [NSFileManager defaultManager];
    //if thumbnail folder not exist, create a new one
    if(![fileManager fileExistsAtPath:globals.THUMBNAILS_PATH])
    {
        NSError *cError;
        [fileManager createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:TRUE attributes:nil error:&cError];
    }
    
    
    NSURL *jurl = [[NSURL alloc]initWithString:[[dict objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *imageName = [[dict objectForKey:@"url"] lastPathComponent];
    NSError *imgError;
    NSData *imgData= [NSData dataWithContentsOfURL:jurl options:0 error:&imgError];
    if (imgError) {
        NSLog(@"Image Error: %@",imgError);
        return;
    }
    
    //image file path for current image
    NSString *filePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
    
    //    //if the thumbnail folder doesn't exist it means that it got deleted somehow so let's create it
    //    if(!([globals.EVENT_NAME length]>1))
    //    {
    //        if ([globals.CURRENT_ENC_STATUS isEqualToString:@"live"]) {
    //            globals.EVENT_NAME=@"live";
    //        }else{
    //            globals.EVENT_NAME = @"";
    //        }
    //    }
    NSData *imgTData;
    NSString *teleImageFilePath;
    //save telesteration thumb
    if([[dict objectForKey:@"type"]intValue]==4)
    {
        //tele image datat
        imgTData= [NSData dataWithContentsOfURL:[NSURL URLWithString:[[dict objectForKey:@"teleurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:0 error:nil];
        NSString *teleImageName = [[dict objectForKey:@"teleurl"] lastPathComponent];
        //image file path for telestration
        teleImageFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
        
    }
    
    if (([[dict objectForKey:@"type"]intValue]!=4 && imgData != nil )||([[dict objectForKey:@"type"]intValue]==4 && imgData != nil && imgTData != nil) ) {
        
        [imgData writeToFile:filePath atomically:YES];
        
        if ([[dict objectForKey:@"type"]intValue]==4) {
            [imgTData writeToFile:teleImageFilePath atomically:YES ];
        }
        
        if (!globals.DOWNLOADED_THUMBNAILS_SET){
            globals.DOWNLOADED_THUMBNAILS_SET = [NSMutableArray arrayWithObject:[dict objectForKey:@"id"]];
        } else {
            [globals.DOWNLOADED_THUMBNAILS_SET addObject:[dict objectForKey:@"id"]];
        }
    }
}

-(void)showSpinner
{
    [globals.SPINNERVIEW removeSpinner];
    globals.SPINNERVIEW = nil;
    globals.SPINNERVIEW = [SpinnerView loadSpinnerIntoView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
}

-(void)encoderStatus
{
    //current absolute time in seconds
    double currentSystemTime = CACurrentMediaTime();
    NSMutableDictionary *summarydict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime", nil];
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:summarydict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {
        
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }

     NSString *url = [NSString stringWithFormat:@"%@/min/ajax/encoderstatjson/%@",globals.URL,jsonString];
    //callback method and parent view controller reference for the appqueue
    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(encoderStatusCallback:)],self,@"10", nil];
    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller",@"timeout", nil];
    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [globals.APP_QUEUE enqueue:url dict:instObj];
    
    //send the first upload local tag request
    //the other local tags requests will be sent after get response from the server
    if (globals.NUMBER_OF_LOCAL_TAGS_UPDATED == 0) {
        [self sendLocalTagRequest];
    }
}



//for testing
//int count = 0;
-(void)encoderStatusCallback:(id)jsonArray
{

    globals.CURRENT_ENC_STATUS=[jsonArray objectForKey:@"status"];
    int encStateCode = [[jsonArray objectForKey:@"code"] intValue];
    

    
    //this case will happen, if camera/prorecoder is disconnected during live event and then reconnected
    if ([globals.EVENT_NAME isEqual:@"live"] && [globals.CURRENT_ENC_STATUS isEqualToString:encStateStreamingOk]) {
        globals.CURRENT_ENC_STATUS = encStateLive;
    }
    
    if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive] && [globals.EVENT_NAME isEqualToString:@""]){//[globals.OLD_ENCODER_STATUS isEqualToString:@"stopped"]) {
        globals.eventExistsOnServer = TRUE;
        globals.DID_START_NEW_EVENT = TRUE;
        globals.EVENT_NAME=@"live";
        globals.HUMAN_READABLE_EVENT_NAME = @"Live";
        globals.CURRENT_PLAYBACK_EVENT = [NSString stringWithFormat:@"%@/events/live/video/list.m3u8",globals.URL];
        globals.DID_RECV_GAME_TAGS = FALSE;
        [self getAllGameTags];
        NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
        //AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
        
        [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
        [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
        [globals.VIDEO_PLAYER_LIST_VIEW pause];
        
        [globals.VIDEO_PLAYER_LIVE2BENCH setVideoURL:videoURL];
        [globals.VIDEO_PLAYER_LIVE2BENCH setPlayerWithURL:videoURL];
        [globals.VIDEO_PLAYER_LIVE2BENCH pause];
        globals.VIDEO_PLAYBACK_FAILED = FALSE;
        globals.PLAYABLE_DURATION = -1;
        [self restartSyncMeTimer];
        //update calendar events
        [self getLocalEvents];
        
        //NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&         NEW LIVE EVENT STARTED : GET NEW EVETNS");
    }else if((([globals.CURRENT_ENC_STATUS isEqualToString:encStateStopping] && ![globals.OLD_ENCODER_STATUS isEqualToString:encStateStopping]) || ([globals.CURRENT_ENC_STATUS isEqualToString:encStateStopped] && ![globals.OLD_ENCODER_STATUS isEqualToString:encStateStopped]) || ([globals.CURRENT_ENC_STATUS isEqualToString:encStateReady] && [globals.OLD_ENCODER_STATUS isEqualToString:encStateLive])) &&[globals.EVENT_NAME isEqualToString:@"live"]  ){
        //if the current event is live and 1. current encoder status is stopping and old ecoder status is not stopping 2. current encoder status is stopped and
        //the old encoder status is not stopped 3. the current encoder status is ready and the old encoder status is live, show the live event stopped message.
        
        //stop syncme timer
        [self stopSyncMeTimer];
        //when encoder status is "off", reset the player
        globals.CURRENT_PLAYBACK_EVENT = @"";
        NSURL *videoURL = [NSURL URLWithString:globals.CURRENT_PLAYBACK_EVENT];
       // AVPlayer *myPlayer = [AVPlayer playerWithURL:videoURL];
        
        [globals.VIDEO_PLAYER_LIVE2BENCH setVideoURL:videoURL];
        [globals.VIDEO_PLAYER_LIVE2BENCH setPlayerWithURL:videoURL];
        
        [globals.VIDEO_PLAYER_LIST_VIEW setVideoURL:videoURL];
        [globals.VIDEO_PLAYER_LIST_VIEW setPlayerWithURL:videoURL];
        globals.VIDEO_PLAYBACK_FAILED = FALSE;
        globals.PLAYABLE_DURATION = -1;
        
        NSString *pathToLive =[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *delError;
        [fileManager removeItemAtPath:pathToLive error:&delError];
       
        //pop up to inform user that stream was ended
        if (!liveStreamEndedAlert) {
            liveStreamEndedAlert = [[CustomAlertView alloc] initWithTitle:@"myplayXplay" message:@"The live stream has ended" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [liveStreamEndedAlert show];
//            [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:liveStreamEndedAlert];
            [[NSNotificationCenter defaultCenter]postNotificationName:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            globals.WHICH_SPORT = @"";
            [globals.TEAM_SETUP removeAllObjects];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SportInformationUpdated" object:nil];
        }
        globals.EVENT_NAME=@"";
    }else if(([globals.CURRENT_ENC_STATUS isEqualToString:encStateReady] || [globals.CURRENT_ENC_STATUS isEqualToString:encStateStopped])&& !globals.DID_START_NEW_EVENT &&![globals.EVENT_NAME isEqualToString:@"live"]&&![globals.EVENT_NAME isEqualToString:@""] && [globals.OLD_ENCODER_STATUS isEqualToString:encStateStopping]){
        //if the user is viewing old event when the live stream stopped, @"The live stream has ended" view won't pop up, then we couldn't get the latest local events from customTabBar; So we need to the "getlocalevents" method here
         //NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&   REVIEWING OTHER EVENT : GET NEW EVETNS");
        [self getLocalEvents];
        //isEventStopped = TRUE;
    }
    
    //when the live event is completely stopped, send request to the server to request for all old events and update calendar
    if (([globals.CURRENT_ENC_STATUS isEqualToString:encStateReady]&& [globals.OLD_ENCODER_STATUS isEqualToString:encStateStopping]) || ([globals.CURRENT_ENC_STATUS isEqualToString:encStateStopped] && [globals.OLD_ENCODER_STATUS isEqualToString:encStateLive]) ) {
        //NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&  OLD LIVE EVENT STOPPED COMPLETELY : GET NEW EVETNS");
        [self getLocalEvents];
    }
    
    if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateCameraDisconnected] || [globals.CURRENT_ENC_STATUS isEqualToString:encStateProrecorderDisconnected]) {
        globals.CURRENT_ENC_STATUS = @"disconnected";
    }
    
    if (![globals.OLD_ENCODER_STATUS isEqualToString:globals.CURRENT_ENC_STATUS]) {
        if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]) {
            //If the current encoder status is live and old status is not live and the user is in live2bench view,make sure the video player goes to live (i.e. the user paused the video and then resume to live, the video should go to live).
            //NOTE: we need to check wether the current event live or not. If the user is playing back past event, pause or resume encoder should not effect the video playback.
            if (globals.IS_IN_FIRST_VIEW && [globals.EVENT_NAME isEqualToString:@"live"]) {
                 [globals.VIDEO_PLAYER_LIVE2BENCH goToLive];
            }
           
        }
        globals.OLD_ENCODER_STATUS = globals.CURRENT_ENC_STATUS;
        encoderStatusAlert = nil;
        encoderStatusCount = 0;
    }else{
        encoderStatusCount++;
    }
    
    //if @"disconnected" happens 5 times(10 secs, encoderStatusCount == 4),pop up error alert view
    if ((([globals.CURRENT_ENC_STATUS isEqualToString:encStateNoCamera] || [globals.CURRENT_ENC_STATUS isEqualToString:@"disconnected"]) && encoderStatusCount >= 4) || (encStateCode & STAT_NOCAM) ){//[globals.OLD_ENCODER_STATUS isEqualToString:@"disconnected"]) {
        if (!encoderStatusAlert) {
          
            NSString * message = @"No camera is detected. Please check the camera connection.";
            
            
            if (![CustomAlertView alertMessageExists:message]){
                 encoderStatusAlert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
                [encoderStatusAlert show];
                previousAlertView = encoderStatusAlert;
            }
            
//            encoderStatusAlert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"No camera is detected. Please check the camera connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            BOOL alertExists = NO;
//            for (UIAlertView *alert in globals.ARRAY_OF_POPUP_ALERT_VIEWS){
//                ////NSLog(@"alert: %@", alert.message);
//                ////NSLog(@"message: %@", encoderStatusAlert.message);
//                if ([alert.message isEqualToString:encoderStatusAlert.message]){
//                    alertExists = YES;
//                }
//            }
//            if (!alertExists){
//                [encoderStatusAlert show];
//                previousAlertView = encoderStatusAlert;
//                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:encoderStatusAlert];
//            }
        }
        
    }else if([globals.CURRENT_ENC_STATUS isEqualToString:encStatePaused]){
        if (!encoderStatusAlert && [globals.EVENT_NAME isEqualToString:@"live"]) {
            [globals.VIDEO_PLAYER_LIVE2BENCH pause];
            
            NSString * message = @"The encoder is paused. It can be resumed in the encoder control page.";
            
            if (![CustomAlertView alertMessageExists:message]){
                 encoderStatusAlert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [encoderStatusAlert show];
                previousAlertView = encoderStatusAlert;
            }
            
//            encoderStatusAlert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"The encoder is paused. It can be resumed in the encoder control page." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            BOOL alertExists = NO;
//            for (UIAlertView *alert in globals.ARRAY_OF_POPUP_ALERT_VIEWS){
//                if ([alert.message isEqualToString:encoderStatusAlert.message]){
//                    alertExists = YES;
//                }
//            }
//            if (!alertExists){
//                [encoderStatusAlert show];
//                previousAlertView = encoderStatusAlert;
//                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:encoderStatusAlert];
//            }
        }
        
    }else if([globals.CURRENT_ENC_STATUS isEqualToString:@""]){
        if (!encoderStatusAlert) {
            
            NSString * message = @"No response from the server. Please check the server connection.";
            
            if (![CustomAlertView alertMessageExists:message] ) {
                 encoderStatusAlert = [[CustomAlertView alloc]initWithTitle:@"myplayXplay" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [encoderStatusAlert show];
                previousAlertView = encoderStatusAlert;
            }
//            encoderStatusAlert = [[UIAlertView alloc]initWithTitle:@"myplayXplay" message:@"No response from the server. Please check the server connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            BOOL alertExists = NO;
//            for (UIAlertView *alert in globals.ARRAY_OF_POPUP_ALERT_VIEWS){
//                if ([alert.message isEqualToString:encoderStatusAlert.message]){
//                    alertExists = YES;
//                }
//            }
//            if (!alertExists){
//                [encoderStatusAlert show];
//                previousAlertView = encoderStatusAlert;
//                [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:encoderStatusAlert];
//            }
        }
    }else if ([globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]){
        
        //if the status becomes "live", remove the previoius alertview from the globals.ARRAY_OF_POPUP_ALERT_VIEWS
        if (previousAlertView) {
            
//            CustomAlertView
            
            if ([CustomAlertView alertMessageExists:previousAlertView.message]){
                [CustomAlertView removeAlertWithMessage:previousAlertView.message];
                encoderStatusAlert = nil;
            }

//            if (globals.ARRAY_OF_POPUP_ALERT_VIEWS) {
//                NSArray *tempArr = [globals.ARRAY_OF_POPUP_ALERT_VIEWS copy];
//                for (UIAlertView *alert in tempArr){
//                    if ([alert.message isEqualToString:previousAlertView.message]){
//                        [globals.ARRAY_OF_POPUP_ALERT_VIEWS removeObject:alert];
//                        encoderStatusAlert = nil;
//                    }
//                }
//            }
            //when status becoms "live", dismiss the previous alter view
            [previousAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
    }

}


-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:    (NSInteger)buttonIndex
{
    if ([alertView isEqual:liveStreamEndedAlert] ) {
        if(buttonIndex==0)
        {
            [self showSpinner];
            
            [globals.TAGGED_ATTS_DICT removeAllObjects];
            [globals.TAGGED_ATTS_DICT_SHIFT removeAllObjects];
            [globals.ARRAY_OF_COLOURS removeAllObjects];
            [globals.THUMBS_WERE_SELECTED_CLIPVIEW removeAllObjects];
            [globals.THUMBS_WERE_SELECTED_LISTVIEW removeAllObjects];
            globals.THUMB_WAS_SELECTED_CLIPVIEW = nil;
            globals.THUMB_WAS_SELECTED_LISTVIEW = nil;
            //remove all the objects in global CURRENT EVENT THUMBNAILS; Then get all the tag for the new play back event
            [globals.CURRENT_EVENT_THUMBNAILS removeAllObjects];
            //[globals.TAG_MARKER_ITEMS removeAllObjects];
            [globals.ARRAY_OF_TAGSET removeAllObjects];
            [globals.TOAST_QUEUE removeAllObjects];
            
            NSMutableArray *tempArray = [[globals.TAG_MARKER_OBJ_DICT allKeys] mutableCopy];
            for(NSString *key in tempArray){
                [[[globals.TAG_MARKER_OBJ_DICT objectForKey:key] markerView] removeFromSuperview];
            }
            [globals.TAG_MARKER_OBJ_DICT removeAllObjects];
            //reset all the line,period/zone,strength info for new event
            globals.CURRENT_F_LINE = -1;
            globals.CURRENT_D_LINE = -1;
            globals.CURRENT_PERIOD = -1;
            globals.CURRENT_STRENGTH = nil;
            globals.CURRENT_ZONE = nil;
            [globals.DURATION_TAGS_TIME removeAllObjects];
            [globals.DURATION_TYPE_TIMES removeAllObjects];
            if (![globals.CURRENT_ENC_STATUS isEqualToString:encStateLive]) {
                globals.CURRENT_APP_STATE= apstMinNoLive;
                
                globals.DID_START_NEW_EVENT = FALSE;
                globals.HUMAN_READABLE_EVENT_NAME = @"";
                globals.WHICH_SPORT = @"";
                //[[NSNotificationCenter defaultCenter]postNotificationName:@"SportInformationUpdated" object:nil];
                //used in setting view to show the current event's home team, away team and league
                globals.ENCODER_SELECTED_HOME_TEAM = @"Home Team";
                globals.ENCODER_SELECTED_AWAY_TEAM = @"Away Team";
                globals.ENCODER_SELECTED_LEAGUE = @"League";
                
                //isEventStopped = TRUE;
            }else{
                
                [globals.SPINNERVIEW removeSpinner];
                globals.SPINNERVIEW = nil;
            }
            liveStreamEndedAlert = nil;
            
            //get the latest local events to update calendar data
            //[self getLocalEvents];
        }
    }
    
    if (![CustomAlertView alertMessageExists:alertView.message]) {
        [CustomAlertView addAlert:alertView];
    }
//    [globals.ARRAY_OF_POPUP_ALERT_VIEWS addObject:alertView];
}

-(void)syncMe
{
    if (!globals.HAS_MIN) {
        return;
    }
    ////////NSLog(@"syncme");
    if(globals.STOP_TIMERS_FROM_LOGOUT)
    {
        return;
    }
    
    NSMutableDictionary *userInformation = globals.ACCOUNT_INFO;

    //current absolute time in seconds
    double currentSystemTime = 0; //CACurrentMediaTime();
    NSString *eventName = globals.EVENT_NAME;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[userInformation objectForKey:@"hid"],@"user",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",eventName,@"event",[userInformation objectForKey:@"authorization"],@"device", nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString;
    if (! jsonData) {

    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/syncme/%@",globals.URL,jsonString];

     NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(syncMeCallBack:)],self,@"10", nil];
    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller",@"timeout", nil];
    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [globals.APP_QUEUE enqueue:url dict:instObj];
}

- (void)syncMeCallBack:(id)jsonArray
{
    BOOL isDir;
    globals.THUMBNAILS_PATH = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"thumbnails"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:globals.THUMBNAILS_PATH isDirectory:&isDir])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:globals.VIDEOS_PATH withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    if([jsonArray count]>0)
    {
        if([jsonArray objectForKey:@"tags"])
        {
            if(!globals.IS_IN_FIRST_VIEW){
                //when receiving server response, then send the next tagset request in live2benchview
                [[NSNotificationCenter defaultCenter]postNotificationName:@"sendNextTag" object:nil];

            }
            
            globals.DID_CREATE_NEW_TAG=TRUE;
            
            NSMutableDictionary *newTags = [[NSMutableDictionary alloc]init];
            NSArray *tempTags = [[[NSMutableDictionary alloc]initWithDictionary:[jsonArray objectForKey:@"tags"]]allValues];
            
            for (NSDictionary *dict in tempTags) {
                
                //if the tag is deleted, don't add it to the global tags dictionary
                if ( [[dict objectForKey:@"type"]integerValue] != 3) {
                    //NSLog(@"new tag %@",dict);
                    if ([globals.WHICH_SPORT isEqualToString:@"football"]) {
                        if([[dict objectForKey:@"name"] length]>1)
                        {
                            //Suppose opp tags are on the right
                            if([globals.RIGHT_TAG_BUTTONS_NAME containsObject:[dict objectForKey:@"name"]])
                            {
                                [globals.playCallOppArray addObject:dict];
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdatePlayCallOpp" object:nil];
                            }else{
                                [globals.playCallArray addObject:dict];
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdatePlayCall" object:nil];
                            }
                            
                        }
                        
                        //get the latest down tag
                        if ([[dict objectForKey:@"name"] rangeOfString:@"Offense "].location != NSNotFound && [[dict objectForKey:@"type"]integerValue] == 1){
                            globals.CURRENT_DOWN_TAGID = [dict objectForKey:@"id"];
                            BOOL hasNewInfo = FALSE;
                            int currentPlayNumber = [[[dict objectForKey:@"strength"] objectAtIndex:0]integerValue];
                            if (globals.CURRENT_O_PLAY_NUMBER_FB != currentPlayNumber) {
                                globals.CURRENT_O_PLAY_NUMBER_FB = currentPlayNumber;
                                hasNewInfo = TRUE;
                            }
                            
                            int currentDownNumber = [self extractIntFromStr:[dict objectForKey:@"name"]];
                            if (globals.CURRENT_O_DOWN_FB != currentDownNumber){
                                globals.CURRENT_O_DOWN_FB = currentDownNumber;
                                NSMutableDictionary *eventCopy = [[NSMutableDictionary alloc]init];
                                [eventCopy setObject:[NSString stringWithFormat:@"Offense %d",globals.CURRENT_O_DOWN_FB] forKey:@"id"];
                                if ([globals.TOAST_QUEUE count]<=10){
                                    [globals.TOAST_QUEUE addObject:eventCopy];
                                }
                                hasNewInfo = TRUE;
                            }
                            
                            int currentDistance = [self extractIntFromStr:[[dict objectForKey:@"player"] objectAtIndex:0]];
                            if (globals.CURRENT_O_DISTANCE_FB != currentDistance) {
                                globals.CURRENT_O_DISTANCE_FB = currentDistance;
                                hasNewInfo = TRUE;
                            }
                            
                            int currentActionNumber = [self extractIntFromStr:[dict objectForKey:@"zone"]];
                            if (globals.CURRENT_O_ACTION_FB != currentActionNumber) {
                                globals.CURRENT_O_ACTION_FB = currentActionNumber;
                                hasNewInfo = TRUE;
                            }
                            
                            if (hasNewInfo) {
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateFBOffViewControInfo" object:nil];
                            }
                            
                        } else if([[dict objectForKey:@"name"] rangeOfString:@"Defense "].location != NSNotFound && [[dict objectForKey:@"type"]integerValue] == 1 ) {
                            globals.CURRENT_DOWN_TAGID = [dict objectForKey:@"id"];
                            
                            BOOL hasNewInfo = FALSE;
                            int currentPlayNumber = [[[dict objectForKey:@"strength"] objectAtIndex:0]integerValue];
                            
                            if (globals.CURRENT_D_PLAY_NUMBER_FB != currentPlayNumber) {
                                globals.CURRENT_D_PLAY_NUMBER_FB = currentPlayNumber;
                                hasNewInfo = TRUE;
                            }
                            
                            int currentDownNumber = [self extractIntFromStr:[dict objectForKey:@"name"]];
                            if (globals.CURRENT_D_DOWN_FB != currentDownNumber){
                                globals.CURRENT_D_DOWN_FB = currentDownNumber;
                                NSMutableDictionary *eventCopy = [[NSMutableDictionary alloc]init];
                                [eventCopy setObject:[NSString stringWithFormat:@"Defense %d",globals.CURRENT_D_DOWN_FB] forKey:@"id"];
                                if ([globals.TOAST_QUEUE count]<=10){
                                    [globals.TOAST_QUEUE addObject:eventCopy];
                                }
                                hasNewInfo = TRUE;
                            }
                            
                            int currentDistance = [self extractIntFromStr:[[dict objectForKey:@"player"] objectAtIndex:0]];
                            if (globals.CURRENT_D_DISTANCE_FB != currentDistance) {
                                globals.CURRENT_D_DISTANCE_FB = currentDistance;
                                hasNewInfo = TRUE;
                            }
                            
                            int currentActionNumber = [self extractIntFromStr:[dict objectForKey:@"zone"]];
                            if (globals.CURRENT_D_ACTION_FB != currentActionNumber) {
                                globals.CURRENT_D_ACTION_FB = currentActionNumber;
                                hasNewInfo = TRUE;
                            }
                            
                            if (hasNewInfo) {
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateFBDefViewControInfo" object:nil];
                            }
                        }
                        
                    }
                    
                    //add whatever tags just came in to the newtags dictionary so we can access them later and start processing them for clip view
                    NSString *tagId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
                    [newTags setObject:dict forKey:tagId];
                    //NSLog(@"Newtags: %@",newTags);
                    NSString *UUID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
                    //saved the odd-type duration tag which belongs to the current user, and it will be closed later
                    if ([[dict objectForKey:@"type"]intValue] == 99 && [[dict objectForKey:@"deviceid"] isEqualToString:UUID]) {
                        [globals.OPENED_DURATION_TAGS setObject:tagId forKey:[dict objectForKey:@"name"]];
                        if (globals.PRECLOSED_DURATION_TAGS && [[globals.PRECLOSED_DURATION_TAGS allKeys] containsObject:[dict objectForKey:@"name"]]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"precloseDurationTagReceived" object:[dict objectForKey:@"name"]];
                        }
                    }else if ([[dict objectForKey:@"type"]intValue] == 100 && [[dict objectForKey:@"deviceid"] isEqualToString:UUID]){
                        if (globals.OPENED_DURATION_TAGS && [[globals.OPENED_DURATION_TAGS allValues] containsObject:[dict objectForKey:@"id"]]) {
                           
                            [globals.OPENED_DURATION_TAGS removeObjectForKey:[dict objectForKey:@"name"]];
                        }

                    }
                    //will add all of the duration types to whatever arrays they need to be in
                    //we are only going to deal with non 0 type tags because we don't care about the duration for normal tags
                    if([[dict objectForKey:@"type"]integerValue]!=0)
                    {
                        //we are going to save the duration tag to the global duration dictionary by key time
                        NSString *timeStr =[NSString stringWithFormat:@"%@", [dict objectForKey:@"time"]]; //grab time
                        NSString *typeStr =[NSString stringWithFormat:@"%@", [dict objectForKey:@"type"]]; //grab type

                        if(![[globals.DURATION_TAGS_TIME allKeys] containsObject:timeStr]) //if the duration dictionary doesn't already have this time then add it
                        {
                            //use the type value as the key, and the name value as the object in keyvalue pair
                            NSMutableDictionary *t = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[dict objectForKey:@"name"],typeStr, nil];
                            [globals.DURATION_TAGS_TIME setObject:t forKey:timeStr]; // set the new dictionary to the global duration dict
                            //NSLog(@"syncmecallback1 globals.DURATION_TAGS_TIME  %@",globals.DURATION_TAGS_TIME );
                        }else{ //if for some odd reason the time already exists as a key -- will probably only happen at the beginning of the game
                            NSMutableDictionary *t = [[NSMutableDictionary alloc]initWithDictionary:[globals.DURATION_TAGS_TIME objectForKey:timeStr]];
                            int typeInt = [[dict objectForKey:@"type"] intValue];
                            NSString *typeStrStart = [NSString stringWithFormat:@"%d",typeInt-1];// string reprsentation of the starting tag for whatever tag you are on ... we want to make sure that it doesn't already exist at this time, and if it does we will delete it
                            if([[t allKeys]containsObject:typeStrStart])
                            {
                                [t removeObjectForKey:typeStrStart];
                            }
                            

                            [t setObject:[dict objectForKey:@"name"] forKey:typeStr];
                            [globals.DURATION_TAGS_TIME setObject:t forKey:timeStr];// replace the old dictionary with the new one.
                            //NSLog(@"syncmecallback2 globals.DURATION_TAGS_TIME  %@",globals.DURATION_TAGS_TIME );
                        }
                        
                        //// Now we put the time tagged into the global time array, but it has to be chronologically sorted
                        if([[globals.DURATION_TYPE_TIMES objectForKey:typeStr] count]>0) // only use the sorting algorithm if there is something in the array
                        {
                            NSMutableArray *ty = [[NSMutableArray alloc]initWithArray:[globals.DURATION_TYPE_TIMES objectForKey:typeStr]];
                            if(![ty containsObject:timeStr])
                            {
                                NSInteger *index = [ty binarySearch:timeStr];
                                index = (int)index > 0 ? index : 0;
                                [ty insertObject:timeStr atIndex:index];
                                [globals.DURATION_TYPE_TIMES setObject:ty forKey:typeStr];
                            }
                            
                        }else{//otherwise just add the time to the array
                            NSMutableArray *ty = [[NSMutableArray alloc] initWithObjects:timeStr, nil];
                            [globals.DURATION_TYPE_TIMES setObject:ty forKey:typeStr];
                        }

                }
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                            //background processing goes here
                    
                            NSURL *jurl = [[NSURL alloc]initWithString:[[dict objectForKey:@"url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                            
                            NSString *imageName = [[dict objectForKey:@"url"] lastPathComponent];
                            NSData *imgData= [NSData dataWithContentsOfURL:jurl options:0 error:nil];
                            
                            
                            //add image to directory
                            NSString *filePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageName]];
                            [imgData writeToFile:filePath atomically:YES ];
                            
                            //save telesteration thumb
                            if([[dict objectForKey:@"type"]intValue]==4)
                            {
                                NSData *imgTData= [NSData dataWithContentsOfURL:[NSURL URLWithString:[[dict objectForKey:@"teleurl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:0 error:nil];
                                
                                //get image name
                                
                                NSError* error;
                                
                                //create thumbnail directory in documents directory
                                
                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                
                                if(![fileManager fileExistsAtPath:globals.THUMBNAILS_PATH])
                                {
                                    [fileManager createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:&error];
                                    
                                }
                                
                                //NSURL *turl = [[NSURL alloc]initWithString:[[dict objectForKey:@"teleurl"]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                NSString *teleImageName = [[dict objectForKey:@"teleurl"] lastPathComponent];
                                //add image to directory
                                NSString *imageFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
                                
                                [imgTData writeToFile:imageFilePath atomically:YES ];
                                
                                globals.LATEST_TELE = dict;
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"getnewtele" object:Nil];
                            }
                            
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                //update UI here
//                            });
//                        });
                    
                    
                    
                }else{
                    //this tag is deleted, delete it from this tablet
                    if ([[globals.CURRENT_EVENT_THUMBNAILS allKeys] containsObject:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]]) {
                        [globals.CURRENT_EVENT_THUMBNAILS removeObjectForKey:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
                    }
                }
                
                //type 0: normal tag, type 4: tele tag, type 100: duration tag,type 2: offense line shift, type 6: defense line shift, type 16: soccer zone shift
                //add tags to toast queue to display
                if([[dict objectForKey:@"type"] intValue]==0||[[dict objectForKey:@"type"] intValue]==100 || [[dict objectForKey:@"type"] intValue]==4 || [[dict objectForKey:@"type"] intValue]==2 || [[dict objectForKey:@"type"] intValue]==6 || [[dict objectForKey:@"type"] intValue]==16)  //&& ![globals.TAG_MARKER_ITEMS objectForKey:[dict objectForKey:@"id"]])
                {
                    if ([[dict objectForKey:@"modified"] intValue] != 1) {
                        
                        if ([globals.TOAST_QUEUE count]<=10){
                            [globals.TOAST_QUEUE addObject:dict];
                        }
        
                    }
                    
                }
                
            }
            
//            if (newTags.count > 0) {
//                if(globals.IS_IN_LIST_VIEW){
//                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateListView" object:[newTags allValues]];
//                }else if (globals.IS_IN_CLIP_VIEW){
//                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateClipView" object:[newTags allValues]];
//                }
//                
//            }
            
            
            //save all the new tags and updated tags during the game
            NSArray *newTagsIdArr = [newTags allKeys];
            globals.NEW_TAGS_FROM_SYNC=[[NSMutableArray alloc]initWithArray:[newTags allValues] ];
            if (globals.CURRENT_EVENT_THUMBNAILS.count>0)
            {
                for(NSString *tag_id in newTagsIdArr){
                    [globals.CURRENT_EVENT_THUMBNAILS setObject:[newTags objectForKey:tag_id] forKey:tag_id];
                }
                
            }else{
                globals.CURRENT_EVENT_THUMBNAILS = [newTags mutableCopy];
            }
            
            //if the current playing event is downloaded, save the new tags to local plist file
            if (globals.IS_LOCAL_PLAYBACK) {
                //thumbnails.plist path
                NSString *filePath = [[globals.EVENTS_PATH stringByAppendingPathComponent:globals.EVENT_NAME] stringByAppendingPathComponent:@"Thumbnails.plist"];
                if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                }
                [globals.CURRENT_EVENT_THUMBNAILS writeToFile:filePath atomically:YES];
            }
            
            //update list view or clip view
            if(globals.IS_IN_LIST_VIEW){
                //NSLog(@"updateListView");
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updateListView" object:[newTags allValues]];
            }else if (globals.IS_IN_CLIP_VIEW){
                //NSLog(@"updateClipView");
                [[NSNotificationCenter defaultCenter]postNotificationName:@"updateClipView" object:[newTags allValues]];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdatedEventThumbnails" object:nil];
        }
        
        if([jsonArray objectForKey:@"events"])
        {
            globals.NEW_EVENTS_FROM_SYNC=[jsonArray objectForKey:@"events"];
            for (NSDictionary *syncEvent in globals.NEW_EVENTS_FROM_SYNC) {
                //update line/zone
                if([[syncEvent objectForKey:@"type"]isEqualToString:@"changed_bitrate"])
                {
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangedBitrate" object:nil ];
                }
                BOOL isLine = FALSE;
                if([self extractIntFromStr:[syncEvent objectForKey:@"type"]]==1){
                    //forward line
                        if ([globals.WHICH_SPORT isEqual:@"hockey"]) {
                            globals.CURRENT_F_LINE = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                            if ([globals.TOAST_QUEUE count]<=10){
                                [globals.TOAST_QUEUE addObject:syncEvent];
                            }
                            isLine = TRUE;
                        }else if([globals.WHICH_SPORT isEqual:@"football"]){
                            //                             globals.CURRENT_O_DOWN_FB = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                            //                             NSMutableDictionary *eventCopy = [syncEvent mutableCopy];
                            //                             [eventCopy setObject:[NSString stringWithFormat:@"Offense %d",globals.CURRENT_O_DOWN_FB] forKey:@"id"];
                            //                             if ([globals.TOAST_QUEUE count]<=10){
                            //                                 [globals.TOAST_QUEUE addObject:eventCopy];
                            //                             }
                        }
                    
                    //defense line
                } else if ([self extractIntFromStr:[syncEvent objectForKey:@"type"]]==5) {
                        if ([globals.WHICH_SPORT isEqual:@"hockey"]) {
                            globals.CURRENT_D_LINE = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                            if ([globals.TOAST_QUEUE count]<=10){
                                [globals.TOAST_QUEUE addObject:syncEvent];
                            }
                            isLine=TRUE;
                        }else if([globals.WHICH_SPORT isEqual:@"football"]){
                            //                            globals.CURRENT_D_DOWN_FB = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                            //                            NSMutableDictionary *eventCopy = [syncEvent mutableCopy];
                            //                            [eventCopy setObject:[NSString stringWithFormat:@"Defense %d",globals.CURRENT_D_DOWN_FB] forKey:@"id"];
                            //                            if ([globals.TOAST_QUEUE count]<=10){
                            //                                [globals.TOAST_QUEUE addObject:eventCopy];
                            //                            }
                        }
                        
                    }
                
                
                //update period/half
                if([self extractIntFromStr:[syncEvent objectForKey:@"type"]] == 7 || [self extractIntFromStr:[syncEvent objectForKey:@"type"]] == 17){
                    if ([globals.WHICH_SPORT isEqual:@"hockey"] || [globals.WHICH_SPORT isEqualToString:@"soccer"] || [globals.WHICH_SPORT isEqualToString:@"rugby"]) {
                        globals.CURRENT_PERIOD = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                    }else if([globals.WHICH_SPORT isEqual:@"football"]){
                        globals.CURRENT_QUARTER_FB = [self extractIntFromStr:[syncEvent objectForKey:@"id"]];
                        if([globals.WHICH_SPORT isEqual:@"football"]){
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateFBBottomViewControInfo" object:nil];
                        }
                    }
                    if ([globals.TOAST_QUEUE count]<=10){
                        [globals.TOAST_QUEUE addObject:syncEvent];
                    }
                } else if([self extractIntFromStr:[syncEvent objectForKey:@"type"]] == 15){
                    globals.CURRENT_ZONE = [syncEvent objectForKey:@"id"];
                    if ([globals.TOAST_QUEUE count]<=10){
                        [globals.TOAST_QUEUE addObject:syncEvent];
                    }
                }
                
                //update strength
                if ([self extractIntFromStr:[syncEvent objectForKey:@"type"]]==9 && [globals.WHICH_SPORT isEqual:@"hockey"]) {
                    globals.CURRENT_STRENGTH = [syncEvent objectForKey:@"id"];
                    //NSLog(@"sync me callback globals.CURRENT_STRENGTH: %@",globals.CURRENT_STRENGTH);
                    if ([globals.TOAST_QUEUE count]<=10){
                        [globals.TOAST_QUEUE addObject:syncEvent];
                    }
                }
                
            }
            
            [[NSNotificationCenter defaultCenter ]postNotificationName:@"RestartUpdate" object:nil];

        }
        //populate tag markers when openning the app (if we already has tags saved in the Thumbnails.plist file)
        
    }
    
    //NSLog(@"globals.DURATION_TAGS_TIME: %@, globals.DURATION_TYPE_TIMES: %@",globals.DURATION_TAGS_TIME,globals.DURATION_TYPE_TIMES);
}

- (NSString *)stringToSha1:(NSString *)hashkey{
    
    // Using UTF8Encoding
    const char *s = [hashkey cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [NSData dataWithBytes:s length:strlen(s)];
    
    // This is the destination
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
    // This one function does an unkeyed SHA1 hash of your hash data
    CC_SHA1(keyData.bytes, keyData.length, digest);
    
    // Now convert to NSData structure to make it usable again
    NSData *out = [NSData dataWithBytes:digest
                                 length:CC_SHA1_DIGEST_LENGTH];
    // description converts to hex but puts <> around it and spaces every 4bytes
    NSString *hash = [out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    // hash is now a string with just the 40char hash value in it
    
    return hash;
}


//send authorization information to "sync" URL
-(void)sync2Cloud{
    
    return;
//    if (!appQueue) {
//        appQueue = [[AppQueue alloc] init];
//    }
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
        //create a dictionary of account information
    NSMutableDictionary *pAccountInformation = globals.ACCOUNT_INFO;
    if(!globals.ACCOUNT_INFO)
    {
        return;
    }
    emailAddress = [self stringToSha1:[pAccountInformation objectForKey:@"emailAddress"] ];
    password = [pAccountInformation objectForKey:@"password"];
    deviceAuthorization = [pAccountInformation objectForKey:@"authorization"];
    deviceCustomer = [pAccountInformation objectForKey:@"customer"];
    
    globals.TAG_BTNS_REQ_SENT=TRUE;
    
    if ([fileManager fileExistsAtPath: globals.ACCOUNT_PLIST_PATH] && emailAddress && password && deviceAuthorization && deviceCustomer){
        
        NSString *randomWord = @"testingSecondURL";
        NSString *p2Data = [NSString stringWithFormat:@"&v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",deviceAuthorization,emailAddress,password,randomWord,deviceCustomer];
       // ////// 
        NSData *postData = [p2Data dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postDataLength = [NSString stringWithFormat:@"%d",[postData length]];
        syncRequest = [[NSMutableURLRequest alloc]init];
        [syncRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/sync/ajax"]]];
        [syncRequest setHTTPMethod:@"POST"];
        [syncRequest setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
        [syncRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
        [syncRequest setHTTPBody:postData];
        
        NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(sync2CloudCallback:)],self, nil];
        NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
        NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [globals.APP_QUEUE enqueue:syncRequest dict:instObj];
        
        randomWord = @"testingSecondURL";
        p2Data = [NSString stringWithFormat:@"&v0=%@&v1=%@&v2=%@&v3=%@&v4=%@",deviceAuthorization,emailAddress,password,randomWord,deviceCustomer];
        postData = [p2Data dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        postDataLength = [NSString stringWithFormat:@"%d",[postData length]];
        syncRequest = [[NSMutableURLRequest alloc]init];
        [syncRequest setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://myplayxplay.net/max/requesttagnames/ajax"]]];
        [syncRequest setHTTPMethod:@"POST"];
        [syncRequest setValue:postDataLength forHTTPHeaderField:@"Content-Length"];
        [syncRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current=Type"];
        [syncRequest setHTTPBody:postData];
        
        objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(requestTagNamesCallback:)],self, nil];
        keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
        instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [globals.APP_QUEUE enqueue:syncRequest dict:instObj];
    }
    
}

//get response from "sync2cloud" URL, get all data: tagnames,events,..etc.
-(void)sync2CloudCallback:(id)json{
    NSDictionary *jsonDictionary= json;
    if([json objectForKey:@"tagnames"])
    {
        globals.DID_RECV_TAG_NAMES=TRUE;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *users = [jsonDictionary objectForKey:@"users"];
    if (users != nil) {
        NSString *hid;
        NSString *tagColour;
        NSString *deleted;
        for(NSDictionary *oneUser in users){
            hid = [oneUser objectForKey:@"hid"];
            tagColour = [oneUser objectForKey:@"tagColour"];
            deleted = [oneUser objectForKey:@"deleted"];
            emailAddress = [oneUser objectForKey:@"email"];
            password = [oneUser objectForKey:@"password"];
        }
      //  ////// 
        if([deleted isKindOfClass:[NSString class]] && [[jsonDictionary objectForKey:@"deleted"] isEqualToString:@"1"]){
            [fileManager removeItemAtPath:globals.ACCOUNT_PLIST_PATH error:NULL];
        }else{
            [fileManager removeItemAtPath:globals.ACCOUNT_PLIST_PATH error:NULL];
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

            [data setObject:[NSString stringWithString:hid] forKey:@"hid"];
            
            if([[globals.ACCOUNT_INFO objectForKey:@"hid"] isEqual:hid] && globals.IS_EULA ){
                [data setObject:@"1" forKey:@"eula"];
            }
            
            [data setObject:[NSString stringWithString:tagColour] forKey:@"tagColour"];
            //[globals.ACCOUNT_INFO setObject:[NSString stringWithString:tagColour] forKey:@"tagColour"];
           
            [data setValue:emailAddress forKey:@"emailAddress"];
          
            [data setValue:password forKey:@"password"];
           
            [data setObject:[NSString stringWithString:deviceAuthorization] forKey:@"authorization"];
          
            [data setObject:[NSString stringWithString:deviceCustomer] forKey:@"customer"];
            [data writeToFile: globals.ACCOUNT_PLIST_PATH atomically:YES];
            
            globals.ACCOUNT_INFO = [data copy];

        }
    }
    

    NSArray  *tagNames = [jsonDictionary objectForKey:@"tagnames"];
    NSString *tagButtonsPath = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"TagButtons.plist"];

    fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: tagButtonsPath])
    {
//        tagButtonsPath = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent: [NSString stringWithFormat: @"TagButtons.plist"]];
    }
    
    NSMutableArray *plistData;
    //if tagnames were recieved - user updated his tags in the cloud
    if (tagNames) {
        //replace old tags with the received ones
        [fileManager removeItemAtPath:tagButtonsPath error:NULL];
        plistData = [[NSMutableArray alloc] init];
        for(NSDictionary *tNames in tagNames){
            NSString *name = [tNames objectForKey:@"name"];
            NSString *position = [tNames objectForKey:@"position"];
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
            
            [data setObject:[NSString stringWithString:name] forKey:@"name"];
            [data setObject:[NSString stringWithString:position] forKey:@"side"];
            
            [plistData addObject:data];
           
        }
         [plistData writeToFile: tagButtonsPath atomically:YES];
    
      
    }else{
        //if([fileManager fileExistsAtPath:tagButtonsPath])
        //plistData = [[NSMutableArray alloc]initWithContentsOfFile:tagButtonsPath];
                 //initialise dictionary
    }
    
    
        //initialise dictionary
    
    eventsArray = [jsonDictionary objectForKey:@"events"];
    //globals.EVENTS_ON_SERVER = [eventsArray copy];
    if (!eventsArray){
        return;
    } else {
       
        [self writingEventsArrayToPlistFile:eventsArray];
    }

    globals.DID_RECV_NEW_CAL_EVENTS=TRUE;
    
    //Called once on startup to sync all offline tags with server
    [self setAllGameTags];
   
}

- (void)requestTagNamesCallback:(id)json
{
    NSDictionary *jsonDict = json;
    if ([jsonDict objectForKey:@"tagbuttons"]) {
        NSString *tagButtonsPath = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"TagButtons.plist"];
        NSMutableArray *tagButtons = [[NSMutableArray alloc] init];
        NSDictionary *replacedDict = [self replaceNullEntriesInDictionary:[jsonDict objectForKey:@"tagbuttons"]];
        for (NSString *key in [replacedDict allKeys]) {
            NSDictionary *dict = [replacedDict objectForKey:key];
            NSDictionary *tag = [NSDictionary dictionaryWithObjects:@[key,[dict objectForKey:@"side"],[dict objectForKey:@"subtags"],[dict objectForKey:@"order"]] forKeys:@[@"name",@"side",@"subtags",@"order"]];
            [tagButtons addObject:tag];
        }
        NSMutableArray *orderedTagButtons = [[tagButtons sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([[obj1 objectForKey:@"side"] isEqualToString:[obj2 objectForKey:@"side"]]) {
                int *order1 = [[obj1 objectForKey:@"order"] intValue];
                int *order2 = [[obj2 objectForKey:@"order"] intValue];
                if (order1 > order2) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            } else {
                if ([[obj1 objectForKey:@"side"] isEqualToString:@"left"]) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }
            
        }] mutableCopy];
        BOOL success = [orderedTagButtons writeToFile:tagButtonsPath atomically:NO];
        NSLog(@"tagButtons.plist written %@successfully",success?@"":@"un");
    }
}

- (NSDictionary*)replaceNullEntriesInDictionary:(NSDictionary*)dict
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    for (NSString *key in dict) {
        if (![dict objectForKey:key]) {
            [newDict setObject:@"" forKey:key];
        } else if ([[dict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
            [newDict setObject:[self replaceNullEntriesInDictionary:[dict objectForKey:key]] forKey:key];
        } else if ([[dict objectForKey:key] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrayOfDict = [[dict objectForKey:key] mutableCopy];
            if (arrayOfDict.count > 0) {
                for (int i = 0; i < arrayOfDict.count; i++) {
                    if ([arrayOfDict[i] isEqual:[NSNull null]]) {
                        [arrayOfDict removeObjectAtIndex:i];
                    }
                }
            }
            [newDict setObject:arrayOfDict forKey:key];
        }
    }
    return newDict;
}

//update events info of current encoder and the events array will be used to update the calendar too
-(void)writingEventsArrayToPlistFile:(NSArray*)eventsArray{
    
    //NSLog(@"################################### eventsArray from server  %@",eventsArray);
    //go through all the new events received from the server, if the event has video id, save it in the local plist file
    if(![eventsArray isKindOfClass:[NSDictionary class]])
    {
        //the local path for plist file which saved all the events
        NSString *plistPath = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent:@"EventsHid.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
       
        NSMutableArray *eventsData;
        if ([fileManager fileExistsAtPath: plistPath])
        {
            //if the EventsHid.plist file exists, initializes the eventsData array with the plist file content
            eventsData = [[NSMutableArray alloc] initWithContentsOfFile: plistPath];
        }else{
             //if the EventsHid.plist file not exist, create a new one
            plistPath = [globals.LOCAL_DOCS_PATH stringByAppendingPathComponent: [NSString stringWithFormat: @"EventsHid.plist"] ];
            eventsData = [[NSMutableArray alloc] init];
        }
        
        NSMutableArray *eventsDataCopy = [eventsData mutableCopy];
        //go through all events in old plist file, if the event was not downloaded, delete it
        for(NSDictionary *event in eventsDataCopy){
            if (![[NSFileManager defaultManager]fileExistsAtPath:[[globals.EVENTS_PATH stringByAppendingPathComponent:[event objectForKey:@"name"]] stringByAppendingPathComponent:@"videos/main.mp4"]]) {
                [eventsData removeObject:event];
            }
        }
        NSString *eventHid;
        NSString *vid;
        NSString *oldHid;
       
        for(NSDictionary *event in eventsArray){
             //check event's vid : 1. get rid of events like: "camera = live/camera = off" which will make the app crash when go to calendar view or my clip view
            // 2. if there is no video id for the event, don't show it in the calendar
            if ([event objectForKey:@"vid"] || [event objectForKey:@"mp4"]) {
                eventHid = [event objectForKey:@"hid"];
                if ([event objectForKey:@"vid"]) {
                    vid = [event objectForKey:@"vid"];
                    [globals.ALL_EVENTS_DICT setObject:event forKey:vid];
                }else if([event objectForKey:@"mp4"]){
                    vid = [event objectForKey:@"mp4"];
                    [globals.ALL_EVENTS_DICT setObject:event forKey:vid];
                }
                
                NSUInteger index = -1;
                for (NSDictionary *oldEvent in eventsData) {
                    oldHid = [oldEvent objectForKey:@"hid"];
                    if ([oldHid isEqualToString:eventHid]) {
                        index = [eventsData indexOfObject:oldEvent];
                    }
                }
                //the current events is already saved in the old event plist file
                if(index != -1){
                    //at this point, all the events saved in eventsData have already downloaded
                    //1. if the event is not deleted from the current encode, delete from eventsData to prevent duplicated event.
                    //Because all the undeleted new events will be added to the eventsData array
                    //2. if the event is deleted from the current encoder,don't remove it from eventsData array.
                    //Because it has been downloaded and deleted new event won't be added to the eventsData array
                    if ([[event objectForKey:@"deleted"]integerValue]!=1) {
                        [eventsData removeObjectAtIndex:index];
                    }
                }
                //if the event is not deleted([event objectForKey:@"deleted"] is equals to 0), added it to the eventsData array
                if ([[event objectForKey:@"deleted"]integerValue]!=1) {
                    [eventsData addObject:event];
                }

            }
        }
        //NSLog(@"###############################################eventsData new events information : %@",eventsData);
        //if writeToFile not success, please check if there is any null value in eventsData
        BOOL didWrite = [eventsData writeToFile: plistPath atomically:YES];
        NSMutableArray *copyData = [[NSMutableArray alloc] init];
        if (!didWrite) {
            for (int i = 0; i<[eventsData count]; i++) {
                NSMutableDictionary *event = [[eventsData objectAtIndex:i] mutableCopy];
                for (NSString *key in [event allKeys]){
                    if (![event objectForKey:key] || [event objectForKey:key] == [NSNull null]){
                        [event setObject:@"" forKey:key];
                    }
                }
                [copyData addObject:event];
            }
            didWrite = [copyData writeToFile: plistPath atomically:YES];
            if (didWrite) {
                NSLog(@"Replaced some null occurances while writing eventsHid.plist");
            } else {
                NSLog(@"Failed to write to eventsHid.plist");
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"oldEventsUpdated" object:nil];
        
        //get all the events from the current encoder
        globals.EVENTS_ON_SERVER = [globals.ALL_EVENTS_DICT allValues];
        
         [[NSNotificationCenter defaultCenter] postNotificationName:@"sync2CloudCallback" object:self];
    }else{
        return;
    }
    
    
}


//get the local new events which may not in the cloud
-(void)getLocalEvents{
//    if (!appQueue) {
//         appQueue = [[AppQueue alloc] init];
//    }
    //current absolute time in seconds
    double currentSystemTime = CACurrentMediaTime();
    NSDictionary *jsonDict = [[NSDictionary alloc]initWithObjectsAndKeys:[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[globals.ACCOUNT_INFO objectForKey:@"authorization"],@"device",nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:0
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSString *url = [NSString stringWithFormat:@"%@/min/ajax/getpastevents/%@",globals.URL,jsonString];

    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:@selector(sync2CloudCallback:)],self,@"20", nil];
    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller",@"timeout", nil];
    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [globals.APP_QUEUE enqueue:url dict:instObj];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
   
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    errorCount = 0;
    ////////NSLog(@"did finish loading");
    //remove the finished request, send the next one
    [globals.ALL_LOCAL_TAGS_REQUEST_QUEUE removeObjectAtIndex:0];
    [self sendLocalTagRequest];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    errorCount++;
    if (errorCount < 2) {
        //resend the request if get error once
        [self sendLocalTagRequest];
        globals.NUMBER_OF_LOCAL_TAGS_UPDATED--;
    }else{
        //if get error twice, remove the current request, send the next one
        [globals.ALL_LOCAL_TAGS_REQUEST_QUEUE removeObjectAtIndex:0];
        [self sendLocalTagRequest];
        errorCount = 0;
    }
}

//check if internet available or not
-(BOOL)checkInternetConnection{
    
    SCNetworkReachabilityFlags flags;
    BOOL receivedFlags;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"www.google.com" UTF8String]);
    
    receivedFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    
    CFRelease(reachability);
    
    return  (!receivedFlags || flags == 0) ? FALSE : TRUE;
}


-(void)stopSyncMeTimer{
    [globals.SYNC_ME_TIMER invalidate];
    globals.SYNC_ME_TIMER = nil;
}
//start sync me timer
-(void)restartSyncMeTimer{
    [globals.SYNC_ME_TIMER invalidate];
    globals.SYNC_ME_TIMER=nil;
    globals.SYNC_ME_TIMER = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                         target:self
                                                       selector:@selector(syncMe)
                                                       userInfo:nil
                                                        repeats:YES];
    
}



-(void)startEncoderStatusTimer{
    
   
    if (globals.HAS_MIN) {
        [globals.ENCODER_STATUS_TIMER invalidate];
        globals.ENCODER_STATUS_TIMER = nil;
        globals.ENCODER_STATUS_TIMER = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(encoderStatus) userInfo:nil repeats:YES];
    }
    
//    if (globals.ALL_LOCAL_TAGS_REQUEST_QUEUE.count > 0 && !uploadLocalTagsTimer) {
//        uploadLocalTagsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(sendLocalTagRequest) userInfo:nil repeats:YES];
//    }

}
@end
