//
//  PxpLogViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-24.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "PxpLogViewController.h"
#import "PxpLog.h"
#import "CustomButton.h"
#import "EncoderManager.h"
#import "RicoPlayerPool.h"
//#import "EncoderProtocol.h"
#import "DeviceLog.h"
#import "EmailActivity.h"


@interface PxpLogViewController ()

@property (atomic, strong) UITextView *textView;
@property (nonatomic,strong)  CustomButton * clearButton;
@property (nonatomic,strong)  CustomButton * upButton;
@property (nonatomic,strong)  CustomButton * downButton;
@property (nonatomic,strong)  CustomButton * camButton;
@property (nonatomic,strong)  CustomButton * encoderButton;
@property (nonatomic,strong)  CustomButton * eventButton;
@property (nonatomic,strong)  CustomButton * crashButton;
@property (nonatomic,strong)  EmailActivity * logEmail;

@end

@implementation PxpLogViewController
{
    EncoderManager * encoderManager;
}


-(instancetype) initWithAppDelegate: (AppDelegate *) appDel{
    self = [super init];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame: CGRectZero];
        self.textView.backgroundColor   = [UIColor blackColor];
        self.textView.font              = [UIFont fontWithName:@"Courier" size:12.0];
        self.textView.editable          = NO;
        self.textView.delegate          = self;
        [self.textView setSelectable:YES];
        [self.textView setTextColor:[UIColor greenColor]];
        [[PxpLog getInstance] addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        
        self.clearButton = [[CustomButton alloc]init];
        self.clearButton.layer.borderWidth = 1;
        self.clearButton.layer.borderColor = [[UIColor grayColor]CGColor];
        [self.clearButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
        [self.clearButton addTarget:self action:@selector(onClear:) forControlEvents:UIControlEventTouchUpInside];
        
        self.upButton = [[CustomButton alloc]init];
        self.upButton.layer.borderWidth = 1;
        self.upButton.layer.borderColor = [[UIColor grayColor]CGColor];
        [self.upButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.upButton setTitle:@"Email Log" forState:UIControlStateNormal];
        [self.upButton addTarget:self action:@selector(emailLog:) forControlEvents:UIControlEventTouchUpInside];
        
        self.downButton = [[CustomButton alloc]init];
        self.downButton.layer.borderWidth = 1;
        self.downButton.layer.borderColor = [[UIColor grayColor]CGColor];
        [self.downButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.downButton setTitle:@"ClearDeviceLog" forState:UIControlStateNormal];
        [self.downButton addTarget:self action:@selector(onClearDevice:) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.camButton = [[CustomButton alloc]init];
        self.camButton.layer.borderWidth = 1;
        self.camButton.layer.borderColor = [[UIColor grayColor]CGColor];
        [self.camButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.camButton setTitle:@"Cam Data" forState:UIControlStateNormal];
        [self.camButton addTarget:self action:@selector(onCams:) forControlEvents:UIControlEventTouchUpInside];

        self.encoderButton = [[CustomButton alloc]init];
        self.encoderButton.layer.borderWidth = 1;
        self.encoderButton.layer.borderColor = [[UIColor grayColor]CGColor];
        [self.encoderButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.encoderButton setTitle:@"Encoder" forState:UIControlStateNormal];
        [self.encoderButton addTarget:self action:@selector(onEncoder:) forControlEvents:UIControlEventTouchUpInside];

        self.eventButton = [[CustomButton alloc]init];
        self.eventButton.layer.borderWidth = 1;
        self.eventButton.layer.borderColor = [[UIColor grayColor]CGColor];
        [self.eventButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.eventButton setTitle:@"Event" forState:UIControlStateNormal];
        [self.eventButton addTarget:self action:@selector(onEvent:) forControlEvents:UIControlEventTouchUpInside];

        self.crashButton = [[CustomButton alloc]init];
        self.crashButton.layer.borderWidth = 1;
        self.crashButton.layer.borderColor = [[UIColor grayColor]CGColor];
        [self.crashButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.crashButton setTitle:@"Tag" forState:UIControlStateNormal];
        [self.crashButton addTarget:self action:@selector(onTagDump:) forControlEvents:UIControlEventTouchUpInside];


        encoderManager = appDel.encoderManager;
    }
    
    return self;
}



-(void)viewDidLoad
{

    
    NSArray * buttons = @[self.clearButton,self.upButton,self.downButton,self.camButton,self.encoderButton,self.eventButton,self.crashButton];
    CGFloat buttonH = 50;
    CGFloat buttonW = 100;//self.view.bounds.size.width / [buttons count];
    CGRect r = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y+buttonH, 705, self.view.bounds.size.height-buttonH-50);
    
    for (NSInteger i=0; i<[buttons count]; i++) {
        CustomButton * b = buttons[i];
        [b setFrame:CGRectMake(i*buttonW, 0, buttonW, buttonH)];
        [self.view addSubview: b];
    }
    
    self.textView.frame = r;
    //self.textView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview: self.textView];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textView setText: [PxpLog getInstance].text];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.textView setText: @""];
}


