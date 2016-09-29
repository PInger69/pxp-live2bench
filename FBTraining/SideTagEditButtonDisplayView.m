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
@synthesize position = _position;
@synthesize order = _order;


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
    

    [self.autoSwitch setOnTintColor:PRIMARY_APP_COLOR];
    [self.autoSwitch setTintColor:PRIMARY_APP_COLOR];
//    [self.autoSwitch setThumbTintColor:[UIColor grayColor]];
    self.button.layer.borderWidth   = 1;
    self.button.layer.cornerRadius  = 5;
    self.enabled = YES;
}

-(NSDictionary*)data
{

    return @{@"name":self.name,@"order":self.order,@"position":self.position};
}

-(void)type:(NSString*)aType
{
    self.typeLabel.text = aType;
}


-(void)setEnabled:(BOOL)enabled
{
    
    _enabled = enabled;
    
    self.button.enabled = _enabled;
//    self.autoSwitch.enabled = _enabled;
    
    
    
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


-(void)setName:(NSString *)name
{
    self.button.titleLabel.text = name;
    [self.button setTitle:name forState:UIControlStateNormal];
}

-(NSString*)name
{
    return self.button.titleLabel.text;
}

-(void)setPosition:(NSString *)position
{
    _position = position;
}

-(NSString*)position
{
    return _position;
}

-(void)setOrder:(NSNumber *)order
{
    _order = order;
}

-(NSNumber*)order
{
    return _order;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
