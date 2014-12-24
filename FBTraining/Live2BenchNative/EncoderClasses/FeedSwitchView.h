//
//  FeedSwitchView.h
//  Live2BenchNative
//
//  Created by dev on 10/28/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EncoderManager.h"
#import "Pip.h"

@interface FeedSwitchView : UIView


@property (nonatomic,strong) NSMutableArray * buttonArray;
@property (nonatomic,assign) NSUInteger     primaryPosition;
@property (nonatomic,assign) NSUInteger     secondaryPosition;


-(id)initWithFrame:(CGRect)frame encoderManager:(EncoderManager*)encoderManager;

-(void)buildButtonsWithData:(NSDictionary*)list;
/**
 *  Primary to secondary, secondary to primary
 */
-(void)swap;

-(Feed*)feedFromKey:(NSString*)key;

-(Feed*)primaryFeed;
-(Feed*)secondaryFeed;
-(void)deselectByIndex:(NSUInteger)index;
-(BOOL)secondarySelected;

@end
