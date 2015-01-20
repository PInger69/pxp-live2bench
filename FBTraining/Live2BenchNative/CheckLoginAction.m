//
//  CheckLoginAction.m
//  Live2BenchNative
//
//  Created by dev on 2015-01-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "CheckLoginAction.h"
#import "UserCenter.h"
#import "ActionList.h"



@implementation CheckLoginAction
{
    UserCenter* userCenter;
}
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


@end
