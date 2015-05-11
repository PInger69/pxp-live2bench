//
//  FakeEncoder.h
//  Live2BenchNative
//
//  Created by dev on 2015-05-11.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "Encoder.h"
#import "EncoderProtocol.h"



@interface FakeEncoder : NSObject <EncoderProtocol>
@property (nonatomic,strong)    NSString                * name;
@property (nonatomic, weak)     EncoderManager          *encoderManager;
@property (nonatomic,assign)    EncoderStatus           status;
@property (nonatomic,strong)    NSString                * statusAsString;
@property (nonatomic,strong)    Event                   * event;        // the current event the encoder is looking at
@property (nonatomic,strong)    NSDictionary            * allEvents;

-(instancetype)init;
+(instancetype)make;
+(int)fakeCount;

@end
