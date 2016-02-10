//
//  RicoView.h
//  Live2BenchNative
//
//  Created by dev on 2016-02-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class RicoPlayer;


@interface RicoView : UIView
@property (nonatomic) AVPlayer *player;

-(void)setRicoPlayer:(RicoPlayer *)ricoPlayer;

@end
