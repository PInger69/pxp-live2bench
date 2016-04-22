//
//  FeedMapIcon.m
//  Live2BenchNative
//
//  Created by dev on 2016-04-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import "FeedMapIcon.h"
#import <QuartzCore/QuartzCore.h>


#define CORNER 3
@interface FeedMapIcon ()
//@property (readonly, strong, nonatomic, nonnull) CAShapeLayer *layer;
@end

@implementation FeedMapIcon
//@dynamic layer;
//
//+ (Class)layerClass {
//    return [CAShapeLayer class];
//}

@synthesize type = _type;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setType:FeedMapIconTypeDualTop];
        [self setBackgroundColor:[UIColor clearColor]];
         [self setNeedsDisplay];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setType:FeedMapIconTypeDualTop];
        [self setBackgroundColor:[UIColor clearColor]];
         [self setNeedsDisplay];
    }
    return self;
}



-(void)setType:(FeedMapIconType)type
{
    _type = type;
    [self setNeedsDisplay];
}

-(FeedMapIconType)type
{
    return _type;
}



- (void)drawRect:(CGRect)rect
{
    switch (_type) {
        case FeedMapIconTypeNone :
            // Stuff
            break;
        case FeedMapIconTypeDualTop :
            [self dualView:0];
            break;
        case FeedMapIconTypeDualBottom :
            [self dualView:1];
            break;
        case FeedMapIconTypeQuad1of4 :
            [self quadView:0];
            break;
        case FeedMapIconTypeQuad2of4 :
            [self quadView:1];
            break;
        case FeedMapIconTypeQuad3of4 :
            [self quadView:2];
            break;
        case FeedMapIconTypeQuad4of4 :
            [self quadView:3];
            break;
        case FeedMapIconTypeUnknown :
        default:
            [self blank];
            break;
    }

   

}

-(void)blank
{
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
 
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, w, h) cornerRadius:CORNER];
    [[UIColor lightGrayColor]setFill];
    [path fill];
    
}


-(void)dualView:(NSInteger)type
{

    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat m = 2;
    
   
    [[UIColor lightGrayColor]setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, w, (h/2)-m) cornerRadius:CORNER];
    if (type == 0)  [PRIMARY_APP_COLOR setFill];
    [path fill];
    
   [[UIColor lightGrayColor]setFill];
    UIBezierPath *path2 =[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, h/2, w, (h/2)-m)cornerRadius:CORNER];
    if (type == 1) [PRIMARY_APP_COLOR setFill];
    [path2 fill];

}

-(void)quadView:(NSInteger)type
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat m = 2;
    CGSize sz =  CGSizeMake(w/2, h/2);
    CGSize sm =  CGSizeMake((w/2)-m, (h/2)-m);
    
    
    void (^onFill)(UIBezierPath*p ,BOOL selected) = ^void(UIBezierPath*p,BOOL selected) {
        if (selected) {
            [PRIMARY_APP_COLOR setFill];
        } else {
            [[UIColor lightGrayColor]setFill];
        }
        [p fill];
    };
    
    
    UIBezierPath *path1 =     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, sm.width, sm.height)                 cornerRadius:CORNER];
    onFill(path1, (type==0) );
    
    UIBezierPath *path2 =     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(sz.width, 0, sm.width, sm.height)          cornerRadius:CORNER];
    onFill(path2, (type==1) );
    
    UIBezierPath *path3 =     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, sz.height, sm.width, sm.height)         cornerRadius:CORNER];
    onFill(path3, (type==2) );
    
    UIBezierPath *path4 =     [UIBezierPath bezierPathWithRoundedRect:CGRectMake(sz.width, sz.height, sm.width, sm.height)  cornerRadius:CORNER];
    onFill(path4, (type==3) );

    
    
}


@end
