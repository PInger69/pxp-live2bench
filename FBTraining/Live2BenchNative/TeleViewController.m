//
//  TeleViewController.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-28.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "TeleViewController.h"
#import "FullScreenViewController.h"


#define LITTLE_ICON_DIMENSIONS     40
#define SELECTMARGIN            10.0f



@interface TeleViewController ()

@end

@implementation TeleViewController{
    
    UIImage *teleThumbImage;
    UIViewController <PxpVideoPlayerProtocol>    * videoPlayer;
}

@synthesize teleButton=_teleButton;
@synthesize offsetTime;
@synthesize timeScale;
@synthesize undoButton;
@synthesize clearButton;
@synthesize currentImage;
@synthesize thumbImageView;
static NSString * const BOUNDRY = @"0xKhTmLbOuNdArY";
static NSString * const FORM_FLE_INPUT = @"uploaded";


- (id)initWithController:(UIViewController <PxpVideoPlayerProtocol>    *)aVideoPlayer
{
    self = [super init];

    if (self) {
        videoPlayer = aVideoPlayer;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceCloseTele) name:@"Close Tele" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTeles) name:@"Save Tele" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearAll) name:@"Clear Tele" object:nil];

    
    //initialise the brush colour to blue and brush thickness/opacity
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 255.0/255.0;
    brush = 5.0;
    opacity = 1.0;
    [self setupView];
    [self.teleView setColourWithRed:red green:green blue:blue];
    //clearButton.transform=CGAffineTransformMakeRotation(M_PI/2);
    //saveButton.transform=CGAffineTransformMakeRotation(M_PI/2);
    isStraight=FALSE;
    
    //initialise touch points
    touchStart              = (CGPoint) { -1, -1 };
    touchCurrent            = (CGPoint) { -1, -1 };
    savedShapeStartpoint    = CGPointMake(0, 0);
    savedShapeEndpoint      = CGPointMake(0, 0);
    
//    globals.IS_TELE = TRUE;
//    
//    //get current time scale
//    timeScale = self.l2bVC.videoPlayer.avPlayer.currentTime.timescale;
//    if (timeScale < 1) {
//        timeScale = 600;
//    }
//    CMTime teleTime = CMTimeMakeWithSeconds(globals.TELE_TIME, timeScale);
//    
//     //if the mp4 video file was not downloaded to the local deveice.(Current event is live event or streaming past event from the server)
//    if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location == NSNotFound || globals.IS_IN_BOOKMARK_VIEW) {
//        if (globals.IS_IN_FIRST_VIEW) {
//            [self.l2bVC.videoPlayer pause];
//            //seek to an int time value, will make sure the review tele is accurate
//            [self.l2bVC.videoPlayer.avPlayer seekToTime:teleTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//            [self.l2bVC.videoPlayer pause];
//            //offsetTime = self.l2bVC.videoPlayer.startTime;
//            //globals.TELE_TIME = [self.l2bVC.videoPlayer currentTimeInSeconds];
//            //NSLog(@"Tele view controller globals.TELE_TIME %f",globals.TELE_TIME);
//            [self.l2bVC.teleButton setHidden:TRUE];
//        }else if(globals.IS_IN_LIST_VIEW){
//            [lvController.videoPlayer pause];
//            [lvController.videoPlayer.avPlayer seekToTime:teleTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//            [lvController.videoPlayer pause];
//            [lvController.teleButton setHidden:TRUE];
//        }else if(globals.IS_IN_BOOKMARK_VIEW){
//            [bmvController.videoPlayer pause];
//            //bookmark view's telestration won't be saved, do not need to seek to int time value to pause
//            
//            //[bmvController.videoPlayer.avPlayer seekToTime:CMTimeMakeWithSeconds(globals.TELE_TIME, 1.0) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
//            //[bmvController.videoPlayer.avPlayer pause];
//            [bmvController.teleButton setHidden:TRUE];
//            [saveButton setHidden:TRUE];
//        }
//
//
//    }else{
//        
//        if (globals.IS_IN_FIRST_VIEW) {
//            [self.l2bVC.teleButton setHidden:TRUE];
//        }else if(globals.IS_IN_LIST_VIEW){
//            [lvController.teleButton setHidden:TRUE];
//        }else if(globals.IS_IN_BOOKMARK_VIEW){
//            [bmvController.teleButton setHidden:TRUE];
//            [saveButton setHidden:TRUE];
//        }
//        
//
//    }
    
    
   
    // Do any additional setup after loading the view from its nib.
}


