//
//  RicoPlayerControlProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2016-06-30.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RicoPlayerControlProtocol <NSObject>

@property (nonatomic, assign) BOOL                  slomo;

// player movment

-(void)live;//
-(void)stepByCount:(NSInteger)stepCount;
-(void)play;//
-(void)pause;//
-(void)seekToTime:(CMTime)seekTime toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void(^)(BOOL finished))completionHandler;


//-(BOOL)slomo;
//-(void)setSlomo:(BOOL)slomo;

@end
