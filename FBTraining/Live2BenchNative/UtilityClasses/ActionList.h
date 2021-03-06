//
//  ActionList.h
//  Live2BenchNative
//
//  Created by dev on 2015-01-16.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "ActionListItem.h"


@interface ActionList : NSObject

/**
 *  This will stop processing items in the list untill its set to NO
 *  Note: does not items currently being processed... they will finish
 */
@property (nonatomic,assign) BOOL paused;
@property (nonatomic,assign) BOOL running;

/**
 *  Runs the List
 */
-(void)start;

/**
 *  Clears list as well and completetion block
 */
-(void)clear;

/**
 *  Add Item to end of the list
 *
 *  @param item ActionItem
 */
-(void)addItem:(id<ActionListItem>)item;

/**
 *  Add item to the end of the list and will run a block when flag isFinished = YES
 *
 *  @param item     Action Item
 *  @param onFinish BOOL succsess is for you to guage if the action Item finished
 *                  correctly so you can modifiey in the block the ActionList
 */
-(void)addItem:(id<ActionListItem>)item onItemFinish:(void (^)(BOOL succsess))onFinish;


/**
 *   Add item to the end of the list, will run a block when flag isFinished = YES and
 *
 *  @param item     Action Item
 *  @param onFinish BOOL succsess is for you to guage if the action Item finished
 *                  correctly so you can modifiey in the block the ActionList
 *  @param onStart  This block is run as soon as the ActionList Starts working on the item
 */
-(void)addItem:(id<ActionListItem>)item onItemStart:(void (^)())onStart onItemFinish:(void (^)(BOOL succsess))onFinish;



-(void)addItem:(id<ActionListItem>)item onItemStart:(void (^)())onStart;

/**
 *  Once all items in the list are complete, it will run this block at the end
 *
 *  @param finBlock FinishList Block
 */
-(void)onFinishList:(void(^)(void)) finBlock;





-(void)unShiftItem:(id<ActionListItem>)item;
-(void)unShiftItem:(id<ActionListItem>)item onItemFinish:(void (^)(BOOL succsess))onFinish;
-(void)unShiftItem:(id<ActionListItem>)item   onItemStart:(void (^)())onStart onItemFinish:(void (^)(BOOL succsess))onFinish;
-(void)unShiftItem:(id<ActionListItem>)item onItemStart:(void (^)())onStart;

-(void)addStack:(NSArray*)items;


    










@end







@interface DelayAction : NSObject<ActionListItem>
-(id)initWithTime:(int)time;
@end





