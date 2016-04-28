//
//  FeedMapDisplay.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamViewProtocol.h"
#import "FeedMapIcon.h"
#import "CameraDetails.h"

@class FeedMapDisplay;
@protocol FeedMapDisplayDelegate <NSObject>

-(void)onFeedMapDisplayInput:(FeedMapDisplay*)feedMapDisplay;

@end



@interface FeedMapDisplay : UIView <UITextFieldDelegate,UIPickerViewDelegate>

@property (nonatomic,strong) NSArray * data;
@property (nonatomic,strong) NSDictionary * nameToID;

@property (nonatomic,weak) CameraDetails    * cameraDetails;
@property (strong,nonatomic,readonly) NSString * pickedCamID;
@property (strong,nonatomic) NSString * feedMapLocation;


@property (weak, nonatomic) IBOutlet UIPickerView *sourcePicker;

@property (weak, nonatomic) IBOutlet UILabel *offestLabel;
@property (weak, nonatomic) IBOutlet UIStepper *offsetStepper;
@property (assign,nonatomic) double offset;

@property (weak, nonatomic) id<FeedMapDisplayDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel        * cellName;
@property (weak, nonatomic) IBOutlet FeedMapIcon    * icon;
@property (weak, nonatomic) IBOutlet UIView         * streamViewPlaceHolder;

@property (nonatomic,strong) id <StreamViewProtocol> streamViewController;

-(NSString*)currentPick;

-(void)refresh;
-(void)stop;
@end
