//
//  UserColourView.m
//  Live2BenchNative
//
//  Created by dev on 7/22/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "UserColourView.h"
#import "CustomButton.h"
#import "UserColorButton.h"
#import "FilterItemProtocol.h"

#define USER_BUTTON_CONTAINER_WIDTH     200
#define USER_BUTTON_HEIGHT              40
#define ROWS_IN_EVENTS                  6
#define PADDING                         3
@implementation UserColourView
{
    UILabel                 * label;
    NSString                * accessLable;
    NSString                * (^filterBlock)(NSDictionary*tag);
    NSMutableArray          * buttonList;
/*TO DELETE
//    FilterProcessor         * filterP;
//    NSMutableSet            * selectedTags;
*/
}


@synthesize buttonSize;
@synthesize label;

- (id)initWithFrame:(CGRect)frame Name:(NSString*)nme AccessLable:(NSString*)aLabel
{
    self = [super initWithFrame:frame];
    if (self) {
        name = nme;
        accessLable = aLabel;
        buttonSize  = CGSizeMake(USER_BUTTON_CONTAINER_WIDTH, USER_BUTTON_HEIGHT);
        self.invoked     = NO;
        label       = [[UILabel alloc] initWithFrame:CGRectMake(0,-34,USER_BUTTON_CONTAINER_WIDTH,30)];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        [label setText:name];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:17.0f]];
        [self addSubview:label];
        
        buttonList      = [[NSMutableArray alloc]init];
        selectedTags    = [[NSMutableSet alloc]init];
        self.filterP         = [[FilterProcessor alloc]initWithTagKey:aLabel];
        
    }
    return self;
}

/**
 *  This will be the main input for the first all the tags to be filtered
 *  This will also be the main input from the linked list
 *  @param list to be filtered
 */
-(void)inputArray:(NSArray*)list
{
    [self.filterP inputArray:list];
    if(self.next) [self.next inputArray:[self.filterP processedList]];
}



/*TO DELETE

//-(void)update
//{
//    [filterP updateWith:selectedTags]; //what ever is selected or unselected
//    if(self.next){
//        [self.next inputArray:[filterP processedList]];
//        [self.next update];
//    } else {
//        if (onSelectSelector) [selTarget performSelector:onSelectSelector withObject:self];
//    }
//}
*/

-(void)populate:(NSArray *)list
{
    //remove any previous buttons
    for (CustomButton * buttonObj in buttonList) {
        [buttonObj removeFromSuperview];
    }
    [buttonList removeAllObjects];
    
    
    
    NSMutableArray * pool = [[NSMutableArray alloc]init];
    for(id <FilterItemProtocol> tag in list){
        NSString * tagValue = (filterBlock != NULL)? filterBlock(tag.rawData): tag.rawData[accessLable];
        if ([pool containsObject:tagValue]) continue;
        [pool addObject:tagValue];
    }
    
    NSArray * buttonLabels = (NSArray *)pool;
    

    for(NSString *tagLabel in buttonLabels)
    {
        int i = [buttonLabels indexOfObject:tagLabel];
        float bWidth = (USER_BUTTON_CONTAINER_WIDTH - (PADDING *buttonLabels.count)) /buttonLabels.count;

        CustomButton  *eventButton = [self buildButton:CGRectMake(i*(bWidth+PADDING), 0, bWidth, USER_BUTTON_HEIGHT) btnText:tagLabel accessibilityLabel:accessLable];
        
        [self addSubview:eventButton];
        i++;
    }
    
    [self keepSelectionOnRefresh:buttonList buttonsSelected:selectedTags];
}


-(CustomButton *)buildButton:(CGRect)frame btnText:(NSString*)btnTxt accessibilityLabel:(NSString*)aLabel
{
//    CustomButton  *eventButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
   
    CustomButton  *eventButton = [[UserColorButton alloc]initWithFrame:frame btnText:btnTxt accessibilityLabel:aLabel];
//    [eventButton setFrame:frame];
//
//    [eventButton setBackgroundColor:[self colorWithHexString:btnTxt]];
//    [eventButton setTitle:btnTxt forState:UIControlStateNormal];
//    [eventButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//    [eventButton setAccessibilityLabel:aLabel];
//    [eventButton setAlpha:0.1f];
//    [eventButton setSelected:NO];
    
    [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:eventButton];
    [buttonList addObject:eventButton];
    return eventButton;
}


// This calls a selector and tells the next object to update
-(void)cellSelected:(id)sender
{
    CustomButton  *button = (CustomButton *)sender;
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
//    if (!isButtonSelected) {
//        [button setAlpha:0.1f];
//    } else {
//        [button setAlpha:1.0f];
//    }
    
    [button setSelected:isButtonSelected];
    
    if(button.isSelected){
//        [button setAlpha:1.0f];
        [selectedTags addObject:button.titleLabel.text];
    } else {
//         [button setAlpha:0.1f];
        [selectedTags removeObject:button.titleLabel.text];
    }
    
    [self update];
}


-(void)update
{
    [super update];
}


-(void)deselectAll
{
    [selectedTags removeAllObjects];
    [self update];
        self.invoked = NO;
    for(CustomButton *button in buttonList)
    {
        [button setSelected:FALSE];
        [button setAlpha:0.1f];
    }
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
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
