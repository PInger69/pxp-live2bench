//
//  PxpTelestration.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestration.h"

@implementation PxpTelestration
{
    __nonnull NSMutableArray *_actionStack;
}

@synthesize actionStack = _actionStack;

+ (nonnull instancetype)telestrationFromData:(nonnull NSString *)data {
    NSString *base64 = [[data stringByReplacingOccurrencesOfString:@"(" withString:@"+"] stringByReplacingOccurrencesOfString:@")" withString:@"/"];
    
    PxpTelestration *telestration = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSData alloc] initWithBase64EncodedString:base64 options:0]];
    
    return [telestration isKindOfClass:self] ? telestration : [[self alloc] init];
}

- (nonnull instancetype)init {
    return [self initWithSize:CGSizeZero actions:@[]];
}

- (nonnull instancetype)initWithSize:(CGSize)size {
    return [self initWithSize:size actions:@[]];
}

- (nonnull instancetype)initWithSize:(CGSize)size actions:(nonnull NSArray *)actions {
    self = [super init];
    if (self) {
        _size = size;
        _actionStack = [NSMutableArray arrayWithArray:actions];
    }
    return self;
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSArray *actions = [aDecoder decodeObjectForKey:@"a"];
        
        _size = [aDecoder decodeCGSizeForKey:@"s"];
        _actionStack = actions ? [NSMutableArray arrayWithArray:actions] : [NSMutableArray array];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeCGSize:self.size forKey:@"s"];
    [aCoder encodeObject:self.actionStack forKey:@"a"];
}

- (nonnull NSString *)data {
    // TODO - compress the data :)
    
    NSString *base64 = [[NSKeyedArchiver archivedDataWithRootObject:self] base64EncodedStringWithOptions:0];
    
    return [[base64 stringByReplacingOccurrencesOfString:@"+" withString:@"("] stringByReplacingOccurrencesOfString:@"/" withString:@")"];
}

- (void)pushAction:(nonnull PxpTelestrationAction *)action {
    [_actionStack addObject:action];
}

- (nullable PxpTelestrationAction *)popAction {
    PxpTelestrationAction *action = _actionStack.lastObject;
    [_actionStack removeLastObject];
    return action;
}

- (nonnull NSArray *)sortedActions {
    return [self.actionStack sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"displayTime" ascending:NO]]];
}

- (nonnull NSArray *)actionStackForTime:(NSTimeInterval)time {
    
    // calculate the last clear action
    NSTimeInterval clear = -INFINITY;
    for (PxpTelestrationAction *action in self.sortedActions.reverseObjectEnumerator) {
        if (action.type == PxpClear && action.displayTime <= time) {
            clear = action.displayTime;
        }
    }
    
    // add valid actions.
    NSMutableArray *stack = [NSMutableArray array];
    for (PxpTelestrationAction *action in self.actionStack) {
        if (clear <= action.displayTime && action.displayTime <= time) {
            [stack addObject:action];
        }
    }
    return stack;
}

@end
