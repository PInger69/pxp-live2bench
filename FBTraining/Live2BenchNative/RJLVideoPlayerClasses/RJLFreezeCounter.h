//
//  RJLFreezeCounter.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-02.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJLFreezeCounter : NSObject


@property (nonatomic,strong) NSTimer        * freezeTimer;
@property (nonatomic,assign) NSInteger      freezeCounter;
@property (nonatomic,assign) NSInteger      subzeroCounter;
@property (nonatomic,assign) NSInteger      maxfreeze;

-(instancetype)initWithTarget:(id)target selector:(SEL)sel object:(id)arg;

-(instancetype)initWithOnFreeze:(void (^)(BOOL))onFreeze  onCriticalFreeze:(void (^)())subZero;


-(void)startTimer:(int)interval max:(int)max;
-(void)reset;

-(void)start;
-(void)stop;



@end
