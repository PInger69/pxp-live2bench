//
//  thumbnailCell.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-30.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "thumbnailCell.h"
#import "Tag.h"

#define PADDING             5

@implementation thumbnailCell

@synthesize imageView;
@synthesize thumbName=_thumbName;
@synthesize thumbTime=_thumbTime;
@synthesize thumbDur=_thumbDur;
@synthesize thumbColour=_thumbColour;
@synthesize activityInd=_activityInd;
@synthesize thumbPeriod = _thumbPeriod;
@synthesize thumbRatingOne = _thumbRatingOne;
@synthesize thumbRatingTwo = _thumbRatingTwo;
@synthesize thumbRatingThree = _thumbRatingThree;
@synthesize thumbRatingFour = _thumbRatingFour;
@synthesize thumbRatingFive = _thumbRatingFive;
@synthesize thumbDeleteButton=_thumbDeleteButton;
@synthesize iPath=_iPath;
@synthesize imageLoaded;
@synthesize backgroundView=_backgroundView;
@synthesize translucentEditingView;
@synthesize checkmarkOverlay;
@synthesize data = _data;

- (id)init
{
    self = [super init];
    if (self) {
        [self setupView];
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupView];

    }
    return self;
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

- (void)setupView
{
    
    self.backgroundView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//    [self.backgroundView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self.backgroundView setAutoresizingMask: UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.backgroundView setImage:[UIImage imageNamed:@"clip-back-just.png"]];
    [self addSubview:self.backgroundView];
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live.png"]];
    //self.imageView.contentMode = UIViewContentModeCenter;
    [self.imageView setFrame:CGRectMake(2, 2, self.backgroundView.bounds.size.width - 5, 131.0f)];
    //CGRect aspectRect = [self frameWithAspectRatioForImage:self.imageView withFrame:self.imageView.frame];
    //[self.imageView setFrame:aspectRect];
    //[self.imageView setAutoresizingMask: UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [self.backgroundView addSubview:self.imageView];
    
    self.thumbColour = [[ClipCornerView alloc] initWithFrame:CGRectMake(self.imageView.frame.size.width-30, 0.0f, 30, 30)];
    [self.thumbColour setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    self.thumbColour.layer.masksToBounds = YES;
    self.thumbColour.layer.cornerRadius = 1; // if you like rounded corners
    self.thumbColour.layer.shadowOffset = CGSizeMake(-1, 0);
    self.thumbColour.layer.shadowRadius = 2;
    self.thumbColour.layer.shadowOpacity = 0.8;
    [self.imageView addSubview:self.thumbColour];
   
    self.thumbName = [[UILabel alloc] initWithFrame:CGRectMake(self.imageView.frame.origin.x+PADDING, 140.0f, self.imageView.bounds.size.width*3/4, 18.0f)];
    [self.thumbName setText:@"Name"];
    [self.thumbName setTextColor:[UIColor darkGrayColor]];
    [self.thumbName setBackgroundColor:[UIColor clearColor]];
    [self.thumbName setFont:[UIFont systemFontOfSize:17.0f]];
    [self addSubview:self.thumbName];
    
    self.thumbPeriod = [[UILabel alloc] initWithFrame:CGRectMake(self.thumbName.frame.origin.x+PADDING, CGRectGetMaxY(self.thumbName.frame), self.imageView.bounds.size.width/2, 18.0f)];
    [self.thumbPeriod setText:@"Period"];
    [self.thumbPeriod setTextColor:[UIColor darkGrayColor]];
    [self.thumbPeriod setBackgroundColor:[UIColor clearColor]];
    [self.thumbPeriod setFont:[UIFont systemFontOfSize:17.0f]];
//    [self addSubview:self.thumbPeriod];
    
    self.thumbDur = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbName.frame)-(7*PADDING), self.thumbName.frame.origin.y, self.imageView.bounds.size.width/3 + 2*PADDING, 18.0f)];
    [self.thumbDur setText:@"s"];
    [self.thumbDur setTextAlignment:NSTextAlignmentRight];
    [self.thumbDur setTextColor:[UIColor darkGrayColor]];
    [self.thumbDur setBackgroundColor:[UIColor clearColor]];
    [self.thumbDur setFont:[UIFont systemFontOfSize:17.0f]];
    [self addSubview:self.thumbDur];
    
    
    self.thumbTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbPeriod.frame)-(3*PADDING), CGRectGetMaxY(self.thumbDur.frame), self.imageView.bounds.size.width/2, 18.0f)];
    [self.thumbTime setText:@"Time"];
    [self.thumbTime setTextAlignment:NSTextAlignmentRight];
    [self.thumbTime setTextColor:[UIColor darkGrayColor]];
    [self.thumbTime setBackgroundColor:[UIColor clearColor]];
    [self.thumbTime setFont:[UIFont systemFontOfSize:17.0f]];
    [self addSubview:self.thumbTime];
    
    //self.thumbColour.frame.size.width - 5*16.0f - 4*9.0f
    self.thumbRatingOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.thumbRatingOne setContentMode:UIViewContentModeScaleAspectFit];
    [self.thumbRatingOne setFrame:CGRectMake(50, 110.0f, 16.0f, 16.0f)];
