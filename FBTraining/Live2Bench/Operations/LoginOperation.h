//
//  LoginOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PostOperation.h"

@interface LoginOperation : PostOperation
-(instancetype)initWithEmail:(NSString*)email password:(NSString*)password;
@end
