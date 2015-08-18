//
//  DropdownButton.m
//  Live2BenchNative
//
//  Created by Dev on 2013-09-20.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "DropdownButton.h"

@implementation DropdownButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [self setBackgroundColor: [UIColor colorWithWhite:0.95f alpha:1.0f]];
        //[self setBackgroundImage:[UIImage imageNamed:@"lightGreySelect"] forState:UIControlStateNormal];
        //[self setBackgroundImage:[UIImage imageNamed:@"darkGreySelect"] forState:UIControlStateSelected];
        [self setBackgroundImage:[Utility makeOnePixelUIImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [self setBackgroundImage:[Utility makeOnePixelUIImageWithColor:[UIColor darkGrayColor]] forState:UIControlStateSelected];
        [self setImageEdgeInsets:UIEdgeInsetsMake(0.0f, -120.0f, 0.0f, 0.0f)];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 50.0f, 0.0f, 50.0f)];
        [self setFont:[UIFont defaultFontOfSize:17.0f]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews]; 
    self.titleLabel.font = self.titleFont;
    if (!self.dropdownIcon){
        self.dropdownIcon = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 30.0f, (self.bounds.size.height - 20.0f)/2, 20.0f, 20.0f)];
        self.dropdownIcon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
        self.dropdownIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.dropdownIcon.userInteractionEnabled = NO;
        [self.dropdownIcon setImage:[UIImage imageNamed:@"dropdown"]];
        [self addSubview:self.dropdownIcon];
    }
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected)
    {
        [self.dropdownIcon setImage:[UIImage imageNamed:@"dropdownSelect"]];
        [self setFont:[UIFont regularFontOfSize: 17.0f]];
    }
    else
    {
        [self.dropdownIcon setImage:[UIImage imageNamed:@"dropdown"]];
        [self setFont:[UIFont defaultFontOfSize: 17.0f]];
    }
}

- (void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    if (enabled)
    {
        self.dropdownIcon.alpha = 1.0f;
    } else {
        self.dropdownIcon.alpha = 0.6f;
    }
}
@end
