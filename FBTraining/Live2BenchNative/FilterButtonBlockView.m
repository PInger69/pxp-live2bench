//
//  FilterButtonBlockView.m
//  Live2BenchNative
//
//  Created by dev on 8/5/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FilterButtonBlockView.h"
#import "CustomButton.h"




@implementation FilterButtonBlockView
{


}
@synthesize buttonSize;
@synthesize buttonMargin; // used only during populate
@synthesize orientation;
@synthesize groupLength;
@synthesize label;
@synthesize fixedFilter;



- (id)initWithFrame:(CGRect)frame Name:(NSString*)nme AccessLable:(NSString*)aLabel
{
    self = [super initWithFrame:frame];
    if (self) {
        
        accessLable = aLabel;
        name        = nme;
        buttonSize  = CGSizeMake(120, 25);
        buttonSize  = CGSizeMake(10, 10);
        orientation = FilterButtonBlockHorzontal;
        groupLength = 5;
        label = [[UILabel alloc] initWithFrame:CGRectMake(10,-34,70,40)];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        [label setText:nme];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:17.0f]];
        [self addSubview:label];
        
        

        //        self.layer.borderWidth = 1;
        
        buttonList      = [[NSMutableArray alloc]init];
        selectedTags    = [[NSMutableSet alloc]init];
        self.filterP         = [[FilterProcessor alloc]initWithTagKey:aLabel];
        
    }
    return self;
}

/**
 *  This takes in the full tag list and breaks it down to just the tags types you want
 *  displayed in the view. This will clear out any buttons that are placesed if ran again
 *  @param list all tags
 */
-(void)populate:(NSArray *)list
{
    //remove any previous buttons
    for (CustomButton * buttonObj in buttonList) {
        [buttonObj removeFromSuperview];
    }
    [buttonList removeAllObjects];
    
    
    NSArray * buttonLabels;
    // get all unique
    if (fixedFilter) {
        buttonLabels = fixedFilter;
    } else {
        NSMutableSet * uniqueSet = [[NSMutableSet alloc]init];
        for(NSDictionary *tag in list){
            NSString * tagValue = (filterBlock != NULL)? filterBlock(tag): tag[accessLable];
            if ([uniqueSet containsObject:tagValue]) continue;
            [uniqueSet addObject:tagValue];
        }
        
        buttonLabels = [[uniqueSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    

    

    
    int i = 0;
    int gLength = groupLength-1;
    for(NSString *tagLabel in buttonLabels)
    {
        if ([tagLabel isEqualToString:@""]) continue;
        int colNum;
        int rowNum;
        
        if (orientation == FilterButtonBlockVertical) {
            colNum = floor(i/gLength);
            
            rowNum = (i)%gLength>=0 ? (i)%gLength : gLength;
        } else {
            colNum = (i)%gLength>=0 ? (i)%gLength : gLength;
            rowNum = floor(i/gLength);
        }
      
        
        int posX = colNum * (buttonSize.width+buttonMargin.width);
        int posY = rowNum * (buttonSize.height+buttonMargin.height);
        
        
        CustomButton  *eventButton = [self buildButton:
                                      CGRectMake(posX,
                                                 posY,
                                                 buttonSize.width,
                                                 buttonSize.height)
                                               btnText:tagLabel accessibilityLabel:accessLable];
        
        
        
        [self addSubview:eventButton];
        i++;
    }
    
    [self keepSelectionOnRefresh:buttonList buttonsSelected:selectedTags];
}




-(void)setFilterBlock:(NSString* (^)(NSDictionary*))madeKey
{
    filterBlock = madeKey;
    [self.filterP setFilterBlock:madeKey];
    
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


/**
 *  This creates the button structure (maybe the button should have its own class)
 *
 *  @param frame  buttons Position and size
 *  @param btnTxt the text that will be visible on the button
 *  @param aLabel accessibilityLabel
 *
 *  @return produced button
 */
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
//    [self addSubview:eventButton];
    [buttonList addObject:eventButton];
    return eventButton;
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


-(void)deselectAll
{
    [selectedTags removeAllObjects];
    [self update];
    self.invoked = NO;
    for(CustomButton *button in buttonList)
    {
        [button setSelected:FALSE];
    }
}







@end
