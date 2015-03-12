//
//  DurationView.h
//  Live2BenchNative
//
//  Created by dev on 8/7/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FilterComponentAbstract.h"
#import "FilterProcessor.h"

@interface DurationView : FilterComponentAbstract
@property (strong,nonatomic) UILabel                    * label;
@property (assign,nonatomic) CGSize                     buttonSize; // used only during populate method

- (id)initWithFrame:(CGRect)frame Name:(NSString*)name;
- (id)initWithFrame:(CGRect)frame Name:(NSString*)name dict:(NSMutableDictionary*)dictOfPredicates;

-(void)populate:(NSArray *)list;
-(void)deselectAll;
-(void)update;

-(void)inputArray:(NSArray*)list;
-(NSArray*)refinedList;
@end
