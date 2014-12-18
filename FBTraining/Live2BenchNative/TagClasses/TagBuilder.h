//
//  TagBuilder.h
//  Live2BenchNative
//
//  Created by dev on 10/27/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncoderManager.h"

// This class is used to collect tag info and present it to the encoder manager class
// as well at keep track of Duration Tags


@interface TagBuilder : NSObject
{
    EncoderManager* encoderManager;

}
/**
 *  <#Description#>
 *
 *  @param eventType <#eventType description#>
 *
 *  @return <#return value description#>
 */
-(id)initWithEventType:(EncoderManager*)eManager;



-(void)createTag:(NSString*)tagTime data:(NSMutableDictionary*)data isDuration:(BOOL)isDuration;

@end
