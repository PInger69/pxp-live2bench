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


@interface UserCenter : NSObject
{
    NSURLRequest            * urlRequest;
    NSURLConnection         * encoderConnection;

    EncoderTask         * currentCommand;

}

@property (atomic,strong) NSMutableArray           * tagNames;
@property (atomic,strong,readonly) NSMutableArray  * defaultTagNames;
//@property (atomic,strong) NSString               * userPick;// team pic
@property (atomic,strong) LeagueTeam               * taggingTeam;

@property (atomic,strong) NSMutableDictionary    * currentEventThumbnails;
@property (atomic,assign) BOOL                   isLoggedIn;
@property (atomic,assign) BOOL                   isEULA;

@property (atomic,strong) NSString               * customerID;
@property (atomic,strong) NSString               * customerAuthorization;
@property (atomic,strong) NSString               * customerEmail;
@property (atomic,strong) NSString               * userHID;
@property (atomic,strong) UIColor                * customerColor;


//Paths

@property (atomic,strong) NSString               * accountInfoPath;
@property (atomic,strong) NSString               * localPath;


// Preferences
@property (atomic,assign) NSInteger              * preferenceLiveBuffer;

@property (nonatomic,strong) NSString               * l2bMode;


+(instancetype)getInstance;

-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath;
//-(void)enableObservers:(BOOL)isObserve;
-(void)writeAccountInfoToPlist;
-(void)logoutOfCloud;
-(void)updateTagInfoFromCloud;

-(void)verifyGet:(NSMutableDictionary *)tData  timeStamp:(NSNumber *)aTimeStamp;
// Action methods

-(id<ActionListItem>)logoutAction;
-(id<ActionListItem>)checkLoginPlistAction;

-(NSDictionary*)namedCamerasByUser;
-(void)addCameraName:(NSString*)name camID:(NSString*)camID;

-(void)savePickByCameraLocation:(NSString*)camLocation pick:(NSString*)userPick;
-(NSString*)getPickByCameraLocation:(NSString*)camLocation;






@end
