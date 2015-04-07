//
//  ScreenController.m
//  Live2BenchNative
//
//  Created by dev on 9/9/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ScreenController.h"
#import "AirPlayDetector.h"
#import "PxpVideoPlayerProtocol.h"
#import "LogoViewController.h"


//@interface UIViewController (rotationStuff)
//
//@end
//
//@implementation UIViewController (rotationStuff)
//
//-(BOOL)shouldAutorotate{
//    return YES;
//}
//
//@end

@interface ScreenController()

@property (strong, nonatomic) LogoViewController *logoViewController;

@end


@implementation ScreenController
{
    UIScreen        * screenTwo;
    UIWindow        * externalWindow;
    AirPlayDetector * detector;
    CGRect          screenBounds;
    
    UIView          * debugPanel;
    UIImageView     *anotherImage;
    
    UIViewController<PxpVideoPlayerProtocol> * videoPlayer;
    int             prevDispayIndex;
    CGRect          prevPlayerViewRect;
    CGRect          prevPlayerViewBounds;
    CGRect          prevPlayerLayerRect;
    CGRect          prevPlayerLayerBounds;
    UIView          * prevView;
    UIImageView     * placeHolder;
    AVPlayerLayer   * externalScreenLayer;
    //BOOL            doesScreenMirroring;
    
}

//@synthesize view;
@synthesize screenDetected;

-(id)init
{
    self = [super init];
    if (self){
        self.doesScreenMirroring = YES;
        
        screenDetected = ([UIScreen screens].count > 1)?TRUE:FALSE;
        self.enableDisplay = FALSE;
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(screenDidConnect:)
         name:UIScreenDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(screenDidDisconnect:)
         name:UIScreenDidDisconnectNotification object:nil];
        
        self.viewController = [[UIViewController alloc]init];
        self.viewController.view.layer.backgroundColor = [UIColor blueColor].CGColor;
        UIImageView *viewControllerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default-Landscape.png"]];
        self.viewController.view = viewControllerView;
        self.logoViewController = [[LogoViewController alloc] init];
        anotherImage = [[UIImageView alloc] init];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTabChange:) name:NOTIF_SWITCH_MAIN_TAB object:nil];
        placeHolder = [self _buildPlaceHolder];
        // faking a notification because if a screen was attached before it could be detected
        if (screenDetected) [self screenDidConnect:[[NSNotification alloc]initWithName:NOTIF_SWITCH_MAIN_TAB object:[[UIScreen screens] objectAtIndex:1] userInfo:nil]];
        [ExternalScreenButton setAllHidden:!screenDetected];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenMirroringValue:) name:@"Setting - Screen Mirroring" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addImageToExternal:) name:NOTIF_POST_ON_EXTERNAL_SCREEN object:nil];
    }
    return self;
}

-(void)addImageToExternal: (NSNotification *) note{
    [anotherImage setFrame: screenBounds];
    [anotherImage setImage: note.object];
    [self.viewController.view addSubview: anotherImage];
}

-(void)screenMirroringValue: (NSNotification *)note{
    BOOL newValue = [note.userInfo[@"Value"] boolValue];
    self.doesScreenMirroring = newValue;
    
    if (self.doesScreenMirroring) {
        externalWindow = nil;
        
    }else if([UIScreen screens].count > 1){
        externalWindow = [self _buildExternalScreen:screenBounds screen:screenTwo];
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CLIPVIEW_TAG_RECEIVED object:nil userInfo:@{@"name" : [NSString stringWithFormat:@"%@", newValue?@"True":@"False"]}];
}

/**
 *  This is the rect that will fill the place of the videoPlayer when it moves, purely asthetic
 *
 *  @return placeHolder
 */
-(UIImageView*)_buildPlaceHolder
{
    UIImageView* img = [[UIImageView alloc]init];
    [img setBackgroundColor:[UIColor darkGrayColor]];
    return img;
}



