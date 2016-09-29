//
//  DownloadClipFromTag.m
//  Live2BenchNative
//
//  Created by dev on 2016-09-16.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DownloadClipFromTag.h"
#import "TagProtocol.h"
#import "EncoderProtocol.h"
#import "EncoderOperation.h"


@interface DownloadClipFromTag ()

@property (nonatomic,strong) id<TagProtocol> tag;
@property (nonatomic,strong) id<EncoderProtocol> encoder;


@end


@implementation DownloadClipFromTag




- (instancetype)initWithTag:(id<TagProtocol>)tag encoder:(id<EncoderProtocol>)encoder
{
    NSMutableArray * opCollection = [NSMutableArray new];
    
    // go thur all sources and tell the encoder to cut all the mp4s
    
    // once they are all cut
    
     
    for (NSString * srcKey in [[tag feeds] allKeys]) {
        EncoderOperation * tagMod = [[EncoderOperationMakeMP4fromTag alloc]initEncoder:encoder data:@{}];
        [opCollection addObject:tagMod];
    }
    
    
    
    
    
    
    
    
    
    self = [super initWithOperations:@[]];
    if (self) {
        
    }
    return self;
}
@end
