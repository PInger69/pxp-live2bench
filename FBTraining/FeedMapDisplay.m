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
        NSInteger index = [self.view.subviews indexOfObject:self.streamViewPlaceHolder];
        [self.view insertSubview:self.streamViewController.view atIndex:index];
        [self.streamViewPlaceHolder removeFromSuperview];
        self.offset = 0.0;
        
        NSLog(@"%@",NSStringFromCGRect(self.view.frame));

            [self.heightAnchor constraintEqualToConstant:self.view.frame.size.height].active = YES;
            [self.widthAnchor constraintEqualToConstant: self.view.frame.size.width].active  = YES;

             self.layer.cornerRadius = 3;
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
//- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    FeedMapController * fmc =  (FeedMapController *) pickerView.dataSource;
//    NSArray * camDataList = fmc.camDataList;
//    CameraDetails * cameraDtails = camDataList[row];
//    
//
//    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:cameraDtails.name attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//
//      return cameraDtails.name;
////    return attString;
//}

-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    FeedMapController * fmc =  (FeedMapController *) pickerView.dataSource;
    NSArray * camDataList = fmc.camDataList;
    CameraDetails * cameraDtails = camDataList[row];
    
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:cameraDtails.name attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
//    return cameraDtails.name;
        return attString;

}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    FeedMapController * fmc =  (FeedMapController *) pickerView.dataSource;
    
    NSArray * camDataList = fmc.camDataList;
    CameraDetails * cameraDtails = camDataList[row];
    self.cameraDetails = cameraDtails;
    
    
    [[UserCenter getInstance]savePickByCameraLocation:self.feedMapLocation pick:self.cameraDetails.cameraID];
    if (self.streamViewController) [self.streamViewController url:cameraDtails.rtsp];
    [fmc reloadStreams];

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
