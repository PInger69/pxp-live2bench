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

    AVAsset * copyAsset = [self copy];
    // for some starange reason if you call .metadata on the av asset before it goes in to AVAssetImageGenerator it will no error out
    
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:copyAsset];
    

    
    CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if (error) {
    
    }
    
    return image && !error ? image : nil;
}

@end