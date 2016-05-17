//
//  FeedMapController.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-05.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraDetails.h"
extern NSString * const FeedMapControllerDidSubmitChangeNotification;

extern NSString * const kTopDual;
extern NSString * const kBottomDual;

extern NSString * const kQuad1of4;
extern NSString * const kQuad2of4;
extern NSString * const kQuad3of4;
extern NSString * const kQuad4of4;

@class FeedMapController;
@protocol FeedMapControllerDelegate <NSObject>

-(void)onRefresh:(FeedMapController*)deedMapController;

@end




@interface FeedMapController : NSObject <UIPickerViewDataSource>

@property (strong,nonatomic) NSMutableDictionary    * camIDtoUserInput;
@property (strong,nonatomic) NSArray                * camIDs;
@property (weak,nonatomic)  id<FeedMapControllerDelegate>                    delegate;

@property (strong,nonatomic) NSArray * feedMapDisplays;
@property (strong,nonatomic) NSMutableDictionary * feedMapDisplaysDict;

@property (strong,nonatomic) NSMutableDictionary * camDataByCamID;

// new
@property (nonatomic,strong) NSMutableArray * camDataList;

+(NSMutableDictionary*)mappedCamData;
+(instancetype)instance;

-(void)populate;


-(void)reloadStreams;
-(void)refresh;
-(void)refreshLocationCells;
-(void)submitChanges;

-(void)getCameraDetailsFromServer;
-(CameraDetails*)getCameraDetailsByID:(NSString*)cameraID;
-(CameraDetails*)getCameraDetailsByLabel:(NSString*)labelName;

-(NSString*)getSourceFromPlayerLocation:(NSString*)playerLocation;


@end
