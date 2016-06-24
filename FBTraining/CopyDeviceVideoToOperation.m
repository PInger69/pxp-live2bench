//
//  CopyDeviceVideoToOperation.m
//  StandAloneEncoderBuild
//
//  Created by dev on 2016-06-08.
//  Copyright © 2016 dev. All rights reserved.
//

#import "CopyDeviceVideoToOperation.h"

@interface CopyDeviceVideoToOperation ()



@end



@implementation CopyDeviceVideoToOperation



- (instancetype)initAsset:(PHAsset*)asset outputStringURL:(NSString*)url
{
    
    self = [super init];
    if (self) {
        self.asset = asset;
        self.url = [NSURL fileURLWithPath:url];
        self.outputFileType = AVFileTypeMPEG4;
        success = NO;
    }
    return self;

}

- (instancetype)initAsset:(PHAsset*)asset outputURL:(NSURL*)url
{

    self = [super init];
    if (self) {
        self.asset = asset;
        self.url = url;
        self.outputFileType = AVFileTypeMPEG4;
        success = NO;
    }
    return self;


}




- (instancetype)init
{
    self = [super init];
    if (self) {
        self.outputFileType = AVFileTypeMPEG4;
        success = NO;
    }
    return self;
}





-(void)start
{
    
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:[self.url absoluteString] isDirectory:NULL]){
        [[NSFileManager defaultManager] removeItemAtPath:[self.url absoluteString] error:NULL];
    }
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        AVAssetExportSession *exporter  = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL              = self.url;
        exporter.outputFileType         = self.outputFileType;

        [exporter exportAsynchronouslyWithCompletionHandler:^{
            // here your file will be saved into file system at specified exportUrl
            
            success = [[NSFileManager defaultManager] fileExistsAtPath:[self.url absoluteString] isDirectory:NULL];
            
            
            [self willChangeValueForKey:@"isFinished"];
            [self willChangeValueForKey:@"isExecuting"];
            finished = YES;
            executing = NO;
            [self didChangeValueForKey:@"isExecuting"];
            [self didChangeValueForKey:@"isFinished"];
        }];

    }];
    
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    

}


-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return executing;
}

-(BOOL)isFinished
{
    return finished;
}



@end