-(void)onCrash:(id)sender
{
 [[Crashlytics sharedInstance] crash];
}

-(void)onCrashTop:(id)sender
{
    [[Crashlytics sharedInstance] crash];
}

-(void)onClear:(id)sender
{
    [PxpLog clear];
}
-(void)onClearDevice:(id)sender
{
    NSLog(@"onClearDevice");
    [PxpLog clearDeviceLog];
}


-(void)onScroll:(id)sender
{
    CustomButton * button = (CustomButton *)sender;
    
    if ([button.titleLabel.text isEqualToString:@"Top"]) {

        NSRange top = NSMakeRange(0, 1);
        [self.textView scrollRangeToVisible:top];


    } else {
        if(self.textView.text.length > 0 ) {
            NSRange bottom = NSMakeRange(self.textView.text.length -1, 1);
            [self.textView scrollRangeToVisible:bottom];
        }

    }
}

-(void)emailLog:(id)sender
{
    
//    [Utility hasInternetOnComplete:^(BOOL succsess) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            if ([Utility hasInternet]) {
                self.logEmail = [EmailActivity new];
                self.logEmail.presetingViewController = self;
                [self.logEmail launch];
            } else {
                
                    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_STATUS_LABEL_CHANGED object:self];
                    
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Pxp"
                                                                                    message:@"Internet not found."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                    // build NO button
                    UIAlertAction* cancelButtons = [UIAlertAction
                                                    actionWithTitle:OK_BUTTON_TXT
                                                    style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * action)
                                                    {
                                                        [[CustomAlertControllerQueue getInstance] dismissViewController:alert animated:YES completion:nil];
                                                    }];
                    [alert addAction:cancelButtons];
                    
                    [[CustomAlertControllerQueue getInstance] presentViewController:alert inController:ROOT_VIEW_CONTROLLER animated:YES style:AlertImportant completion:nil];
                    
                

            }
//        });
        
//    }];
 
}


-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(selectAll:))
        return YES;
    
    if (action == @selector(select:))
        return YES;
    
    if (action == @selector(cut:))
        return NO;
    
    if (action == @selector(copy:))
        return YES;
    
    if (action == @selector(paste:))
        return NO;
    return [super canPerformAction:action withSender:sender];


}

-(void)selectAll:(id)sender
{
    [self.textView selectAll:sender];
}

-(void)onCams:(id)sender
{

    Encoder * enc = (Encoder *)encoderManager.primaryEncoder;
    
    if (enc) {
        EncoderOperation * camOp = [[EncoderOperationCameraData alloc]initEncoder:enc data:nil];
        
        [enc runOperation:camOp];
        __weak Encoder * weakEncoder = enc;
        
        [camOp setOnRequestComplete:^(NSData *d, EncoderOperation *op) {
            if (!weakEncoder.cameraData){
                PXPLog(@"No primaryEncoder Found");
                PXPLog(@"   Check if an Event is playing");
            } else {
                
                
                for (NSString* key in [[RicoPlayerPool instance].defaultController.players allKeys]) {
                    RicoPlayer * asdf = (RicoPlayer *)[RicoPlayerPool instance].defaultController.players[key];
                    
                    
                    
                    AVURLAsset * ass = ((AVURLAsset *)asdf.avPlayer.currentItem.asset);
                    PXPLog(@"Player %@  Offset: %@",key,[NSString stringWithFormat:@"%f",CMTimeGetSeconds(asdf.offsetTime) ]);
                    PXPLog(@"  CR: %@   ",ass.URL);
                    PXPLog(@"  LQ: %@   ",((Feed*)asdf.feed).lqPath);
                    PXPLog(@"  HQ: %@   ",((Feed*)asdf.feed).hqPath);
                    PXPLog(@" ");
                }
                PXPLog(@" ");
                PXPLog(@"Camera Formats Match: %@",([op.encoder.cameraResource allCamerasHaveMatchingFormats])?@"TRUE":@"FALSE");
                
                NSDictionary    * results =[Utility JSONDatatoDict:d];
                NSArray * list = [results[@"camlist"]allValues];
                PXPLog(@"%@",list);
            }
        }];
        
        
//        [camOp setCompletionBlock:^{
//            if (!weakEncoder.cameraData){
//                PXPLog(@"No primaryEncoder Found");
//                PXPLog(@"   Check if an Event is playing");
//            } else {
//                PXPLog(@"%@",weakEncoder.cameraData);
//            }
//            
//        }];
        
    } else {
    
        PXPLog(@"No primaryEncoder Found");
        PXPLog(@"   Check if an Event is playing");
    
    }
    
    
    

    
    if ( [encoderManager.authenticatedEncoders count] && !enc){
        PXPLog(@"Displaying other cam data found on network...");
        for (Encoder * encItem in encoderManager.authenticatedEncoders) {
            PXPLog(@"%@",encItem);
            EncoderOperation * camOp1 = [[EncoderOperationCameraData alloc]initEncoder:encItem data:nil];
            
            [encItem runOperation:camOp1];

            [camOp1 setOnRequestComplete:^(NSData *d, EncoderOperation *op) {
                
                    NSDictionary    * results =[Utility JSONDatatoDict:d];
                    NSArray * list = [results[@"camlist"]allValues];
                    PXPLog(@"%@",list);
 
            }];

            
        }
    
    }
    
//    if ([RicoPlayerPool instance]) {
//         PXPLog(@"#### <Pooled Players> ####");
//        PXPLog(@"");
//        for (RicoPlayer * rp in [RicoPlayerPool instance].pooledPlayers) {
//            PXPLog(@"%@: cTime: %f  dTime: %f",rp.name,CMTimeGetSeconds(rp.currentTime),CMTimeGetSeconds(rp.duration));
//        }
//        PXPLog(@"");
//         PXPLog(@"#### </Pooled Players> ####");
//    }
    
  

    
}

