//
//  GetUserTagsOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "PostOperation.h"

@interface GetUserTagsOperation : PostOperation

- (instancetype)initEmail:(NSString*)email password:(NSString*)aPassword authorization:(NSString*)authorization customerHid:(NSString*)customerHid;

@end
