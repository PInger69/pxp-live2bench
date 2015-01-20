//
//  UserCenter.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-04.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionList.h"

@interface UserCenter : NSObject

@property (nonatomic,strong) NSMutableArray         * tagNames;
@property (nonatomic,strong) NSString               * userPick;// team pic

@property (nonatomic,strong) NSMutableDictionary    * currentEventThumbnails;
@property (nonatomic,assign) BOOL                   isLoggedIn;
@property (nonatomic,assign) BOOL                   isEULA;



//Paths

@property (nonatomic,strong) NSString               * accountInfoPath;



-(id)initWithLocalDocPath:(NSString*)aLocalDocsPath;

-(void)enableObservers:(BOOL)isObserve;




// Action methods

-(id<ActionListItem>)loginAction;




@end
