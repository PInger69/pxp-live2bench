//
//  TagBuilder.m
//  Live2BenchNative
//
//  Created by dev on 10/27/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "TagBuilder.h"
#import "EncoderManager.h"
#import "Globals.h"

@implementation TagBuilder
{
    int tagsinQueueInOfflineMode;

}


-(id)initWithEventType:(EncoderManager*)eManager;
{
    self = [super init];
    if (self) {
        tagsinQueueInOfflineMode    = 0;
        encoderManager              = eManager;
    }
    
    return self;
}





-(void)createTag:(NSString*)tagTime data:(NSMutableDictionary*)data isDuration:(BOOL)isDuration
{
    // Create an empty mutable dictionary
    NSMutableDictionary *tag = [NSMutableDictionary dictionary];
    
    // Populate it with common date taken from the event, user and encoder
    [tag addEntriesFromDictionary:@{
                                     @"event"       : encoderManager.currentEvent,
                                     @"colour"      : [[Globals instance].ACCOUNT_INFO objectForKey:@"tagColour"],
                                     @"user"        : [[Globals instance].ACCOUNT_INFO objectForKey:@"hid"],
                                     @"id"          : [@"temp_" stringByAppendingString:tagTime],
                                     @"type"        : @"0",
                                     @"comment"     : @"",
                                     @"rating"      : @"0",
                                     @"coachpick"   : @"0",
                                     @"bookmark"    : @"0",
                                     @"deleted"     : @"0",
                                     @"edited"      : @"0",
                                     @"local"       : @"1"
                                     }];

    // Add the collected data to the teg dict
    [tag addEntriesFromDictionary:data];

}












// Utils
-(NSString*)toDisplayTime:(NSString*)tTime
{
    NSUInteger  dTotalSeconds   = [tTime floatValue];
    NSUInteger  dHours          = floor(dTotalSeconds / 3600);
    NSUInteger  dMinutes        = floor(dTotalSeconds % 3600 / 60);
    NSUInteger  dSeconds        = floor(dTotalSeconds % 3600 % 60);
    NSString    *displayTime    = [NSString stringWithFormat:@"%01i:%02i:%02i",dHours, dMinutes, dSeconds];

    return displayTime;
}

-(void)dispatchThumbnailCreate:(NSURL*)url time:(NSString*)tTime dirPath:(NSString*)dirThumbPath fileName:(NSString*)fname onComplete:(void(^)(void))onComplete
{
    
     NSString *imagePath = [dirThumbPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.jpg",fname]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        BOOL isDir;
        if(![[NSFileManager defaultManager] fileExistsAtPath:dirThumbPath isDirectory:&isDir])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:dirThumbPath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        //create thumbnail using avfoundation and save it in the local dir
        NSURL *videoURL                         = url;
        AVAsset *asset                          = [AVAsset assetWithURL:videoURL];
        AVAssetImageGenerator *imageGenerator   = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        
        [imageGenerator setMaximumSize:CGSizeMake(190, 106)];
        [imageGenerator setApertureMode:AVAssetImageGeneratorApertureModeProductionAperture];
        //CMTime time = [[dict objectForKey:@"cmtime"] CMTimeValue];//CMTimeMake(30, 1);
        CMTime time             = CMTimeMakeWithSeconds([tTime floatValue], 1);
        CGImageRef imageRef     = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        UIImage *thumbnail      = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        NSData *imageData       = UIImageJPEGRepresentation(thumbnail, 0.5);
        if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isDir])
        {
            [[NSFileManager defaultManager] createFileAtPath:imagePath contents:nil attributes:nil];
        }
        //add image to directory
        [imageData writeToFile:imagePath atomically:YES ];
        if (onComplete) onComplete();
    });


}



@end
