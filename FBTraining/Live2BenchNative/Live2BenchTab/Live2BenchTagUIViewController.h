//
//  Live2BenchTagUIViewController.h
//  Live2BenchNative
//
//  Created by dev on 2014-12-10.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderButton.h"
@interface Live2BenchTagUIViewController : UIViewController
{
    NSMutableArray      * tagButtonsLeft;
    NSMutableArray      * tagButtonsRight;
    NSInteger           * tagCount;
    NSMutableDictionary * buttons;
}

@property (assign,nonatomic) BOOL       enabled;
@property (assign,nonatomic) BOOL       hidden;
@property (assign,nonatomic) CGSize     buttonSize;
@property (assign,nonatomic) CGFloat    gap;
@property (assign,nonatomic) CGFloat    topOffset;

-(id)initWithView:(UIView*)view;
-(void)inputTagData:(NSArray*)listOfDicts;
-(void)addActionToAllTagButtons:(SEL)sel addTarget:(id)target forControlEvents:(UIControlEvents)controlEvent;

-(void)clear;
-(BorderButton*)getButtonByName:(NSString*)btnName;


@end
