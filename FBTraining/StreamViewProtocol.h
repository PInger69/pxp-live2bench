//
//  StreamViewProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StreamViewProtocol <NSObject>

@property (nonatomic,strong) UIView * view;

-(void)url:(NSString*)urlPath;
-(void)refresh;
-(void)clear;

@end
