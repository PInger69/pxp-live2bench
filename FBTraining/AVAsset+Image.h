//
//  AVAsset+Image.h
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-16.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (Image)

- (nullable UIImage *)imageForTime:(CMTime)time;

@end
