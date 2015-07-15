//
//  PxpTelestration.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-08.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PxpTelestrationAction.h"

@interface PxpTelestration : NSObject<NSCoding>

@property (readonly, assign, nonatomic) CGSize size;
@property (readonly, strong, nonatomic, nonnull) NSArray *actionStack;
@property (readonly, strong, nonatomic, nonnull) NSArray *sortedActions;
@property (readonly, strong, nonatomic, nonnull) NSData *data;

+ (nonnull instancetype)telestrationFromData:(nonnull NSData *)data;

- (nonnull instancetype)initWithSize:(CGSize)size;
- (nonnull instancetype)initWithSize:(CGSize)size actions:(nonnull NSArray *)actions;
- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder;

- (void)pushAction:(nonnull PxpTelestrationAction *)action;
- (nullable PxpTelestrationAction *)popAction;

- (nonnull NSArray *)actionStackForTime:(NSTimeInterval)time;

@end
