//
//  ToggleButton.m
//  Live2BenchNative
//
//  Created by dev on 8/27/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "ToggleButton.h"
#import "CustomButton.h"

#define USER_BUTTON_CONTAINER_WIDTH     200

@implementation ToggleButton
{
    UILabel                 * label;
    NSString                * accessLable;
    NSString                * (^filterBlock)(NSDictionary*tag);
    CustomButton            * mainButton;

}

- (id)initWithFrame:(CGRect)frame Name:(NSString*)nme AccessLable:(NSString*)aLabel
{
    self = [super initWithFrame:frame];
    if (self) {
        name = nme;
        self.invoked     = NO;
        label       = [[UILabel alloc] initWithFrame:CGRectMake(0,-34,USER_BUTTON_CONTAINER_WIDTH,30)];
        [label setText:name];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:17.0f]];
        [self addSubview:label];
        
        mainButton = [self buildButton:CGRectMake(0,0, USER_BUTTON_CONTAINER_WIDTH, 40) btnText:@"Coach Pick" accessibilityLabel:@"coachPick"] ;
        [self addSubview:mainButton];
        
        selectedTags    = [[NSMutableSet alloc]init];
        self.filterP         = [[FilterProcessor alloc]initWithTagKey:aLabel];
        

        
    }
    return self;

}


-(void)setFilterBlock:(NSString* (^)(NSDictionary*))blk
{
     [self.filterP setFilterBlock:blk];
}

-(CustomButton *)buildButton:(CGRect)frame btnText:(NSString*)btnTxt accessibilityLabel:(NSString*)aLabel
{

    CustomButton  *eventButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
    [eventButton setFrame:frame];
    [eventButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:SECONDARY_APP_COLOR] forState:UIControlStateNormal];
    [eventButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR] forState:UIControlStateSelected];
    [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    [eventButton setTitle:btnTxt forState:UIControlStateNormal];
    [eventButton setAccessibilityLabel:aLabel];
    [eventButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [eventButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    eventButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];

    return eventButton;
}

-(void)inputArray:(NSArray*)list
{
    [self.filterP inputArray:list];
    if(self.next) [self.next inputArray:[self.filterP processedList]];
}

-(void)deselectAll
{
    [selectedTags removeAllObjects];
    [self update];
    self.invoked = NO;
    [mainButton setSelected:FALSE];
}

-(void)populate:(NSArray *)list
{
//    mainButton = [self buildButton:self.frame btnText:@"sdafsd" accessibilityLabel:@"coachPick"] ;
    
    
    mainButton.accessibilityLabel = @"1";
//
//    [self addSubview:mainButton];
//
//    [self keepSelectionOnRefresh:<#(NSMutableArray *)#> buttonsSelected:<#(NSMutableSet *)#>

}


-(void)cellSelected:(id)sender
{
    CustomButton  *button = (CustomButton *)sender;
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;

    [button setSelected:isButtonSelected];
    
    if(button.isSelected){
        [selectedTags addObject:button.titleLabel.text];
    } else {
        [selectedTags removeObject:button.titleLabel.text];
    }
    
    [self update];
}

/**
 *  Returns the list after its been filtered by the component
 *  this will mostly be directed to the next linked object or to the Filter View for displaying
 *  @return new list of tags
 */
-(NSArray*)refinedList
{
    return [self.filterP processedList];
}

@end
