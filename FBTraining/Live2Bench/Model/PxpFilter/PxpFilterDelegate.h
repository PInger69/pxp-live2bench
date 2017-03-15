//
//  PxpFilterDelegate.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PxpFilter;
@protocol PxpFilterDelegate <NSObject>


-(void)onFilterComplete:(PxpFilter*)filter;
@optional
-(void)onFilterChange:(PxpFilter*)filter;


@end
