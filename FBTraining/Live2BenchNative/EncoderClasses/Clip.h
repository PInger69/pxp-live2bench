//
//  Clip.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-09.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Its kinda like the Event Class but is used to only manage the sources for local content
 */

@interface Clip : NSObject

@property (nonatomic,strong)            NSString       * name;
@property (nonatomic,strong)            NSString       * clipId;
@property (nonatomic,assign)            int            rating;
@property (nonatomic,strong)            NSString       * comment;
@property (nonatomic,strong)            NSDictionary   * feeds;
@property (nonatomic,strong)            NSDictionary   * rawData;
@property (nonatomic,strong)            NSString       * path;


-(instancetype)initWithDict:(NSDictionary*)data;

@end
