//
//  StreamViewVideoKit.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamViewProtocol.h"

@interface StreamViewVideoKit : UIView <StreamViewProtocol>
@property (nonatomic,strong) UIView * view;
-(void)url:(NSString*)urlPath;
@end
