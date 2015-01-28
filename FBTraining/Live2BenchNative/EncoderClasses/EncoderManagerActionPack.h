//
//  EncoderManagerActionPack.h
//  Live2BenchNative
//
//  Created by dev on 2015-01-21.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionList.h"
#import "EncoderManager.h"


@interface CheckWiFiAction : NSObject <ActionListItem>

-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager;
@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
-(void)start;

@end

@interface CheckForACloudAction : NSObject <ActionListItem>

@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;
-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager;
-(void)start;

@end

@interface CheckMasterEncoderAction : NSObject <ActionListItem>

-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager;

/**
 *  This property is observeded by the action list once Changed to YES it will move to the next action
 *  if one is found.
 *
 *  Once added to the ActionList it will be changed to NO
 */
@property (nonatomic,assign) BOOL isFinished;

/**
 *  This is if you want to send a success or not with the onFinish block if added to the list
 */
@property (nonatomic,assign) BOOL isSuccess;


/**
 *  The will get runned as soon as it is the current item in the action list
 */
-(void)start;
@end

@interface LogoutAction : NSObject <ActionListItem>

-(id)initWithEncoderManager:(EncoderManager*)aEncoderManager;

/**
 *  This property is observeded by the action list once Changed to YES it will move to the next action
 *  if one is found.
 *
 *  Once added to the ActionList it will be changed to NO
 */
@property (nonatomic,assign) BOOL isFinished;

/**
 *  This is if you want to send a success or not with the onFinish block if added to the list
 */
@property (nonatomic,assign) BOOL isSuccess;


/**
 *  The will get runned as soon as it is the current item in the action list
 */
-(void)start;
@end

@interface CloudTagNamesToUserCenter : NSObject <ActionListItem>

@property (nonatomic,assign) BOOL isFinished;
@property (nonatomic,assign) BOOL isSuccess;

-(void)start;
-(id <ActionListItem>)reset;
@end
