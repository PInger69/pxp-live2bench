//
//  BooleanOperation.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-10.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BooleanOperation : NSOperation

@property (nonatomic,assign) BOOL success;
@property (nonatomic,strong) NSMutableArray * onSuccessOperations;
@property (nonatomic,strong) NSMutableArray * onFailOperations;



@end
