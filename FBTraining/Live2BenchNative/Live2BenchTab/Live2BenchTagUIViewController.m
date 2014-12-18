//
//  Live2BenchTagUIViewController.m
//  Live2BenchNative
//
//  Created by dev on 2014-12-10.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "Live2BenchTagUIViewController.h"

#import "Globals.h"
/*
 This class manages the creation of the side tags as well as displays them

 
 */

@implementation Live2BenchTagUIViewController
{

    UIView * placementView;
}
@synthesize enabled     = _enabled;
@synthesize hidden      = _hidden;
@synthesize buttonSize  = _buttonSize;
@synthesize gap         = _gap;
@synthesize topOffset   = _topOffset;

-(id)initWithView:(UIView*)view
{
    self = [super init];
    if (self) {
        tagButtonsLeft      = [[NSMutableArray alloc]init];
        tagButtonsRight     = [[NSMutableArray alloc]init];
        buttons             = [[NSMutableDictionary alloc]init];
        placementView       = view;
//        self.view           = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 500, 200)];
        tagCount            = 0;
        _topOffset          = 100.0f; // space from top of the screen
        _buttonSize         = CGSizeMake( 124.0f, 30.0f );
        _gap                = 2;
        _enabled            = NO;
        
    }

    return self;
}

// this builds the tags from the supplied data
-(void)inputTagData:(NSArray*)listOfDicts
{
    [self clear]; // clear if any is present
     for (NSDictionary * btnData in listOfDicts) {
         // Builds the button and adds it to the view
         [placementView addSubview:[self _buildButton:btnData]];
     }
    self.enabled = _enabled; // sets the fade after build base off last setting of enabled
}



-(void)addActionToAllTagButtons:(SEL)sel addTarget:(id)target forControlEvents:(UIControlEvents)controlEvent
{
    for (NSMutableArray * list in @[tagButtonsLeft,tagButtonsRight]) {
        for (BorderButton * btn in list) {
            [btn addTarget:target action:sel forControlEvents:controlEvent];
        }
    }
}


-(void)clear
{
    tagCount = 0;
    for (NSMutableArray * list in @[tagButtonsLeft,tagButtonsRight]) {
        for (BorderButton * btn in list) {
            [btn removeFromSuperview];
        }
        [list removeAllObjects];
    }
    [buttons removeAllObjects];
}


-(BorderButton *)_buildButton:(NSDictionary*)dict
{
    BorderButton * btn = [BorderButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:[dict objectForKey:@"name"] forState:UIControlStateNormal];
    [btn setTag:tagCount++];
    
    [buttons setObject:btn forKey:[dict objectForKey:@"name"]];
    
    if( [[dict objectForKey:@"side"] isEqualToString:@"left"]  || [[dict objectForKey:@"position"] isEqualToString:@"left"]){

        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [btn setAccessibilityValue:@"left"];
        
        [btn setFrame:CGRectMake(0,
                                 ( [tagButtonsLeft count] * (_buttonSize.height + _gap) ) + _topOffset,
                                 _buttonSize.width,
                                 _buttonSize.height) ];
        
        [tagButtonsLeft addObject:btn];
        
        // TODO DEPREICATED START
        if (![[Globals instance].LEFT_TAG_BUTTONS_NAME containsObject:[dict objectForKey:@"name"]]) {
            [[Globals instance].LEFT_TAG_BUTTONS_NAME addObject:[dict objectForKey:@"name"]];
        }
        // TODO DEPREICATED END
        
    } else { /// Right Tags
        
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn setAccessibilityValue:@"right"];
        
        [btn setFrame:CGRectMake(self.view.bounds.size.width - _buttonSize.width,
                                 ( [tagButtonsRight count] * (_buttonSize.height + _gap) ) + _topOffset,
                                 _buttonSize.width,
                                 _buttonSize.height) ];
        
        [tagButtonsRight addObject:btn];
        
        // TODO DEPREICATED START
        if (![[Globals instance].RIGHT_TAG_BUTTONS_NAME containsObject:[dict objectForKey:@"name"]]) {
            [[Globals instance].RIGHT_TAG_BUTTONS_NAME addObject:[dict objectForKey:@"name"]];
        }
        // TODO DEPREICATED END
    
    }
    
    return btn;
}


-(BorderButton*)getButtonByName:(NSString*)btnName
{

    return [buttons objectForKey:btnName];

}


/////////////////////////////////////////////////// getter and setters

-(void)setEnabled:(BOOL)enabled
{
    [self willChangeValueForKey:@"enabled"];
    _enabled = enabled;
    
    CGFloat     alpha       = (_enabled)?   1.0f:0.6f;
    BOOL        interEnable = (_enabled)?   TRUE:FALSE;
    
    for (NSMutableArray * list in @[tagButtonsLeft,tagButtonsRight]) {
        for (BorderButton * btn in list) {
            [btn setAlpha:alpha];
            [btn setUserInteractionEnabled:interEnable];
        }
    }
   
    [self didChangeValueForKey:@"enabled"];
}

-(BOOL)enabled
{
    return _enabled;
}



-(void)setHidden:(BOOL)hidden
{
    [self willChangeValueForKey:@"hidden"];
    _enabled = hidden;
    
     for (NSMutableArray * list in @[tagButtonsLeft,tagButtonsRight]) {
        for (BorderButton * btn in list) {
            [btn setHidden:_enabled];
        }
    }
    
    [self didChangeValueForKey:@"hidden"];
}

-(BOOL)hidden
{
    return _hidden;
}




@end
