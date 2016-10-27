//
//  DownloadOperationDepricated.h
//  Live2BenchNative
//
//  Created by dev on 2016-10-14.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "DownloadOperation.h"

@interface DownloadOperationDepricated : DownloadOperation
{
//    BOOL        executing;
//    BOOL        finished;
    
}

//@property (nonatomic,strong)    NSURLSession    * session;
//
//@property (nonatomic,strong)    NSURLRequest    * request;
//
//@property (nonatomic,strong)    NSURL           * source;
//@property (nonatomic,strong)    NSString        * destination;
//@property (nonatomic,assign)    NSInteger       timeout;
//@property (nonatomic,assign)    double          expectedBytes;
//@property (nonatomic,assign)    double          receivedBytes;
//
//@property (nonatomic,assign)    NSInteger       attempts;
//@property (nonatomic,strong)    NSError         * error;
//
//@property (copy, nonatomic)     void(^onRequestProgress)(DownloadOperation* operation);
//@property (copy, nonatomic)     void(^onRequestRecieved)(DownloadOperation* operation);

- (instancetype)initWith:(NSURL*)url destination:(NSString*)destination;



@end
