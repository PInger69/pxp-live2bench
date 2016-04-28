//
//  FeedMappingViewController.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-04.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "FeedMappingViewController.h"
#import "RicoPlayer.h"

#import "FeedMapDisplay.h"
#import "FeedMapController.h"
#import "NameCameraCellView.h"
#import "EncoderManager.h"
#import "NullCameraDetails.h"

#define BOX_WIDTH 615

@interface FeedMappingViewController () <UITextFieldDelegate,FeedMapControllerDelegate>

@property (nonatomic,strong) UIStackView        * cameraNameStackView;

@property (nonatomic,strong) UIStackView        * stackViewTop;
@property (nonatomic,strong) UIStackView        * stackViewMid;
@property (nonatomic,strong) UIStackView        * stackViewBot;

@property (nonatomic,strong) FeedMapController  * feedMapController;
@property (nonatomic,assign) BOOL               hasUserInteracted;

@end





@implementation FeedMappingViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    self.feedMapController = [FeedMapController instance];
    self.feedMapController.delegate = self;
    
    CGFloat m = 50;
    
    
    // build the container for the camera naming
    CGFloat h = 700;
    
    self.cameraNameStackView = [[UIStackView alloc]initWithFrame:CGRectMake(m, 0, BOX_WIDTH,h)];

    self.cameraNameStackView.alignment  = UIStackViewAlignmentTop;
    self.cameraNameStackView.axis       = UILayoutConstraintAxisVertical;
    self.cameraNameStackView.spacing    = 3;
    [self.view addSubview:self.cameraNameStackView];

    [self.feedMapController populate];
    [self.feedMapController refresh];

    [self buildCameraLabeler];
}



-(void)buildCameraLabeler
{
    // remove all elements
    [self.cameraNameStackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView * aCell = obj;
        [self.cameraNameStackView removeArrangedSubview:aCell];
        [aCell removeFromSuperview];
    }];
    
    
    
    
    // Build the cameraPart of the StackView
    
    
    NSArray * camIdList         = [self.feedMapController camDataList];
    // make camera header
    UIView * headerContainer    = [[UIView alloc]initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 30)];
    UILabel * alabel            = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 200, 20)];
    
    [headerContainer.heightAnchor constraintEqualToConstant:headerContainer.bounds.size.height].active = YES;
    [headerContainer.widthAnchor  constraintEqualToConstant:headerContainer.bounds.size.width].active  = YES;
    
    [alabel setTextColor:[UIColor whiteColor]];
    alabel.text = @"Cameras on encoder:";
    [headerContainer addSubview:alabel];
    [self.cameraNameStackView addArrangedSubview:headerContainer];
    // end make header
    
    
    
    // build the cameras
    
    for (NSInteger  i=0; i<[camIdList count]; i++) {
        
        CameraDetails * details         = camIdList[i];
        
        if ([details isKindOfClass:[NullCameraDetails class]]) continue;
        
        NameCameraCellView * cell       = [NameCameraCellView new];
        
        cell.camIDLabel.text            = details.cameraID;
        cell.UserInputField.text        = details.name;
        cell.UserInputField.delegate    = self;
        cell.UserInputField.tag         = 2;
        cell.ipAddressLabel.text        = details.ipAddress;
        [self.cameraNameStackView addArrangedSubview:cell];
    }
    
    
    // make camera header
    headerContainer    = [[UIView alloc]initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 30)];
    alabel             = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 200, 20)];
    
    [headerContainer.heightAnchor constraintEqualToConstant:headerContainer.bounds.size.height].active = YES;
    [headerContainer.widthAnchor  constraintEqualToConstant:headerContainer.bounds.size.width].active  = YES;
    
    [alabel setTextColor:[UIColor whiteColor]];
    alabel.text = @"Camera Map Locations:";
    [headerContainer addSubview:alabel];
    [self.cameraNameStackView addArrangedSubview:headerContainer];
    // end make header


    
    // build a scroll view for all the feed map stack
    
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 500)];
//    scrollView.layer.borderWidth = 1;
    scrollView.scrollEnabled = YES;

    [scrollView.heightAnchor constraintEqualToConstant:scrollView.bounds.size.height].active = YES;
    [scrollView.widthAnchor  constraintEqualToConstant:scrollView.bounds.size.width].active  = YES;
    [self.cameraNameStackView addArrangedSubview:scrollView];
    
    //
