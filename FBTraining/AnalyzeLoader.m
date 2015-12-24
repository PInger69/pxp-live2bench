//
//  AnalyzeLoader.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-08.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "AnalyzeLoader.h"
#import "EncoderManager.h"
#import "EncoderOperation.h"
#import "UserCenter.h"
#import "DownloadOperation.h"


@interface AnalyzeLoader ()

@property (nonatomic ,strong) NSOperationQueue  * operationQueue;
@property (nonatomic ,strong) NSMutableArray    * tagModResponces;

@property (nonatomic,weak) Event    * event;
@property (nonatomic,weak) Encoder  * encoder;

@end




@implementation AnalyzeLoader


- (instancetype)initWithTag:(Tag*)tag
{
    self = [super init];
    if (self) {
        self.currentTag         = tag;
        self.operationQueue     = [NSOperationQueue new];
        self.tagModResponces    = [NSMutableArray new];
        self.status             = ANALYZE_LOADER_STATE_IDLE;
        self.event              = self.currentTag.event;
        self.encoder            = (Encoder *)self.currentTag.event.parentEncoder;
    }
    return self;
}


// Start getting URLS
-(void)start
{
    self.status             = ANALYZE_LOADER_STATE_GET_URLS;

    // Make sync block
    NSOperation * syncer = [NSOperation new];

    [syncer setCompletionBlock:^{
        [self downloadedTags];
    }];
    
    NSArray * keys = [self.event.feeds allKeys];
    
    // this makes all the cources
    for (NSString * srcID in keys) {
        
        NSDictionary * data =
        @{
          @"id": self.currentTag.ID,
          @"event": (self.currentTag.isLive)?LIVE_EVENT:self.event.name,
          @"requesttime":GET_NOW_TIME_STRING,
          @"bookmark":@"1", // is this needed
          @"user":[UserCenter getInstance].userHID,
          @"name":self.currentTag.name,
          @"srcValue":srcID,// used by encoder to locate and cut clip
          @"sidx":[NSString stringWithFormat:@"%@hq", srcID] //          @"sidx":[Utility removeSubString:@"s_" in:srcID]
         };
        
        EncoderOperationMakeMP4fromTag * operation = [[EncoderOperationMakeMP4fromTag alloc]initEncoder:self.encoder data:data];
        operation.timeout = 15;
        [operation setOnRequestComplete:^(NSData * data,EncoderOperation* op) {
            NSDictionary * dict = [Utility JSONDatatoDict:data];
            [self.tagModResponces addObject:dict];
        }];
        
        [syncer addDependency:operation];
        [self.encoder runOperation:operation];
    }
    

    [self.operationQueue addOperation:syncer];
    if(!self.currentTag){
    
    }
    
    
     [[LocalMediaManager getInstance]saveClip:nil withData:self.currentTag.rawData];
}


-(void)downloadedTags
{
    NSLog(@"%s",__FUNCTION__);
    self.status = ANALYZE_LOADER_STATE_DOWNLOADING;
    NSOperation * syncer = [NSOperation new];
    
    [syncer setCompletionBlock:^{
       
    }];
    
    
    
    // This collects all the source keys and urls
    NSMutableDictionary * sourceDict = [NSMutableDictionary new];
    for (NSDictionary * dict in self.tagModResponces) {
        if (!dict)continue;
        [sourceDict addEntriesFromDictionary:dict[@"vidurl_2"]];
    }
    
    
    NSArray * scrKeys = [sourceDict allKeys];
    for (NSString * aKey in scrKeys) {

        // make filename and location
        
        NSString * videoName = [NSString stringWithFormat:@"%@_vid_%@+%@hq.mp4",self.event.name,self.currentTag.ID, aKey];
        NSString * path = [NSString stringWithFormat:@"%@/%@",[[LocalMediaManager getInstance] bookmarkedVideosPath] ,videoName];
        
        NSLog(@"Save Path: %@",path);
        // build download Operation
        DownloadOperation * downLoad = [[DownloadOperation alloc]initWith:[NSURL URLWithString:sourceDict[aKey]] destination:path];
        downLoad.timeout = 15;
 
        [downLoad setOnRequestRecieved:^(DownloadOperation * op) {
             // on first get header length
        }];
        [downLoad setOnRequestProgress:^(DownloadOperation *op) {
            // progress of download
        }];
        
        [downLoad setCompletionBlock:^{
           // when download is complete
            // This makes a new clip or addeds the video to an existing clip
            PXPLog(@"Video Saved to Clip: %@",videoName);
            [[LocalMediaManager getInstance]saveClip:videoName withData:self.currentTag.rawData];
        }];

        [self.operationQueue addOperation:downLoad];
        [syncer addDependency:downLoad];
    }
    
    [syncer setCompletionBlock:^{
        [self complete];
    }];



    [self.operationQueue addOperation:syncer];
}



-(void)complete
{
    self.status = ANALYZE_LOADER_STATE_COMPLETE;
    if (self.delegate) {
        [self.delegate onCompletion:self finalClip:[[LocalMediaManager getInstance] getClipByTag:self.currentTag scrKey:nil]];
    }
}



@end
