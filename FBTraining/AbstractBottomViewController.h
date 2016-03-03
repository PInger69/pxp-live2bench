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
#import "SideTagButton.h"
#import "BottomViewTimeProviderDelegate.h"




@interface AbstractBottomViewController : UIViewController


@property (nonatomic,weak) id <BottomViewTimeProviderDelegate> delegate;

//@property (strong, nonatomic, nullable)    AVPlayer *videoPlayer;
//@property (strong, nonatomic, nullable)    Event *currentEvent;

//@property (readonly, copy, nonatomic, nonnull) NSString *currentPeriod;

-(void)postTag:(nonnull NSDictionary *)tagDic;
-(void)modifyTag:(nonnull NSDictionary *)tagDic;
//-(void)deleteTag:(nonnull Tag *)tag;
-(void)clear;

/*// To be override by subclasses
-(nonnull instancetype)init;
-(void)update;
-(void)postTagsAtBeginning;
-(void)setIsDurationVariable:(SideTagButtonModes)buttonMode;*/


@end