//    [self addSubview:self.thumbRatingOne];
    
    self.thumbRatingTwo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.thumbRatingTwo setContentMode:UIViewContentModeScaleAspectFit];
    [self.thumbRatingTwo setFrame:CGRectMake(CGRectGetMaxX(self.thumbRatingOne.frame) + 9.0f, 110.0f, 16.0f, 16.0f)];
//    [self addSubview:self.thumbRatingTwo];
    
    self.thumbRatingThree = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.thumbRatingThree setContentMode:UIViewContentModeScaleAspectFit];
    [self.thumbRatingThree setFrame:CGRectMake(CGRectGetMaxX(self.thumbRatingTwo.frame) + 9.0f, 110.0f, 16.0f, 16.0f)];
//    [self addSubview:self.thumbRatingThree];
    
    self.thumbRatingFour = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.thumbRatingFour setContentMode:UIViewContentModeScaleAspectFit];
    [self.thumbRatingFour setFrame:CGRectMake(CGRectGetMaxX(self.thumbRatingThree.frame) + 9.0f, 110.0f, 16.0f, 16.0f)];
//    [self addSubview:self.thumbRatingFour];

    self.thumbRatingFive = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_selected"]];
    [self.thumbRatingFive setContentMode:UIViewContentModeScaleAspectFit];
    [self.thumbRatingFive setFrame:CGRectMake(CGRectGetMaxX(self.thumbRatingFour.frame) + 9.0f, 110.0f, 16.0f, 16.0f)];
//    [self addSubview:self.thumbRatingFive];
    imageLoaded = FALSE;
    
    self.activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityInd setFrame:CGRectMake((self.thumbColour.frame.size.width - self.activityInd.frame.size.width)/2, CGRectGetMaxY(self.thumbColour.frame) + 62.0f, 37.0f, 37.0f)];
    [self addSubview:self.activityInd];
    
    translucentEditingView = [[UIView alloc] initWithFrame:self.bounds];
    [translucentEditingView setBackgroundColor:PRIMARY_APP_COLOR];
    [translucentEditingView setAlpha:0.3];
    //[translucentEditingView setUserInteractionEnabled:FALSE];
    [translucentEditingView setTag:998];
    translucentEditingView.hidden = YES;
    [self addSubview:translucentEditingView];
    
    
    checkmarkOverlay = [[UIImageView alloc] initWithFrame:self.bounds];
    [checkmarkOverlay setImage:[UIImage imageNamed:@"checkmarkOverlay"]];
    [checkmarkOverlay setTag:999];
    [checkmarkOverlay setUserInteractionEnabled:TRUE];
    [checkmarkOverlay setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:checkmarkOverlay];
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = [[UIColor grayColor]CGColor];
    
    self.thumbDeleteButton = [[CustomButton alloc] initWithFrame: CGRectMake(-22, -17, 45, 45)];
    [self.thumbDeleteButton setImage: [self deleteImage] forState:UIControlStateNormal];
    [self.thumbDeleteButton setImage: [self deleteImageForHighlighted] forState:UIControlStateHighlighted];
    self.clipsToBounds = NO;
    
}




