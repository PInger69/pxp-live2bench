//
//  PxpFullscreenResponder.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-08-11.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PxpFullscreenResponse) {
    PxpFullscreenResponseNone,
    PxpFullscreenResponseEnter,
    PxpFullscreenResponseLeave,
};


@protocol PxpFullscreenResponder <NSObject>

@property (readonly, assign, nonatomic) PxpFullscreenResponse fullscreenResponse;

@end
