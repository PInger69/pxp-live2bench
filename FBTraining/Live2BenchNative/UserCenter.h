//
//  UserCenter.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionList.h"
#import "EncoderTask.h"
#import "LeagueTeam.h"


#define L2B_MODE_HQ                 @"hq"
#define L2B_MODE_PROXY              @"proxy"
#define L2B_MODE_STREAM_OPTIMIZE    @"streamOp"
#define L2B_MODE_DUAL               @"dual"


@interface UserCenter : NSObject




@property (nonatomic,strong) NSOperationQueue * queue;


@property (atomic,strong) NSMutableArray           * tagNames;
@property (atomic,strong,readonly) NSMutableArray  * defaultTagNames;
//@property (atomic,strong) NSString               * userPick;// team pic
@property (atomic,strong) LeagueTeam               * taggingTeam;

@property (atomic,strong) NSMutableDictionary    * currentEventThumbnails;
@property (atomic,assign) BOOL                   isLoggedIn;
@property (atomic,assign) BOOL                   isEULA;
@property (atomic,assign) BOOL                   isStartLocked;

@property (atomic,strong) NSString               * customerID;
@property (atomic,strong) NSString               * customerDeviceID;
@property (atomic,strong) NSString               * customerAuthorization;
@property (atomic,strong) NSString               * customerEmail;
@property (atomic,strong) NSString               * userHID;
@property (atomic,strong) UIColor                * customerColor;

@property (atomic,strong) NSString                * currentTagSetName;
//Paths

@property (atomic,strong) NSString               * accountInfoPath;
@property (atomic,strong) NSString               * localPath;


// Preferences
@property (nonatomic,assign) NSInteger              preferenceLiveBuffer;
@property (nonatomic,assign) NSInteger              role;
@property (nonatomic,assign) NSString               * roleName;
@property (nonatomic,strong) NSString               * userTeam;
@property (nonatomic,strong) NSSet                  * rolePermissions;
@property (nonatomic,strong) NSPredicate            * teamPredicate;

@property (nonatomic,strong) NSString               * l2bMode;

@property (nonatomic,assign) double preRoll;
@property (nonatomic,assign) double postRoll;

@property (nonatomic,strong) NSSet              * tagsFlaggedForAutoDownload;

+(instancetype)getInstance;

-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath;
//-(void)enableObservers:(BOOL)isObserve;
-(void)writeAccountInfoToPlist;
-(void)logoutOfCloud;
-(void)updateTagInfoFromCloud;

-(void)verifyGet:(NSMutableDictionary *)tData  timeStamp:(NSNumber *)aTimeStamp;
// Action methods


-(id<ActionListItem>)checkLoginPlistAction;

-(NSDictionary*)namedCamerasByUser;
-(void)addCameraName:(NSString*)name camID:(NSString*)camID;

-(void)savePickByCameraLocation:(NSString*)camLocation pick:(NSString*)userPick;
-(NSString*)getPickByCameraLocation:(NSString*)camLocation;


-(void)saveVideoRecieptData:(NSDictionary*)reciept;
-(NSArray*)videoRecieptKeys;
-(NSDictionary*)videoRecieptDataForKey:(NSString*)key;
-(void)videoRecieptDataClear;

-(NSString*)deviceTypeHash;

@end
