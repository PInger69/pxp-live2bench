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
    if ([[NSFileManager defaultManager] fileExistsAtPath: userCenter.accountInfoPath])
    {
        NSDictionary * userData     = [[NSMutableDictionary alloc] initWithContentsOfFile: userCenter.accountInfoPath];
        userCenter.isEULA           = [[userData objectForKey:@"eula"]intValue]==1;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_USER_INFO_RETRIEVED object:userData];
        
        self.isSuccess = YES;

        
    } else {
        
        
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
