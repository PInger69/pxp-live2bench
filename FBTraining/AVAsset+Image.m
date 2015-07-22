//
//  AVAsset+Image.m
//  Live2BenchNative
//
//  Created by Nico Cvitak on 2015-07-16.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "AVAsset+Image.h"

@implementation AVAsset (Image)

- (nullable UIImage *)imageForTime:(CMTime)time {
    NSError *error;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self];
    
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image && !error ? image : nil;
}

@end