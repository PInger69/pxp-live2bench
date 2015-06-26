//
//  EncoderCommand.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncoderCommand : NSObject

@property (nonatomic)           SEL                 selector;
@property (nonatomic)           id                  target;
@property (nonatomic,assign)    int                 priority;
@property (nonatomic,assign)    float               timeOut;
@property (nonatomic,strong)    NSMutableDictionary * tagData;
@property (nonatomic)           NSNumber            * timeStamp;
@property (nonatomic, copy)     void(^onComplete)();


@end
