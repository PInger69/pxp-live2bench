//
//  JPFont.h
//  JumpPad
//
//  Created by Si Te Feng on 12/11/2013.
//  Copyright (c) 2013 Si Te Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPFont : UIFont


+ (UIFont*)coolFontOfSize: (CGFloat)size;
+ (UIFont*)dashletTitleFont;



//Default Fonts Arraged accroding to thickness

+ (NSString*)defaultBoldFont;
+ (NSString*)defaultBoldItalicFont;

//Regular Series
+ (NSString*)defaultFont;
+ (NSString*)defaultItalicFont;


+ (NSString*)defaultMediumFont;

+ (NSString*)defaultLightFont;
+ (NSString*)defaultThinFont;

+ (NSString*)defaultUltraLightFont;

@end
