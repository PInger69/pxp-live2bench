//
//  FeedMapDisplay.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "FeedMapDisplay.h"
#import "FeedMapController.h"

#import "StreamViewVideoKit.h"
@interface FeedMapDisplay ()

@end


@implementation FeedMapDisplay


@synthesize cameraDetails   = _cameraDetails;
@synthesize pickedCamID     = _pickedCamID;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:@"FeedMapCell" owner:self options:nil];
        self.bounds = self.view.bounds;
        [self addSubview:self.view];
        
        self.streamViewController = [[StreamViewVideoKit alloc]initWithFrame:self.streamViewPlaceHolder.frame];
        [self.streamViewPlaceHolder removeFromSuperview];
        [self addSubview:self.streamViewController.view];
        self.sourcePicker.delegate      = self;
        self.offset                     = 0.0;
        self.view.layer.cornerRadius    = 3;
        [self.view setBackgroundColor:[UIColor whiteColor]];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [[NSBundle mainBundle]loadNibNamed:@"FeedMapCell" owner:self options:nil];
        self.bounds = self.view.bounds;
        [self addSubview:self.view];
        
        self.streamViewController = [[StreamViewVideoKit alloc]initWithFrame:self.streamViewPlaceHolder.frame];
        
        [self.streamViewPlaceHolder removeFromSuperview];
        self.offset = 0.0;
        [self addSubview:self.streamViewController.view];
//        self.feedName.delegate = self;
        self.sourcePicker.delegate      = self;

        [self.heightAnchor constraintEqualToConstant:self.frame.size.height].active = YES;
        [self.widthAnchor constraintEqualToConstant: self.frame.size.width].active  = YES;
       self.layer.cornerRadius = 3;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle]loadNibNamed:@"FeedMapCell" owner:self options:nil];
        
        self.offset = 0.0;
        [self addSubview:self.view];
        
        self.streamViewController = [[StreamViewVideoKit alloc]initWithFrame:self.streamViewPlaceHolder.frame];
        
        [self.streamViewPlaceHolder removeFromSuperview];
        
        [self addSubview:self.streamViewController.view];
//        self.feedName.delegate = self;
        self.sourcePicker.delegate      = self;
        
        
        self.layer.cornerRadius = 3;
//        self.data = @[@{@"src":@"A",@"url":@"http:A"},@{@"src":@"B",@"url":@"http:B"},@{@"src":@"C",@"url":@"http:C"},@{@"src":@"D",@"url":@"http:D"}];
    }
    return self;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(onFeedMapDisplayInput:)]) {
        [self.delegate onFeedMapDisplayInput:self];
    }
    
    return YES;
}


#pragma mark - UIPicker Delegate methods
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    FeedMapController * fmc =  (FeedMapController *) pickerView.dataSource;
    NSArray * camDataList = fmc.camDataList;
    CameraDetails * cameraDtails = camDataList[row];
    return cameraDtails.name;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    FeedMapController * fmc =  (FeedMapController *) pickerView.dataSource;
    
    NSArray * camDataList = fmc.camDataList;
    CameraDetails * cameraDtails = camDataList[row];
    self.cameraDetails = cameraDtails;
    
    
    
    [[UserCenter getInstance]savePickByCameraLocation:self.feedMapLocation pick:self.cameraDetails.cameraID];
    if (self.streamViewController) [self.streamViewController url:cameraDtails.rtsp];
}

-(void)refresh
{
//    [[UserCenter getInstance]savePickByCameraLocation:self.feedMapLocation pick:self.cameraDetails.cameraID];
    if (self.streamViewController) [self.streamViewController url:self.cameraDetails.rtsp];

}

-(void)stop
{
    if (self.streamViewController) [self.streamViewController clear];
}

-(NSString*)currentPick
{
      FeedMapController * fmc =  (FeedMapController *) self.sourcePicker.dataSource;
    NSArray * camDataList = fmc.camDataList;
    if (![camDataList count]) return nil;
    CameraDetails * cameraDtails = camDataList[ [self.sourcePicker selectedRowInComponent:0]];

    return cameraDtails.name;

}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// getter and setter for camera Details

-(NSString*)pickedCamID
{
    return self.cameraDetails.cameraID;
}

- (IBAction)valueChanged:(id)sender
{
    self.offset  = [(UIStepper*)sender value];
    
    
     [self.offestLabel setText:[NSString stringWithFormat:@"%.01f", self.offset]];
}

@end
