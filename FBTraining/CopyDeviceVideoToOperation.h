//
//  CopyDeviceVideoToOperation.h
//  StandAloneEncoderBuild
//
//  Created by dev on 2016-06-08.
//  Copyright © 2016 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface CopyDeviceVideoToOperation : NSOperation
{
    BOOL        executing;
    BOOL        finished;
    BOOL        success;
}

@property (strong,nonatomic) PHAsset    * asset;
@property (strong,nonatomic) NSURL      * url;
@property (strong,nonatomic) NSString   * outputFileType;

- (instancetype)initAsset:(PHAsset*)asset outputStringURL:(NSString*)url;
- (instancetype)initAsset:(PHAsset*)asset outputURL:(NSURL*)url;

@end
