//
//  EncoderParseProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-10-26.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Encoder;

@protocol EncoderParseProtocol <NSObject>


typedef NS_ENUM (NSInteger, ParseMode){
    ParseModeVersionCheck
};



-(void)parse:(NSData*)data mode:(ParseMode)mode for:(Encoder*)encoder;

@end
