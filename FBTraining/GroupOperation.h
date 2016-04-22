//
//  GroupOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-08.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupOperation : NSOperation

- (instancetype)initWithOperations:(NSArray*)operations;

@end
