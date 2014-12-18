//
//  NumberedSeekerButton.h
//  QuickTest
//
//  Created by dev on 6/19/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NumberedSeekerButton : UIButton

-(id)initForwardLargeWithFrame:(CGRect)frame;
-(id)initBackwardLargeWithFrame:(CGRect)frame;
-(id)initForwardNormalWithFrame:(CGRect)frame;
-(id)initBackwardNormalWithFrame:(CGRect)frame;



-(void)setTextNumber:(float)num;
@end
