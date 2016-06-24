//
//  DurationTagButtonView.h
//  Live2BenchNative
//
//  Created by dev on 2016-05-31.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DurationTagButtonView : UIView
@property (nonatomic,strong) UILabel * nameLabel;
@property (nonatomic,strong) UILabel * timeLabel;
@property (nonatomic,assign) CGFloat    startTime;
@property (nonatomic,assign) BOOL hasPostedWarning;


@end
