//
//  ListViewCell.m
//  Live2BenchNative
//
//  Created by dev on 13-02-19.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "ListViewCell.h"

@implementation ListViewCell

@synthesize tagname,tagtime,tagImage,coachpickButton,bookmarkButton,tagInfoText,controlButton,tagPlayersView,playersNumberLabel;
@synthesize translucentEditingView,checkmarkOverlay;
@synthesize playersLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    
    self.tagImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live.png"]];
    self.tagImage.contentMode = UIViewContentModeCenter;
    self.tagImage.layer.borderColor = [[UIColor colorWithWhite:0.7f alpha:1.0f] CGColor];
    self.tagImage.layer.borderWidth = 1.0f;
    [self.tagImage setFrame:CGRectMake(10.0f, 10.0f, 175.0f, 150.0f)];
    CGRect aspectRect = [self frameWithAspectRatioForImage:self.tagImage withFrame:self.tagImage.frame];
    [self.tagImage setFrame:aspectRect];
    [self.tagImage setAutoresizingMask: UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [self addSubview:self.tagImage];
        
    self.tagcolor = [[ClipCornerView alloc] initWithFrame:CGRectMake(self.tagImage.frame.size.width - 30, 0.0f, 30, 30)];
    [self.tagcolor setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    self.tagcolor.layer.masksToBounds = YES;
    self.tagcolor.layer.cornerRadius = 1; // if you like rounded corners
    self.tagcolor.layer.shadowOffset = CGSizeMake(-1, 0);
    self.tagcolor.layer.shadowRadius = 2;
    self.tagcolor.layer.shadowOpacity = 0.8;
    [self.tagImage addSubview:self.tagcolor];
    
    tagname = [[UILabel alloc] initWithFrame:CGRectMake(tagImage.frame.origin.x + tagImage.frame.size.width + 60, tagImage.frame.origin.y +13, 150.0f, 18.0f)];
    [self.tagtime setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [tagname setText:@"Name"];
    [tagname setBackgroundColor:[UIColor clearColor]];
    [tagname setFont:[UIFont defaultFontOfSize:17.0f]];
    [self addSubview:tagname];
    
    
    tagInfoText = [[UITextView alloc]initWithFrame:CGRectMake(tagname.frame.origin.x-2 , tagname.frame.origin.y + tagname.frame.size.height -5.0f, self.frame.size.width, 50)];
    [self.tagInfoText setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [tagInfoText setBackgroundColor:[UIColor clearColor]];
    [tagInfoText setText:@"Duration: \nPeriod: "];
    [tagInfoText setTextAlignment:NSTextAlignmentLeft];
    [tagInfoText setFont:[UIFont defaultFontOfSize:17.0f]];
    [tagInfoText setEditable:FALSE];
    [tagInfoText setUserInteractionEnabled:FALSE];
    [self addSubview:tagInfoText];
    
    playersLabel = [[UILabel alloc]initWithFrame:CGRectMake(tagname.frame.origin.x+3, CGRectGetMaxY(tagInfoText.frame)-5.0f, 70, 25.0f)];
    [playersLabel setText:@"Player(s):"];
    [playersLabel setTextAlignment:NSTextAlignmentLeft];
    [playersLabel setFont:[UIFont defaultFontOfSize:17.0f]];
    [self addSubview:playersLabel];
    
    tagPlayersView = [[UIScrollView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(playersLabel.frame), CGRectGetMaxY(tagInfoText.frame)-5.0f ,self.frame.size.width - tagImage.frame.size.width-playersLabel.frame.size.width-20, 25.0f)];
    tagPlayersView.delegate = self;
    tagPlayersView.scrollEnabled = TRUE;
    tagPlayersView.showsHorizontalScrollIndicator = YES;
    [tagPlayersView setContentSize:CGSizeMake(1.5*tagPlayersView.frame.size.width, tagPlayersView.frame.size.height)];
    tagPlayersView.bounces = TRUE;
    [self addSubview:tagPlayersView];
    
    playersNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tagPlayersView.frame.size.width, tagPlayersView.frame.size.height)];
    [playersNumberLabel setText:@""];
    [playersNumberLabel setTextAlignment:NSTextAlignmentLeft];
    [playersNumberLabel setFont:[UIFont defaultFontOfSize:17.0f]];
    [tagPlayersView addSubview:playersNumberLabel];
    
    tagtime = [[UILabel alloc] initWithFrame:CGRectMake(tagImage.frame.size.width -72, tagImage.frame.size.height - 40.0f, 70.0f, 17.0f)];
    [self.tagtime setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [tagtime setText:@"Time"];
    [tagtime setTextAlignment:NSTextAlignmentCenter];
    [tagtime setBackgroundColor:[UIColor blackColor]];
    [tagtime setTextColor:[UIColor whiteColor]];
    [tagtime setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.tagImage addSubview:tagtime];
    
    //self.tagcolor.frame.size.width - 5*16.0f - 4*9.0f
    self.tagRatingFive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.tagRatingFive setContentMode:UIViewContentModeScaleAspectFit];
    [self.tagRatingFive setFrame:CGRectMake(20, 110.0f, 16.0f, 16.0f)];
    [self addSubview:self.tagRatingFive];
    
    self.tagRatingFour = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.tagRatingFour setContentMode:UIViewContentModeScaleAspectFit];
    [self.tagRatingFour setFrame:CGRectMake(CGRectGetMaxX(self.tagRatingFive.frame) + 9.0f, 110.0f, 16.0f, 16.0f)];
    [self addSubview:self.tagRatingFour];
    
    self.tagRatingThree = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.tagRatingThree setContentMode:UIViewContentModeScaleAspectFit];
    [self.tagRatingThree setFrame:CGRectMake(CGRectGetMaxX(self.tagRatingFour.frame) + 9.0f, 110.0f, 16.0f, 16.0f)];
    [self addSubview:self.tagRatingThree];
    
    self.tagRatingTwo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.tagRatingTwo setContentMode:UIViewContentModeScaleAspectFit];
    [self.tagRatingTwo setFrame:CGRectMake(CGRectGetMaxX(self.tagRatingThree.frame) + 9.0f, 110.0f, 16.0f, 16.0f)];
    [self addSubview:self.tagRatingTwo];
    
    self.tagRatingOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.tagRatingOne setContentMode:UIViewContentModeScaleAspectFit];
    [self.tagRatingOne setFrame:CGRectMake(CGRectGetMaxX(self.tagRatingTwo.frame) + 9.0f, 110.0f, 16.0f, 16.0f)];
    [self addSubview:self.tagRatingOne];
    
    coachpickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [coachpickButton setBackgroundImage:[UIImage imageNamed:@"coach.png"] forState:UIControlStateNormal];
    [coachpickButton setBackgroundImage:[UIImage imageNamed:@"coachPicked.png"] forState:UIControlStateSelected];
    [coachpickButton setFrame:CGRectMake(CGRectGetMaxX(tagImage.frame) + 15.0f, CGRectGetMaxY(tagPlayersView.frame) + 5, 32.0f, 32.0f)];
    [coachpickButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self addSubview:coachpickButton];
    
    bookmarkButton = [DownloadButton buttonWithType:UIButtonTypeCustom];
    [bookmarkButton setState:DBDefault];
    [bookmarkButton setFrame:CGRectMake(CGRectGetMaxX(coachpickButton.frame) + 20.0f, coachpickButton.frame.origin.y, 32.0f, 32.0f)];
    [bookmarkButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self addSubview:bookmarkButton];
    
    tagActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [tagActivityIndicator setFrame:CGRectMake((self.tagcolor.frame.size.width - tagActivityIndicator.frame.size.width)/2, CGRectGetMaxY(self.tagcolor.frame) + 62.0f, 37.0f, 37.0f)];
    [self addSubview:tagActivityIndicator];
    
    translucentEditingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [translucentEditingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [translucentEditingView setBackgroundColor: [UIColor colorWithRed:255/255.0f green:206/255.0f blue:119/255.0f alpha:1.0f]];
    [translucentEditingView setAlpha:0.3];
    [translucentEditingView setUserInteractionEnabled:FALSE];
    [self addSubview:translucentEditingView];
    
    checkmarkOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 110, coachpickButton.frame.origin.y, 70, 70)];//cell.bounds];
    [checkmarkOverlay setImage:[UIImage imageNamed:@"checkmarkOverlay"]];
    [checkmarkOverlay setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [checkmarkOverlay setAlpha:1.0];
    [self addSubview:checkmarkOverlay];


}

-(CGRect)frameWithAspectRatioForImage:(UIImageView *)value withFrame:(CGRect)screenRect
{
    float hfactor = value.bounds.size.width / screenRect.size.width;
    float vfactor = value.bounds.size.height / screenRect.size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = value.bounds.size.width / factor;
    float newHeight = value.bounds.size.height / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = 2;//(screenRect.size.width - newWidth) / 2;
    float topOffset = 2;//(screenRect.size.height - newHeight) / 2;
    
    CGRect newRect = CGRectMake(leftOffset, topOffset, newWidth, newHeight);
    return newRect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
