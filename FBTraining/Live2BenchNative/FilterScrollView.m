 //
//  FilterScrollView.m
//  QuickTest
//
//  Created by dev on 7/11/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "FilterScrollView.h"
#import "CustomButton.h"
#import "FilterProcessor.h"
#import "FilterItemProtocol.h"


#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#define ROWS_IN_EVENTS                 6
#define PADDING                        3






/**
 *  This class should be almost view as more of an abstract.
 *  it will be part of a linked list of that will start with a list of all tags
 *  and each component it passes thru will define the display list more

 *  This class needs to be a simple in and out with a refresh for new tags and data
 
 */
@implementation FilterScrollView
{
    SEL onSelectSelector;
    id selTarget;
}
@synthesize buttonMargin;
@synthesize buttonSize;
@synthesize previous;
@synthesize next;
@synthesize label;
@synthesize rowCount;
@synthesize sortType;
@synthesize filterP;
@synthesize selectedTags;

- (id)initWithFrame:(CGRect)frame Name:(NSString*)name AccessLable:(NSString*)aLabel
{
    self = [super initWithFrame:frame];
    if (self) {
        invoked         = NO;
        accessLable     = aLabel;
        buttonSize      = CGSizeMake(120, 25);
        buttonMargin    = CGSizeMake(PADDING, PADDING);
        rowCount        = ROWS_IN_EVENTS;
        sortType        = FilterScrollSortAlpha;
        label           = [[UILabel alloc] initWithFrame:CGRectMake(10,-38,70,40)];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        [label setText:name];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:17.0f]];
        [self addSubview:label];
        
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        [scrollView setDelegate:self];
        [self addSubview:scrollView];
//        self.layer.borderWidth = 1;
        
        buttonList      = [[NSMutableArray alloc]init];
        selectedTags    = [[NSMutableSet alloc]init];
        filterP         = [[FilterProcessor alloc]initWithTagKey:aLabel];
        [scrollView setScrollEnabled:TRUE];
    }
    return self;
}


// this will descided the buttons and

-(void)setFilterBlock:(NSString* (^)(NSDictionary*))madeKey
{
    filterBlock = madeKey;
    [filterP setFilterBlock:madeKey];

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
    
    // get all unique
    NSMutableSet * uniqueSet = [[NSMutableSet alloc]init];
   
    for(id <FilterItemProtocol> tag in list){
        
        // This check the tag for a direct key to a String using a block
        if (filterBlock != NULL){
            NSString * tagValueA = (filterBlock != NULL)? filterBlock(tag.rawData): tag[accessLable];
            if ([uniqueSet containsObject:tagValueA]) continue;
            [uniqueSet addObject:tagValueA];
            
        }
        
        // This check the tag for a direct key to a String
        else if ([tag.rawData[accessLable] isKindOfClass:[NSString class]]) {
            NSString * tagValueB = tag.rawData[accessLable];
            if ([uniqueSet containsObject:tagValueB] || [tagValueB isEqualToString:@""]) continue;
            [uniqueSet addObject:tagValueB];
        }
        
        // This sees if the value of the key is an array and adds each to the unique search
        else if ([tag.rawData[accessLable] isKindOfClass:[NSArray class]]) {
            NSArray * checkArray = tag.rawData[accessLable];
            for (id item in checkArray) {
                NSNumber * tagValueC = item;
                if ([uniqueSet containsObject:tagValueC]) continue;
                [uniqueSet addObject:tagValueC];
            }
        }

        
    }

    
    NSArray * buttonLabels;
    
    switch (sortType) {
        
        case FilterScrollSortNumarical:
                buttonLabels = [[uniqueSet allObjects] sortedArrayUsingComparator:^(id obj1, id obj2) {
                    return [obj1 intValue] - [obj2 intValue];
                }];
            break;
            
        case FilterScrollSortAlpha:
        default:
                buttonLabels = [[uniqueSet allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            break;
    }
    
    
   
    
    int colNum = 0;
    int rowNum = 0;
    for (int k = 0; k<buttonLabels.count; k++  ) {
        
        
        
        NSString    *tagLabel       = [buttonLabels objectAtIndex:k];
        CGRect      rect            =  CGRectMake(colNum * (buttonSize.width+buttonMargin.width),
                                                  rowNum * (buttonSize.height+buttonMargin.height),
                                                  buttonSize.width, buttonSize.height);
        
        if (++rowNum ==rowCount){
            rowNum = 0;
            colNum++;
        }
        
        CustomButton  *eventButton = [self buildButton:rect btnText:tagLabel accessibilityLabel:accessLable];
        [scrollView addSubview:eventButton];
    }
    
    [scrollView setContentSize:CGSizeMake((colNum+1) * buttonSize.width, self.frame.size.height)];
  
    
    // this perserves the filtering on refresh
    
    if ([selectedTags count] == 0) return; // if noselectTags skip this part
    
    for (CustomButton *activeButton in buttonList){
        if ([selectedTags containsObject:activeButton.titleLabel.text])
        {
            activeButton.selected = YES;
        }
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
    [eventButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [eventButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
    [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    [eventButton setTitle:btnTxt forState:UIControlStateNormal];
    [eventButton setAccessibilityLabel:aLabel];
    [eventButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [eventButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    eventButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    [scrollView addSubview:eventButton];
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


/**
 *  This is the method that will run when ever the component is tapped and is
 *  and is the last compoenent in the linked list.
 *  @param sel
 *  @param target
 */
-(void)onSelectPerformSelector:(SEL)sel addTarget:(id)target
{
    selTarget = target;
    onSelectSelector = sel;
}


/**
 *  This will update the list of tages produced by this component
 *  by updating FilterProcessor with a set of selected tags that the user has picked and
 *  then sends the processed list to the next component. If there are no more components then it 
 *  will run the selector. The new refined list is ready to be displayed
 */
-(void)update
{
      invoked = ([selectedTags count])? YES : NO; // a quick bool for if its used or not
    [filterP updateWith:selectedTags]; //what ever is selected or unselected
    if(next){
        [next inputArray:[filterP processedList]];
        [next update];
    } else {
        if (onSelectSelector) [selTarget performSelector:onSelectSelector withObject:self];
    }
}


/**
 *  This will be the main input for the first all the tags to be filtered
 *  This will also be the main input from the linked list
 *  @param list to be filtered
 */
-(void)inputArray:(NSArray*)list
{
    [filterP inputArray:list];
    if(self.next) [self.next inputArray:[filterP processedList]];
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


-(void)deselectAll
{
    [selectedTags removeAllObjects];
    invoked = NO;
    [self update];
    for(CustomButton *button in buttonList)
    {
        [button setSelected:FALSE];
    }
}

-(void)nextComponent:(id <FilterComponent>)nxt
{
    self.next = nxt;
}

-(void)previousComponent:(id <FilterComponent>)prev
{
    self.previous = prev;
}

-(NSString*)getName
{
    return label.text;
}
-(BOOL)isInvoked
{
    return invoked;
}


@end