-(void)onEncoder:(id)sender
{
    PXPLog(@"Primary Encoder:");
    PXPLog(@"  %@",encoderManager.primaryEncoder);
    PXPLog(@"Authenticated Encoders:");
    PXPLog(@"  %@",encoderManager.authenticatedEncoders);
    PXPLog(@"");
    
}

-(void)onEvent:(id)sender
{
    Event * evt;
    if (!encoderManager.primaryEncoder){
        PXPLog(@"No current Event because no encoder");
    } else {
        
        evt = encoderManager.primaryEncoder.event;
        PXPLog(@"%@",evt);
        
        NSMutableDictionary * theFeeds = evt.feeds;
        for (NSString * key in [theFeeds allKeys]) {
            Feed * afeed = theFeeds[key];
            PXPLog(@"  Feed: %@",key);
            PXPLog(@"    HQ: %@",[afeed.hqPath absoluteString]);
            PXPLog(@"    LQ: %@",[afeed.lqPath absoluteString]);
        }

        PXPLog(@" Sport - %@",evt.eventType);
        

        LeagueTeam * ht = evt.teams[kHomeTeam];
        LeagueTeam * at = evt.teams[kAwayTeam];
        PXPLog(@"   Home Team: %@",ht.name);
        PXPLog(@"   Teams League: %@",ht.league.name);
        PXPLog(@" ");
        PXPLog(@"   Away Team: %@",at.name);
        PXPLog(@"   Teams League: %@",at.league.name);
        PXPLog(@" ");
        PXPLog(@" ");
        PXPLog(@" <Raw Event Data!!> (/min/ajax/getpastevents for just current event)");
        PXPLog(@" %@",        evt.rawData);
        PXPLog(@" </Raw Event Data!!>");
    }
    
    

    
}


-(void)onTagDump:(id)sender
{
    Event * evt;
    if (!encoderManager.primaryEncoder){
        PXPLog(@"No current Event because no encoder");
    } else {
        
        evt = encoderManager.primaryEncoder.event;
        PXPLog(@"All Tags for - %@",evt);
        PXPLog(@"#   TYPE  ID  NAME   LIVE");
        NSArray * tags = [evt.tags copy];
        for (NSInteger i = 0; i<[tags count]; i++) {
            Tag * tag = tags[i];
            
            
            NSMutableString * outputpart = [NSMutableString new];
            
            NSString *indexColumn = [[NSString stringWithFormat:@"%ld", (long)i] stringByPaddingToLength:4 withString:@" " startingAtIndex:0];
            [outputpart appendString:indexColumn];
            
            NSString *typeColumn = [[NSString stringWithFormat:@"%ld", (long)tag.type] stringByPaddingToLength:6 withString:@" " startingAtIndex:0];
            [outputpart appendString:typeColumn];
            
            NSString *idColumn = [[NSString stringWithFormat:@"%@", tag.ID] stringByPaddingToLength:4 withString:@" " startingAtIndex:0];
            [outputpart appendString:idColumn];
            
            
            NSString *nameColumn = [[NSString stringWithFormat:@"%@", tag.name] stringByPaddingToLength:20 withString:@" " startingAtIndex:0];
            [outputpart appendString:nameColumn];
            
            NSString *liveColumn = [[NSString stringWithFormat:@"%@", (tag.isLive)?@"YES":@"NO"] stringByPaddingToLength:25 withString:@" " startingAtIndex:0];
            [outputpart appendString:liveColumn];

            
            //NSLog(@"%ld. %ld ID: %@  name:%@ st: %f  dr: %d   dID: %@",(long)i,(long)tag.type,tag.ID,tag.name,tag.startTime,tag.duration,(tag.durationID)?:@"none");
//            PXPLog(@"%ld.\t%ld %@  %@ st:%f  dr:%d",(long)i,(long)tag.type,tag.ID,tag.name,tag.startTime,tag.duration);
            PXPLog(outputpart);
        }
        
    }
    
    
    
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
   
      dispatch_async(dispatch_get_main_queue(), ^{
          if (self.textView.window)[self.textView setText: [PxpLog getInstance].text];
      });
//    if(self.textView.text.length > 0 ) {
//        NSRange bottom = NSMakeRange(self.textView.text.length -1, 1);
//        [self.textView scrollRangeToVisible:bottom];
//    }
}
@end