-(void)screenDidConnect:(NSNotification*)aNotification
{
    screenDetected = ([UIScreen screens].count > 1)?TRUE:FALSE;
    [ExternalScreenButton setAllHidden:!screenDetected];
    screenTwo     = [aNotification object];
    screenBounds    = screenTwo.bounds;
    
    [self.viewController.view setFrame:screenBounds];
    
    if(!detector) detector      = [[AirPlayDetector alloc]init];
    
    //    UIAlertView *alert;
    //    NSString * msg = ([detector isAirPlayAvailable])?@"-Airplay Found!-":@"-Airplay NOT Found!-";
    //    alert = [[UIAlertView alloc] initWithTitle:@"screenDidConnect" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Okay",nil];
    //    [alert show];
    
    
    if (!externalWindow && !self.doesScreenMirroring) {
        externalWindow    = [self _buildExternalScreen:screenBounds screen:screenTwo];
        //        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"ScreenFound" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Say Hello",nil];
        //        [alert1 show];
        
        //        externalWindow          = [[UIWindow alloc] initWithFrame:screenBounds];
        //        externalWindow.screen   = screenTwo;
        //        [detector startMonitoring:externalWindow];
        //        [externalWindow addSubview:view];
        //        externalWindow.hidden = NO;
        //        [detector startMonitoring:externalWindow];
    }
    
    
}

-(UIWindow *)_buildExternalScreen:(CGRect)bounds screen:(UIScreen*)secondScreen
{
    UIWindow * window           = [[UIWindow alloc] initWithFrame:bounds];
    window.screen               = secondScreen;
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        CGRect frame = window.frame;
        frame.size.width = window.frame.size.height;
        frame.size.height = window.frame.size.width;
        window.frame = frame;
        
        self.viewController = [[UIViewController alloc]init];
        self.viewController.view.layer.backgroundColor = [UIColor blueColor].CGColor;
        UIImageView *viewControllerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Default-Landscape.png"]];
        self.viewController.view = viewControllerView;
        self.viewController.view.transform = CGAffineTransformMakeRotation(-(3.14/2));
    }
    
    window.rootViewController = self.viewController;
    window.hidden = NO;
    //[detector startMonitoring:window];
    return window;
}



-(void)screenDidDisconnect:(NSNotification*)aNotification
{
    screenDetected = ([UIScreen screens].count > 1)?TRUE:FALSE;
    [ExternalScreenButton setAllHidden:!screenDetected];
    if (detector){
        [detector destroy];
    }
    if (screenDetected) externalWindow = nil;
    //NSString * count = [NSString stringWithFormat:@"%i",[UIScreen screens].count];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"screenDidDisconnect" message:count delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Say Hello",nil];
    //    [alert show];
    //    [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:NOTIF_SWITCH_MAIN_TAB];
}

/*
 - (void)checkForExistingScreenAndInitializeIfPresent
 {
 if ([[UIScreen screens] count] > 1)
 {
 // Associate the window with the second screen.
 // The main screen is always at index 0.
 UIScreen*    secondScreen = [[UIScreen screens] objectAtIndex:1];
 screenBounds = secondScreen.bounds;
 
 externalWindow = [[UIWindow alloc] initWithFrame:screenBounds];
 externalWindow.screen = secondScreen;
 
 // Add a white background to the window
 UIView*            whiteField = [[UIView alloc] initWithFrame:screenBounds];
 whiteField.backgroundColor = [UIColor whiteColor];
 
 [externalWindow addSubview:whiteField];
 
 
 // Center a label in the view.
 NSString*    noContentString = [NSString stringWithFormat:@"<no content>"];
 CGSize        stringSize = [noContentString sizeWithFont:[UIFont systemFontOfSize:18]];
 
 CGRect        labelSize = CGRectMake((screenBounds.size.width - stringSize.width) / 2.0,
 (screenBounds.size.height - stringSize.height) / 2.0,
 stringSize.width, stringSize.height);
 
 UILabel*    noContentLabel = [[UILabel alloc] initWithFrame:labelSize];
 noContentLabel.text = noContentString;
 noContentLabel.font = [UIFont systemFontOfSize:18];
 [whiteField addSubview:noContentLabel];
 
 // Go ahead and show the window.
 externalWindow.hidden = NO;
 }
 }
 */

