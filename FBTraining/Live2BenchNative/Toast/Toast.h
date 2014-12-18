//
//  Toast.h
//  Live2BenchNative
//
//  Created by DEV on 2013-04-03.
//  Copyright (c) 2013 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilitiesController.h"

@interface Toast : UIView
{
    UILabel* eventTitle;
    UtilitiesController *uController;
    UIView *colourStripe;
}



-(id)init;
-(void)setEventForColour:(NSString*)event colour:(NSString*)hexColour;
@end
