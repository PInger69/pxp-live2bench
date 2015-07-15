//
//  PxpCircleButton.h
//  PxpTelestration
//
//  Created by Nico Cvitak on 2015-07-14.
//  Copyright © 2015 Nicholas Cvitak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PxpCircleButton : UIButton

@property (readonly, assign, nonatomic) CGPoint center;
@property (readonly, assign, nonatomic) CGFloat radius;

@end
