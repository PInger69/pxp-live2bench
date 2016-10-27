//
//  ListViewCell.m
//  Live2BenchNative
//
//  Created by dev on 13-02-19.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "ListViewCell.h"
#import "RatingOutput.h"
#import "ListTableViewController.h"




//static CGFloat const kBounceValue = 10.0f;

@interface ListViewCell() <UIGestureRecognizerDelegate>



@end

@implementation ListViewCell

@synthesize tagname,tagtime,tagImage,coachpickButton,tagInfoText,controlButton,tagPlayersView,playersNumberLabel;
@synthesize translucentEditingView;
//checkmarkOverlay;
@synthesize playersLabel;
@synthesize ratingscale;

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
    /*
    self.tagcolor.layer.masksToBounds = NO;
    self.tagcolor.layer.cornerRadius = 1; // if you like rounded corners
    self.tagcolor.layer.shadowOffset = CGSizeMake(-1, 0);
    self.tagcolor.layer.shadowRadius = 2;
    self.tagcolor.layer.shadowOpacity = 0.8;
     */
    [self.tagImage addSubview:self.tagcolor];
    
    tagname = [[UILabel alloc] initWithFrame:CGRectMake(tagImage.frame.origin.x + tagImage.frame.size.width + 44, tagImage.frame.origin.y +13, 150.0f, 18.0f)];
    //[self.tagtime setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [tagname setText:NSLocalizedString(@"Name", nil)];
    [tagname setBackgroundColor:[UIColor clearColor]];
    [tagname setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.myContentView addSubview:tagname];
    
    
    tagInfoText = [[UITextView alloc]initWithFrame:CGRectMake(tagname.frame.origin.x - 4, tagname.frame.origin.y + tagname.frame.size.height -5.0f, self.frame.size.width, 50)];
    //[self.tagInfoText setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [tagInfoText setBackgroundColor:[UIColor clearColor]];
    //[tagInfoText setText: [NSString stringWithFormat:@"%@: \n%@: ", NSLocalizedString(@"Duration", nil), NSLocalizedString(@"Period", nil)]];
    [tagInfoText setTextAlignment:NSTextAlignmentLeft];
    [tagInfoText setFont:[UIFont defaultFontOfSize:17.0f]];
    [tagInfoText setEditable:FALSE];
    [tagInfoText setUserInteractionEnabled:FALSE];
    [self.myContentView addSubview:tagInfoText];
    
    playersLabel = [[UILabel alloc]initWithFrame:CGRectMake(tagname.frame.origin.x+1, CGRectGetMaxY(tagInfoText.frame)-5.0f, 70, 25.0f)];
    //[playersLabel setText:NSLocalizedString(@"Player(s):", nil)];
    [playersLabel setTextAlignment:NSTextAlignmentLeft];
    [playersLabel setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.myContentView addSubview:playersLabel];
    
    //tagPlayersView = [[UIScrollView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(playersLabel.frame), CGRectGetMaxY(tagInfoText.frame)-5.0f ,self.frame.size.width - tagImage.frame.size.width-playersLabel.frame.size.width-20, 25.0f)];
    tagPlayersView = [[UIScrollView alloc]initWithFrame:CGRectMake(tagname.frame.origin.x+68, CGRectGetMaxY(tagInfoText.frame)-5.0f ,100.0f, 25.0f)];
    tagPlayersView.delegate = self;
    tagPlayersView.scrollEnabled = TRUE;
    tagPlayersView.showsHorizontalScrollIndicator = YES;
    //[tagPlayersView setBackgroundColor:[UIColor greenColor]];
    //[tagPlayersView setContentSize:CGSizeMake(1.5*tagPlayersView.frame.size.width, tagPlayersView.frame.size.height)];
    tagPlayersView.bounces = TRUE;
    [tagPlayersView setHidden:true];
    [self.myContentView addSubview:tagPlayersView];
    
    playersNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 5000, tagPlayersView.frame.size.height)];
    [playersNumberLabel setText:@""];
    [playersNumberLabel setTextAlignment:NSTextAlignmentLeft];
    [playersNumberLabel setFont:[UIFont defaultFontOfSize:17.0f]];
    [tagPlayersView addSubview:playersNumberLabel];
    
    tagtime = [[UILabel alloc] initWithFrame:CGRectMake(tagImage.frame.size.width -72, tagImage.frame.size.height - 18.0f, 70.0f, 17.0f)];
    [self.tagtime setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [tagtime setText:NSLocalizedString(@"Time", nil)];
    [tagtime setTextAlignment:NSTextAlignmentCenter];
    [tagtime setBackgroundColor:[UIColor blackColor]];
    [tagtime setTextColor:[UIColor whiteColor]];
    [tagtime setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.tagImage addSubview:tagtime];
    
    
    
    self.tagtimeFromGameStart = [[UILabel alloc] initWithFrame:CGRectMake(0, tagImage.frame.size.height - 18.0f, 78.0f, 17.0f)];
//    [self.tagtimeFromGameStart setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
    [self.tagtimeFromGameStart setText:NSLocalizedString(@"Time", nil)];
    [self.tagtimeFromGameStart setTextAlignment:NSTextAlignmentCenter];
    [self.tagtimeFromGameStart setBackgroundColor:[UIColor blackColor]];
    [self.tagtimeFromGameStart setTextColor:[UIColor whiteColor]];
    [self.tagtimeFromGameStart setFont:[UIFont defaultFontOfSize:17.0f]];
    [self.tagImage addSubview:self.tagtimeFromGameStart];
    
   
    self.ratingscale = [ [RatingOutput alloc] initWithFrame:CGRectMake(tagImage.frame.size.width - 332, tagImage.frame.size.height - 26.0f, 70.0f, 17.0f)];
    [self.tagImage addSubview:ratingscale];

    
    //self.tagcolor.frame.size.width - 5*16.0f - 4*9.0f
    
    
    coachpickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [coachpickButton setBackgroundImage:[[UIImage imageNamed:@"coach.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [coachpickButton setBackgroundImage:[[UIImage imageNamed:@"coachPicked.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [coachpickButton setFrame:CGRectMake(CGRectGetMaxX(tagImage.frame) + 44, CGRectGetMaxY(tagPlayersView.frame) + 5, 32.0f, 32.0f)];
    [coachpickButton addTarget:self action:@selector(coachPickSelected) forControlEvents:UIControlEventTouchUpInside];
    //[coachpickButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.myContentView addSubview:coachpickButton];
    

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
    if (!coachpickButton.selected) {
        [coachpickButton setSelected:true];
        _currentTag.coachPick = true;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_currentTag];
    }else if (coachpickButton.selected){
        [coachpickButton setSelected:false];
        _currentTag.coachPick = false;
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIF_MODIFY_TAG object:_currentTag];
    }
}

-(void)setCurrentTag:(Tag *)currentTag{
    if (currentTag.coachPick) {
        [coachpickButton setSelected:true];
    }else{
        [coachpickButton setSelected:false];
    }
    _currentTag = currentTag;
}


@end


