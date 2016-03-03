//
//  UIDrawer.m
//  Live2BenchNative
//
//  Created by dev on 2016-02-29.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "UIDrawer.h"

@interface UIDrawer ()

@end

@implementation UIDrawer

@synthesize openStyle = _openStyle;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isOpen             = YES;
        self.animationTime  = 0.1;
        self.contentArea    = [UIView new];
        [self addSubview:self.contentArea];
        self.openStyle      = UIDrawerBottom;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isOpen             = YES;

        self.animationTime  = 1;
        self.contentArea    = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.contentArea];
        self.openCenterPoint = self.contentArea.center;
        self.openStyle      = UIDrawerBottom;
    }
    return self;
}


-(void)open:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(willOpen:)]) {
        [self.delegate willOpen:self];
    }
    self.contentArea.hidden = NO;
    
    NSTimeInterval time = (animated)? self.animationTime : 0.0;
    

    
    [UIView animateWithDuration:time
                     animations:^() {
                        self.contentArea.center = self.openCenterPoint;
                         
                     } completion:^(BOOL finished) {
                         // this fires on every frame
                         
                        if (finished){
                            // this is when its done
                            if ([self.delegate respondsToSelector:@selector(didOpen:)]) {
                             [self.delegate didOpen:self];
                            }
                            _isOpen = YES;
                        }
                     }];

}

-(void)close:(BOOL)animated
{

    if ([self.delegate respondsToSelector:@selector(willClose:)]) {
        [self.delegate willClose:self];
    }
    
    NSTimeInterval time = (animated)? self.animationTime : 0.0;
    


    [UIView animateWithDuration:time
                     animations:^() {
                       
                         self.contentArea.center = self.closeCenterPoint;
                       
                     }completion:^(BOOL finished) {
                         // This fires on every frame of the animation
                         if (finished){
                             if ([self.delegate respondsToSelector:@selector(didClose:)]) {
                                 [self.delegate didClose:self];
                             }
                             _isOpen = NO;
                             self.contentArea.hidden = YES;
                         }
                     }];
   
}

#pragma mark - getters setters



-(void)setOpenStyle:(UIDrawerOpenStyle)openStyle
{
    [self willChangeValueForKey:@"openStyle"];
    _openStyle = openStyle;
    [self didChangeValueForKey:@"openStyle"];
    switch (_openStyle) {
        case UIDrawerTop:
            self.closeCenterPoint = CGPointMake(self.openCenterPoint.x, self.openCenterPoint.y - self.contentArea.frame.size.height);
            break;
        case UIDrawerRight:
            self.closeCenterPoint = CGPointMake(self.openCenterPoint.x + self.contentArea.frame.size.width, self.openCenterPoint.y);
            break;
        case UIDrawerLeft:
            self.closeCenterPoint = CGPointMake(self.openCenterPoint.x - self.contentArea.frame.size.width, self.openCenterPoint.y);
            break;
        case UIDrawerBottom:
            self.closeCenterPoint = CGPointMake(self.openCenterPoint.x, self.openCenterPoint.y + self.contentArea.frame.size.height);
            break;
            
        default:
            break;
    }
    
}

-(UIDrawerOpenStyle)openStyle
{
    return _openStyle;
}



-(BOOL)isIsOpen
{
    return _isOpen;
}

-(void)setIsOpen:(BOOL)isOpen
{
    if (isOpen && !_isOpen) {
        [self open:NO];
    } else if  (!isOpen && _isOpen){
        [self close:NO];
    }
    [self willChangeValueForKey:@"isOpen"];
    _isOpen = isOpen;
    [self didChangeValueForKey:@"isOpen"];
}


#pragma mark - Overrides

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
//    self.contentArea.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
}



@end
