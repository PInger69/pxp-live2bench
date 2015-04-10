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
@property (weak, nonatomic) UIViewController <PxpVideoPlayerProtocol> *videoPlayer;
//The zooming will only function within this limitFrame
@property (assign, nonatomic) BOOL enabled;
// This property will control the color of the border of the zoomView
// as well as the undo zoom button color
@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) NSMutableArray *viewsToAvoid;

//Although this is the default initialization method, it is still acceptable to use init, but the
//video player property must still get passed in later.
-(instancetype)initForVideoPlayer: (UIViewController <PxpVideoPlayerProtocol> *) videoPlayer;
-(UIPanGestureRecognizer *) panGestureRecognizer;
-(void)addVideoPlayerLayer: (AVPlayerLayer *)videoLayer;


@end
