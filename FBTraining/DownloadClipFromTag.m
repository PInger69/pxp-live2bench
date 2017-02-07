//
//  DownloadClipFromTag.m
//  Live2BenchNative
//
//  Created by dev on 2016-09-16.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DownloadClipFromTag.h"
#import "DownloadOperation.h"
#import "DownloaderQueue.h"

@interface DownloadClipFromTag ()

@property (nonatomic,strong) id<TagProtocol> tag;
@property (nonatomic,strong) id<EncoderProtocol> encoder;
@property (nonatomic,assign) NSInteger CurrentAttemptCount;

@end


@implementation DownloadClipFromTag




- (instancetype)initWithTag:(id<TagProtocol>)tag encoder:(id<EncoderProtocol>)encoder sources:(NSArray*)sources
{
    
    executing               = NO;
    finished                = NO;
    
    self.opCollection = [NSMutableArray new];
    self.attemptCount             = 3;
    self.CurrentAttemptCount      = 0;
    self.tag                      = tag;
    self.encoder                  = encoder;
    
    
    
    // collect source
    NSArray * srcToDownload = (sources)?sources:[[tag feeds] allKeys];
    
    
    
    
    NSOperation * prevDownload;
    
    // this sends the MP4 cutting
    
    for (NSString * srcKey in srcToDownload) {
        
        NSMutableDictionary * data = [[self.tag rawData]mutableCopy]; // add source to this
        
        NSString * srcKeyQ = [NSString stringWithFormat:@"%@hq",srcKey];
        
        data = [NSMutableDictionary dictionaryWithDictionary:
                                                @{
                                                  @"id": tag.ID,
                                                  @"event": (tag.isLive)?LIVE_EVENT:tag.event,
                                                  @"requesttime":GET_NOW_TIME_STRING,
                                                  @"bookmark":@"1",
                                                  @"user":[UserCenter getInstance].userHID
                                                  }];
        
        
        if (![[self.encoder version] isEqualToString:@"0.94.5"]) {
            [data addEntriesFromDictionary:@{
                                           @"name":tag.name
                                           ,@"srcValue":srcKeyQ // used by encoder to locate and cut clip
                                           ,@"sidx":srcKeyQ
                                             }];
        }
        
        
        // make operation to download but send it to the encoder operation and make it dependant on it
        DownloadOperation * downloadOperation = [DownloadOperation new];//;[DownloadOperation new];
        
        
        __weak DownloadClipFromTag * weakSelf = self;
        
        EncoderOperation * tagMod = [[EncoderOperationMakeMP4fromTag alloc]initEncoder:encoder data:data];
        
        // !!!:
        
        [tagMod setOnRequestComplete:^(NSData * rData, EncoderOperation * op) {
            
          
            if (!rData){
                [downloadOperation cancel];
                NSDictionary * userInfo = @{
                                                NSLocalizedDescriptionKey:               @"Failed to cut clip on server.",
                                                NSLocalizedFailureReasonErrorKey:        @"To many cut request simultaneously or cut request timed out.",
                                                NSLocalizedRecoverySuggestionErrorKey:   @"Please try again later when server traffic is not over loaded."
                                                };
                NSError * aError = [[NSError alloc]initWithDomain:PxpErrorDomain code:DOWNLOAD_CLIP_ERROR userInfo:userInfo];
//
                if (weakSelf.onFail){
                    weakSelf.onFail(aError);
                }
                return;
            }
            
            NSError      * parseError;
            NSDictionary * paredData             = [Utility JSONDatatoDict:rData error:&parseError];
            if (parseError && weakSelf.onFail) {
                weakSelf.onFail(parseError);
            }
            
            
            
            NSString     * urlForImageOnServer   = (NSString *)[paredData objectForKey:@"vidurl"];
            if (!urlForImageOnServer) PXPLog(@"Warning: vidurl not found on Encoder");
            
            
            
            NSString    * remotePath;       // Where the file is on the server
            NSString    * videoName;
            NSString    * tagID             = paredData[@"id"];
            
             if (![[self.encoder version] isEqualToString:@"0.94.5"]) {
                 // this part can be replaced with a regex
                 NSString * sidx     = paredData[@"requrl"];
                 NSRange  d          =  [sidx rangeOfString:@"sidx\":\""];
                 d                       = NSMakeRange(0, d.length+d.location);
                 sidx =  [sidx stringByReplacingCharactersInRange:d withString:@""];
                 d =  [sidx rangeOfString:@"\""];
                 d = NSMakeRange( d.location,[sidx length]-d.location);
                 sidx =  [sidx stringByReplacingCharactersInRange:d withString:@""];
                 NSString *src = sidx;
             
                 
                 // we add "+srcID" so we can grab the srcID from the file name by scanning up to the '+'
                 videoName        = [NSString stringWithFormat:@"%@_vid_%@+%@.mp4",paredData[@"event"],paredData[@"id"], src];
                 
                 NSString * ip                = [weakSelf.encoder ipAddress];
                 NSString * remoteSrc         = [src stringByReplacingOccurrencesOfString:@"s_" withString:@""];
//                 NSString * downloaderRefKey  =  paredData[@"srcValue"]; // this is used for the downloader and the localmedia manager
                 NSString * eventName        = ([weakSelf.encoder event].live)?LIVE_EVENT:paredData[@"event"] ;
                 
                 
                 remotePath       = [NSString stringWithFormat:@"http://%@/events/%@/video/%@_vid_%@.mp4", ip,eventName, remoteSrc, tagID];
                 
                 
                
//                 NSString        * dlKey = [NSString stringWithFormat:@"%@-%@",tagID,downloaderRefKey ];
                 

             } else {
                 remotePath = urlForImageOnServer;
                 videoName        = [NSString stringWithFormat:@"%@_vid_%@+%@.mp4",paredData[@"event"],paredData[@"id"], @"s_00hq"];
             }
            
            

            NSString    * destinationPath  = [NSString stringWithFormat:@"%@/%@",[[LocalMediaManager getInstance] bookmarkedVideosPath] ,videoName];
            NSLog(@"download destination path %@", destinationPath);
            
            
            downloadOperation.source        = [NSURL URLWithString:remotePath];
            downloadOperation.destination   = destinationPath;
            downloadOperation.onFail        = (weakSelf.onFail)?weakSelf.onFail:nil;

            [downloadOperation setCompletionBlock:^{
                
                [[LocalMediaManager getInstance] saveClip:videoName withData:[self.tag rawData]];
            }];
            
            
            
            NSString *event     = paredData[@"event"];
            NSString *globalIDSrc  = [NSString stringWithFormat:@"%@_%@_%@", event, tagID,srcKey];
            
            [DownloaderQueue trackOperation:downloadOperation key:globalIDSrc ];
            
            if (weakSelf.onCutComplete && rData){
                weakSelf.onCutComplete(rData,nil);
            }
        }];
    
        
        if (prevDownload) {
        
            [tagMod addDependency:prevDownload];
        }
        
        
        [downloadOperation addDependency:tagMod];
        prevDownload = downloadOperation;
    
        
        [self.opCollection addObject:downloadOperation];
        [self.opCollection addObject:tagMod];
    }
    
    
    
    
    
    
    self = [super initWithOperations:[self.opCollection copy]];
    if (self) {
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
    
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    self.internalQueue.suspended = NO;
    [self.internalQueue addOperation:self.finishingOperation];
    
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

-(void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    finished  = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


@end
