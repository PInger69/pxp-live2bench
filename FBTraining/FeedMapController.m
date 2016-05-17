//
//  FeedMapController.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-05.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "FeedMapController.h"
#import "FeedMapDisplay.h"
#import "EncoderManager.h"
#import "Encoder.h"
#import "NullCameraDetails.h"


// This class will hold all camData from the current encoder


NSString* const FeedMapControllerDidSubmitChangeNotification                   = @"FeedMapControllerDidSubmitChangeNotification";


NSString* const kTopDual                   = @"topDual";
NSString* const kBottomDual                = @"bottomDual";

NSString* const kQuad1of4                  = @"quad1of4";
NSString* const kQuad2of4                  = @"quad2of4";
NSString* const kQuad3of4                  = @"quad3of4";
NSString* const kQuad4of4                  = @"quad4of4";

static NSMutableDictionary * _mappedCamData;

static FeedMapController * _instance;
@interface FeedMapController ()




@end



@implementation FeedMapController

+(NSMutableDictionary*)mappedCamData
{
    if (!_mappedCamData) {
        _mappedCamData = [NSMutableDictionary new];

    }
    
    return _mappedCamData;
}

+ (instancetype)instance
{
    if (!_instance) {
        _instance = [FeedMapController new];
        [_instance refresh];
    }
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.feedMapDisplaysDict = [NSMutableDictionary new];
        self.camDataList         = [NSMutableArray new];

        FeedMapDisplay * (^makeDisplay)(NSString* label,NSString* locationName,NSInteger type) = ^FeedMapDisplay*(NSString* label,NSString* locationName,NSInteger type)
        {
            FeedMapDisplay * fm1 = [FeedMapDisplay new];
            [fm1.icon setType:type];
            fm1.cellName.text = label;
            fm1.feedMapLocation = locationName;
            fm1.sourcePicker.delegate = fm1;
            fm1.sourcePicker.dataSource = self;
            return fm1;
        };
        
        // build the UI for the controller based off the data (hard coded from now)
        
        [self.feedMapDisplaysDict setObject:makeDisplay(@"kQuad1of4",kQuad1of4,FeedMapIconTypeQuad1of4) forKey:kQuad1of4];
        [self.feedMapDisplaysDict setObject:makeDisplay(@"kQuad2of4",kQuad2of4,FeedMapIconTypeQuad2of4) forKey:kQuad2of4];
        [self.feedMapDisplaysDict setObject:makeDisplay(@"kQuad3of4",kQuad3of4,FeedMapIconTypeQuad3of4) forKey:kQuad3of4];
        [self.feedMapDisplaysDict setObject:makeDisplay(@"kQuad4of4",kQuad4of4,FeedMapIconTypeQuad4of4) forKey:kQuad4of4];
        
        [self.feedMapDisplaysDict setObject:makeDisplay(@"Top Dual View",kTopDual,FeedMapIconTypeDualTop) forKey:kTopDual];
        [self.feedMapDisplaysDict setObject:makeDisplay(@"Bottom Dual View",kBottomDual,FeedMapIconTypeDualBottom) forKey:kBottomDual];
        

        self.feedMapDisplays    = [self.feedMapDisplaysDict allValues];
        [self getCameraDetailsFromServer];
    }
    return self;
}


#pragma mark - Camera Data Manager
// These methods will hold the camera data and also provide a way to get the camera data by name, even the user created name


