//
//  SpinnerView.h
//  Live2BenchNative
//
//  Created by DEV on 2013-03-27.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define NOTIF_OPEN_SPINNER          @"openSpinner"
#define NOTIF_CLOSE_SPINNER         @"closeSpinner"
#define NOTIF_UPDATE_SPINNER        @"updateSpinner"



@interface SpinnerView : UIVisualEffectView
+(SpinnerView *)loadSpinnerIntoView:(UIVisualEffectView  *)superView;
-(void)removeSpinner;

// NEW

+(SpinnerView*)getInstance;
// This spinner will listen to dispatched events
+(void)initTheGlobalSpinner;
+(NSDictionary*)message:(NSString*)aMessage progress:(float)aProgress animated:(BOOL)aAnimated;
-(id)initStatic;


@end
