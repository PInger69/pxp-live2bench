//
//  Feed.h
//  Live2BenchNative
//
//  Created by dev on 2014-11-18.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feed : NSObject

@property (nonatomic, assign)            int         quality;
@property (nonatomic, assign,readonly)   BOOL        hasHighQuality;
@property (nonatomic, assign,readonly)   BOOL        hasLowQuality;
@property (nonatomic, strong)            NSString    * sourceName;
@property (nonatomic,assign)             BOOL        isAlive;

-(id)initWithURLDict:(NSDictionary *)aDict;
-(id)initWithURLString:(NSString *)aPath quality:(int)qlty;
-(NSURL *)path;



@end