// This gets the camrea details from the server and stores them in an array
-(void)getCameraDetailsFromServer
{
    Encoder * encoder =  (Encoder *)[EncoderManager getInstance].primaryEncoder;
    
    encoder = (encoder)?encoder:[EncoderManager getInstance].masterEncoder;
    
    encoder = (encoder)?encoder:(Encoder *)[EncoderManager getInstance].liveEvent.parentEncoder;
    
    
    NSDictionary * savedNames = [[UserCenter getInstance]namedCamerasByUser];
    
    
    if (encoder) {
        
        NSMutableArray * uniqueCamsDetails = [NSMutableArray new] ;
        
        NSArray * tempArray = [encoder.cameraData allValues];
        for (CameraDetails  * cd in tempArray) {
            BOOL isInArray = NO;
            for (CameraDetails  * uniqueCD in uniqueCamsDetails) {
                if ([uniqueCD.cameraID isEqualToString:cd.cameraID]) {
                    isInArray = YES;
                }
            }
            
            if (!isInArray) {
                
                // this changes the name to what the user saved
                if ([savedNames objectForKey:cd.cameraID]){
                    cd.name = [savedNames objectForKey:cd.cameraID];
                }
                
                [uniqueCamsDetails addObject:cd];
            }
            
        }
        
              self.camDataList = uniqueCamsDetails;
        
        // attatch cam data to UI
        
        NSArray * list              = [encoder.cameraData allValues];
        NSArray * allFeedMapKeys    = [self.feedMapDisplaysDict allKeys];
        
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CameraDetails * cam = (CameraDetails *) obj;
            
            for (NSString* key in allFeedMapKeys) {
                
                
                FeedMapDisplay * fm = [self.feedMapDisplaysDict objectForKey:key];
                
                NSString * pick = [fm currentPick];
                if ([pick isEqualToString:cam.name]) {
                    fm.cameraDetails = cam;
                }
                NSLog(@"");
            }
            
            
            
            
            
        }];
        
//        [uniqueCamsDetails addObject:[NullCameraDetails new]];
  
        // refresh UI?
        if ([self.delegate respondsToSelector:@selector(onRefresh:)]){
            [self.delegate onRefresh:self];
        }
    }
}


-(CameraDetails*)getCameraDetailsByID:(NSString*)cameraID
{
    
    for (CameraDetails* camDat in self.camDataList) {
        if ([camDat.cameraID isEqualToString:cameraID]) return camDat;
    }
    
    return nil;
}


-(CameraDetails*)getCameraDetailsByLabel:(NSString*)labelName
{
    for (CameraDetails* camDat in self.camDataList) {
        if ([camDat.name isEqualToString:labelName]) return camDat;
    }
    return nil;
}





// This populates the feed map with cam data
-(void)populate
{
        NSArray * displayList = [self.feedMapDisplaysDict allValues];
    
        [displayList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FeedMapDisplay * fm = (FeedMapDisplay *)obj;
            
//            fm
            NSLog(@"");
        }];


    
}


-(void)reloadStreams
{
    NSArray * feedMapDisplays = [self.feedMapDisplaysDict allValues];

    for (FeedMapDisplay* display in feedMapDisplays) {
        [display refresh];
    }
    
}

-(void)refresh
{

    [self getCameraDetailsFromServer];

    
    
    Encoder * encoder =  (Encoder *)[EncoderManager getInstance].primaryEncoder;
    
    encoder = (encoder)?encoder:[EncoderManager getInstance].masterEncoder;

    if (encoder) {

        
        EncoderOperation * op = [[EncoderOperationCameraData alloc]initEncoder:encoder data:nil];
        
        [op setOnRequestComplete:^(NSData *jsonData, EncoderOperation *operation) {
            

            // on complete
            if ([self.delegate respondsToSelector:@selector(onRefresh:)]) {
                [self.delegate onRefresh:self];
            }
        }];
    
        NSArray * list              = [encoder.cameraData allValues];
        NSArray * allFeedMapKeys    = [self.feedMapDisplaysDict allKeys];
        
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CameraDetails * cam = (CameraDetails *) obj;
            
            
            [allFeedMapKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString * dictKey = (NSString *) obj;
                FeedMapDisplay * fm = [self.feedMapDisplaysDict objectForKey:dictKey];
                
                if ([fm.currentPick isEqualToString:cam.name]) {
                    fm.cameraDetails = cam;
                }
                NSLog(@"");
            }];
            
            
            
            



        }];
        
        
        
        
        
    }

}



-(void)submitChanges
{
    [[NSNotificationCenter defaultCenter]postNotificationName:FeedMapControllerDidSubmitChangeNotification object:self];
}



-(void)refreshLocationCells
{
    NSArray * allCells = [self.feedMapDisplaysDict allValues];
    for (FeedMapDisplay *aCell in allCells) {
        [aCell.sourcePicker reloadAllComponents];
    }
}


#pragma mark - UIPicker Data Delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.camDataList count];
}



-(NSString*)getSourceFromPlayerLocation:(NSString*)playerLocation
{
    
    FeedMapDisplay* fm = [self.feedMapDisplaysDict objectForKey:playerLocation];
    CameraDetails * camD = fm.cameraDetails;
    
    NSString* result = camD.source;
    
    return result;

}


@end
