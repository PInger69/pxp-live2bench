//
//  AbstractBottomViewController.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-16.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVPlayer.h>
#import "Event.h"

@interface AbstractBottomViewController : UIViewController

@property (nonatomic,strong)    AVPlayer    * videoPlayer;
@property (nonatomic,strong)    Event * currentEvent;

-(void)postTag:(NSDictionary*)tagDic;
-(void)modifyTag:(Tag*)tag;
-(void)deleteTag:(Tag*)tag;
-(void)clear;

// To be override by subclasses
-(id)init;
-(void)update;
-(void)postTagsAtBeginning;
-(NSString *)currentPeriod;


@end
