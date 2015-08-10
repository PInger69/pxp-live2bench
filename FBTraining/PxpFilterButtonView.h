//
//  PxpFilterButtonView.h
//  Live2BenchNative
//
//  Created by andrei on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface PxpFilterButtonView : UIView<PxpFilterModuleProtocol>

@property (nonatomic,strong) NSString *sortByPropertyKey;

@property (nonatomic,strong) NSMutableArray *buttonList;

@property (assign, nonatomic) CGSize buttonSize;

@property (assign, nonatomic) CGSize buttonMargin;

// Protocol
@property (nonatomic, weak) PxpFilter *parentFilter;

-(void)buildButtonsWith:(NSArray*)buttons;  // Build with the button pool created

-(void)buildButtons; // Build with buttons given

-(void)addButtonToPool:(NSDictionary*)dict;

@end
