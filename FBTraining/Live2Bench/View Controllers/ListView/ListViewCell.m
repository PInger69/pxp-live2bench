 //
//  ListViewCell.m
//  Live2BenchNative
//
//  Created by dev on 13-02-19.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "ListViewCell.h"
#import "RatingOutput.h"

//static CGFloat const kBounceValue = 10.0f;

@interface ListViewCell() <UIGestureRecognizerDelegate>



@end

@implementation ListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupView];
        
        
    }
    return self;
}
-(void)deleteButtonPressed{
    self.deleteBlock(self);
}

- (void) prepareForReuse
{
    
    self.tagImage.image             = [UIImage imageNamed:@"live.png"];
    self.tagname.text               = @"";
    self.tagtime.text               = @"";
    self.tagInfoText.text           = @"";
    self.tagcolor.backgroundColor   = nil;
    self.myContentView              = nil;
    self.playersLabel.text          = @"";
    self.playersNumberLabel.text    = @"";
    self.ratingscale.rating         = 0;
    
    [super prepareForReuse];
    
}



- (void)setupView
{
    [super setupView];
    

    UIView *anExtraView = [UIView new];
    anExtraView.backgroundColor = [UIColor whiteColor];

    self.myContentView = anExtraView;
    
    self.deleteButton.frame = CGRectMake(380, 0, 80, 155);
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.deleteButton setBackgroundColor:[UIColor redColor]];
    [self.contentView addSubview:self.deleteButton];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:anExtraView];

    self.tagImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live.png"]];
    self.tagImage.layer.borderColor = [[UIColor colorWithWhite:0.7f alpha:1.0f] CGColor];
    self.tagImage.layer.borderWidth = 1.0f;
    [self.tagImage setFrame:CGRectMake(0.0f, 0.0f, 230.0f, 155.0f)];
    [self.myContentView addSubview:self.tagImage];
    
    
    self.tagcolor = [[ClipCornerView alloc] initWithFrame:CGRectMake(self.tagImage.frame.size.width - 30, 0.0f, 30, 30)];
    [self.tagcolor setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [self.tagImage addSubview:self.tagcolor];
    
    self.tagname = [[UILabel alloc] initWithFrame:CGRectMake(self.tagImage.frame.origin.x + self.tagImage.frame.size.width + 44, self.tagImage.frame.origin.y +13, 150.0f, 18.0f)];
    //[self.tagtime setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [self.tagname setText:NSLocalizedString(@"Name", nil)];
    [self.tagname setBackgroundColor:[UIColor clearColor]];
    [self.tagname setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.myContentView addSubview:self.tagname];
    
    
    self.tagInfoText = [[UITextView alloc]initWithFrame:CGRectMake(self.tagname.frame.origin.x - 4, self.tagname.frame.origin.y + self.tagname.frame.size.height -5.0f, self.frame.size.width, 50)];
    //[self.tagInfoText setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.tagInfoText setBackgroundColor:[UIColor clearColor]];
    //[tagInfoText setText: [NSString stringWithFormat:@"%@: \n%@: ", NSLocalizedString(@"Duration", nil), NSLocalizedString(@"Period", nil)]];
    [self.tagInfoText setTextAlignment:NSTextAlignmentLeft];
    [self.tagInfoText setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.tagInfoText setEditable:FALSE];
    [self.tagInfoText setUserInteractionEnabled:FALSE];
    [self.myContentView addSubview:self.tagInfoText];
    
    self.playersLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.tagname.frame.origin.x+1, CGRectGetMaxY(self.tagInfoText.frame)-5.0f, 70, 25.0f)];
    //[playersLabel setText:NSLocalizedString(@"Player(s):", nil)];
    [self.playersLabel setTextAlignment:NSTextAlignmentLeft];
    [self.playersLabel setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.myContentView addSubview:self.playersLabel];
    
    //tagPlayersView = [[UIScrollView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(playersLabel.frame), CGRectGetMaxY(tagInfoText.frame)-5.0f ,self.frame.size.width - tagImage.frame.size.width-playersLabel.frame.size.width-20, 25.0f)];
    self.tagPlayersView = [[UIScrollView alloc]initWithFrame:CGRectMake(self.tagname.frame.origin.x+68, CGRectGetMaxY(self.tagInfoText.frame)-5.0f ,100.0f, 25.0f)];
    self.tagPlayersView.delegate = self;
    self.tagPlayersView.scrollEnabled = TRUE;
    self.tagPlayersView.showsHorizontalScrollIndicator = YES;
    //[tagPlayersView setBackgroundColor:[UIColor greenColor]];
    //[tagPlayersView setContentSize:CGSizeMake(1.5*tagPlayersView.frame.size.width, tagPlayersView.frame.size.height)];
    self.tagPlayersView.bounces = TRUE;
    [self.tagPlayersView setHidden:true];
    [self.myContentView addSubview:self.tagPlayersView];
    
    self.playersNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 5000, self.tagPlayersView.frame.size.height)];
    [self.playersNumberLabel setText:@""];
    [self.playersNumberLabel setTextAlignment:NSTextAlignmentLeft];
    [self.playersNumberLabel setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.tagPlayersView addSubview:self.playersNumberLabel];
    
    self.tagtime = [[UILabel alloc] initWithFrame:CGRectMake(self.tagImage.frame.size.width -72, self.tagImage.frame.size.height - 18.0f, 70.0f, 17.0f)];
    [self.tagtime setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [self.tagtime setText:NSLocalizedString(@"Time", nil)];
    [self.tagtime setTextAlignment:NSTextAlignmentCenter];
    [self.tagtime setBackgroundColor:[UIColor blackColor]];
    [self.tagtime setTextColor:[UIColor whiteColor]];
    [self.tagtime setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.tagImage addSubview:self.tagtime];
    
    
    
    self.tagtimeFromGameStart = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tagImage.frame.size.height - 18.0f, 78.0f, 17.0f)];
