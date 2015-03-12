//
//  UserCenter.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//




// This class is the center point for all user data such as the tag names and other user data
// all plists will be loaded to this class if it should be accsessed
// it will manage making, updating and retreving pl data
#import "UserCenter.h"
#import "ActionList.h"
#import "UserCenterActionPack.h" // This has all the user Actions
#import "CloudEncoder.h"// to get defins


#define PLIST_THUMBNAILS        @"Thumbnails.plist"
#define PLIST_PLAYER_SETUP      @"players-setup.plist"
#define PLIST_EVENT_HID         @"EventsHid.plist"
#define PLIST_ACCOUNT_INFO      @"accountInformation.plist"



@implementation UserCenter
{

    NSFileManager   * fileManager;
    id              tagNameObserver;
    BOOL            observering;
    
    NSDictionary    * rawResponce;
    
    
    NSArray * eventHIDs;
    
    
    
    
    CheckLoginPlistAction     * _checkLoginPlistAction;
}

@synthesize tagNames                = _tagNames;
@synthesize userPick                = _userPick;
@synthesize currentEventThumbnails  = _currentEventThumbnails;
@synthesize isLoggedIn              = _isLoggedIn;
@synthesize isEULA                  = _isEULA;

@synthesize accountInfoPath         = _accountInfoPath;
@synthesize customerColor           = _customerColor;
// about the userData

@synthesize customerID              = _customerID;
@synthesize customerAuthorization   = _customerAuthorization;
@synthesize customerEmail           = _customerEmail;
@synthesize userHID             = _userHID;
@synthesize localPath               = _localPath;


-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath
{
    self = [super init];
    if (self) {
        // paths
        _localPath       = aLocalDocsPath;
        _accountInfoPath = [_localPath stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
        _isEULA         = NO;
        observering     = NO;
        fileManager     = [NSFileManager defaultManager];
        
        
        
        if ([fileManager fileExistsAtPath: _accountInfoPath])
        {
            rawResponce     = [[NSMutableDictionary alloc] initWithContentsOfFile: _accountInfoPath];
            [self updateCustomerInfoWith:rawResponce];
            _tagNames       = [self convertToL2BReadable: rawResponce key:@"tagnames"];
        }
        
        eventHIDs = [[NSArray alloc]initWithContentsOfFile:[_localPath stringByAppendingPathComponent:PLIST_EVENT_HID]];
        
        
        // notifications will mostly be coming from the cloud Encoder
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(update:)                   name:NOTIF_USER_CENTER_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkCredentials:)         name:NOTIF_CREDENTIALS_TO_VERIFY object:nil]; // listen to the app for check
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cloudCredentialsResponce:) name:NOTIF_CLOUD_VERIFY_RESULTS object:nil]; // listen to the Cloud for check
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dataRequest:)              name:NOTIF_USER_CENTER_DATA_REQUEST object:nil]; // listen to the Cloud for check
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logoutUser:)               name:NOTIF_USER_LOGGED_OUT object:nil]; // listen to the Cloud for check
        
        _checkLoginPlistAction     = [[CheckLoginPlistAction alloc]initWithCenter:self];
        
    }
    return self;
}



#pragma mark -
#pragma mark Observer Methods




// a logged out user get their plist deleted
-(void)logoutUser:(NSNotification *)note
{
    if ([[note.userInfo objectForKey:@"success"]boolValue]){
        NSString *filePath = _accountInfoPath;
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }

}



/**
 *  Passing the Request from the app to the Cloud Encoder
 *
 *  @param note NSNotification
 */
-(void)dataRequest:(NSNotification*)note
{

    NSString * requestType = note.userInfo[@"type"];
    
    if ([requestType isEqualToString:UC_REQUEST_EVENT_HIDS]) {
        void (^passingDataBack)(NSArray*) = [note.userInfo objectForKey:@"block"];
        passingDataBack(eventHIDs);
    } else if ([requestType isEqualToString:UC_REQUEST_USER_INFO]){
        void (^passingDataBack)(NSDictionary*) = [note.userInfo objectForKey:@"block"];
        passingDataBack(rawResponce);
    }
}


