//
//  ListViewCell.h
//  Live2BenchNative
//
//  Created by dev on 13-02-19.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+Default.h"
#import "ClipCornerView.h"
#import "DownloadButton.h"

@interface ListViewCell : UITableViewCell<UIScrollViewDelegate>{

    UILabel *tagname;
    UILabel *tagtime;
    ClipCornerView *tagcolor;
    UIButton *coachpickButton;
    DownloadButton *bookmarkButton;
    UIImageView *tagImage;
    UIActivityIndicatorView *tagActivityIndicator;
    UIImageView *tagRatingOne;
    UIImageView *tagRatingTwo;
    UIImageView *tagRatingThree;
    UIImageView *tagRatingFour;
    UIImageView *tagRatingFive;
    UITextView *tagInfoText;
    UIScrollView *tagPlayersView;
    UILabel *playersNumberLabel;
    UILabel *playersLabel;
    UIButton *controlButton;
    UIView *translucentEditingView;
    UIImageView *checkmarkOverlay;
}
@property (nonatomic, strong) UILabel *tagname;
@property (nonatomic, strong) UILabel *tagtime;
@property (nonatomic, strong) ClipCornerView *tagcolor;
@property (nonatomic, strong) UIButton *coachpickButton;
@property (nonatomic, strong) DownloadButton *bookmarkButton;
@property (nonatomic, strong) UIImageView *tagImage;
@property (nonatomic, strong) UIActivityIndicatorView *tagActivityIndicator;
@property (nonatomic, strong) UIImageView *tagRatingOne;
@property (nonatomic, strong) UIImageView *tagRatingTwo;
@property (nonatomic, strong) UIImageView *tagRatingThree;
@property (nonatomic, strong) UIImageView *tagRatingFour;
@property (nonatomic, strong) UIImageView *tagRatingFive;
@property (nonatomic) BOOL imageLoaded;
@property (nonatomic, strong) UITextView *tagInfoText;
@property (nonatomic, strong) UIScrollView *tagPlayersView;
@property (nonatomic, strong) UIButton *controlButton;
@property (nonatomic, strong) UILabel *playersNumberLabel;
@property (nonatomic, strong) UIView *translucentEditingView;
@property (nonatomic, strong) UIImageView *checkmarkOverlay;
@property (nonatomic, strong) UILabel *playersLabel;

@end
