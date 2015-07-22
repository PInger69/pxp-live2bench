//
//  FeedInspector.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-20.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Feed.h"
#import "ActionList.h"

#define NOTIF_FEED_INSPECTION_COMPLETE @"NOTIF_FEED_INSPECTION_COMPLETE"
/*
 This class will check all aspects of a Feed instance and then set its mode if it has issues. As well as populate its error list with all found errors
 */
@interface FeedInspector : NSObject




+(void)investigate:(Feed*)suspectFeed;



@property(nonatomic,weak)   Feed            * suspectFeed;
@property(nonatomic,strong) NSMutableArray  * errors;
@property(nonatomic,strong) NSMutableArray  * urlsToCheck;
@property(nonatomic,strong) ActionList      * actionList;

@end
