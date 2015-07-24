//
//  TagSelectResponder.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-23.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag.h"

@protocol TagSelectResponder

- (void)didSelectTag:(nonnull Tag *)tag source:(nonnull NSString *)source;

@end
