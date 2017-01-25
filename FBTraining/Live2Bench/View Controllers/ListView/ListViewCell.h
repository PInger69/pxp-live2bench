//
//  ListViewCell.h
//  Live2BenchNative
//
//  Created by dev on 13-02-19.
//  Copyright (c) 2013 DEV. All rights reserved.
//
#import "DeletableTableViewCell.h"
#import <UIKit/UIKit.h>
#import "UIFont+Default.h"
#import "ClipCornerView.h"
#import "DownloadButton.h"
#import "RatingOutput.h"
#import "Tag.h"

@interface ListViewCell : DeletableTableViewCell<UIScrollViewDelegate>{
    
    
}
@property (nonatomic, strong) UILabel *tagname;
@property (nonatomic, strong) UILabel *tagtime;
@property (nonatomic, strong) UILabel *tagtimeFromGameStart;
@property (nonatomic, strong) ClipCornerView *tagcolor;
@property (nonatomic, strong) UIButton *coachpickButton;
@property (nonatomic, strong) UIImageView *tagImage;
@property (nonatomic, strong) UIActivityIndicatorView *tagActivityIndicator;
@property (nonatomic) BOOL imageLoaded;
@property (nonatomic, strong) UITextView *tagInfoText;
@property (nonatomic, strong) UIScrollView *tagPlayersView;
@property (nonatomic, strong) UIButton *controlButton;
@property (nonatomic, strong) UILabel *playersNumberLabel;
@property (nonatomic, strong) UIView *translucentEditingView;
@property (nonatomic, strong) UILabel *playersLabel;
@property (nonatomic,strong) RatingOutput *ratingscale;
@property (nonatomic,strong) Tag *currentTag;



@end
