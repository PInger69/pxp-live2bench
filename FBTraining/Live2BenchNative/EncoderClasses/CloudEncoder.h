//
//  CloudEncoder.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Encoder.h"

#define NOTIF_CLOUD_VERIFY          @"cloudVerify"
#define NOTIF_CLOUD_VERIFY_RESULTS  @"cloudVerifyResults"
//#define NOTIF_USER_LOGGED_OUT       @"userLoggedout" // {@"success":<bool>} // moved to common

#define CE_TAG_NAMES_GET            @"tagNamesGet:timeStamp:" // fix
#define CE_VERIFY_GET               @"verifyGet:timeStamp:" // Activate
#define CE_LOGOUT               @"logout:timeStamp:" // Logout

@interface CloudEncoder : Encoder <EncoderProtocol>
@property (nonatomic,assign) BOOL   loggedIn;

-(void)startObserving;
-(void)updateTagInfoFromCloud;
-(void)logoutOfCloud;

@end
