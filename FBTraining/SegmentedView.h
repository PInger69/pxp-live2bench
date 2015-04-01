//
//  SegmentedViewController.h
//  SegmentedViewController
//
//  Created by dev on 2015-01-23.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "AbstractComponentClassProtocol.h"



@interface SegmentedView : NSObject <AbstractComponentClassProtocol>

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic) NSString *componentType;
@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSArray *positionArray;
@property (strong, nonatomic)NSDictionary *dataDictionary;
@property (assign, nonatomic) CGRect frame;
@property (weak, nonatomic) UIView *parentView;
@property (nonatomic) BOOL selectable;

@property (strong, nonatomic) NSArray *informationArray;
@property (strong, nonatomic) UISegmentedControl *segmentView;
@property (strong, nonatomic) UIColor *tintColor;
@property (assign, nonatomic) CGSize segmentSize;


-(instancetype)initWithDataDictionary: (NSDictionary *)dataDictionary andPlistDictionary: (NSDictionary *)plistDictionary;

//--------------------------
@property (strong, nonatomic) UIView *viewForEachPart;
@property (strong, nonatomic) UILabel *segmentTitle;
@property (strong, nonatomic) UISegmentedControl *secondSegmentView;
@property (assign, nonatomic) int segmentQuantity;


@end
