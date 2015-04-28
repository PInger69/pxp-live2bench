//
//  CalendarBar.m
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/2/23.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "CalendarBar.h"

@interface CalendarBar ()

@property (nonatomic, strong) NSMutableArray *arrayOfButtonsInBar;

@end

@implementation CalendarBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame andIndex:(int)index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
        self.layer.borderWidth = 1.0f;
        
        if (index == 1) {
            UIButton *game = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
            [game setTitle:@"Recent Games" forState:UIControlStateNormal];
            UIButton *date = [[UIButton alloc] initWithFrame:CGRectMake(300, 0, 180, 50)];
            [date setTitle:@"Date" forState:UIControlStateNormal];
            UIButton *download = [[UIButton alloc] initWithFrame:CGRectMake(480, 0, 170, 50)];
            [download setTitle:@"Download" forState:UIControlStateNormal];
            UIButton *open = [[UIButton alloc] initWithFrame:CGRectMake(650, 0, 150, 50)];
            [open setTitle:@"Open" forState:UIControlStateNormal];
            
            self.arrayOfButtonsInBar = [NSMutableArray arrayWithObjects:game, date, download, open, nil];
            for (UIButton *button in self.arrayOfButtonsInBar) {
                [self addSubview:button];
                button.titleLabel.textAlignment = NSTextAlignmentCenter;
                //button.titleLabel.textColor = [UIColor orangeColor];
                [button setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
                //button.titleLabel.tintColor = [UIColor orangeColor];
                //button.titleLabel.font = [UIFont systemFontOfSize:17.0];
                [button.titleLabel setFont:[UIFont systemFontOfSize:22.0]];
                button.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
                button.layer.borderWidth = 0.5f;
                
                button.backgroundColor = [UIColor whiteColor];
            }
        } else {
            UIButton *game = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 380, 50)];
            [game setTitle:@"Previous Games" forState:UIControlStateNormal];
            UIButton *download = [[UIButton alloc] initWithFrame:CGRectMake(380, 0, 280, 50)];
            [download setTitle:@"Download" forState:UIControlStateNormal];
            UIButton *open = [[UIButton alloc] initWithFrame:CGRectMake(660, 0, 140, 50)];
            [open setTitle:@"Open" forState:UIControlStateNormal];
            
            self.arrayOfButtonsInBar = [NSMutableArray arrayWithObjects:game, download, open, nil];
            for (UIButton *button in self.arrayOfButtonsInBar) {
                [self addSubview:button];
                button.titleLabel.textAlignment = NSTextAlignmentCenter;
                button.titleLabel.textColor = PRIMARY_APP_COLOR;
                //button.titleLabel.tintColor = [UIColor orangeColor];
                //button.titleLabel.font = [UIFont systemFontOfSize:17.0];
                [button.titleLabel setFont:[UIFont systemFontOfSize:22.0]];
                [button setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateNormal];
                button.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
                button.layer.borderWidth = 0.5f;
                
                button.backgroundColor = [UIColor whiteColor];
            }
        }
    }
    
    return self;
}

@end
