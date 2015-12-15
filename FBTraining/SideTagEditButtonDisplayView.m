//
//  SideTagEditButtonDisplayView.m
//  Live2BenchNative
//
//  Created by dev on 2015-12-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "SideTagEditButtonDisplayView.h"

@interface SideTagEditButtonDisplayView ()

@property (nonatomic, strong) UIView *containerView;


@end

@implementation SideTagEditButtonDisplayView
@synthesize enabled = _enabled;
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    
    UIView *view = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SideTagEditButtonDisplay"
                                                     owner:self
                                                   options:nil];
    for (id object in objects) {
        if ([object isKindOfClass:[UIView class]]) {
            view = object;
            break;
        }
    }
    
    if (view != nil) {
        _containerView = view;
//        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
//        [self setNeedsUpdateConstraints];
    }
    
    

    self.button.layer.borderWidth = 1;
    self.enabled = YES;
}


-(void)type:(NSString*)aType
{
    self.typeLabel.text = aType;
}


-(void)setEnabled:(BOOL)enabled
{
    
    _enabled = enabled;
    
    self.button.enabled = _enabled;

    if (_enabled) {
        self.button.layer.borderColor = PRIMARY_APP_COLOR.CGColor;
    } else {
        self.button.layer.borderColor = [UIColor lightGrayColor].CGColor;

    }
    
}


-(BOOL)enabled
{
    return _enabled;
}

-(void)tintColorDidChange
{

    [super tintColorDidChange];

    if (_enabled){
        self.button.layer.borderColor = self.tintColor.CGColor;
    } else {
       self.button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
