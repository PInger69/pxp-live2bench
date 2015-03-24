//
//  RangeSlider.h
//  RangeSlider
//
//  Created by dev on 2015-02-02.
//  Copyright (c) 2015 Avoca Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterComponent.h"
#import "FilterProcessor.h"

@interface RangeSlider : UIControl <FilterComponent>

@property (nonatomic) Float64 highestValue;
@property (nonatomic) Float64 lowestValue;




@property (nonatomic) UIColor* trackColour;
@property (nonatomic) UIColor* trackHighlightColour;
@property (nonatomic) UIColor* knobColour;
@property (nonatomic) float curvaceousness;
@property (nonatomic) float knobBorderThickness;


// Filter Component Methods
@property (strong,nonatomic) id <FilterComponent>       previous;
@property (strong,nonatomic) id <FilterComponent>       next;
@property (strong, nonatomic) NSString                  *name;
@property (assign, nonatomic) BOOL                      invoked;
@property (nonatomic)        id                         selTarget;
@property (nonatomic)        SEL                        onSelectSelector;
@property (nonatomic, strong) NSMutableSet              *selectedTags;
@property (strong,nonatomic) FilterProcessor            * filterP;
@property (strong,nonatomic) NSString                   * (^filterBlock)(NSDictionary*tag);
@property (strong, nonatomic) NSMutableArray            * arrayOfTags;


-(instancetype)initWithFrame: (CGRect) frame Name: (NSString *)name AccessLable: (NSString *)accessLabel;
@end
