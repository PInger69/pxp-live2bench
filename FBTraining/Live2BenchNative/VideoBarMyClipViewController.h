//
//  VideoBarMyClipViewController.h
//  Live2BenchNative
//
//  Created by dev on 9/2/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"
#import "Slomo.h"
#import "SeekButton.h"
#import "VideoBarContainerView.h"
@interface VideoBarMyClipViewController : UIViewController
{
    VideoBarContainerView   * container;
    UIView                  * background;
    UILabel                 * tagLabel;
    Slomo                   * slomoButton;
    SeekButton              * forwardButton;
    SeekButton              * backwardButton;
    VideoPlayer             * videoPlayer;
    NSArray                 * activeElements;
}
-(id)initWithVideoPlayer:(VideoPlayer *)vidPlayer;

-(void)setTagName:(NSString*)name;

@end
