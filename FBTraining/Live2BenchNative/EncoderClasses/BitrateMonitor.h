//
//  BitrateMonitor.h
//  Live2BenchNative
//
//  Created by dev on 11/6/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Encoder.h"
#import "EncoderProtocol.h"

@interface BitrateMonitor : UIView

@property (nonatomic,strong) NSString * name;

-(id)initWithFrame:(CGRect)frame encoder: ( Encoder * )aEncoder;


@end
