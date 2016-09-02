//
//  RicoSourcePickerButtons.h
//  Live2BenchNative
//
//  Created by dev on 2016-03-15.
//  Copyright © 2016 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RicoSourcePickerButtons;



@protocol RicoSourcePickerButtonsDelegate <NSObject>

-(void)onPressButton:(RicoSourcePickerButtons*)picker;


@end



@interface RicoSourcePickerButtons : UIView

@property (nonatomic,weak)  id<RicoSourcePickerButtonsDelegate> delegate;

@property (nonatomic,strong) NSMutableArray * buttonArray;
@property (nonatomic,strong) NSArray        * stringArray;
@property (nonatomic,assign) NSInteger      selectedTag;
@property (nonatomic,assign) NSString       * selectedString;
@property (nonatomic,strong) UIColor        * selectedColor;
@property (nonatomic,strong) UIColor        * deselectedColor;


-(void)buildButtonsWithString:(NSArray*)arrayOfString;
-(void)selectButtonByIndex:(NSInteger)index;
-(void)selectButtonByString:(NSString*)buttonString;

-(void)highlightButtonByIndex:(NSInteger)index;
-(void)highlightButtonByString:(NSString*)buttonString;

-(void)deselectAll;
@end
