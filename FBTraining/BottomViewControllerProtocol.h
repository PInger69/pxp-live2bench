//
//  BottomViewControllerProtocol.h
//  Live2BenchNative
//
//  Created by dev on 2015-07-27.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "SideTagButton.h"

@protocol BottomViewControllerProtocol <NSObject>

@property (nonatomic,strong,nullable)       Event *currentEvent;
@property (strong, nonatomic, nullable)    AVPlayer *videoPlayer;
@property (strong,nonatomic,nullable)      UIView  *mainView;

@optional
-(void)update;
-(void)postTagsAtBeginning;
-(void)setIsDurationVariable:(SideTagButtonModes)buttonMode;
-(void)closeAllOpenTagButtons;
-(void)clear;
-(nonnull NSString *)currentPeriod;
-(void)allToggleOnOpenTags;

@end
