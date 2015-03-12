//
//  ExternalScreenButton.m
//  Live2BenchNative
//
//  Created by dev on 10/2/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//
/**
 *  This is a pooled button class that is checked by the screenController class
 *  when ever a screen is attached it will set the hidden to false and when the screen is removed it will be hidden set to true
 *
 *  @param idinitWithFrame:CGRect
 *
 *  @return
 */
#import "ExternalScreenButton.h"

@implementation ExternalScreenButton

static NSMutableArray   * allExternalScreenButtons;
static bool visible;
+(void)initializeStatics
{
    allExternalScreenButtons 				= [[NSMutableArray alloc]init];
}


+(void)setAllHidden:(BOOL)hidden
{
    if (!allExternalScreenButtons) [ExternalScreenButton initializeStatics];
    visible = hidden;
    for(ExternalScreenButton * item in allExternalScreenButtons){
        [item setHidden:hidden];
    }
};


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!allExternalScreenButtons) [ExternalScreenButton initializeStatics];
        [allExternalScreenButtons addObject:self];
        [self setTitle:@"Ext" forState:UIControlStateNormal];
        [self setHidden:visible];
    }
    return self;
}



@end