-(void)setData:(Tag *)data
{
    _data = data;
}

-(Tag *)data
{

    return _data;
}

-(void)prepareForReuse
{
    _data = nil;
    self.imageView.image = [UIImage imageNamed:@"live.png"];
    self.thumbPeriod.text = @"";
    self.thumbName.text = @"";
    self.thumbTime.text = @"";
    self.thumbDur.text = @"";
    self.thumbColour.backgroundColor = nil;
    self.backgroundView = nil;
    self.data = nil;
    
    self.checkmarkOverlay.hidden = YES;
    self.translucentEditingView.hidden = YES;
    [super prepareForReuse];

}

-(void)setDeletingMode: (BOOL) mode{
    if (mode) {
        [self wiggleView];
        [self addSubview: self.thumbDeleteButton];
    }else{
        [self.layer removeAllAnimations];
        [self.thumbDeleteButton removeFromSuperview];
        self.checkmarkOverlay.hidden = YES;
        self.translucentEditingView.hidden = YES;
    }
}

-(void)wiggleView {
    
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
//    animation.keyPath = @"position.x";
//    animation.values = @[ @0, @8, @-8, @4, @0 ];
//    animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
//    animation.duration = 0.4;
//    animation.additive = YES;
//    animation.repeatCount = HUGE_VALF;
//    [self.layer addAnimation:animation forKey:@"wiggle"];
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.values = @[@(-0.03f), @(0.03f)];
    animation.autoreverses = YES;
    animation.duration = 0.1;
    animation.repeatCount = HUGE_VALF;
    [self.layer addAnimation:animation forKey:@"wiggle"];
    
}

-(UIImage *) deleteImage{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45), NO, [UIScreen mainScreen].scale);

    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 45, 45) cornerRadius:15];
    [[UIColor lightGrayColor] setFill];
    [circlePath fill];
    
    UIBezierPath *xPath = [UIBezierPath bezierPath];
    
    [xPath moveToPoint: CGPointMake(15, 15)];
    [xPath addLineToPoint: CGPointMake(30, 30)];
    [xPath moveToPoint: CGPointMake(30, 15)];
    [xPath addLineToPoint: CGPointMake(15, 30)];
    
    [[UIColor blackColor] setStroke];
    
    xPath.lineWidth = 2.0;
    [xPath stroke];
    
    UIImage *deleteButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return deleteButtonImage;
}

-(UIImage *) deleteImageForHighlighted{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(45, 45), NO, [UIScreen mainScreen].scale);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 45, 45) cornerRadius:15];
    [[UIColor blackColor] setFill];
    [circlePath fill];
    
    UIBezierPath *xPath = [UIBezierPath bezierPath];
    
    [xPath moveToPoint: CGPointMake(15, 15)];
    [xPath addLineToPoint: CGPointMake(30, 30)];
    [xPath moveToPoint: CGPointMake(30, 15)];
    [xPath addLineToPoint: CGPointMake(15, 30)];
    
    [[UIColor whiteColor] setStroke];
    
    xPath.lineWidth = 2.0;
    [xPath stroke];
    
    UIImage *deleteButtonImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return deleteButtonImage;
}

// need this to capture button taps since they are outside of self.frame
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    
    if (!self.thumbDeleteButton.hidden && CGRectContainsPoint(self.thumbDeleteButton.frame, point)) {
        return self.thumbDeleteButton;
    }
//    //for (UIView *subview in self.subviews) {
//        if (CGRectContainsPoint(self.frame, point)) {
//            return self;
//        }
//    //}
    
    // use this to pass the 'touch' onward in case no subviews trigger the touch
    return [super hitTest:point withEvent:event];
}


@end
