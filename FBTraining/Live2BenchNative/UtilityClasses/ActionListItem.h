//
//  ActionListItem.h
//  Live2BenchNative
//
//  Created by dev on 2015-06-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ActionListItemDelegate.h"
@class ActionList;

/**
 * This is the object that you add to the object list
 */
@protocol ActionListItem <NSObject>

@required

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

@property (nonatomic,weak)  id <ActionListItemDelegate>  delegate;

/**
 *  The will get runned as soon as it is the current item in the action list
 */
-(void)start;

@optional

@property (nonatomic,weak)  ActionList      * listItemOwner;

/**
 *  should toggle isFinished and success
 *
 *  @return
 */
-(id <ActionListItem>)reset;

@end




