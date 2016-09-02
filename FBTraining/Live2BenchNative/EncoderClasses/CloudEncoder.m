//
//  CloudEncoder.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "CloudEncoder.h"
#import "EncoderTask.h"
//#import <objc/runtime.h>
#import "Utility.h"
#import "EncoderManager.h"

#define GET_NOW_TIME [ NSNumber numberWithDouble:CACurrentMediaTime()]





@interface CloudEncoder ()




@end

@implementation CloudEncoder
{


}

@synthesize loggedIn = _loggedIn;



- (instancetype)init
{
    self = [super init];
    if (self) {
        _loggedIn = NO;

    }
    return self;
}





-(void)startObserving
{
    //self.name = @"Cloud Encoder";
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(verifyUser:) name:NOTIF_CLOUD_VERIFY object:nil];// UserCenter is what is dispatching

}

/**
 *  Asked to check user info
 *
 *  @param note
 */
-(void)verifyUser:(NSNotification*)note
{

    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:note.userInfo];
    [self issueCommand:CE_VERIFY_GET priority:1 timeoutInSec:15 tagData:dict timeStamp:GET_NOW_TIME];
}

-(void)updateTagInfoFromCloud
{
    __block CloudEncoder * weakSelf = self;
   
   
    void (^onRecieveData)(NSDictionary*) = ^void(NSDictionary* theData){
        [weakSelf issueCommand:CE_TAG_NAMES_GET priority:99 timeoutInSec:15 tagData:[NSMutableDictionary dictionaryWithDictionary:theData] timeStamp:GET_NOW_TIME];
    };
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UC_REQUEST_USER_INFO object:self userInfo:@{@"block":onRecieveData}];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_CENTER_DATA_REQUEST object:self userInfo:@{@"type":UC_REQUEST_USER_INFO,@"block":onRecieveData}];
}

-(void)logoutOfCloud
{
    __block CloudEncoder * weakSelf = self;
    
    
    
    void (^onRecieveData)(NSDictionary*) = ^void(NSDictionary* theData){
        [weakSelf issueCommand:CE_LOGOUT priority:99 timeoutInSec:15 tagData:[NSMutableDictionary dictionaryWithDictionary:theData] timeStamp:GET_NOW_TIME];
    };
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_UC_REQUEST_USER_INFO object:self userInfo:@{@"block":onRecieveData}];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_CENTER_DATA_REQUEST object:self userInfo:@{@"type":UC_REQUEST_USER_INFO,@"block":onRecieveData}];

    
}




#pragma mark -
#pragma  mark Responces


-(void)tagNamesResponce:(NSData *)data
{

    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
    if ([jsonDict objectForKey:@"tagbuttons"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_TAG_NAMES_FROM_CLOUD object:self userInfo:jsonDict];
    }
    
}

-(void)verifyResponce:(NSData *)data
{
    
    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
     if ([[jsonDict objectForKey:@"success"]boolValue]) {
         self.loggedIn = YES;
     }
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_CLOUD_VERIFY_RESULTS object:self userInfo:jsonDict];
}


-(void)logoutResponce:(NSData *)data
{
    NSDictionary * jsonDict = [Utility JSONDatatoDict:data];
    if ([[jsonDict objectForKey:@"success"]boolValue]) {
        self.loggedIn = NO;
        
    }

    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_LOGGED_OUT object:self userInfo:jsonDict];

}



@end
