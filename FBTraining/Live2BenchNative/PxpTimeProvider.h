//
//  PxpTimeProvider.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-15.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PxpTimeProvider

@property (readonly, assign, nonatomic) NSTimeInterval currentTime;

@end
