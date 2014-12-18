//
//  JPXMLTag.h
//  StatsImportXML
//
//  Created by Si Te Feng on 7/8/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPXMLTag : NSObject



@property (nonatomic, assign) NSUInteger identifier;
@property (nonatomic, assign) float startTime; 
@property (nonatomic, assign) float endTime;
@property (nonatomic, strong) NSString* code;


@property (nonatomic, strong) NSString* textName;


- (instancetype)initWithId: (NSUInteger)identifier :(NSString*)code :(float)startTime :(float)endTime textName: (NSString*)name;


@end
