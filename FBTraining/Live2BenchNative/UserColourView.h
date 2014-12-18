//
//  UserColourView.h
//  Live2BenchNative
//
//  Created by dev on 7/22/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FilterScrollView.h"
#import "FilterComponentAbstract.h"


@interface UserColourView : FilterComponentAbstract
@property (strong,nonatomic) UILabel                    * label;
@property (assign,nonatomic) CGSize                     buttonSize; // used only during populate method
- (id)initWithFrame:(CGRect)frame Name:(NSString*)nme AccessLable:(NSString*)aLabel;


-(void)populate:(NSArray *)list;
-(void)deselectAll;
-(void)update;
//-(void)setFilterBlock:(NSString* (^)(NSDictionary*))madeKey;
-(void)inputArray:(NSArray*)list;
-(NSArray*)refinedList;

@end
