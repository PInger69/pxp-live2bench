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
@property (strong,nonatomic,nullable)      UIView  *mainView;

-(void)update;
-(void)clear;

@optional

-(void)postTagsAtBeginning;
-(void)setIsDurationVariable:(SideTagButtonModes)buttonMode;
-(void)closeAllOpenTagButtons;

-(nonnull NSString *)currentPeriod;
-(void)allToggleOnOpenTags;
-(void)addData:(nonnull NSString *)type name:(nonnull NSString*)name;

@end
