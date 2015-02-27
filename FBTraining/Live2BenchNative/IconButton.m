//
//  IconButton.m
//  Live2BenchNative
//
//  Created by Dev on 2013-09-25.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import "IconButton.h"

@implementation IconButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.iconLocation = 1;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    switch (self.iconLocation) {
        case 0:
            self.titleLabel.frame = CGRectMake(10.0f, 5.0f, self.bounds.size.width, (self.bounds.size.height)/2 - 10.0f);
//            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.imageView.frame = CGRectMake(self.bounds.size.width/4, (self.bounds.size.height)/2, self.bounds.size.width/2, (self.bounds.size.height)/2 - 15.0f);
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
        case 1:
            [super layoutSubviews];
            break;
        case 2:
            self.titleLabel.frame = CGRectMake(10.0f, (self.bounds.size.height)/2, self.bounds.size.width, (self.bounds.size.height)/2 - 10.0f);
//            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.imageView.frame = CGRectMake(self.bounds.size.width/4, 5.0f, self.bounds.size.width/2, (self.bounds.size.height)/2 - 15.0f);
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
        case 3:
            self.imageView.frame = CGRectMake(self.bounds.size.width - self.imageView.bounds.size.width, self.imageView.frame.origin.y, self.imageView.bounds.size.width, self.imageView.bounds.size.height);
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.titleLabel.frame = CGRectMake(10.0f, self.titleLabel.frame.origin.y, self.titleLabel.bounds.size.width + 20.0f, self.titleLabel.bounds.size.height);
//            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            break;
        default:
            break;
    }
}

@end
