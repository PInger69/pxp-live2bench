//
//  StatsCell.h
//  Live2BenchNative
//
//  Created by DEV on 1/7/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BorderButton.h"

@interface StatsCell : UITableViewCell

@property(nonatomic,strong)NSMutableArray *columns;
//@property(nonatomic,strong)NSMutableDictionary *columnButtonPositions;
@property(nonatomic) int columnNumber;
@property(nonatomic) int gridCellWidth;
@property(nonatomic) int titleLabelWidth;

-(void)addColumns:(int)columnNumber :(int)gridCellWidth :(int)titleLabelWidth;


@end
