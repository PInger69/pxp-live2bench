//
//  BottomViewTimeProviderDelegate.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-24.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BottomViewTimeProviderDelegate <NSObject>
@property (nonatomic,assign) CMTime currentTime;

@end
