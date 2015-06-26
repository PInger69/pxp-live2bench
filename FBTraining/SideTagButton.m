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
}

@synthesize durationID = _durationID;
@synthesize isOpen      =_isOpen;
@synthesize mode        = _mode;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self setBackgroundColor:[UIColor clearColor]];
        //[[self layer] setBorderColor:self.tintColor.CGColor];
        [[self layer] setBorderWidth:1.0f];
        [self setContentEdgeInsets:UIEdgeInsetsMake(3, 5, 3, 5)];
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];
        
        self.mode = SideTagButtonModeDisable;
        [self setEnabled:false];

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
        [self setAlpha:1.0];
        
    }else if(!enabled){
        [[self layer] setBorderColor:[UIColor grayColor].CGColor];
        [self setAlpha:0.2];
    }
}




-(void)setHighlighted:(BOOL)highlighted{
    super.highlighted = highlighted;
    [self setNeedsDisplay];
    
    if (highlighted) {
        if (!self.selected) self.backgroundColor = self.tintColor;
    } else {
        if (!self.selected) self.backgroundColor = [UIColor clearColor];
    }
    
}


-(void)setSelected:(BOOL)selected
{
    super.selected = selected;
    [self setNeedsDisplay];
    
    if (selected) {
        self.backgroundColor = self.tintColor;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }

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
                break;
            case SideTagButtonModeRegular :
                prevMode = SideTagButtonModeRegular;
                _durationID = nil;
                [self setEnabled:true];
                break;
            case SideTagButtonModeToggle :
                prevMode = SideTagButtonModeToggle;
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
    } else if (!isOpen && _isOpen && self.mode == SideTagButtonModeToggle) {
        [self setHighlighted:false];
        self.durationID = nil; // clear id as soon as its finished closing
    }
    _isOpen = isOpen;
}







@end
