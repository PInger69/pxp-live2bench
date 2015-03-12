//
//  UtilitiesController.h
//  Live2BenchNative
//
//  Created by dev on 13-02-04.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AppQueue.h"
#import "Live2BenchViewController.h"
//#import "Globals.h"
#import "sys/socket.h"
#import "netinet/in.h"
#import "SystemConfiguration/SystemConfiguration.h"
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "NSArray+BinarySearch.h"

//@class AppQueue;
@class Live2BenchViewController;

@interface UtilitiesController : NSObject{
//    Globals *globals;
    //AppQueue *appQueue;
    Live2BenchViewController *live2BenchViewController;
    NSString * responseMsg;
    int isSuccess;
    NSDictionary *userDictionary;
    int encoderStatusCounter;
    BOOL alertSent;
    BOOL isEventStopped;
    int downloadTagsLeft;
    NSOperationQueue *operationQueue;
    CustomAlertView *liveStreamEndedAlert;
}

//@property (nonatomic,strong) AppQueue *appQueue;
@property (nonatomic,strong) NSString *deviceAuthorization;
@property (nonatomic,strong) NSString *deviceCustomer;
@property (nonatomic,strong) NSString *emailAddress;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSMutableURLRequest *request;
@property (nonatomic,strong) NSMutableURLRequest *syncRequest;
@property (nonatomic,strong) NSMutableURLRequest *getLocalEventRequest;
@property (nonatomic,strong) NSURLConnection *conn;
@property (nonatomic,strong) Live2BenchViewController *live2BenchViewController;
@property (nonatomic) BOOL isEventStopped;
@property (nonatomic,strong) CustomAlertView *encoderStatusAlert;
@property (nonatomic,strong) CustomAlertView *liveStreamEndedAlert;
@property (nonatomic)BOOL didResendGetAllTeamsRequest;
@property (nonatomic)BOOL didResendGetAllTagsRequest;
@property (nonatomic,strong)NSTimer *uploadLocalTagsTimer;
@property (nonatomic)int errorCount;
@property (nonatomic,strong)UIPopoverController *chooseTeamPlayerPopup; //pop up for the user the choose which team players he/she wants to tag
@property (nonatomic)int encoderStatusCount;
@property (nonatomic,strong)CustomAlertView *previousAlertView;

-(int) extractIntFromStr:(NSString*) originalString;
-(void) writeTagsToPlist;
-(void) setAllGameTags;
-(void)getAllTeams;
-(void)showSpinner;
-(NSString *)getIPAddress;
-(void)getAllGameTags;
-(id)init;
-(BOOL)hasConnectivity;
-(int)getSuccess;
-(void)syncMeCallBack:(id)jsonArray;
//-(void)syncMe:(NSTimer *)timer;
-(UIColor*)colorWithHexString:(NSString*)hex;

-(void)sync2Cloud;
-(void)sync2CloudCallback:(id)json;
- (NSString*)getResponse;
-(void)getLocalEvents;
-(void)stopSyncMeTimer;
-(void)restartSyncMeTimer;
-(void)startEncoderStatusTimer;
-(BOOL)checkInternetConnection;
@end
