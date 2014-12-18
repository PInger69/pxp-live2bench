//
//  SignalStrengthViewController.m
//  Live2BenchNative
//
//  Created by Dev on 2013-11-01.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "SignalStrengthViewController.h"

@interface SignalStrengthViewController ()

@end

@implementation SignalStrengthViewController

@synthesize globals;

NSTimer *timer;
UIView *maxRange;
UIView *midRange;
UIView *minRange;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    globals = [Globals instance];
    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateSignalStrengths) userInfo:nil repeats:YES];
    [timer fire];
    [self.SSIDLabel setText:[NSString stringWithFormat:@"SSID: %@",[self fetchSSIDInfo]]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
}

- (void)viewDidLayoutSubviews
{
    maxRange.frame = CGRectMake(self.graphView.frame.origin.x, self.graphView.frame.origin.y, self.graphView.bounds.size.width, self.graphView.bounds.size.height/3);
    midRange.frame = CGRectMake(maxRange.frame.origin.x, CGRectGetMaxY(maxRange.frame), maxRange.bounds.size.width, maxRange.bounds.size.height);
    minRange.frame = CGRectMake(midRange.frame.origin.x, CGRectGetMaxY(midRange.frame), midRange.bounds.size.width, midRange.bounds.size.height);
}

- (void)setupView {
    self.SSIDLabel = [CustomLabel labelWithStyle:CLStyleOrange];
    self.SSIDLabel.frame = CGRectMake(5.0f, 2.0f, self.view.bounds.size.width - 10.0f, 30.0f);
    self.SSIDLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.SSIDLabel];
    
    self.graphView = [[GraphView alloc] initWithFrame:CGRectMake(5.0f, CGRectGetMaxY(self.SSIDLabel.frame) + 5.0f, self.view.bounds.size.width - 10.0f, self.view.bounds.size.height - 50.0f)];
    self.graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.graphView setBackgroundColor:[UIColor clearColor]];
    [self.graphView setFill:YES];
    [self.graphView setSpacing:0];
    [self.graphView setStrokeColor: [UIColor colorWithWhite:0.4f alpha:0.9f]];
    [self.graphView setZeroLineStrokeColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [self.graphView setLineWidth:1];
    [self.graphView setCurvedLines:NO];
    self.graphView.layer.borderColor = [[UIColor colorWithWhite:0.7f alpha:1.0f] CGColor];
    self.graphView.layer.borderWidth = 1.0f;
    
    maxRange = [[UIView alloc] initWithFrame:CGRectMake(self.graphView.frame.origin.x, self.graphView.frame.origin.y, self.graphView.bounds.size.width, self.graphView.bounds.size.height/3)];
    maxRange.backgroundColor = [UIColor colorWithRed:0.5f green:1.0f blue:0.5f alpha:0.3f];
    maxRange.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:maxRange];
    
    midRange = [[UIView alloc] initWithFrame:CGRectMake(maxRange.frame.origin.x, CGRectGetMaxY(maxRange.frame), maxRange.bounds.size.width, maxRange.bounds.size.height)];
    midRange.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.5f alpha:0.3f];
    midRange.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:midRange];
    
    minRange = [[UIView alloc] initWithFrame:CGRectMake(midRange.frame.origin.x, CGRectGetMaxY(midRange.frame), midRange.bounds.size.width, midRange.bounds.size.height)];
    minRange.backgroundColor = [UIColor colorWithRed:1.0f green:0.5f blue:0.5f alpha:0.3f];
    minRange.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:minRange];
    [self.view addSubview:self.graphView];
    
}

- (void)updateSignalStrengths
{
    float graphPoint = globals.BIT_RATE > 0.0f ? globals.BIT_RATE : 0.0f;
    graphPoint = graphPoint > 1000.0f ? 1000.0f : graphPoint;
    [self.graphView setPoint: graphPoint];
    if (graphPoint < 1000.0f/3) {
        [self.graphView setFillColor: [UIColor colorWithRed:1.0f green:0.5f blue:0.5f alpha:0.6f]];
    } else if (graphPoint < 2*1000.0f/3) {
        [self.graphView setFillColor: [UIColor colorWithRed:1.0f green:1.0f blue:0.5f alpha:0.6f]];
    } else {
        [self.graphView setFillColor: [UIColor colorWithRed:0.5f green:1.0f blue:0.5f alpha:0.6f]];
    }
}

-(NSString*)fetchSSIDInfo
{
    NSArray *ifs = (__bridge NSArray *)(CNCopySupportedInterfaces());
//    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        NSLog(@"%s: %@ => %@", __func__, ifnam, info);
        if (info && [info count]) {
            break;
        }
    }
    return [info objectForKey:@"SSID"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