/**
 *  Passing the Request from the app to the Cloud Encoder
 *
 *  @param note NSNotification
 */
-(void)checkCredentials:(NSNotification*)note
{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOUD_VERIFY object:self userInfo:note.userInfo];
}

/**
 *  this recieved data from the Cloud Encoder about the users Credentials
 *
 *  @param note NSNotification
 */
-(void)cloudCredentialsResponce:(NSNotification*)note
{
    rawResponce = note.userInfo;
    
    if ([[rawResponce objectForKey:@"success"]boolValue]) {
        [self updateCustomerInfoWith:rawResponce];
    }
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CREDENTIALS_VERIFY_RESULT object:self userInfo:note.userInfo];
    

}



-(void)updateCustomerInfoWith:(NSDictionary *)dataDict
{
    _customerID             = [dataDict objectForKey:@"customer"];
    _customerEmail          = [dataDict objectForKey:@"emailAddress"];
    _userHID                = [dataDict objectForKey:@"hid"];
    _customerColor          = [Utility colorWithHexString:[dataDict objectForKey:@"tagColour"]];
    _customerAuthorization  = [dataDict objectForKey:@"authorization"];

}



// This updates this class based of the keys in the userdict
-(void)update:(NSNotification*)note
{
    NSDictionary * data = note.userInfo;

    if ([data objectForKey:@"userPick"]) self.userPick = [data objectForKey:@"userPick"];
}


