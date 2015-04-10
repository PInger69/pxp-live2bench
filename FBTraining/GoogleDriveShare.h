//
//  GoogleDriveShare.h
//  Live2BenchNative
//
//  Created by dev on 2015-03-17.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "SocialSharingProtocol.h"
#import <Foundation/Foundation.h>

@interface GoogleDriveShare : NSObject <SocialSharingProtocol>
@property (assign, nonatomic) BOOL isLoggedIn;
@end
