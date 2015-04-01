//
//  Feed.h
//  Live2BenchNative
//
//  Created by dev on 2014-11-18.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feed : NSObject

@property (nonatomic, assign)            int            quality;
@property (nonatomic, assign,readonly)   BOOL           hasHighQuality;
@property (nonatomic, assign,readonly)   BOOL           hasLowQuality;
@property (nonatomic, strong)            NSString       * sourceName;   // raw source name
@property (nonatomic,assign)             BOOL           isAlive;        // for observering
@property (nonatomic, strong)            NSDictionary   * info;         // any extra data that needs to be associated with the feed e.g. tag plist

-(id)initWithURLDict:(NSDictionary *)aDict;
-(id)initWithURLString:(NSString *)aPath quality:(int)qlty;
-(NSURL *)path;



@end
