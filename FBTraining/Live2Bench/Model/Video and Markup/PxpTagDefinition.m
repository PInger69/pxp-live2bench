//
//  PxpTagDefinition.m
//  Live2Bench
//
//  Created by BC Holmes on 2017-02-08.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import "PxpTagDefinition.h"

@implementation PxpTagDefinition

-(instancetype) initWithName:(NSString*) name order:(NSInteger) order position:(PxpTagDefinitionPosition) position {
    if (self = [super init]) {
        self.name = name;
        self.order = order;
        self.position = position;
    }
    return self;
}

-(NSDictionary*) toDictionary {
    return @{
             @"name" : self.name,
             @"order" : @(self.order),
             @"position" : self.position == PxpTagDefinitionPositionLeft ? @"left" : @"right"
             };
}

+(NSArray*) fromArrayOfDictionaries:(NSArray*) array {
    NSMutableArray* result = [NSMutableArray new];
    
    for (NSDictionary* dictionary in array) {
        PxpTagDefinition* definition = [PxpTagDefinition fromDictionary:dictionary];
        if (definition != nil) {
            [result addObject:definition];
        }
    }
    
    return [NSArray arrayWithArray:result];
}

+(PxpTagDefinition*) fromDictionary:(NSDictionary*) dictionary {
    
    id tempName = dictionary[@"name"];
    NSString* name = tempName == [NSNull null] ? nil : (NSString*) tempName;
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([name isEqualToString:@"--"]) { // bad legacy representation of "nil"
        name = nil;
    }
    if ([name isEqualToString:@""]) {
        name = nil;
    }
    if (name != nil) {
        NSInteger order = [dictionary[@"order"] integerValue];
        NSString* position = dictionary[@"position"];
        return [[PxpTagDefinition alloc] initWithName:name order:order position:[position isEqualToString:@"left"] ? PxpTagDefinitionPositionLeft : PxpTagDefinitionPositionRight];
    } else {
        return nil;
    }
}

-(NSString*) description {
    return [NSString stringWithFormat:@"#%ld: %@", self.order, self.name];
}

@end
