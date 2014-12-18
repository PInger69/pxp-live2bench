//
//  JPXMLTag.m
//  StatsImportXML
//
//  Created by Si Te Feng on 7/8/14.
//  Copyright (c) 2014 Si Te Feng. All rights reserved.
//

#import "JPXMLTag.h"

@implementation JPXMLTag


- (instancetype)initWithId: (NSUInteger)identifier :(NSString*)code :(float)startTime :(float)endTime textName: (NSString*)name
{
    
    self = [super init];
    self.identifier = identifier;
    self.startTime = startTime;
    self.endTime   = endTime;
    self.code = code;
    
    if(!name || [name isEqual:@""])
        self.textName = @"No Name";
    else
        self.textName = name;
    
    return self;
    
}


- (NSString*)description
{
    NSString* returnString = [NSString stringWithFormat:@"Tag[%li]: [%.0f, %.0f) [%@]", (long)self.identifier, self.startTime, self.endTime, self.code];
    
    return returnString;
    
}



@end
