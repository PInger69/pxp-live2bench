//
//  ShareOptionsViewController.m
//  Live2BenchNative
//
//  Created by 漠川 阮 on 15/3/17.
//  Copyright (c) 2015年 DEV. All rights reserved.
//

#import "ShareOptionsViewController.h"

@interface ShareOptionsViewController ()

@property (strong, nonatomic) NSArray *shareOptions;
@property (strong, nonatomic) NSMutableArray *optionButtons;

@end

@implementation ShareOptionsViewController{
    id buttonTarget;
    SEL selectorToCall;
}

- (instancetype)initWithArray:(NSArray *)Options andIcons:(NSArray *)optionIcons andSelectedIcons: (NSArray *)selectedIcons {
    self = [super init];
    if (self) {
        self.shareOptions = Options;
        self.optionButtons = [NSMutableArray array];
        
        CGFloat width = 60.0f;
        CGFloat height = 60.0f;
        
        int i = 1;
        for (NSString *shareOption in self.shareOptions) {
            CGFloat horizontalGap = (280 - 60*3) / 4;
            CGFloat verticalGap = (180 - 60*2) / 3;
            CGFloat xPosition = (((i-1) % 3) + 1)*horizontalGap + ((i-1) % 3)*width;
            CGFloat yPosition = (i/4 + 1)*verticalGap + (i/4)*height;
            
            UIButton *optionButton = [[UIButton alloc] initWithFrame:CGRectMake(xPosition, yPosition, width, height)];
            [optionButton setImage: optionIcons[i-1] forState: UIControlStateNormal];
            [optionButton setImage: selectedIcons[i-1] forState: UIControlStateHighlighted];
            
            [optionButton setTitle:shareOption forState:UIControlStateNormal];
            [optionButton addTarget:self action:@selector(shareOptionChosen:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:optionButton];
            [self.optionButtons addObject:optionButton];
            
            i++;
        }
    }
    return self;
}

- (void)setOnSelectTarget: (id)target andSelector: (SEL) selector{
    buttonTarget = target;
    selectorToCall = selector;
}

- (void)shareOptionChosen:(UIButton *)sender {
    NSString *optionChosen = sender.titleLabel.text;
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [buttonTarget performSelector:selectorToCall withObject:optionChosen];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
