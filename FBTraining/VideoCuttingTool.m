//
//  VideoCuttingTool.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-27.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "VideoCuttingTool.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoCuttingTool

-(NSData *)createClipAtTime: (float) time withLength: (float) length fromVideoFilePath: (NSString *) videoFilePath{
    
    NSURL *videoToTrimURL = [[NSURL alloc] initFileURLWithPath: videoFilePath];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoToTrimURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    CMTime start = CMTimeMakeWithSeconds(time, 1);
    CMTime duration = CMTimeMakeWithSeconds(length, 1);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = range;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCompleted:
                 //[self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:outputURL]];
                 NSLog(@"Export Complete %d %@", exportSession.status, exportSession.error);
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed:%@",exportSession.error);
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Canceled:%@",exportSession.error);
                 break;
             default:
                 break;
         }
         
     }];
    
    return [NSData dataWithContentsOfFile:outputURL];
}

@end