-(void)enableObservers:(BOOL)isObserve
{
    if (observering && !isObserve){
        [[NSNotificationCenter defaultCenter]removeObserver:tagNameObserver];
    } else if (!observering && isObserve) {
        NSLog(@"UserCenter see data from Cloud Encoder");
        tagNameObserver     =    [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_TAG_NAMES_FROM_CLOUD object:nil queue:nil usingBlock:^(NSNotification *note) {
        
       NSMutableDictionary         * tgnames = [note.userInfo mutableCopy];
           
        // this is clearing out all the illigal NULL in the dict, so the plist can be written
        NSMutableDictionary         * onlyTags = [[tgnames objectForKey:@"tagbuttons"]mutableCopy];
        [tgnames setObject:onlyTags forKey:@"tagbuttons"];
            
        for (NSString * theKey in [onlyTags allKeys]) {
            NSMutableDictionary * checkedTag =  [[onlyTags objectForKey:theKey]mutableCopy];
            [onlyTags setObject:checkedTag forKey:theKey];
            [checkedTag removeObjectForKey:@"subtags"];
//            if ([checkedTag objectForKey:@"subtags"]) {
//                NSMutableArray * listSubtags = [checkedTag objectForKey:@"subtags"];
//                for (int i=0; i<[listSubtags count]; i++) {
//                    NSLog(@"");
//                    if ([listSubtags objectAtIndex:i] == [NSNull null]  ){
//                        [listSubtags replaceObjectAtIndex:i withObject:@""];
//                    }
//                }
//            }
        }
            
        // get user info plist
        NSString                * plistPath   = [_localPath stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
        NSMutableDictionary     * userInfo    = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        if (tgnames){// no respoince from cloud
            
            // convert new tags for Live to bench
            _tagNames = [self convertToL2BReadable: tgnames key:@"tagbuttons"];
            
      
            // delete old tags if there
            if ([userInfo objectForKey:@"tagnames"]){
                [userInfo removeObjectForKey:@"tagnames"];
            }
            
            // write new tags
            [userInfo setObject:[tgnames objectForKey:@"tagbuttons"] forKey:@"tagnames"];
            
//             save data
            if ([[userInfo copy] writeToFile:plistPath atomically: YES]) {
                NSLog(@"WRITE");
            } else {
                NSLog(@"Fail");
            }

        } else {
            
            _tagNames =[self convertToL2BReadable: rawResponce key:@"tagnames"];
//                _tagNames = [self _buildTagNames:localPath];
        }
        }];
    }
    observering = isObserve;
}


/**
 *  This converts the tag data in to a format that is comsumable to the Live2Bench
 *
 *  @param aLocalPath <#aLocalPath description#>
 *
 *  @return <#return value description#>
 */
-(NSMutableArray*)_buildTagNames:(NSString*)aLocalPath
{

    
    
    
    
    NSString        * tagFilePath   = [aLocalPath stringByAppendingPathComponent:PLIST_ACCOUNT_INFO];
    NSDictionary    * userInfo      =  [[NSDictionary alloc] initWithContentsOfFile:tagFilePath];
    NSDictionary    * tagnames      = [userInfo objectForKey:@"tagnames"];
    return  tagnames;
}


-(NSMutableArray*)convertToL2BReadable:(NSDictionary *)toConvert key:(NSString*)key
{
    NSDictionary * buttons      = [toConvert objectForKey:key];

    NSMutableArray * tempLeft   = [[NSMutableArray alloc]init];
    NSMutableArray * tempRigh   = [[NSMutableArray alloc]init];
    
    if  ([buttons isKindOfClass:[NSArray class]]){
    
        NSArray * items2 = [toConvert objectForKey:key] ;
        
        
        for (int i=0; i<[items2 count]; i++) {
            NSDictionary  * tbtn = items2[i];
            NSString * side = [tbtn objectForKey:@"position"];
            if ([side isEqualToString:@"left"]) {
                
                [tempLeft addObject:@{@"name":items2[i][@"name"], @"position":side, @"order": [NSNumber numberWithInt:i]}];
            } else {
                [tempRigh addObject:@{@"name":items2[i][@"name"], @"position":side, @"order": [NSNumber numberWithInt:i]}];
            }
        }
        
//        
//        for (NSString * i in items){
//            NSDictionary  * tbtn = [buttons objectForKey:i];
//            NSString * side = [tbtn objectForKey:@"side"];
//            if ([side isEqualToString:@"left"]) {
//                [tempLeft addObject:@{@"name":i, @"position":side, @"order": [tbtn objectForKey:@"order"]}];
//            } else {
//                [tempRigh addObject:@{@"name":i, @"position":side, @"order": [tbtn objectForKey:@"order"]}];
//            }
//        }
        
        
    } else {
        NSArray * items = [buttons allKeys];
        
        for (NSString * i in items){
            NSDictionary  * tbtn = [buttons objectForKey:i];
            NSString * side = [tbtn objectForKey:@"side"];
            if ([side isEqualToString:@"left"]) {
                [tempLeft addObject:@{@"name":i, @"position":side, @"order": [tbtn objectForKey:@"order"]}];
            } else {
                [tempRigh addObject:@{@"name":i, @"position":side, @"order": [tbtn objectForKey:@"order"]}];
            }
        }
    }
    
    

    
   NSMutableArray * temp = [[NSMutableArray alloc]init];
    [temp addObjectsFromArray:tempLeft];
    [temp addObjectsFromArray:tempRigh];
    return temp;
}


-(void)writeAccountInfoToPlist
{
    [rawResponce writeToFile: _accountInfoPath atomically:YES];
}

-(id<ActionListItem>)checkLoginPlistAction
{
    return [_checkLoginPlistAction reset];
}


// Write plists


//update events info of current encoder and the events array will be used to update the calendar too
-(void)writingEventsArrayToPlistFile:(NSArray*)eventsArray{
    
//    //NSLog(@"################################### eventsArray from server  %@",eventsArray);
//    //go through all the new events received from the server, if the event has video id, save it in the local plist file
//    if(![eventsArray isKindOfClass:[NSDictionary class]])
//    {
//        //the local path for plist file which saved all the events
//        NSString *plistPath = [localPath stringByAppendingPathComponent:PLIST_EVENT_HID];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//        NSMutableArray *eventsData;
//        if ([fileManager fileExistsAtPath: plistPath])
//        {
//            //if the EventsHid.plist file exists, initializes the eventsData array with the plist file content
//            eventsData = [[NSMutableArray alloc] initWithContentsOfFile: plistPath];
//        }else{
//            //if the EventsHid.plist file not exist, create a new one
//            plistPath = [localPath stringByAppendingPathComponent: [NSString stringWithFormat: PLIST_EVENT_HID] ];
//            eventsData = [[NSMutableArray alloc] init];
//        }
//        
//        NSMutableArray *eventsDataCopy = [eventsData mutableCopy];
//        //go through all events in old plist file, if the event was not downloaded, delete it
//        for(NSDictionary *event in eventsDataCopy){
//            if (![[NSFileManager defaultManager]fileExistsAtPath:[[globals.EVENTS_PATH stringByAppendingPathComponent:[event objectForKey:@"name"]] stringByAppendingPathComponent:@"videos/main.mp4"]]) {
//                [eventsData removeObject:event];
//            }
//        }
//        NSString *eventHid;
//        NSString *vid;
//        NSString *oldHid;
//        
//        for(NSDictionary *event in eventsArray){
//            //check event's vid : 1. get rid of events like: "camera = live/camera = off" which will make the app crash when go to calendar view or my clip view
//            // 2. if there is no video id for the event, don't show it in the calendar
//            if ([event objectForKey:@"vid"] || [event objectForKey:@"mp4"]) {
//                eventHid = [event objectForKey:@"hid"];
//                if ([event objectForKey:@"vid"]) {
//                    vid = [event objectForKey:@"vid"];
//                    [globals.ALL_EVENTS_DICT setObject:event forKey:vid];
//                }else if([event objectForKey:@"mp4"]){
//                    vid = [event objectForKey:@"mp4"];
//                    [globals.ALL_EVENTS_DICT setObject:event forKey:vid];
//                }
//                
//                NSUInteger index = -1;
//                for (NSDictionary *oldEvent in eventsData) {
//                    oldHid = [oldEvent objectForKey:@"hid"];
//                    if ([oldHid isEqualToString:eventHid]) {
//                        index = [eventsData indexOfObject:oldEvent];
//                    }
//                }
//                //the current events is already saved in the old event plist file
//                if(index != -1){
//                    //at this point, all the events saved in eventsData have already downloaded
//                    //1. if the event is not deleted from the current encode, delete from eventsData to prevent duplicated event.
//                    //Because all the undeleted new events will be added to the eventsData array
//                    //2. if the event is deleted from the current encoder,don't remove it from eventsData array.
//                    //Because it has been downloaded and deleted new event won't be added to the eventsData array
//                    if ([[event objectForKey:@"deleted"]integerValue]!=1) {
//                        [eventsData removeObjectAtIndex:index];
//                    }
//                }
//                //if the event is not deleted([event objectForKey:@"deleted"] is equals to 0), added it to the eventsData array
//                if ([[event objectForKey:@"deleted"]integerValue]!=1) {
//                    [eventsData addObject:event];
//                }
//                
//            }
//        }
//        //NSLog(@"###############################################eventsData new events information : %@",eventsData);
//        //if writeToFile not success, please check if there is any null value in eventsData
//        [eventsData writeToFile: plistPath atomically:YES];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"oldEventsUpdated" object:nil];
//        
//        //get all the events from the current encoder
//        globals.EVENTS_ON_SERVER = [globals.ALL_EVENTS_DICT allValues];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"sync2CloudCallback" object:self];
//    }else{
//        return;
//    }
    
    
}




@end
