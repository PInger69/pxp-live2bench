//
//  SetSummaryOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-08-05.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PostOperation.h"
#import "EncoderProtocol.h"

typedef NS_OPTIONS(NSInteger, SummaryType)  {
    SummaryTypeGame,
    SummaryTypeMonth
    
};


@interface SetSummaryOperation : PostOperation
@property (nonatomic,strong)    id <EncoderProtocol> encoder;

- (instancetype)initWithUser:(NSString*)user summary:(NSString*)summary eventID:(NSString*)eventID type:(SummaryType)type encoder:(id<EncoderProtocol>)encoder;

@end
