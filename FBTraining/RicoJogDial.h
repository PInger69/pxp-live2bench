//
//  RicoJogDial.h
//  Live2BenchNative
//
//  Created by dev on 2015-12-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RicoJogDial;

@protocol RicoJogDialJogDialDelegate <NSObject>

-(void)onMovement:(RicoJogDial*)dial value:(CGFloat)value;

@end

@interface RicoJogDial : UIView
@property (nonatomic,assign) CGFloat sensitivity;
@property (nonatomic,weak) id <RicoJogDialJogDialDelegate> delegate;

@end
