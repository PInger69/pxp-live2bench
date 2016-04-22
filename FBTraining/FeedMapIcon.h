//
//  FeedMapIcon.h
//  Live2BenchNative
//
//  Created by dev on 2016-04-04.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, FeedMapIconType)  {
    FeedMapIconTypeNone,
    
    FeedMapIconTypeDualTop,
    FeedMapIconTypeDualBottom,
    FeedMapIconTypeQuad1of4,
    FeedMapIconTypeQuad2of4,
    FeedMapIconTypeQuad3of4,
    FeedMapIconTypeQuad4of4,
    
    FeedMapIconTypeUnknown
};



@interface FeedMapIcon : UIView

@property (nonatomic,assign) FeedMapIconType  type;



@end
