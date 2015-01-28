//
//  UserCenterActionPack.h
//  Live2BenchNative
//
//  Created by dev on 2015-01-21.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCenter.h"
#import "ActionList.h"

@interface CheckLoginPlistAction : NSObject  <ActionListItem>
@property (nonatomic,assign) BOOL isSuccess;
@property (nonatomic,assign) BOOL isFinished;

-(id)initWithCenter:(UserCenter*)aUserCenter;
-(void)start;

@end