//when a tab is selected in fullcreen mode we have to close the telestration otherwise it will show up on top of the entire app
-(void)forceCloseTele
{
    if (![self.view superview]) return;
        
    self.teleView.isBlank = YES;
    [self.view removeFromSuperview];
    [self.teleView clearTelestration];
  
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCloseTeleView:)]) {
        [self.delegate onCloseTeleView:self];
    }
}

-(void)setupView
{

    self.view.frame = videoPlayer.view.frame;
//    self.teleView = [[TeleView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.height,self.view.frame.size.width)];
    self.teleView = [[TeleView alloc] initWithFrame:self.view.frame];
    [self.teleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    self.teleView.tvController = self;
    [self.view addSubview:self.teleView];
    [self.teleView setNeedsLayout];
    
    UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [redButton addTarget:self action:@selector(colorPicked:) forControlEvents:UIControlEventTouchUpInside];
//    [redButton setBackgroundImage:[UIImage imageNamed:@"red"] forState:UIControlStateNormal];
    [redButton setBackgroundColor:[UIColor redColor]];
    [redButton.layer setCornerRadius:24];
    [redButton setFrame:CGRectMake(972.0f, 450.0f, 45.0f, 45.0f)];
    [redButton setTag:0];
    [self.view addSubview:redButton];
    
    UIButton *greenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [greenButton addTarget:self action:@selector(colorPicked:) forControlEvents:UIControlEventTouchUpInside];
//    [greenButton setBackgroundImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
    [greenButton setBackgroundColor:[UIColor greenColor]];
    [greenButton.layer setCornerRadius:24];
    [greenButton setFrame:CGRectMake(redButton.frame.origin.x, CGRectGetMaxY(redButton.frame) + 5.0f, 45.0f, 45.0f)];
    [greenButton setTag:1];
    [self.view addSubview:greenButton];

    UIButton *blueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blueButton addTarget:self action:@selector(colorPicked:) forControlEvents:UIControlEventTouchUpInside];
//    [blueButton setBackgroundImage:[UIImage imageNamed:@"blue"] forState:UIControlStateNormal];
    [blueButton setBackgroundColor:[UIColor blueColor]];
    [blueButton.layer setCornerRadius:24];
    [blueButton setFrame:CGRectMake(greenButton.frame.origin.x, CGRectGetMaxY(greenButton.frame) + 5.0f, 45.0f, 45.0f)];
    [blueButton setTag:2];
    [blueButton setSelected:YES];
    [self.view addSubview:blueButton];
    
    undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [undoButton addTarget:self action:@selector(undoStroke) forControlEvents:UIControlEventTouchUpInside];
    [undoButton setBackgroundImage:[UIImage imageNamed:@"undoButton"] forState:UIControlStateNormal];
    [undoButton setBackgroundImage:[UIImage imageNamed:@"undoButtonSelect"] forState:UIControlStateHighlighted];
    [undoButton setFrame:CGRectMake(20.0f, 500.0f, 45.0f, 45.0f)];
    [undoButton setEnabled:NO];
    [self.view addSubview:undoButton];
    
    lineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lineButton addTarget:self action:@selector(colorPicked:) forControlEvents:UIControlEventTouchUpInside];
    [lineButton setFrame:CGRectMake(redButton.frame.origin.x - 50.0f, redButton.frame.origin.y, 45.0f, 45.0f)];
    [lineButton setImage:[UIImage imageNamed:@"lineButton"] forState:UIControlStateNormal];
    [lineButton setImage:[UIImage imageNamed:@"lineButtonSelect"] forState:UIControlStateSelected];
    [lineButton setTag:3];
    [self.view addSubview:lineButton];
    
    arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [arrowButton addTarget:self action:@selector(colorPicked:) forControlEvents:UIControlEventTouchUpInside];
    [arrowButton setFrame:CGRectMake(redButton.frame.origin.x - 50.0f, greenButton.frame.origin.y, 45.0f, 45.0f)];
    [arrowButton setImage:[UIImage imageNamed:@"arrowButton"] forState:UIControlStateNormal];
    [arrowButton setImage:[UIImage imageNamed:@"arrowButtonSelect"] forState:UIControlStateSelected];
    [arrowButton setTag:4];
    [self.view addSubview:arrowButton];
    
    focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [focusButton addTarget:self action:@selector(colorPicked:) forControlEvents:UIControlEventTouchUpInside];
    [focusButton setFrame:CGRectMake(redButton.frame.origin.x - 50.0f, blueButton.frame.origin.y, 45.0f, 45.0f)];
    [focusButton setImage:[UIImage imageNamed:@"lineButton"] forState:UIControlStateNormal];
    [focusButton setImage:[UIImage imageNamed:@"lineButtonSelect"] forState:UIControlStateSelected];
    [focusButton setTag:5];
    [self.view addSubview:focusButton];
    [focusButton setHidden:YES];
    
    self.colourIndicator = [[UIView alloc] initWithFrame:CGRectMake(blueButton.frame.origin.x - 1.0f, blueButton.frame.origin.y - 1.0f, blueButton.bounds.size.width + 2.0f, blueButton.bounds.size.height + 2.0f)];
    [self.colourIndicator.layer setCornerRadius:26];
    [self.colourIndicator setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.colourIndicator];
    [self.view sendSubviewToBack:self.colourIndicator];
    
     //if the mp4 video file was not downloaded to the local deveice.(Current event is live event or streaming past event from the server)
