//
//  FullScreenViewController.h
//  Live2BenchNative
//
//  Created by dev on 9/25/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPlayer.h"


@interface FullScreenViewController : UIViewController
{
    CGRect          screenBounds;
    int             prevDispayIndex;
    CGRect          prevPlayerViewRect;
    CGRect          prevPlayerViewBounds;
    CGRect          prevPlayerLayerRect;
    CGRect          prevPlayerLayerBounds;
    UIView          * prevView;
}



@property (weak,  nonatomic) VideoPlayer   * player;
@property (strong,nonatomic) NSString      * context;
@property (assign,nonatomic) BOOL          enable;

-(id)initWithVideoPlayer:(VideoPlayer *) videoPlayer;


/**
 *  PROTECTED METHOD
 *
 *  @param player 
 */
-(void)buildAddSubview:(VideoPlayer*)player;

@end
