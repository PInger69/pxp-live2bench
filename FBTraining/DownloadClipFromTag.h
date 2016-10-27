//
//  DownloadClipFromTag.h
//  Live2BenchNative
//
//  Created by dev on 2016-09-16.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "GroupOperation.h"
#import "TagProtocol.h"
#import "EncoderProtocol.h"
#import "EncoderOperation.h"
#import "LocalMediaManager.h"


@interface DownloadClipFromTag : GroupOperation
{
    BOOL        executing;
    BOOL        finished;
    
}


@property (nonatomic,assign) NSInteger attemptCount;
@property (nonatomic,strong) NSError * error;

@property (nonatomic,strong) NSMutableArray * opCollection;

@property (copy, nonatomic)     void(^onCutComplete)(NSData*data,NSError*error);
@property (copy, nonatomic)     void(^onFail)(NSError*error);



// gets the tag. If no sources are sent then it will download all
- (instancetype)initWithTag:(id<TagProtocol>)tag encoder:(id<EncoderProtocol>)encoder sources:(NSArray*)sources;
@end