//    if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location == NSNotFound  || globals.IS_IN_BOOKMARK_VIEW) {
//
//        saveButton = [BorderButton buttonWithType:UIButtonTypeCustom];
//        [saveButton setFrame:CGRectMake(377.0f, 695.0f, 123.0f, 33.0f)];
//        //[saveButton setBackgroundImage:[UIImage imageNamed:@"tab-bar"] forState:UIControlStateNormal];
//        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
//        [saveButton addTarget:self action:@selector(saveTeles) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:saveButton];
//        
//        clearButton = [BorderButton buttonWithType:UIButtonTypeCustom];
//        [clearButton setFrame:CGRectMake(CGRectGetMaxX(saveButton.frame) + 15.0f, saveButton.frame.origin.y, 123.0f, 33.0f)];
//        //[clearButton setBackgroundImage:[UIImage imageNamed:@"tab-bar"] forState:UIControlStateNormal];
//        [clearButton setTitle:@"Close" forState:UIControlStateNormal];
//        [clearButton addTarget:self action:@selector(clearAll) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:clearButton];
//
//    }
}



/*
-(int)roundValue:(float)numberToRound{
    numberToRound = numberToRound;
    if (globals.IS_IN_FIRST_VIEW && self.l2bVC.videoPlayer.duration - numberToRound < 2) {
        return (int)numberToRound;
    }else if (globals.IS_IN_LIST_VIEW && lvController.videoPlayer.duration - numberToRound < 2) {
        return (int)numberToRound;
    }else if(globals.IS_IN_BOOKMARK_VIEW && bmvController.videoPlayer.duration - numberToRound < 2){
        return (int)numberToRound;
    }
    
    return  (int)(numberToRound + 0.5);
    
}
*/


- (void)saveTeles
{
    [self.teleView saveTelestration];
    teleImage = self.teleView.teleImage;
    [self.fullScreenViewController.player play];
//    globals.IS_TELE=FALSE;
    [self.view removeFromSuperview];
    NSDictionary *dict = @{@"name":@"Telestration", @"time":[NSString stringWithFormat:@"%f", [self.fullScreenViewController.player currentTimeInSeconds] + 0.3], @"image": teleImage};
    PXPLog(@"The dict to create the tele image is %@", dict);
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_CREATE_TELE_TAG object:nil userInfo:dict]; // MOVE TO ITS DELEGATE
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSaveTeleView:tagData:)]) {
        [self.delegate onSaveTeleView:self tagData:dict];
    }
    
    
