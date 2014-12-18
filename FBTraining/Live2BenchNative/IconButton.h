//
//  IconButton.h
//  Live2BenchNative
//
//  Created by Dev on 2013-09-25.
//  Copyright (c) 2013 DEV. All rights reserved.
//

typedef enum {
    IconTop = 0,
    IconLeft = 1,
    IconBottom = 2,
    IconRight = 3
} IconLocation;


#import "BorderlessButton.h"

@interface IconButton : BorderlessButton

@property (nonatomic) IconLocation iconLocation;

@end