//    [self.tagtimeFromGameStart setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [self.tagtimeFromGameStart setText:NSLocalizedString(@"Time", nil)];
    [self.tagtimeFromGameStart setTextAlignment:NSTextAlignmentCenter];
    [self.tagtimeFromGameStart setBackgroundColor:[UIColor blackColor]];
    [self.tagtimeFromGameStart setTextColor:[UIColor whiteColor]];
    [self.tagtimeFromGameStart setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.tagImage addSubview:self.tagtimeFromGameStart];
    
   
    self.ratingscale = [ [RatingOutput alloc] initWithFrame:CGRectMake(self.tagImage.frame.size.width - 332, self.tagImage.frame.size.height - 26.0f, 70.0f, 17.0f)];
    [self.tagImage addSubview:self.ratingscale];

    
    //self.tagcolor.frame.size.width - 5*16.0f - 4*9.0f
    
    
    self.coachpickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.coachpickButton setBackgroundImage:[[UIImage imageNamed:@"coach"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.coachpickButton setBackgroundImage:[[UIImage imageNamed:@"coachPicked"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self.coachpickButton setFrame:CGRectMake(CGRectGetMaxX(self.tagImage.frame) + 44, CGRectGetMaxY(self.tagPlayersView.frame) + 5, 32.0f, 32.0f)];
    [self.coachpickButton addTarget:self action:@selector(coachPickSelected) forControlEvents:UIControlEventTouchUpInside];
    //[coachpickButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.myContentView addSubview:self.coachpickButton];
    

    _tagActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_tagActivityIndicator setFrame:CGRectMake((self.tagcolor.frame.size.width - _tagActivityIndicator.frame.size.width)/2, CGRectGetMaxY(self.tagcolor.frame) + 62.0f, 37.0f, 37.0f)];
    [self.myContentView addSubview:_tagActivityIndicator];
    
       NSArray *theConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
        [self.contentView addConstraints: theConstraints];
        self.contentViewLeftConstraint = theConstraints[0];
        self.contentViewRightConstraint = theConstraints[1];
    
        self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
        NSArray *theConstraintsAgain = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[theView]-0-|" options:0 metrics:nil views:@{@"theView":self.myContentView}];
        [self.contentView addConstraints: theConstraintsAgain];
    
        self.myContentView.translatesAutoresizingMaskIntoConstraints = NO;

    
    self.cellState = cellStateNormal;
    self.swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.swipeRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.swipeRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    for (UISwipeGestureRecognizer *previous in self.myContentView.gestureRecognizers) {
        [self.myContentView removeGestureRecognizer:previous];
    }
    [self.myContentView addGestureRecognizer:self.swipeRecognizerLeft];
    [self.myContentView addGestureRecognizer:self.swipeRecognizerRight];

}

-(void)setSelected:(BOOL)selected{
    if (selected) {
        [self.translucentEditingView removeFromSuperview];
        self.translucentEditingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.translucentEditingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self.translucentEditingView setBackgroundColor: self.tintColor];

        [self.translucentEditingView setAlpha:0.3];
        [self.translucentEditingView setUserInteractionEnabled:FALSE];
        [self insertSubview:self.translucentEditingView belowSubview:self.tagname];

    }else{

        [self.translucentEditingView removeFromSuperview];
        self.translucentEditingView = nil;
    }
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

-(void)coachPickSelected{
    if (!self.coachpickButton.selected) {
        [self.coachpickButton setSelected:true];
        _currentTag.coachPick = true;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_currentTag];
    }else if (self.coachpickButton.selected){
        [self.coachpickButton setSelected:false];
        _currentTag.coachPick = false;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_currentTag];
    }
}

-(void)setCurrentTag:(Tag *)currentTag{
    if (currentTag.coachPick) {
        [self.coachpickButton setSelected:true];
    }else{
        [self.coachpickButton setSelected:false];
    }
    _currentTag = currentTag;
}


@end