//    if (globals.IS_IN_FIRST_VIEW) {
//        [self.l2bVC.videoPlayer play];
//        [self.l2bVC showFullScreenOverlayButtons];
//
//        if(!teleImage){
//            //if no tele made, press save button, make sure the video begins to play
//            [self.l2bVC.videoPlayer play];
//            return;
//        }
//    }else if(globals.IS_IN_LIST_VIEW){
//        [lvController.videoPlayer play];
//        [lvController showTeleButton];
//        [lvController.saveTeleButton removeFromSuperview];
//        [lvController.clearTeleButton removeFromSuperview];
//        if (globals.IS_LOOP_MODE) {
//            [lvController showFullScreenOverlayButtonsinLoopMode];
//        }else{
//            [lvController showFullScreenOverlayButtons];
//        }
//        
//        if(!teleImage)
//        {
//            //if no tele made, press save button, make sure the video begins to play
//            [lvController.videoPlayer play];
//            return;
//        }
//        
//    }else if(globals.IS_IN_BOOKMARK_VIEW){
//        [bmvController.videoPlayer play];
//        [bmvController showTeleButton];
//        [bmvController showFullScreenOverlayButtons];
//        
//        if(!teleImage)
//        {
//            //if no tele made, press save button, make sure the video begins to play
//            [bmvController.videoPlayer play];
//            return;
//        }
//        
//
//    }
//    globals.DID_CREATE_NEW_TAG=TRUE;
////<<<<<<< Updated upstream
//    //UIImage *teleImage=[self.mainImage.image rotate:UIImageOrientationLeft];
//    CGSize newSize = CGSizeMake(1024, 768);
//    UIGraphicsBeginImageContext( newSize );
//    [teleImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    //using the paused time will help seeking to the accurate time when reviewing telestration
//    NSString *tagTime = [NSString stringWithFormat:@"%f",globals.TELE_TIME - offsetTime];//CMTimeGetSeconds(pausedTime)];
//    
////=======
////    UIImage *teleImage = self.mainImage.image;
////>>>>>>> Stashed changes
//    NSMutableDictionary *dict;
//   
//    //if the mp4 video file was not downloaded to the local deveice.(Current event is live event or streaming past event from the server)
//    if ([globals.CURRENT_PLAYBACK_EVENT rangeOfString:@".mp4"].location == NSNotFound) {
//        // UIImage *teleImage = self.mainImage.image;
//        [self sendTagToServer:teleImage];
//        
//    }else{
//         //tag time is for playing telestration
//        float tagTimeF = globals.TELE_TIME; //CMTimeGetSeconds(cm_time);
//        NSString *tagTime = [NSString stringWithFormat:@"%f",tagTimeF];
//        NSUInteger dTotalSeconds = tagTimeF; //CMTimeGetSeconds(cm_time);
//        NSUInteger dHours = floor(dTotalSeconds / 3600);
//        NSUInteger dMinutes = floor(dTotalSeconds % 3600 / 60);
//        NSUInteger dSeconds = floor(dTotalSeconds % 3600 % 60);
//        NSString *displayTime = [NSString stringWithFormat:@"%i:%02i:%02i",dHours, dMinutes, dSeconds];
//        
//        if (!globals.HAS_MIN || !globals.eventExistsOnServer) {
//            dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",@"telestration",@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", tagTime, @"id", @"1",@"duration",@"4",@"type", displayTime,@"displaytime", @"1", @"local", nil];
//        }else{
//            dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",@"telestration",@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time", tagTime, @"id", @"1",@"duration",@"4",@"type", displayTime,@"displaytime", nil];
//        }
//        
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                                 (unsigned long)NULL), ^(void) {
//            BOOL isDir;
//            if(![[NSFileManager defaultManager] fileExistsAtPath:globals.THUMBNAILS_PATH isDirectory:&isDir])
//            {
//                [[NSFileManager defaultManager] createDirectoryAtPath:globals.THUMBNAILS_PATH withIntermediateDirectories:YES attributes:nil error:NULL];
//            }
//
//            //create tag marker for the new tag
////            [self.l2bVC markTagAtTime:[[dict objectForKey:@"time"] floatValue] colour:[uController colorWithHexString:[globals.ACCOUNT_INFO objectForKey:@"tagColour"]] tagID:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
//       
//            CGSize newSize = CGSizeMake(1024, 1024*9/16);
//            
//            // create a new bitmap image context at the device resolution (retina/non-retina)
//            UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
//            
//            // get context
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            
//            // push context to make it current
//            // (need to do this manually because we are not drawing in a UIView)
//            UIGraphicsPushContext(context);
//            
//            // drawing code comes here- look at CGContext referenc
//            // for available operations
//            // this example draws the inputImage into the context
//            [self.currentImage drawInRect:self.view.frame blendMode:kCGBlendModeNormal alpha:1.0];
//            [teleImage drawInRect:CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
//            //[thumbnail drawInRect:CGRectMake(0, 0, MEDIA_PLAYER_WIDTH, MEDIA_PLAYER_HEIGHT) blendMode:kCGBlendModeNormal alpha:0.8];        // pop context
//            UIGraphicsPopContext();
//            
//            // get a UIImage from the image context- enjoy!!!
//            teleThumbImage = UIGraphicsGetImageFromCurrentImageContext();
//
//            NSString *teleImageName = [NSString stringWithFormat:@"tl%@.png",[dict objectForKey:@"id"]];
//            NSString *thumbImageName = [NSString stringWithFormat:@"tn%@.jpg",[dict objectForKey:@"id"]];
//            NSData *imageData = UIImagePNGRepresentation(teleThumbImage);// newImage
//            NSData *thumbData = UIImageJPEGRepresentation(teleThumbImage, 0.4);
//            //NSData *thumbData = UIImagePNGRepresentation(thumbnail);
//            //add image to directory
//            NSString *teleFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",teleImageName]];
//            NSString *thumbFilePath = [globals.THUMBNAILS_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",thumbImageName]];
//            
//            [imageData writeToFile:teleFilePath atomically:YES ];
//            [thumbData writeToFile:thumbFilePath atomically:YES];
//            [dict setObject:teleFilePath forKey:@"teleurl"];
//            [dict setObject:thumbFilePath forKey:@"url"];
//            //NSDictionary *toSave = [[NSDictionary alloc] initWithDictionary: dict];
//            //save tag information in global dictionary
//            [globals.CURRENT_EVENT_THUMBNAILS setObject:dict forKey:[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]]];
//        });
//        
//        if (globals.HAS_MIN && globals.eventExistsOnServer) {
//            [self sendTagToServer:teleThumbImage];
//        }
//    }
//    
////<<<<<<< Updated upstream
////    NSString *dataPath = [globals.THUMBNAILS_PATH  stringByAppendingPathComponent:@"/teles"];
////    NSError* err;
////    //create thumbnail directory in documents directory
////    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
////        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&err];
////    }
////    
////    //add image to directory - For testing only
////    NSString *filePath = [dataPath stringByAppendingPathComponent:@"/tele.png"];
////    NSData* data = UIImagePNGRepresentation(teleImage);
////    [data writeToFile:filePath atomically:YES];
////    
////=======
////>>>>>>> Stashed changes
//    [self.l2bVC.videoPlayer play];
}

