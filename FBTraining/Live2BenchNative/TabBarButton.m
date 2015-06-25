//
//  TabBarButton.m
//  Live2BenchNative
//
//  Created by Dev on 2013-09-17.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "TabBarButton.h"

@implementation TabBarButton

- (id)initWithName:(NSString *)tabName andImageName:(NSString *)imageName
{
    self = [TabBarButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        self.tabName = tabName;
        self.imageName = imageName;
        [self setTitle:self.tabName forState:UIControlStateNormal];
        [self setImage:[self normalImage] forState:UIControlStateNormal];
        [self setImage:[self selectedImage] forState:UIControlStateSelected];
        [self setBorderColour:[UIColor colorWithWhite:0.8f alpha:1.0f]];
        [self setBorderWidth:1.0f];
        [self setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        [self setBackgroundImage:[UIImage imageNamed:@"lightGreySelect"] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor colorWithWhite:0.2f alpha:1.0f] forState:UIControlStateNormal];
        [self setTitleColor:PRIMARY_APP_COLOR forState:UIControlStateSelected];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
        [self setImageEdgeInsets:UIEdgeInsetsMake(0.0f, -10.0f, 0.0f, 0.0f)];
        [self setFont:[UIFont defaultFontOfSize:20.0f]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel setFont:self.titleFont];
}

- (UIImage*)normalImage
{
    return [UIImage imageNamed:self.imageName];
}

- (UIImage*)selectedImage
{
    return [[UIImage imageNamed:[NSString stringWithFormat:@"%@Select",self.imageName]]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
