//
//  PxpLogViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-04-24.
//  Copyright (c) 2015 DEV. All rights reserved.
//
#import "AppDelegate.h"
#import "PxpLogViewController.h"
#import "PxpLog.h"
#import "CustomButton.h"
#import "EncoderManager.h"
//#import "EncoderProtocol.h"


@interface PxpLogViewController ()

@property (atomic, strong) UITextView *textView;
@property (nonatomic,strong)  CustomButton * clearButton;
@property (nonatomic,strong)  CustomButton * upButton;
@property (nonatomic,strong)  CustomButton * downButton;
@property (nonatomic,strong)  CustomButton * camButton;
@property (nonatomic,strong)  CustomButton * encoderButton;
@property (nonatomic,strong)  CustomButton * eventButton;


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
        self.textView.font              = [UIFont fontWithName:@"Courier" size:18.0];
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
        [self.upButton setTitle:@"Top" forState:UIControlStateNormal];
        [self.upButton addTarget:self action:@selector(onScroll:) forControlEvents:UIControlEventTouchUpInside];
        
        self.downButton = [[CustomButton alloc]init];
        self.downButton.layer.borderWidth = 1;
        self.downButton.layer.borderColor = [[UIColor grayColor]CGColor];
        [self.downButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.downButton setTitle:@"Bottom" forState:UIControlStateNormal];
        [self.downButton addTarget:self action:@selector(onScroll:) forControlEvents:UIControlEventTouchUpInside];
        
        
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



        encoderManager = appDel.encoderManager;
    }
    
    return self;
}




-(void)viewDidLoad
{

    NSArray * buttons = @[self.clearButton,self.upButton,self.downButton,self.camButton,self.encoderButton,self.eventButton];
    CGFloat buttonH = 50;
    CGFloat buttonW = 118;//self.view.bounds.size.width / [buttons count];
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

-(void)onClear:(id)sender
{
    [PxpLog clear];
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
    
    if (!enc && !enc.cameraData){
        PXPLog(@"No primaryEncoder Found");
        PXPLog(@"   Check if an Event is playing");        
    } else {
        PXPLog(@"%@",enc.cameraData);
    }
    
    if ( [encoderManager.authenticatedEncoders count] && !enc){
        PXPLog(@"Displaying other cam data found on network...");
        for (Encoder * encItem in encoderManager.authenticatedEncoders) {
            PXPLog(@"%@",encItem.cameraData);
        }
    
    }
    
    
    
  

    
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