-(UIView*)buildDebugPanel:(VideoPlayer *)video
{
    
    videoPlayer         = video;
    debugPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 50, 300, 100)];
    debugPanel.layer.borderWidth = 2;
    [debugPanel setBackgroundColor:[UIColor grayColor]];
    
    ExternalScreenButton * togg = [[ExternalScreenButton alloc]initWithFrame:CGRectMake(10, 10, 80, 50)];
    // [togg setFrame:CGRectMake(10, 10, 80, 50)];
    togg.layer.borderWidth = 2;
    [togg setTitle:@"ON/OFF" forState:UIControlStateNormal];
    [togg addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [debugPanel addSubview:togg];
    
    
    UIButton * btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn2 setFrame:CGRectMake(100, 10, 80, 50)];
    btn2.layer.borderWidth = 2;
    [btn2 setTitle:@"Normal" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(returnVideoToPreviousViewFromExternal) forControlEvents:UIControlEventTouchUpInside];
    [debugPanel addSubview:btn2];
    
    UIButton * btn3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn3 setFrame:CGRectMake(200, 10, 80, 50)];
    btn3.layer.borderWidth = 2;
    [btn3 setTitle:@"Push" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(debugMethodToPushVideoToExternal) forControlEvents:UIControlEventTouchUpInside];
    [debugPanel addSubview:btn3];
    
    return debugPanel;
}

-(void)toggle
{
    if (!screenDetected) return;
    
    if (externalWindow != nil){
        [self screenDidConnect:[[NSNotification alloc]initWithName:NOTIF_SWITCH_MAIN_TAB object:[[UIScreen screens] objectAtIndex:1] userInfo:nil]];
        [self returnVideoToPreviousViewFromExternal];
        externalWindow = nil;
    } else {
        externalWindow    = [self _buildExternalScreen:screenBounds screen:screenTwo];
        [self moveVideoToExternalDisplay:videoPlayer];
    }
}

-(void)debugMethodToPushVideoToExternal
{
    [self moveVideoToExternalDisplay:videoPlayer];
}

//-(void)moveVideoToExternalDisplay: (UIViewController <PxpVideoPlayerProtocol> *)VideoPlayer
//{
//     //if (videoPlayer.view.superview == self.viewController.view) return;
//    if([UIScreen screens].count ==1 || self.doesScreenMirroring)return;
//    // saving prev data
//    videoPlayer             = VideoPlayer;
//
//    AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
//    playerLayer.player = videoPlayer.avPlayer;
//    [CATransaction begin];
//    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//    playerLayer.frame = videoPlayer.view.bounds;
//    [CATransaction commit];
//    externalScreenLayer = playerLayer;
//
//    UIView *videoLayerView =[[UIView alloc]initWithFrame:videoPlayer.playBackView.bounds];
//    [videoLayerView.layer addSublayer:externalScreenLayer];
//    [videoPlayer.playBackView addSubview: videoLayerView];
//
//    [UIView animateWithDuration:0.25 animations:^{
//        CGRect offscreenFrame = videoPlayer.playBackView.bounds;
//        offscreenFrame.origin.y -= 400;
//        videoLayerView.frame = offscreenFrame;
//    } completion:^(BOOL finished) {
//        [self.viewController.view addSubview: videoLayerView];
//        CGRect largeOffScreenFrame = screenBounds;
//        largeOffScreenFrame.origin.y += largeOffScreenFrame.size.height;
//        videoLayerView.frame = largeOffScreenFrame;
//
//
//        [self.viewController.view.layer addSublayer: externalScreenLayer];
//
//        [CATransaction begin];
//        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//        externalScreenLayer.frame = screenBounds;
//        [CATransaction commit];
//
//
//        [UIView animateWithDuration: 0.25 animations:^{
//            videoLayerView.frame = screenBounds;
//
//        } completion:^(BOOL finished) {
//            [self.viewController.view.layer addSublayer: externalScreenLayer];
//            [videoLayerView removeFromSuperview];
//        }];
//    }];
//
//
//}


