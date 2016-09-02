//
//  DropboxManager.h
//  Live2BenchNative
//
//  Created by dev on 2016-07-13.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
@interface DropboxManager : NSObject

@property (strong,nonatomic) NSOperationQueue * queue;

@property (strong,nonatomic) DBRestClient   * restClient;
@property (strong,nonatomic) DBSession      * session;
@property (strong,nonatomic) NSString       * linkedUserName;
@property (nonatomic,copy) void (^onUserConnected)(NSString*);

+(DropboxManager*)getInstance;



-(void)connect;

@end
