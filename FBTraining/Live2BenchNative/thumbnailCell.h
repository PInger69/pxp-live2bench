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
{
    UIImageView *imageView;
//    UILabel *_thumbPeriod;
//    UILabel *_thumbTime;
//    UILabel *_thumbDur;
    ClipCornerView *_thumbColour;
//    UILabel *_thumbName;
    UIActivityIndicatorView *_activityInd;
    CustomButton *_thumbDeleteButton;
    NSIndexPath *_iPath;
    UIView *translucentEditingView;
    UIImageView *checkmarkOverlay;
}

@property (nonatomic,strong) UIImageView *backgroundView;
@property (nonatomic,strong) NSIndexPath *iPath;
@property(nonatomic,strong)  CustomButton *thumbDeleteButton;
@property (nonatomic,strong) UIActivityIndicatorView *activityInd;
@property (nonatomic,strong) ClipCornerView *thumbColour;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong,nonatomic) UILabel *thumbPeriod;
@property (strong,nonatomic) UILabel *thumbTime;
@property (strong,nonatomic) UILabel *thumbDur;
@property (strong, nonatomic) UILabel *thumbName;
//@property (strong, nonatomic) UIImageView *thumbRatingOne;
//@property (strong, nonatomic) UIImageView*thumbRatingTwo;
//@property (strong, nonatomic) UIImageView *thumbRatingThree;
//@property (strong, nonatomic) UIImageView *thumbRatingFour;
//@property (strong, nonatomic) UIImageView *thumbRatingFive;
@property (nonatomic) BOOL imageLoaded;
@property (nonatomic,strong) UIView *translucentEditingView;
@property (nonatomic,strong) UIImageView *checkmarkOverlay;
@property (nonatomic,strong) Tag *data;
@property (nonatomic,strong) RatingOutput *ratingscale;

-(void)setDeletingMode: (BOOL) mode;


//- (void)didDeleteThumbnail:(id)sender;
@end
