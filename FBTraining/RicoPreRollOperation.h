//
//  RicoPreRollOperation.h
//  Live2BenchNative
//
//  Created by dev on 2015-11-30.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//@protocol RicoPlayerItemOperationDelegate <NSObject>
//
//
//@end



@interface RicoPreRollOperation : NSOperation

@property (nonatomic,assign) BOOL * success;
@property (copy, nonatomic) void(^completionHandler)(BOOL);
- (instancetype)initWithAVPlayer:(AVPlayer*)aPlayer prerollAtRate:(float)aRate;

@end
