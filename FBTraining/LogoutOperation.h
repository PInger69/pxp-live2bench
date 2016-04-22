//
//  LogoutOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PostOperation.h"

@interface LogoutOperation : PostOperation
- (instancetype)initWithEmail:(NSString*)email password:(NSString*)password authorization:(NSString*)authorization color:(NSString*)colorString customerHid:(NSString*)customerHid;
- (instancetype)initWithDictionary:(NSDictionary*)tData;
@end
