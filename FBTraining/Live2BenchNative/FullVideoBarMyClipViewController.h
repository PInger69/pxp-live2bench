//
//  FullVideoBarMyClipViewController.h
//  Live2BenchNative
//
//  Created by dev on 9/3/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpVideoPlayerProtocol.h"

@interface FullVideoBarMyClipViewController : UIViewController

-(id)initWithVideoPlayer:(UIViewController <PxpVideoPlayerProtocol>*)vidPlayer;
-(void)setTagName:(NSString*)name;
-(void)onPressNextPrevPerformSelector:(SEL)sel addTarget:(id)target;
@end
