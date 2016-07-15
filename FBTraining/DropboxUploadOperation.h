//
//  DropboxUploadOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-07-14.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>


@interface DropboxUploadOperation : NSOperation
@property (nonatomic,strong) DBRestClient   * restClient;
@property (nonatomic,copy) void (^onOperationProgress)(CGFloat);
- (instancetype)initUploadFile:(NSString *)fileName toPath:(NSString *)toPath withParentRev:(NSString *)parentRev fromPath:(NSString *)fromPath;

@end
