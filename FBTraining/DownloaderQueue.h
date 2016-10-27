//
//  DownloaderQueue.h
//  Live2BenchNative
//
//  Created by dev on 2016-10-05.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol DownloadOperationQueueItemProtocol <NSObject>



@end


@interface DownloaderQueue : NSObject

+(NSOperation *)getQueueItemByKey:(NSString*)key;
+(void)addDownloadItem:(NSOperation *)item key:(NSString*)key;
+(NSOperationQueue*)queue;
+(void)addOperation:(NSOperation*)operation;
+(void)trackOperation:(NSOperation *)item key:(NSString*)key;

@end
