//
//  DurationView.m
//  Live2BenchNative
//
//  Created by dev on 8/7/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "DurationView.h"
#import "CustomButton.h"
#define USER_BUTTON_CONTAINER_WIDTH     200
#define USER_BUTTON_HEIGHT              40
#define ROWS_IN_EVENTS                  6
#define PADDING                         3


@implementation DurationView
{
    UILabel                 * label;
    FilterProcessor         * filterP;
//    NSString                * (^filterBlock)(NSDictionary*tag);
    NSMutableSet            * selectedTags;
    NSMutableArray          * buttonList;
    NSMutableDictionary     * predicates;
}
@synthesize buttonSize;
@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame Name:(NSString*)name
{
    self = [super initWithFrame:frame];
    if (self) {

        buttonSize = CGSizeMake(USER_BUTTON_CONTAINER_WIDTH, USER_BUTTON_HEIGHT);
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0,-34,USER_BUTTON_CONTAINER_WIDTH,30)];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        [label setText:name];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:17.0f]];
        [self addSubview:label];
        
        buttonList      = [[NSMutableArray alloc]init];
        selectedTags    = [[NSMutableSet alloc]init];
        filterP         = [[FilterProcessor alloc]initWithTagKey:name];
    }
    return self;

}


- (id)initWithFrame:(CGRect)frame Name:(NSString*)name dict:(NSMutableDictionary*)dictOfPredicates
{
    self = [super initWithFrame:frame];
    if (self) {
        predicates = dictOfPredicates;
        buttonSize = CGSizeMake(USER_BUTTON_CONTAINER_WIDTH, USER_BUTTON_HEIGHT);
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0,-34,USER_BUTTON_CONTAINER_WIDTH,30)];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        [label setText:name];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:17.0f]];
        [self addSubview:label];
        
        buttonList      = [[NSMutableArray alloc]init];
        selectedTags    = [[NSMutableSet alloc]init];
        filterP         = [[FilterProcessor alloc]initWithTagKey:name];
    }
    return self;

}


-(void)inputArray:(NSArray*)list
{
    [filterP inputArray:list];
    if(self.next) [self.next inputArray:[filterP processedList]];
}


/**
 *  This is different from the other component filters
 *  it works by taking all the selected buttons and comparing them to a dict of Predicates and 
 *  sends them in to the filter processor to be used
 */
-(void)update
{
    
    NSMutableArray *predFilters = [NSMutableArray array];
    NSArray *selected = [selectedTags allObjects];
    
    for (NSString *selectedButton in selected) {
        [predFilters addObject: [predicates objectForKey:selectedButton]];
    }
    
    [filterP updateWithPredicate:[predFilters copy]];

    if(self.next){
        [self.next inputArray:[filterP processedList]];
        [self.next update];
    } else {
        if (onSelectSelector) [selTarget performSelector:onSelectSelector withObject:self];
    }
}



/**
 *  Returns the list after its been filtered by the component
 *  this will mostly be directed to the next linked object or to the Filter View for displaying
 *  @return new list of tags
 */
-(NSArray*)refinedList
{
    return [filterP processedList];
}

-(void)populate:(NSArray *)list
{
    //remove any previous buttons
    for (CustomButton * buttonObj in buttonList) {
        [buttonObj removeFromSuperview];
    }
    [buttonList removeAllObjects];
    
  
    
//    NSMutableArray * pool = [[NSMutableArray alloc]init];
//    for(NSDictionary *tag in list){
//        NSString * tagValue = (filterBlock != NULL)? filterBlock(tag): tag[@"none"];
//        if ([pool containsObject:tagValue]) continue;
//        [pool addObject:tagValue];
//    }
    
    NSArray * buttonLabels =   [predicates allKeys];
    
    
    for(NSString *tagLabel in buttonLabels)
    {
        int i = [buttonLabels indexOfObject:tagLabel];
        float bWidth = (USER_BUTTON_CONTAINER_WIDTH - (PADDING *buttonLabels.count)) /buttonLabels.count;
        
        CustomButton  *eventButton = [self buildButton:CGRectMake(i*(bWidth+PADDING), 0, bWidth, USER_BUTTON_HEIGHT) btnText:tagLabel accessibilityLabel:tagLabel];
        
        [self addSubview:eventButton];
        i++;
    }
    
}


-(CustomButton *)buildButton:(CGRect)frame btnText:(NSString*)btnTxt accessibilityLabel:(NSString*)aLabel
{
    CustomButton  *eventButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
    [eventButton setFrame:frame];
    
//    [eventButton setBackgroundColor:[self colorWithHexString:btnTxt]];
    [eventButton setTitle:btnTxt forState:UIControlStateNormal];
    [eventButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    [eventButton setAccessibilityLabel:aLabel];
    [eventButton setAlpha:0.1f];
    [eventButton setSelected:NO];
    [self addSubview:eventButton];
    [buttonList addObject:eventButton];
    return eventButton;
}


// This calls a selector and tells the next object to update
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

-(void)deselectAll
{
    [selectedTags removeAllObjects];
    [self update];
    for(CustomButton *button in buttonList)
    {
        [button setSelected:FALSE];
        [button setAlpha:0.1f];
    }
}

@end
