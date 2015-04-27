//
//  FilterItemProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-04-24.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#ifndef Live2BenchNative_FilterItemProtocol_h
#define Live2BenchNative_FilterItemProtocol_h

@protocol FilterItemProtocol <NSObject>

@property (assign, nonatomic) double time;
@property (assign, nonatomic) int duration;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) int rating;
@property (strong, nonatomic) NSString *user;

@optional
@property (strong, nonatomic) NSString *colour;


@end

#endif
