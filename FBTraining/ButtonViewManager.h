//
//  ButtonViewManager.h
//  MultipleButtonsWithPopovers
//
//  Created by dev on 2015-01-26.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "AbstractComponentClassProtocol.h"




@interface ButtonViewManager : NSObject <AbstractComponentClassProtocol>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *componentType;
@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSArray *positionArray;
@property (strong, nonatomic) NSDictionary *dataDictionary;
@property (assign, nonatomic) CGRect frame;
@property (weak, nonatomic) UIView *parentView;
@property (nonatomic) BOOL selectable;

@property (assign, nonatomic) CGSize gap;

//-(instancetype)initWithDataDictionary: (NSDictionary *)dataDictionary andPlistDictionary: (NSDictionary *)plistDictionary;

@end