-(void)sendTagToServer:(UIImage*) teleImage{
    
//    CGSize newSize = CGSizeMake(1024, 768);
//    UIGraphicsBeginImageContext( newSize );
//    [teleImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    //using the paused time will help seeking to the accurate time when reviewing telestration
//    NSString *tagTime = [NSString stringWithFormat:@"%f",globals.TELE_TIME - offsetTime];//CMTimeGetSeconds(pausedTime)];
//    
//    //current absolute time in seconds
//    double currentSystemTime = CACurrentMediaTime();
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:globals.EVENT_NAME,@"event",@"telestration",@"name",[globals.ACCOUNT_INFO objectForKey:@"tagColour"],@"colour",[NSString stringWithFormat:@"%f",currentSystemTime],@"requesttime",[globals.ACCOUNT_INFO objectForKey:@"hid"],@"user",tagTime,@"time",@"1",@"duration",@"4",@"type",nil];
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
//    NSString *jsonString;
//    if (! jsonData) {
//        
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/min/ajax/teleset",globals.URL]]
//                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                            timeoutInterval:60];
//    //create post request
//    [request setHTTPMethod:@"POST"];
//    NSString *boundary = @"----WebKitFormBoundarycC4YiaUFwM44F6rT";
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
//    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
//    NSMutableData *body = [NSMutableData data];
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[@"Content-Disposition: form-data; name=tag\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    // [body appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
//    // Now we need to append the different data 'segments'. We first start by adding the boundary.
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[@"Content-Disposition: form-data; name=file; filename=picture.png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    // We now need to tell the receiver what content type we have
//    // In my case it's a png image. If you have a jpg, set it to 'image/jpg'
//    [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    // Now we append the actual image data
//    [body appendData:[NSData dataWithData:UIImagePNGRepresentation(tempImage)]];
//    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    // and again the delimiting boundary
//    //NSString *tempstr =[[NSString alloc]initWithData:body encoding:NSStringEncodingConversionAllowLossy];
//    [request setHTTPBody:body];
//    NSArray *objects = [[NSArray alloc]initWithObjects:[NSValue valueWithPointer:nil],self, nil];
//    NSArray *keys = [[NSArray alloc]initWithObjects:@"callback",@"controller", nil];
//    NSDictionary *instObj = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    
//    NSString * foo = [[NSString alloc]initWithData:body encoding:NSASCIIStringEncoding]; // used to ////////NSLog appqueue response
//    ////////NSLog(@"jjson -- %@",foo);
//    [globals.APP_QUEUE enqueue:request dict:instObj];
//    
////    NSString *dataPath = [globals.THUMBNAILS_PATH  stringByAppendingPathComponent:@"/teles"];
////    NSError* err;
////    //create thumbnail directory in documents directory
////    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
////        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&err];
////    }
////    
////    //add image to directory - For testing only
////    NSString *filePath = [dataPath stringByAppendingPathComponent:@"/tele.png"];
////    NSData* data = UIImagePNGRepresentation(self.mainImage.image);
////    [data writeToFile:filePath atomically:YES];
//    

}

- (void)checkUndoState {
    if ([self.teleView hasUndoState]) {
        [self.undoButton setEnabled:YES];
    } else {
        [self.undoButton setEnabled:NO];
    }
    if ([self.teleView isEmptyCanvas]) {
        [clearButton setTitle:@"Close" forState:UIControlStateNormal];
    } else {
        [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    }
}
//    UITouch *touch = [touches anyObject];
//    lastPoint = [touch previousLocationInView:self.view];
//    lastPoint2 = [touch previousLocationInView:self.view];
//    currentPoint = [touch locationInView:self.view];
//    
//    if(currentPoint.y<50)
//    {
//        return;
//    }
//    originPoint =[touch locationInView:self.view];
/*
//TODO: comment out straight line, need to add later
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //isStraight=TRUE;
    UITouch *touch = [touches anyObject];

    lastPoint2 = lastPoint;
    lastPoint = [touch previousLocationInView:self.view];
    currentPoint = [touch locationInView:self.view];
    
    if(currentPoint.y<50)
    {
        return;
    }
    if(!isStraight)
    {
        UIGraphicsBeginImageContext(self.mainImage.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint mid1 = midPoint(lastPoint, lastPoint2);
    CGPoint mid2 = midPoint(currentPoint, lastPoint);
    
    
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
    
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    // Use QuadCurve is the key
    CGContextAddQuadCurveToPoint(context, lastPoint.x, lastPoint.y, mid2.x, mid2.y);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, brush);
    CGContextSetRGBStrokeColor(context,red, green, blue, 1.0);
    CGContextStrokePath(context);
    
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    }else{
        UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClosePath(context);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, originPoint.x, originPoint.y);
        CGContextAddLineToPoint(context,currentPoint.x, currentPoint.y);
        CGContextSetLineWidth(context, brush);
        CGContextSetRGBStrokeColor(context,red, green, blue, 1.0);
        
        CGContextStrokePath(context);
        //[self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
}
*/
-(void)colorPicked:(id)sender
{
    CustomButton * PressedButton = (CustomButton*)sender;
    BOOL shouldAnimate = false;

    switch(PressedButton.tag)
    {
        case 0:
            shouldAnimate = YES;
            red = 255.0f/255.0f;
            green = 0.0f/255.0f;
            blue = 0.0f/255.0f;
            break;
        case 1:
            shouldAnimate = YES;
            red = 0.0f/255.0f;
            green = 255.0f/255.0f;
            blue = 0.0f/255.0f;
            break;
        case 2:
            shouldAnimate = YES;
            red = 0.0f/255.0f;
            green = 0.0f/255.0f;
            blue = 255.0f/255.0f;
            break;
        case 3:
            [lineButton setSelected:![lineButton isSelected]];
            self.teleView.isStraight = [lineButton isSelected];
            break;
        case 4:
            [arrowButton setSelected:![arrowButton isSelected]];
            self.teleView.isArrow = [arrowButton isSelected];
            break;
//        case 5:
//            [focusButton setSelected:![focusButton isSelected]];
//            self.teleView.isFocus = [focusButton isSelected];
//            break;
    }
    if (shouldAnimate){
        [UIView animateWithDuration:0.1 animations:^{
            [self.colourIndicator setFrame:CGRectMake(PressedButton.frame.origin.x - 1.0f, PressedButton.frame.origin.y - 1.0f, self.colourIndicator.bounds.size.width, self.colourIndicator.bounds.size.height)];
        }];
    }
    [self.teleView setColourWithRed:red green:green blue:blue];
}

- (void)undoStroke {
    if ([self.teleView hasUndoState]) {
        [undoButton setEnabled:YES];
    } else {
        [undoButton setEnabled:NO];
    }
    [self.teleView undoStroke];
}
/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!isStraight)
    {
    if(!mouseSwiped) {
        UITouch *touch = [touches anyObject];

        currentPoint = [touch locationInView:self.view];
        
        if(currentPoint.y<50)
        {
            return;
        }
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    }
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
  

    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}
*/

-(void)clearAll
{
//    NSLog(@"isBlank: %@",self.teleView.isBlank ? @"yes" : @"no");
//    if (self.teleView.isBlank) {
//        globals.IS_TELE=FALSE;
//        if (globals.IS_IN_FIRST_VIEW) {
//            [self.l2bVC showFullScreenOverlayButtons];
//            [self.l2bVC.videoPlayer play];
////            [self.l2bVC.saveTeleButton removeFromSuperview];
////            [self.l2bVC.clearTeleButton removeFromSuperview];
//            [self.view removeFromSuperview];
//            [self.l2bVC.videoPlayer play];
//        }else if(globals.IS_IN_LIST_VIEW){
//            [self.lvController.saveTeleButton removeFromSuperview];
//            [self.lvController.clearTeleButton removeFromSuperview];
//            if (globals.IS_LOOP_MODE) {
//                [lvController showFullScreenOverlayButtonsinLoopMode];
//            }else{
//                [lvController showFullScreenOverlayButtons];
//            }
//            [lvController showTeleButton];
//            [lvController.videoPlayer play];
//        }else if (globals.IS_IN_BOOKMARK_VIEW){
//            [bmvController showFullScreenOverlayButtons];
//            [bmvController showTeleButton];
//            [bmvController.videoPlayer play];
//        }
//        [self.view removeFromSuperview];
//        [self.teleView removeFromSuperview];
//        self.teleView = nil;
//    }else{
//        [clearButton setTitle:@"Close" forState:UIControlStateNormal];
//        [self.teleView clearTelestration];
//    }
//   
}


CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (void)didReceiveMemoryWarning
{
     [super didReceiveMemoryWarning];
    [self.teleView didReceiveMemoryWarning];
    PXPLog(@"*** didReceiveMemoryWarning ***");
}



-(void) startTelestration{
  //  NSInteger vpIndex =     [self.fullScreenViewController.view.subviews indexOfObject: self.fullScreenViewController.player.view];
    

//    [self.fullScreenViewController.view insertSubview:self.view atIndex:vpIndex+1];
    [videoPlayer.view addSubview:self.view];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onOpenTeleView:)]) {
        [self.delegate onOpenTeleView:self];
    }
    
}

@end
