//
//  DownloadOperationSuperOld.m
//  Live2BenchNative
//
//  Created by dev on 2016-10-17.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DownloadOperationSuperOld.h"
#import "DownloadItem.h"

@interface DownloadOperationSuperOld ()
@property (nonatomic,strong) DownloadItem * download;
@end


@implementation DownloadOperationSuperOld



- (instancetype)initWith:(NSURL*)url destination:(NSString*)destination
{
    self = [super init];
    if (self) {
        
        self.download = [[DownloadItem alloc]initWithURL:[url absoluteString] destination:destination];
    }
    return self;
}


-(void)start
{

    [self.download start];
}

@end
