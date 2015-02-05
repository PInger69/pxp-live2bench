//
//  RJLFreezeCounter.h
//  Live2BenchNative
//
//  Created by dev on 2015-02-02.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RJLFreezeCounter : NSObject


@property (nonatomic,strong) NSTimer * freezeTimer;

-(instancetype)initWithTarget:(id)target selector:(SEL)sel object:(id)arg;

-(void)startTimer:(int)interval max:(int)max;
-(void)reset;

-(void)start;
-(void)stop;



@end
