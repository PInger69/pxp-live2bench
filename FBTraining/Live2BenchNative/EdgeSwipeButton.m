//
//  EdgeSwipeButton.m
//  Live2BenchNative
//
//  Created by Si Te Feng on 6/23/14.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "EdgeSwipeButton.h"

@interface EdgeSwipeButton()
{
    
}

@property (nonatomic, strong) UIImageView* buttonImageView;



@end



static const int kLightIndicatorTag = 285;
static const int JPControlEventCancel = 527;

@implementation EdgeSwipeButton
@synthesize selected= _selected, highlighted = _highlighted;

- (instancetype)initWithFrame:(CGRect)frame imageOffset:(CGFloat)offset
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        
        self.type = JPSwipeButtonTypeRetract;
        
        self.backgroundColor = [UIColor clearColor];
        _buttonImageOffset = offset;
        _buttonPanRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPanned:)];
        _buttonPanRec.delegate = self;
        [self addGestureRecognizer: _buttonPanRec];
        
        UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)];
        tapRec.numberOfTapsRequired = 1;
        tapRec.delegate = self;
        [self addGestureRecognizer:tapRec];
        
        self.buttonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offset, 0, frame.size.width, frame.size.height)];
        self.buttonImageView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        _originalPosition        = self.buttonImageView.frame.origin.x;
        _lastButtonImagePosition = self.buttonImageView.frame.origin.x;
        self.buttonImageView.contentMode = UIViewContentModeScaleToFill;
        
        _lightIndicator = [[UIView alloc] initWithFrame:CGRectMake(-8, 0, 8, self.buttonImageView.frame.size.height)];
        _lightIndicator.tag = kLightIndicatorTag;
        _lightIndicator.backgroundColor = [self.class normalColor];
        [self.buttonImageView addSubview:_lightIndicator];
        [self addSubview:self.buttonImageView];
        
        _colorBeforeSwipe = [EdgeSwipeButton normalColor];
        
    }
    
    return self;
}


- (void) buttonPanned: (UIPanGestureRecognizer*)rec
{
    CGFloat translation = [rec translationInView:self].x;
    
    if(rec.state == UIGestureRecognizerStateBegan)
    {
        _colorBeforeSwipe = _lightIndicator.backgroundColor;
        _translationWhenActivated = 0;
        _translationWhenActIsSet = NO;
    }
    else if(rec.state == UIGestureRecognizerStateChanged)
    { //maintain highlight
    }
    else
    {
        [self setSelected:self.selected]; //back to normal color
    }
    
    //Changing the Button Image Position
    if(rec.state == UIGestureRecognizerStateChanged)
    {
        CGFloat activationPosition = _buttonImageOffset-self.buttonImageView.frame.size.width;
        if(self.buttonImageView.frame.origin.x - activationPosition > 0 || fabs(translation)<fabs(_translationWhenActivated) ) //not dragged all the way OR panned back
        {
            _lightIndicator.backgroundColor = _colorBeforeSwipe;
            
            self.buttonImageView.frame = CGRectMake(_lastButtonImagePosition + translation, 0, self.buttonImageView.frame.size.width, self.buttonImageView.frame.size.height);
            
            _translationWhenActIsSet = NO;
        
        }
        else
        {
            _lightIndicator.backgroundColor = [EdgeSwipeButton highlightedColor];
            if(_translationWhenActIsSet == NO)
            {
                _translationWhenActivated = translation;
                _translationWhenActIsSet = YES;
                
            }
        }
        
    }
    else if(rec.state == UIGestureRecognizerStateEnded)
    {
        CGFloat activationPosition = _buttonImageOffset-self.buttonImageView.frame.size.width;
        if(self.buttonImageView.frame.origin.x - activationPosition > 0) //not dragged all the way
        {
            [self retractButtonImage];
            [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
        }
        else //drag successful, button state change
        {
            [self activateButton];
        }
        
        _lastButtonImagePosition = self.buttonImageView.frame.origin.x;
    }
    // Fix this... it bugs the crap out of me
//     CGFloat activationPosition = _buttonImageOffset-self.buttonImageView.frame.size.width;
//    if (self.buttonImageView.frame.origin.x - activationPosition < 0){
//        [self.buttonImageView setFrame:
//            CGRectMake(self.buttonImageView.frame.origin.x - activationPosition,
//                       self.buttonImageView.frame.origin.y,
//                       self.buttonImageView.frame.size.width,
//                       self.buttonImageView.frame.size.height)];
//    }
}


- (void)buttonTapped:(UITapGestureRecognizer*)rec
{
    
    [self activateButton];
    
}



- (void)activateButton
{
    //if it's a selected retain button though, dismiss function
    if(self.type == JPSwipeButtonTypeRetain && self.selected)
    {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
    else
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        //Back to acticated position
        [UIView animateWithDuration:0.1 animations:^{
            self.buttonImageView.frame = CGRectMake(_buttonImageOffset-self.buttonImageView.frame.size.width, 0, self.buttonImageView.frame.size.width, self.buttonImageView.frame.size.height);
        }];
    }
    
    
    if(self.type == JPSwipeButtonTypeRetract)
    {
        NSTimer* buttonRetractTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(retractButtonImage) userInfo:nil repeats:NO];
        [buttonRetractTimer isValid];
    }
    else
    {
        if(!_dismissTapRec)
        {
            _dismissTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTappedToDismiss:)];
        }
        
        if(![[self gestureRecognizers] containsObject:_dismissTapRec])
            [self addGestureRecognizer:_dismissTapRec];
    }

}



