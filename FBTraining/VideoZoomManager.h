//
//  VideoZoomManager.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VideoZoomManager : NSObject

@property (strong, nonatomic) UIView *videoView;
@property (assign, nonatomic) CGRect zoomFrame;


-(instancetype)initForVideoView: (UIView *) videoView;
-(void)addTarget: (id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
