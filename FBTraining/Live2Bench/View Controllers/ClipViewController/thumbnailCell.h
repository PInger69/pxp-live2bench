//
//  thumbnailCell.h
//  Live2BenchNative
//
//  Created by DEV on 2013-01-30.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "ClipCornerView.h"
#import "RatingOutput.h"

@class Tag;

@interface thumbnailCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *backgroundPlaneView;
@property(nonatomic,strong)  UIButton* thumbDeleteButton;
@property (nonatomic,strong) UIActivityIndicatorView *activityInd;
@property (nonatomic,strong) ClipCornerView *thumbColour;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UILabel *thumbPeriod;
@property (strong,nonatomic) UILabel *thumbTime;
@property (strong,nonatomic) UILabel *thumbGameTime;
@property (strong,nonatomic) UILabel *thumbDur;
@property (strong, nonatomic) UILabel *thumbName;
@property (nonatomic) BOOL imageLoaded;
@property (nonatomic,strong) UIView *translucentEditingView;
@property (nonatomic,strong) UIImageView *checkmarkOverlay;
@property (nonatomic,strong) Tag *data;
@property (nonatomic,strong) RatingOutput *ratingscale;

@property (nonatomic, assign) NSUInteger instanceNumber;

-(void)setDeletingMode: (BOOL) mode;

@end
