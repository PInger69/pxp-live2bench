//
//  PxpTelestration.m
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import "PxpTelestration.h"
#import "PxpTelestrationRenderer.h"

#import "PxpTelestrationInterchangeFormat.h"

@implementation PxpTelestration
{
    NSMutableArray * __nonnull _actionStack;
}

@synthesize actionStack = _actionStack;

+ (nonnull instancetype)telestrationFromData:(nonnull NSString *)base64 {
    // decode from base64.
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64 options:0];
    
    // try to create a PXPTIF telestration from the data.
    PXPTIFTelestrationRef __nullable telestrationData = PXPTIFTelestrationCreateWithData(data.bytes, data.length);
    if (telestrationData) {
        
        // get action count.
        uint32_t n_actions = PXPTIFTelestrationGetActionCount(telestrationData);
        
        // extract actions.
        NSMutableArray *actions = [NSMutableArray arrayWithCapacity:n_actions];
        for (uint32_t i = 0; i < n_actions; i++) {
            // create action object.
            PxpTelestrationAction *action = [[PxpTelestrationAction alloc] init];
            
            // get action data.
            PXPTIFActionRef __nonnull actionData = PXPTIFTelestrationGetActions(telestrationData)[i];
            
            // get color.
            PXPTIFColor color = PXPTIFActionGetColor(actionData);
            
            // get and assign type.
            action.type = PXPTIFActionGetType(actionData);
            
            // assign color as UIColor.
            action.strokeColor = [UIColor colorWithRed:color.r / 255.0 green:color.g / 255.0 blue:color.b / 255.0 alpha:color.a / 255.0];
            
            // get and assign stroke width.
            action.strokeWidth = PXPTIFActionGetWidth(actionData);
            
            // get points.
            uint32_t n_points = PXPTIFActionGetPointCount(actionData);
            
            for (uint32_t j = 0; j < n_points; j++) {
                [action addPoint:[[PxpTelestrationPoint alloc] initWithPointData:PXPTIFActionGetPoints(actionData)[j]]];
            }
            
            // add to actions array.
            [actions addObject:action];
        }
        
        // create telestration object from data.
        PxpTelestration *telestration = [[self alloc] initWithSize:CGSizeMake(PXPTIFTelestrationGetWidth(telestrationData), PXPTIFTelestrationGetHeight(telestrationData)) actions:actions];
        
        // get and assign properties.
        telestration.isStill = PXPTIFTelestrationIsStill(telestrationData);
        telestration.sourceName = [NSString stringWithUTF8String:PXPTIFTelestrationGetSourceName(telestrationData)];
        
        // destroy PXPTIF telestration data.
        PXPTIFTelestrationDestroy(telestrationData);
        
        return telestration;
    } else {
        return [[self alloc] init];
    }
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
        _sourceName = [aDecoder decodeObjectForKey:@"n"];
        _isStill = [aDecoder decodeBoolForKey:@"i"];
        _actionStack = actions ? [NSMutableArray arrayWithArray:actions] : [NSMutableArray array];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeCGSize:self.size forKey:@"s"];
    [aCoder encodeObject:self.sourceName forKey:@"n"];
    [aCoder encodeBool:self.isStill forKey:@"i"];
    [aCoder encodeObject:self.actionStack forKey:@"a"];
}

- (nonnull NSString *)data {
    
    // allocate actions array.
    PXPTIFActionRef __nonnull actions[_actionStack.count];
    
    // create actions.
    for (NSUInteger i = 0; i < _actionStack.count; i++) {
        PxpTelestrationAction *__nonnull action = _actionStack[i];
        
        // stack allocate points.
        PXPTIFPoint points[action.points.count];
        
        for (NSUInteger j = 0; j < action.points.count; j++) {
            points[j] = [action.points[j] pointData];
        }
        
        CGFloat r, g, b, a;
        [action.strokeColor getRed:&r green:&g blue:&b alpha:&a];
        
        actions[i] = PXPTIFActionCreate(action.type, PXPTIFColorMake(255.0 * r, 255.0 * g, 255.0 * b, 255.0 * a), action.strokeWidth, points, (uint32_t) MIN(action.points.count, UINT32_MAX));
    }
    
    // create PXPTIF telestration.
    PXPTIFTelestrationRef __nonnull telestration = PXPTIFTelestrationCreate(self.sourceName.UTF8String ? self.sourceName.UTF8String : "", self.size.width, self.size.height, self.isStill, actions, (uint32_t) MIN(_actionStack.count, UINT32_MAX));
    
    // get the PXPTIF data representation.
    size_t size;
    void *__nonnull data = PXPTIFTelestrationCreateDataRepresentation(telestration, &size);
    
    // base64 encode the data.
    return [[NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES] base64EncodedStringWithOptions:0];
}

- (NSTimeInterval)startTime {
    NSTimeInterval time = INFINITY;
    for (PxpTelestrationAction *action in self.actionStack) {
        time = MIN(time, action.points.firstObject ? [action.points.firstObject displayTime] : +INFINITY);
    }
    return MAX(0.0, time);
}

- (NSTimeInterval)duration {
    NSTimeInterval time = -INFINITY;
    for (PxpTelestrationAction *action in self.actionStack) {
        time = MAX(time, action.points.lastObject ? [action.points.lastObject displayTime] : -INFINITY);
    }
    
    NSTimeInterval duration = time - self.startTime;
    
    return isfinite(duration) ? MAX(0.0, duration) : 0.0;
}

- (NSTimeInterval)thumbnailTime {
    NSTimeInterval t = self.startTime + self.duration;
    
    NSArray *sortedActions = self.sortedActions;
    for (PxpTelestrationAction *action in sortedActions.reverseObjectEnumerator) {
        if (action.type == PxpClear) {
            t = action.displayTime - (1.0 / 60.0);
            break;
        }
    }
    
    return t;
}

- (nonnull UIImage *)thumbnail {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    PxpTelestrationRenderer *renderer = [[PxpTelestrationRenderer alloc] initWithTelestration:self];
    [renderer renderInContext:ctx size:self.size atTime:self.thumbnailTime];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
