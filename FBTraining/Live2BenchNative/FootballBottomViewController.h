//
//  FootballBottomViewController.h
//  Live2BenchNative
//
//  Created by DEV on 2013-08-14.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractBottomViewController.h"
#import "BottomViewControllerProtocol.h"


typedef NS_OPTIONS (NSInteger,FootballModes){
    
    FootballDisable,
    FootballOffenseStart,
    FootballDefenseStart,
    FootballOffenseCalculate,
    FootballDefenseCalculate,
    FootballOffenseSend,
    FootballDefenseSend
};


@interface FootballBottomViewController : AbstractBottomViewController <BottomViewControllerProtocol,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,strong) NSMutableArray *playCallOppData;
@property (nonatomic,strong) NSMutableArray *playCallData;


@end
