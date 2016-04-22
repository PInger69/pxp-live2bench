//
//  RLEncoderProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2016-03-11.
//  Copyright © 2016 DEV. All rights reserved.
//


/*
    This is the new encoder class to replace the old Encoder Class
*/


#import <Foundation/Foundation.h>

@protocol RLEncoderProtocol <NSObject>




-(void)runOperation:(EncoderOperation*)operation;

@end
