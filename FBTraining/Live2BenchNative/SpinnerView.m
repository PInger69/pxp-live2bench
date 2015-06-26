//
//  SpinnerView.m
//  Live2BenchNative
//
//  Created by DEV on 2013-03-27.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "SpinnerView.h"

@implementation SpinnerView
{
    id                          openObserver;
    id                          closeObserver;
    id                          updateObserver;
    UIActivityIndicatorView     * indicator;
    UILabel                     * progressMessage;
    UIProgressView              * progressBar;
    UIVisualEffectView          * blurEffect;
    
}
static SpinnerView *instance;


+(SpinnerView*)getInstance
{
    if (!instance) {
    
        instance = [[SpinnerView alloc]initStatic];
    }

    return instance;
};

+(void)initTheGlobalSpinner
{
    if (!instance) {
        instance = [[SpinnerView alloc]initStatic];
    }
}

+(NSDictionary*)message:(NSString*)aMessage progress:(float)aProgress animated:(BOOL)aAnimated
{
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    
    if(aMessage) [dict setObject:aMessage forKey:@"message"];
    [dict setObject:[NSNumber numberWithFloat:aProgress] forKey:@"progress"];
    [dict setObject:[NSNumber numberWithBool:aAnimated] forKey: @"animated"];
    
    return [dict copy];
}




// This is the new global spinner that is controlled by notifivations
-(id)initStatic
{


    self = [super init];
    if (self) {
        // Initialization code
        
        
        [self setFrame:[UIApplication sharedApplication].keyWindow.rootViewController.view.bounds];
        
        
        UIImageView *background = [[UIImageView alloc] initWithImage:[self addBackground]];
        background.alpha = 0.7;
      [self addSubview:background];
        
        
        indicator =
        [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge] ;
        // Set the resizing mask so it's not stretched
        indicator.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin;
        // Place it in the middle of the view
        indicator.center = self.center;
        [self addSubview:indicator];
        
        // progress bar
        
        progressBar                         = [[UIProgressView alloc] initWithFrame:CGRectMake(300,450,400,100)];
        progressBar.progress                = 0.0;
        progressBar.progressTintColor       = PRIMARY_APP_COLOR;
        progressBar.bounds                  = CGRectMake(progressBar.bounds.origin.x, progressBar.bounds.origin.y, 400, 30);
        [progressBar setProgressViewStyle:UIProgressViewStyleBar];
       [self addSubview:progressBar];
        
        
        
        // build message area
        progressMessage                     = [[UILabel alloc] initWithFrame:CGRectMake(315, 455, 400, 30)];
        progressMessage.text                = @"";
        progressMessage.textColor           = [UIColor whiteColor];
        progressMessage.backgroundColor     = [UIColor clearColor];
        progressMessage.textAlignment       = NSTextAlignmentCenter;
        progressMessage.bounds              = CGRectMake(progressMessage.bounds.origin.x, progressMessage.bounds.origin.y, 400, 30);
        [self addSubview:progressMessage];
        
        

//       __block SpinnerView * weakSelf;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOpenSpinner:) name:NOTIF_OPEN_SPINNER object:nil];
        
        openObserver = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_OPEN_SPINNER object:nil queue:nil usingBlock:^(NSNotification *note) {
            UIView * theApp = [UIApplication sharedApplication].keyWindow.rootViewController.view;
            
            [theApp addSubview:instance];
//            if (!blurEffect) {
//                 UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//                blurEffect = [[UIVisualEffectView alloc]initWithEffect:effect];
//                blurEffect.frame = CGRectMake(100, 100, 100, 100);
//                
//                [instance addSubview:blurEffect];
//                blurEffect.layer.borderWidth = 1;
//            }
            
            
            
            [indicator startAnimating];
            CATransition *animation = [CATransition animation];
            animation.type = kCATransitionFade;
//            NSLog(@"Global Spinner OPEN");
            
            if ([note.userInfo objectForKey:@"message"]){
                progressMessage.text = [note.userInfo objectForKey:@"message"];
            
            }
            if ([note.userInfo objectForKey:@"progress"]){
                [progressBar setProgress:[[note.userInfo objectForKey:@"progress"]floatValue]
                                animated:[[note.userInfo objectForKey:@"animated"]boolValue]];
            }
            theApp.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        }];
        
        closeObserver = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_CLOSE_SPINNER object:nil queue:nil usingBlock:^(NSNotification *note) {
            instance.superview.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            [indicator stopAnimating];
            [instance removeFromSuperview];

        }];
        
        
        updateObserver = [[NSNotificationCenter defaultCenter]addObserverForName:NOTIF_UPDATE_SPINNER object:nil queue:nil usingBlock:^(NSNotification *note) {
            if ([note.userInfo objectForKey:@"message"]){
                progressMessage.text = [note.userInfo objectForKey:@"message"];
                
            }
            if ([note.userInfo objectForKey:@"progress"]){

                [progressBar setProgress:[[note.userInfo objectForKey:@"progress"]floatValue]
                                animated:[[note.userInfo objectForKey:@"animated"]boolValue]];
            }
        }];
        
