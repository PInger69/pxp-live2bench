//
//  VideoZoomManager.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-19.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PxpVideoPlayerProtocol.h"

/**
 *  This is a simple little class that manages the zooming capabilities of the Video Players
 */
@interface VideoZoomManager : NSObject

//Only a reference to the video player is needed for this class to be functional
@property (strong, nonatomic) UIViewController <PxpVideoPlayerProtocol> *videoPlayer;

//Although this is the default initialization method, it is still acceptable to use init, but the
//video player property must still get passed in later.
-(instancetype)initForVideoPlayer: (UIViewController <PxpVideoPlayerProtocol> *) videoPlayer;
-(UIPanGestureRecognizer *) panGestureRecognizer;


@end
