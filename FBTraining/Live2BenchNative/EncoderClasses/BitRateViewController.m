//
//  BitRateViewController.m
//  Live2BenchNative
//
//  Created by dev on 11/7/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "BitRateViewController.h"

#import "BitrateMonitor.h"
#import "Encoder.h"

@interface BitRateViewController ()
{

    EncoderManager          * encoderManager;
    NSMutableDictionary     * builtMonitors;
    CGSize                  monitorSize;
}
@end

@implementation BitRateViewController



-(instancetype)initWithAppDelegate:(AppDelegate*)appDel
{
    self = [super init];
    if (self) {
        encoderManager  = appDel.encoderManager;
        monitorSize     = CGSizeMake(600, 100);
        builtMonitors   = [[NSMutableDictionary alloc]init];
        self.view       = [[UIView alloc]initWithFrame:CGRectMake(10, 200,400, 400)];
        self.view.backgroundColor = [UIColor colorWithWhite:0.95f alpha: 1.0f];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 303, 50)];
        [titleLabel setText: NSLocalizedString(@"Encoder Statuses", nil)];
        [titleLabel setFont: [UIFont fontWithName:@"Helvetica" size:28.0]];
        [titleLabel setTextAlignment: NSTextAlignmentCenter];
        [self.view addSubview: titleLabel];
        

        
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refresh:) name:NOTIF_ENCODER_COUNT_CHANGE object:encoderManager];
        
    }
    return self;
}


/**
 *  This adds encoders to the list
 *
 *  @param note
 */
-(void)refresh:(NSNotification*)note
{
    //[self removeEncoder];
    //[self addEncoder];
}

-(void)removeEncoder{
    // Remove the monitors for encoders that have been disconnected
    NSSet           * currentlyWatched  = [[NSSet alloc]initWithArray:[builtMonitors allKeys]];
    /*NSMutableSet    * shouldWatch       = [[NSMutableSet alloc]init];
    
    for (Encoder * aEncoder in encoderManager.authenticatedEncoders) {
        [shouldWatch addObject:aEncoder.name];
    }
    
    NSMutableSet           * nameOfMonitorsToBeRemoved = [[NSMutableSet alloc]init];
    
    [nameOfMonitorsToBeRemoved setSet:currentlyWatched];
    [nameOfMonitorsToBeRemoved minusSet:shouldWatch];*/
    
    for (NSString * mNames in currentlyWatched) {
        BitrateMonitor* monitor1 = [builtMonitors objectForKey:mNames];
        [monitor1 removeFromSuperview];
        [builtMonitors removeObjectForKey:mNames];
    }
    [self rearrange];
}

-(void)addEncoder{
    // this adds new encoders
    for (Encoder * coder in encoderManager.authenticatedEncoders) {
        NSString * eName = coder.name;
        if ([builtMonitors objectForKey:eName] == nil) {
            BitrateMonitor* monitor =  [[BitrateMonitor alloc]initWithFrame:CGRectMake(0, 0, monitorSize.width, monitorSize.height) encoder:coder];
            monitor.name = eName;
            [builtMonitors setObject:monitor forKey:eName];
            [self.view addSubview:monitor];
        }
    }
    
    [self rearrange];
}

-(BitrateMonitor*)buildMonitorWithFrame:(CGRect)aFrame encoder:(Encoder*)aEncoder
{
    BitrateMonitor* monitor =  [[BitrateMonitor alloc]initWithFrame:aFrame encoder:aEncoder];
    monitor.name = aEncoder.name;
    return monitor;
}


/**
 *  This should reposition the encoders
 */
-(void)rearrange
{
    
    float   yOffset = 120;
    int     count   = 0;
    NSArray * list = [builtMonitors allValues];
    
    for (BitrateMonitor * monitor in list){
        
        [monitor setFrame:CGRectMake(5, yOffset + (count * (monitorSize.height+60)), 703 - 150, monitorSize.height)];
        count++;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addEncoder];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeEncoder];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


@end