//        if (!blurEffect) {
//            UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//            blurEffect = [[UIVisualEffectView alloc]initWithEffect:effect];
//            blurEffect.frame = CGRectMake(300, 200, 200, 200);
//            
//            [self addSubview:blurEffect];
//            blurEffect.layer.borderWidth = 1;
//        }

    }
    return self;

    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)onOpenSpinner:(NSNotification*)note
{

    UIView * theApp = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    [theApp addSubview:instance];
//    if (blurEffect) {
//        
//        blurEffect = nil;
//        UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        blurEffect = [[UIVisualEffectView alloc]initWithEffect:effect];
//        blurEffect.frame = CGRectMake(300, 100, 400, 400);
//        
//        [instance addSubview:blurEffect];
//        blurEffect.layer.borderWidth = 1;
//    }
//    
    
    
    [indicator startAnimating];
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    //            NSLog(@"Global Spinner OPEN");
    
    if ([note.userInfo objectForKey:@"message"]){
        progressMessage.text = [note.userInfo objectForKey:@"message"];
        
    }
    if ([note.userInfo objectForKey:@"progress"]){
        [progressBar setProgress:[[note.userInfo objectForKey:@"progress"]floatValue]
                        animated:[[note.userInfo objectForKey:@"animated"]boolValue]];
    }
    theApp.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;


}





+(SpinnerView *)loadSpinnerIntoView:(UIView *)superView{
	// Create a new view with the same frame size as the superView
	SpinnerView *spinnerView = [[SpinnerView alloc] initWithFrame:superView.bounds] ;
	// If something's gone wrong, abort!
	if(!spinnerView){ return nil; }
    // Create a new image view, from the image made by our gradient method
    UIImageView *background = [[UIImageView alloc] initWithImage:[spinnerView addBackground]];
	// Make a little bit of the superView show through
    background.alpha = 0.7;
    [spinnerView addSubview:background];
    
    
    UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge] ;
	// Set the resizing mask so it's not stretched
    indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
	// Place it in the middle of the view
    indicator.center = spinnerView.center;
	// Add it into the spinnerView
    [spinnerView addSubview:indicator];
	// Start it spinning! Don't miss this step
	[indicator startAnimating];
	[superView addSubview:spinnerView];
    // Create a new animation
    CATransition *animation = [CATransition animation];
	// Set the type to a nice wee fade
    animation.type = kCATransitionFade;

	return spinnerView;
}

- (UIImage *)addBackground{
	// Create an image context (think of this as a canvas for our masterpiece) the same size as the view
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
	// Our gradient only has two locations - start and finish. More complex gradients might have more colours
//    size_t num_locations = 2;
	// The location of the colors is at the start and end
//    CGFloat locations[2] = { 0.0, 1.0 };
	// These are the colors! That's two RBGA values
//    CGFloat components[8] = {
//        0.4,0.4,0.4, 0.8,
//        0.1,0.1,0.1, 0.5 };
	// Create a color space
    CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	// Create a gradient with the values we've set up
//    CGGradientRef myGradient = CGGradientCreateWithColorComponents (myColorspace, components, locations, num_locations);
	// Set the radius to a nice size, 80% of the width. You can adjust this
//    float myRadius = (self.bounds.size.width*.8)/2;
	// Now we draw the gradient into the context. Think painting onto the canvas
//    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, self.center, 0, self.center, myRadius, kCGGradientDrawsAfterEndLocation);
	// Rip the 'canvas' into a UIImage object
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	// And release memory
    CGColorSpaceRelease(myColorspace);
//    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
	// … obvious.
    return image;
}

-(void)removeSpinner{
    // Add this in at the top of the method. If you place it after you've remove the view from the superView it won't work!
    
	// Take me the hells out of the superView!
	[super removeFromSuperview];
}


@end
