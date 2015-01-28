//
//  AppDelegateActionPack.h
//  Live2BenchNative
//
//  Created by dev on 2015-01-23.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "ActionList.h"

@interface RequestUserInfoAction : NSObject <ActionListItem>

@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;

-(instancetype)initWithAppDelegate:(AppDelegate*)appDel;
-(void)start;

@end

@interface RequestEulaAction : NSObject <ActionListItem>

@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
-(instancetype)initWithAppDelegate:(AppDelegate*)appDel;
-(void)start;

@end


