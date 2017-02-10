//
//  PxpTagDefinition.h
//  Live2Bench
//
//  Created by BC Holmes on 2017-02-08.
//  Copyright © 2017 Avoca. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PxpTagDefinitionPosition) {
    PxpTagDefinitionPositionLeft,
    PxpTagDefinitionPositionRight
};

@interface PxpTagDefinition : NSObject

@property (nonatomic, strong, nonnull) NSString* name;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) PxpTagDefinitionPosition position;

@end