- (void)buttonTappedToDismiss: (UITapGestureRecognizer*)rec
{
    
    if(rec.state == UIGestureRecognizerStateBegan)
    {

        _lightIndicator.backgroundColor = [EdgeSwipeButton highlightedColor];
    }
    else
    {
        _lightIndicator.backgroundColor = [EdgeSwipeButton normalColor];
    }
    
    if(rec.state == UIGestureRecognizerStateEnded)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self retractButtonImage];
        [self setSelected: NO];
    }
    
    
}



- (void)retractButtonImage
{
    [UIView animateWithDuration:0.2 animations:^{
        self.buttonImageView.frame = CGRectMake(_originalPosition, 0, self.buttonImageView.frame.size.width, self.buttonImageView.frame.size.height);
    }];
    
    _lastButtonImagePosition = self.buttonImageView.frame.origin.x;
    
    if(self.type == JPSwipeButtonTypeRetain)
    {
        [self removeGestureRecognizer:_dismissTapRec];

    }
    
}


- (void)bringUpButtonImage
{
    CGFloat activationPosition = _buttonImageOffset-self.buttonImageView.frame.size.width;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.buttonImageView.frame = CGRectMake(_originalPosition, activationPosition, self.buttonImageView.frame.size.width, self.buttonImageView.frame.size.height);
    }];
    
    _lastButtonImagePosition = self.buttonImageView.frame.origin.x;
    
    if(self.type == JPSwipeButtonTypeRetain)
    {
//        [self removeGestureRecognizer:_buttonPanRec];
        [self addGestureRecognizer:_dismissTapRec];
    }
    
     _lightIndicator.backgroundColor = [EdgeSwipeButton highlightedColor];
}



- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.buttonImageView.image = image;
}



- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (selected)
    {
        _lightIndicator.backgroundColor = [self.class selectedColor];

    }
    else
    {
        _lightIndicator.backgroundColor = [self.class normalColor];
        
    }
}



+ (UIColor*)selectedColor
{
    return [UIColor orangeColor];
}

+ (UIColor*)highlightedColor
{
    return [[UIColor orangeColor] colorWithAlphaComponent:0.6];
}

+ (UIColor*)normalColor
{
    return [UIColor darkGrayColor];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
