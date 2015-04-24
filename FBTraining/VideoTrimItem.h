//
//  VideoTrimItem.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-30.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "DownloadItem.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoTrimItem : DownloadItem

-(instancetype)initWithVideoURLString:(NSString*)URLString destination:(NSString*)aPath andTimeRange: (CMTimeRange) range;

@end
