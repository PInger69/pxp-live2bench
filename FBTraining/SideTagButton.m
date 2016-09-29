
//
//  SideTagButton.m
//  Live2BenchNative
//
//  Created by dev on 2015-06-23.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "SideTagButton.h"
#import "Tag.h"


@implementation SideTagButton
{
    SideTagButtonModes           prevMode;
    UIColor         *backgroundColor;
    UIView          * fadeColorView;
}

@synthesize durationID = _durationID;
@synthesize isOpen      =_isOpen;
@synthesize mode        = _mode;
@synthesize isBusy      = _isBusy;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setBackgroundColor:[UIColor clearColor]];
        //[[self layer] setBorderColor:self.tintColor.CGColor];
        [self.layer setBorderWidth:1.0f];
        [self setContentEdgeInsets:UIEdgeInsetsMake(3, 5, 3, 5)];
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//        [self setBackgroundImage:[Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR] forState:UIControlStateSelected];
//        [self setBackgroundImage:[Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR] forState:UIControlStateHighlighted];
//        [self setBackgroundImage:[Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR]  forState:UIControlStateNormal];
        [self setBackgroundImage:[Utility makeOnePixelUIImageWithColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.25]] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        
        self.mode = SideTagButtonModeDisable;
        backgroundColor = [UIColor clearColor];
        [self setEnabled:false];
        
        
        self.durationView = [[DurationTagButtonView alloc]initWithFrame:self.bounds];
        self.durationView.hidden = YES;
        [self addSubview:self.durationView];
        fadeColorView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [fadeColorView setBackgroundColor:PRIMARY_APP_COLOR];
         fadeColorView.alpha = 0;
        [fadeColorView setUserInteractionEnabled:NO];
        [self insertSubview:fadeColorView atIndex:0];
    }
    return self;
}

-(void)sendAction:(nonnull SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event
{

    if (self.mode == SideTagButtonModeToggle)[self setSelected:!self.selected];
    [super sendAction:action to:target forEvent:event];
}

-(void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled) {
        [[self layer] setBorderColor:self.tintColor.CGColor];
        [self setAlpha:1.0];
        
    }else if(!enabled){
        [[self layer] setBorderColor:[UIColor grayColor].CGColor];
        [self setAlpha:0.2];
    }
}




-(void)setHighlighted:(BOOL)highlighted{
    super.highlighted = highlighted;
    [self setNeedsDisplay];
    
}


-(void)setSelected:(BOOL)selected
{
    super.selected = selected;
    [self setNeedsDisplay];
}



-(void)setDurationID:(NSString *)durationID{
    _durationID = durationID;
}

-(void)tintColorDidChange
{
    [super tintColorDidChange];
    if (_mode != SideTagButtonModeDisable) {
        [[self layer] setBorderColor:self.tintColor.CGColor];
    }
    
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
}



-(void)setMode:(SideTagButtonModes)mode
{

    if (_mode == mode) return;
        _mode = mode;
    
        switch (mode) {
            case SideTagButtonModeDisable :
                [self setEnabled:false];
                self.alpha = 1;
                break;
            case SideTagButtonModeRegular :
                prevMode = SideTagButtonModeRegular;
                _durationID = nil;
                self.alpha = 1;
                self.userInteractionEnabled = YES;
                [self setEnabled:true];
                break;
            case SideTagButtonModeToggle :
                prevMode = SideTagButtonModeToggle;
                self.alpha = 1;
                self.userInteractionEnabled = YES;
                [self setEnabled:true];
                break;
             
            default:
                break;
        }

}




-(void)setIsOpen:(BOOL)isOpen
{
    if (isOpen == _isOpen )return;
    
    if (isOpen && !_isOpen && self.mode == SideTagButtonModeToggle){
        [self setHighlighted:true];
        self.durationID = [Tag makeDurationID];
        self.durationView.hidden = NO;
        self.durationView.nameLabel.text = self.titleLabel.text;
    } else if (!isOpen && _isOpen && self.mode == SideTagButtonModeToggle) {
        [self setHighlighted:false];
        self.durationID = nil; // clear id as soon as its finished closing
        [self setSelected:false];
        self.durationView.hidden = YES;
    }
    _isOpen = isOpen;
}

-(void)setIsBusy:(BOOL)isBusy
{
    _isBusy = isBusy;
    if (_isBusy) {
        self.alpha = 0.6;
        self.userInteractionEnabled = NO;
    } else {
        self.alpha = 1;
        self.userInteractionEnabled = YES;
    }
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self.durationView setFrame:self.bounds];
    [fadeColorView setFrame:self.bounds];
    
}

-(BOOL)isBusy
{
    return _isBusy;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [UIView animateWithDuration:1 animations:^{
        fadeColorView.alpha = 1;
        
//    }];
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:1 animations:^{

        fadeColorView.alpha = 0;
    }];
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [UIView animateWithDuration:1 animations:^{
//
//        fadeColorView.alpha = 0;
//    }];
//    
//    
       [super touchesMoved:touches withEvent:event];
}


@end
