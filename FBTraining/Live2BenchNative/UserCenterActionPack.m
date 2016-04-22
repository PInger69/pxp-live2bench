//
//  UserCenterActionPack.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-21.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "UserCenterActionPack.h"



/**
 *  This checks to see if the user has logged in to the app before, by checking it there is a plist
 */
@implementation CheckLoginPlistAction
{
    UserCenter* userCenter;
}

@synthesize delegate = _delegate;

-(id)initWithCenter:(UserCenter*)aUserCenter
{
    self = [super init];
    if (self) {
        userCenter = aUserCenter;
    }
    return self;
}


-(void)start
{
    
    NSDictionary * userData;
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"tempData" ofType:@"plist"];
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: userCenter.accountInfoPath])
    {
        userData                    = [[NSMutableDictionary alloc] initWithContentsOfFile: userCenter.accountInfoPath];
        userCenter.isEULA           = [[userData objectForKey:@"eula"]intValue]==1;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_INFO_RETRIEVED object:userData];

        self.isSuccess = YES;


        
    }
//    else if ([[NSFileManager defaultManager] fileExistsAtPath: plistPath]) {
//    
//        userData                    = [[NSMutableDictionary alloc] initWithContentsOfFile: plistPath];
//        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_INFO_RETRIEVED object:userData];
//                userCenter.accountInfoPath = plistPath;
//        
//        [UserCenter getInstance].customerID                 = @"Guest";//userData[@"customer"];
//        [UserCenter getInstance].customerEmail              = @"Guest";//userData[@"emailAddress"];
//        [UserCenter getInstance].customerAuthorization      = userData[@"authorization"];
//        [UserCenter getInstance].userHID                    = userData[@"hid"];
//        [UserCenter getInstance].tagNames                   = [@[] mutableCopy];
//        self.isSuccess = YES;
//    }
    else {
        
        
        self.isSuccess = NO;
    }
    
    self.isFinished = YES;
}

-(id <ActionListItem>)reset
{   _isSuccess  = NO;
    _isFinished = NO;
    return self;
}

@end