//    
    self.stackViewTop = [[UIStackView alloc]initWithFrame:CGRectMake(0, 0, BOX_WIDTH,580)];
    
    
    Encoder * enc = (Encoder *)[EncoderManager getInstance].primaryEncoder;
    
    if (!enc) enc = (Encoder *)[EncoderManager getInstance].masterEncoder;
    if (!enc) enc = (Encoder *)[EncoderManager getInstance].liveEvent.parentEncoder;
    
   
    
    void (^preSelect)(FeedMapDisplay* fmd,NSString* location) = ^void(FeedMapDisplay* fmd,NSString* location) {
        UIPickerView * p = fmd.sourcePicker;
        FeedMapController * fmc =  (FeedMapController *) p.dataSource;
        NSArray * camDataList = [enc.cameraData allValues];
        if (![camDataList count]) return;
        NSString * loc =  [[UserCenter getInstance]getPickByCameraLocation:location];
        
        
        for (NSInteger i =0; i<[camDataList count]; i++) {
            CameraDetails * c = camDataList[i];
            NSString * camID = c.cameraID;
            
            if ([camID isEqualToString:loc]) {
                [p selectRow:i inComponent:0 animated:NO];
                [p reloadAllComponents];
                fmd.cameraDetails = c;
                [fmd refresh];
                [fmc.camDataList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CameraDetails * cc = obj;
                    NSLog(@"%@",cc.name);
                }];
                
                break;
            }
        }
        

    
      
    };
    
    
    NSArray * list = @[kQuad1of4,kQuad2of4,kQuad3of4,kQuad4of4];//,kTopDual,kBottomDual
    
    for (NSInteger i =0; i<[list count]; i++) {
        NSString * k = list[i];
        FeedMapDisplay* fmd = self.feedMapController.feedMapDisplaysDict[k];
        [self.stackViewTop addArrangedSubview:fmd];
        preSelect(fmd,k);
         [fmd refresh];
    }
    
    self.stackViewTop.axis      = UILayoutConstraintAxisVertical;
    self.stackViewTop.alignment = UIStackViewAlignmentTop;
    self.stackViewTop.spacing   = 3;
    
  [self.stackViewTop addArrangedSubview:[UIView new]];
    scrollView.contentSize = CGSizeMake(BOX_WIDTH, self.stackViewTop.frame.size.height);
    [scrollView addSubview:self.stackViewTop];
    [self.cameraNameStackView addArrangedSubview:scrollView];
    
}


#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
   
    if (textField.tag == 2) {
        [self.cameraNameStackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[NameCameraCellView class]]){
                NameCameraCellView * aCell = obj;
                CameraDetails * camDetail = [self.feedMapController getCameraDetailsByID:aCell.camIDLabel.text];
                camDetail.name = aCell.UserInputField.text;
                
                
                [[UserCenter getInstance]addCameraName:camDetail.name camID:aCell.camIDLabel.text];
                
            }
        }];
        
        
        [self.feedMapController refreshLocationCells];// resets the names of the cells
    }
    
    
    return YES;
}



-(void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_EVENT_CHANGE object:nil];
    [super viewDidAppear:animated];
    self.hasUserInteracted = YES;
    [self.feedMapController populate];
    [self.feedMapController refresh];
    [self buildCameraLabeler];

}

-(void)viewDidDisappear:(BOOL)animated
{
    if (self.hasUserInteracted && [EncoderManager getInstance].liveEvent){
        Encoder * enc = (Encoder *)[EncoderManager getInstance].liveEvent.parentEncoder;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_RELOAD_PLAYERS object:enc];
    }
    
    NSArray * list = @[kQuad1of4,kQuad2of4,kQuad3of4,kQuad4of4];//,kTopDual,kBottomDual
    
    for (NSInteger i =0; i<[list count]; i++) {
        NSString * k = list[i];
        FeedMapDisplay* fmd = self.feedMapController.feedMapDisplaysDict[k];
        [fmd stop];
    }
    
    
    [super viewDidDisappear:animated];
}

-(void)onRefresh:(FeedMapController*)deedMapController
{

    [self buildCameraLabeler];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
