//
//  VideoTrimItem.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-30.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "VideoTrimItem.h"
//#import <AVFoundation/AVFoundation.h>

@interface VideoTrimItem ()

@property (strong, nonatomic) AVURLAsset *videoAsset;
@property (strong, nonatomic) AVAssetExportSession *videoTrimSession;

@end

@implementation VideoTrimItem
{
    CMTimeRange timeRange;
    NSString *videoFilePath;
    NSString *destinationPath;
}

-(instancetype)initWithVideoURLString:(NSString*)URLString destination:(NSString*)aPath andTimeRange: (CMTimeRange) range
{
    self = [super init];
    if (self) {
        videoFilePath = URLString;
        destinationPath = aPath;
        timeRange = range;
    }
    return self;
}

-(void)createClip{
    
    //videoFilePath =
    NSURL *videoToTrimURL = [NSURL fileURLWithPath: videoFilePath];
    
  
    //NSURL *anotherURL = [[NSURL alloc] ini]
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoToTrimURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    
    [exportSession addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    NSLog(@"%@", [AVAssetExportSession exportPresetsCompatibleWithAsset:asset]);
    
    [exportSession determineCompatibleFileTypesWithCompletionHandler:^(NSArray *compatibleFileTypes) {
        NSLog(@"%@", compatibleFileTypes);
    }];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *outputURL = paths[0];
//    NSFileManager *manager = [NSFileManager defaultManager];
//    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
//    outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
    // Remove Existing File
    //[manager removeItemAtPath:outputURL error:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
    }
    
    [AVAssetExportSession determineCompatibilityOfExportPreset:AVAssetExportPresetPassthrough withAsset:asset outputFileType:AVFileTypeMPEG4 completionHandler:^(BOOL compatible) {
        NSLog(@"%i", compatible);
    }];
    
    exportSession.outputURL = [NSURL fileURLWithPath: destinationPath];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
//    CMTime start = CMTimeMakeWithSeconds(time, 1);
//    CMTime duration = CMTimeMakeWithSeconds(length, 1);
//    CMTimeRange range = CMTimeRangeMake(start, duration);
    exportSession.timeRange = timeRange;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         switch (exportSession.status) {
                 
             case AVAssetExportSessionStatusCompleted:
                 //[self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:outputURL]];
                 NSLog(@"Export Complete %ld %@", (long)exportSession.status, exportSession.error);
                 self.status = DownloadItemStatusComplete;
                 if (self.onComplete) {
                     self.onComplete();
                 }
                 if (progressBlock) {
                     progressBlock(1.0, 0);
                 }
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"Failed:%@",exportSession.error);
                 self.status = DownloadItemStatusError;
                 break;
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"Canceled:%@",exportSession.error);
                 self.status = DownloadItemStatusCancel;
                 break;
             default:
                 break;
         }
         
     }];
    
    self.videoAsset = asset;
    self.videoTrimSession = exportSession;

    //return [NSData dataWithContentsOfFile: destinationPath];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    float progress = [((NSNumber *)[change objectForKey:@"new"]) floatValue];
    if (progressBlock) {
        progressBlock(progress, 0);
    }
}

-(void)start{
    [self createClip];
}

-(void)cancel{
    [self.videoTrimSession cancelExport];
}

@end
