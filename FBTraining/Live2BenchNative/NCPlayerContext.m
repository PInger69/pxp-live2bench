//
//  NCPlayerContext.m
//  iOS Workspace
//
//  Created by Nico Cvitak on 2015-06-02.
//  Copyright (c) 2015 Nicholas Cvitak. All rights reserved.
//

#import "NCPlayerContext.h"

@interface NCPlayerContext ()

@property (strong, nonatomic, nonnull) NSMutableSet *playerSet;

@end

@implementation NCPlayerContext

@synthesize playerSet = _playerSet;

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        _playerSet = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Getters / Setters

- (NSArray *)players {
    return self.playerSet.allObjects;
}

@end