-(void)moveVideoToExternalDisplay: (UIViewController <PxpVideoPlayerProtocol> *)VideoPlayer
{
    //if (videoPlayer.view.superview == self.viewController.view) return;
    if([UIScreen screens].count ==1 || self.doesScreenMirroring)return;
    // saving prev data
    videoPlayer             = VideoPlayer;
    
    AVPlayerLayer *playerLayer = videoPlayer.playBackView.secondLayer;
    //playerLayer.player = videoPlayer.avPlayer;
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    playerLayer.frame = videoPlayer.view.bounds;
    [CATransaction commit];
    //[videoPlayer.playBackView.layer insertSublayer:playerLayer atIndex:0];
    //  externalScreenLayer = playerLayer;
    
    UIView *videoLayerView =[[UIView alloc]initWithFrame:videoPlayer.playBackView.bounds];
    [videoLayerView.layer addSublayer:playerLayer];
    [videoPlayer.playBackView addSubview: videoLayerView];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect offscreenFrame = videoPlayer.playBackView.bounds;
        offscreenFrame.origin.y -= 400;
        videoLayerView.frame = offscreenFrame;
    } completion:^(BOOL finished) {
        [self.viewController.view addSubview: videoLayerView];
        CGRect largeOffScreenFrame = screenBounds;
        largeOffScreenFrame.origin.y += largeOffScreenFrame.size.height;
        
        videoLayerView.frame = largeOffScreenFrame;
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        playerLayer.frame = screenBounds;
        [CATransaction commit];
        
        
        [UIView animateWithDuration: 0.25 animations:^{
            videoLayerView.frame = screenBounds;
            
        } completion:^(BOOL finished) {
            [self.viewController.view.layer addSublayer: playerLayer];
            [videoLayerView removeFromSuperview];
            
            externalScreenLayer = playerLayer;
            //videoPlayer.playBackView.videoLayer = playerLayer;
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIF_NEW_VIDEO_LAYER object: playerLayer];
    
}

-(void)returnVideoToPreviousViewFromExternal
{
    if([UIScreen screens].count ==1 || self.doesScreenMirroring)return;
    
    UIView *videoLayerView =[[UIView alloc]initWithFrame: screenBounds];
    [videoLayerView.layer addSublayer: externalScreenLayer];
    [self.viewController.view addSubview: videoLayerView];
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect largeOffScreenFrame = screenBounds;
        largeOffScreenFrame.origin.y += largeOffScreenFrame.size.height;
        videoLayerView.frame = largeOffScreenFrame;
    } completion:^(BOOL finished) {
        CGRect offscreenFrame = videoPlayer.playBackView.bounds;
        offscreenFrame.origin.y -= 400;
        videoLayerView.frame = offscreenFrame;
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        externalScreenLayer.frame = videoPlayer.playBackView.bounds;
        [CATransaction commit];
        
        [videoPlayer.playBackView addSubview: videoLayerView];
        
        
        [UIView animateWithDuration: 0.25 animations:^{
            videoLayerView.frame = videoPlayer.playBackView.bounds;
            
        } completion:^(BOOL finished) {
            [videoPlayer.playBackView.layer insertSublayer: externalScreenLayer atIndex:0];
            [videoLayerView removeFromSuperview];
        }];
    }];
    
    
    //[videoPlayer.playBackView.videoLayer removeFromSuperlayer];
    //[videoPlayer.playBackView.layer insertSublayer:videoPlayer.playBackView.videoLayer atIndex:0];
    
    
}

/**
 *  This will see if there is a main tab change so the external screen can be packed up
 *  The reason for this is that other code will break the positioning if the Screen is not packed up
 *
 *  @param notification
 */
-(void)onTabChange:(NSNotification *)notification {
    [self returnVideoToPreviousViewFromExternal];
}




-(BOOL)enableDisplay {
    
    return self.enableDisplay;
}


-(void)setenableDisplay:(BOOL)isSetToDisplay
{
    if (!screenDetected) {
        self.enableDisplay = FALSE;
        return;
    }
    
    self.enableDisplay = isSetToDisplay;
}

-(BOOL)isConnectionAirPlay
{
    return NO;
}


@end
