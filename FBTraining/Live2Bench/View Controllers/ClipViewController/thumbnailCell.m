//
//  thumbnailCell.m
//  Live2BenchNative
//
//  Created by DEV on 2013-01-30.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "thumbnailCell.h"
#import "Tag.h"
#import "RatingOutput.h"

#define PADDING             5

@interface thumbnailCell()

@property (nonatomic, assign) BOOL weirdCase;
@end

@implementation thumbnailCell

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
    
//    self.backgroundPlaneView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//    [self.backgroundPlaneView setAutoresizingMask: UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
//    [self addSubview:self.backgroundPlaneView];
//    self.backgroundPlaneView.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
//    self.backgroundPlaneView.layer.borderWidth = 3;
    
    self.contentView.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    self.contentView.layer.borderWidth = 3;
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaultTagView"]];

    [self.imageView setFrame:CGRectMake(3, 3, self.bounds.size.width - 6, 131.0f)];

    [self addSubview:self.imageView];
    
    self.thumbColour = [[ClipCornerView alloc] initWithFrame:CGRectMake(self.imageView.frame.size.width-30, 0.0f, 30, 30)];
    [self.thumbColour setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];

    
    [self.imageView addSubview:self.thumbColour];
   
    self.thumbName = [[UILabel alloc] initWithFrame:CGRectMake(self.imageView.frame.origin.x+PADDING, 140.0f, self.imageView.bounds.size.width*3/4, 18.0f)];
    [self.thumbName setText:NSLocalizedString(@"Name", nil)];
    [self.thumbName setTextColor:[UIColor darkGrayColor]];
    [self.thumbName setBackgroundColor:[UIColor clearColor]];
    [self.thumbName setFont:[UIFont systemFontOfSize:15.0f]];
    [self addSubview:self.thumbName];
    
    self.thumbPeriod = [[UILabel alloc] initWithFrame:CGRectMake(self.thumbName.frame.origin.x+PADDING, CGRectGetMaxY(self.thumbName.frame), self.imageView.bounds.size.width/2, 16.0f)];
    [self.thumbPeriod setText:NSLocalizedString(@"Period", nil)];
    [self.thumbPeriod setTextColor:[UIColor darkGrayColor]];
    [self.thumbPeriod setBackgroundColor:[UIColor clearColor]];
    [self.thumbPeriod setFont:[UIFont systemFontOfSize:15.0f]];
    [self.thumbPeriod setHidden:YES];
    [self addSubview:self.thumbPeriod];
    
    self.thumbDur = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbName.frame)-(7*PADDING), self.thumbName.frame.origin.y, self.imageView.bounds.size.width/3 + 2*PADDING, 16.0f)];
    [self.thumbDur setText:@"s"];
    [self.thumbDur setTextAlignment:NSTextAlignmentRight];
    [self.thumbDur setTextColor:[UIColor darkGrayColor]];
    [self.thumbDur setBackgroundColor:[UIColor clearColor]];
    [self.thumbDur setFont:[UIFont systemFontOfSize:15.0f]];
    [self addSubview:self.thumbDur];
    
    
    self.thumbTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbPeriod.frame)-(3*PADDING), CGRectGetMaxY(self.thumbDur.frame), self.imageView.bounds.size.width/2, 16.0f)];
    [self.thumbTime setText: NSLocalizedString(@"Time", nil)];
    [self.thumbTime setTextAlignment:NSTextAlignmentRight];
    [self.thumbTime setTextColor:[UIColor darkGrayColor]];
    [self.thumbTime setBackgroundColor:[UIColor clearColor]];
    [self.thumbTime setFont:[UIFont systemFontOfSize:15.0f]];
    [self addSubview:self.thumbTime];
    
    self.thumbGameTime = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.thumbPeriod.frame)-(3*PADDING), CGRectGetMaxY(self.thumbTime.frame), self.imageView.bounds.size.width/2, 16.0f)];

    [self.thumbGameTime setTextAlignment:NSTextAlignmentRight];
    [self.thumbGameTime setTextColor:[UIColor darkGrayColor]];
    [self.thumbGameTime setBackgroundColor:[UIColor clearColor]];
    [self.thumbGameTime setFont:[UIFont systemFontOfSize:15.0f]];
    [self addSubview:self.thumbGameTime];
    

    self.ratingscale = [[RatingOutput alloc] initWithFrame:CGRectMake(self.imageView.frame.size.width -300, self.imageView.frame.size.height -18.0f, 16.0f, 16.0f)];
    [self.imageView addSubview:self.ratingscale];
    
    self.imageLoaded = FALSE;
    
    self.activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityInd setFrame:CGRectMake((self.thumbColour.frame.size.width - self.activityInd.frame.size.width)/2, CGRectGetMaxY(self.thumbColour.frame) + 62.0f, 37.0f, 37.0f)];
    [self addSubview:self.activityInd];
    
    self.translucentEditingView = [[UIView alloc] initWithFrame:self.bounds];
    [self.translucentEditingView setBackgroundColor:PRIMARY_APP_COLOR];
    [self.translucentEditingView setAlpha:0.3];
    //[translucentEditingView setUserInteractionEnabled:FALSE];
    [self.translucentEditingView setTag:998];
    self.translucentEditingView.hidden = YES;
    [self addSubview:self.translucentEditingView];
    
    
    self.checkmarkOverlay = [[UIImageView alloc] initWithFrame:self.bounds];
    [self.checkmarkOverlay setImage:[[UIImage imageNamed:@"checkmarkOverlay"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self.checkmarkOverlay setTag:999];
    [self.checkmarkOverlay setUserInteractionEnabled:TRUE];
    [self.checkmarkOverlay setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.checkmarkOverlay];
    
    self.thumbDeleteButton = [[UIButton alloc] initWithFrame: CGRectMake(-22, -17, 45, 45)];
    [self.thumbDeleteButton setImage: [self deleteImage] forState:UIControlStateNormal];
    [self.thumbDeleteButton setImage: [self deleteImageForHighlighted] forState:UIControlStateHighlighted];
    self.clipsToBounds = NO;
    
}




-(void)prepareForReuse
{
    self.data = nil;
    [self setDeletingMode:NO];
    [super prepareForReuse];

}

-(void)setDeletingMode: (BOOL) mode{
    if (mode) {
        [self wiggleView];
        [self addSubview: self.thumbDeleteButton];
    } else {
        [self.layer removeAllAnimations];
        [self.thumbDeleteButton removeFromSuperview];
        self.checkmarkOverlay.hidden = YES;
        self.translucentEditingView.hidden = YES;
    }
}

-(void)wiggleView {
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
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.thumbDeleteButton.superview != nil && CGRectContainsPoint(self.thumbDeleteButton.frame, point)) {
        return self.thumbDeleteButton;
    }
    // use this to pass the 'touch' onward in case no subviews trigger the touch
    return [super hitTest:point withEvent:event];
}


@end
