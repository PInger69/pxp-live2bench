//
//  SocialProgressView.m
//  Live2BenchNative
//
//  Created by dev on 2015-03-18.
//  Copyright (c) 2015 DEV. All rights reserved.
//

#import "SocialProgressView.h"

@interface SocialProgressView()

@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation SocialProgressView

-(instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.layer.cornerRadius = 2.0;
        self.layer.borderWidth = 1.0;
        
        CGRect subviewRect =CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        self.progressView = [[UIProgressView alloc] initWithFrame: subviewRect];
        self.progressView.tintColor = [UIColor orangeColor];
        [self.progressView setProgress:0.0];
        [self addSubview: self.progressView];
        
        self.taskLabel = [[UILabel alloc] initWithFrame: subviewRect];
        self.taskLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview: self.taskLabel];
    }
    return self;
}

-(void)setTasksCompleted:(int)tasksCompleted{
    _tasksCompleted = tasksCompleted;
    [self.progressView setProgress: (_tasksCompleted/_tasksToComplete) animated:YES];
    if (_tasksCompleted == _tasksToComplete) {
        _tasksToComplete = 0;
        _tasksCompleted = 0;
        [self.taskLabel setText: @"Progress Completed"];
    }
}

-(void)setTasksToComplete:(int)tasksToComplete{
    _tasksToComplete = tasksToComplete;
    [self.progressView setProgress: (_tasksCompleted/_tasksToComplete) animated:YES];
}

@end
