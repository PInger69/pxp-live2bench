//
//  FilterComponentAbstract.m
//  Live2BenchNative
//
//  Created by dev on 8/5/2014.
//  Copyright (c) 2014 DEV. All rights reserved.
//

#import "FilterComponentAbstract.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation FilterComponentAbstract


@synthesize previous;
@synthesize next;
@synthesize invoked;
@synthesize selectedTags;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
    return (name)?name:@"no name";
}

-(void)update
{
    invoked = ([selectedTags count])? YES : NO; // a quick bool for if its used or not
    [self.filterP updateWith:selectedTags]; //what ever is selected or unselected
    if(self.next){
        [self.next inputArray:[self.filterP processedList]];
        [self.next update];
    } else {
        if (onSelectSelector) [selTarget performSelector:onSelectSelector withObject:self];
    }


}

-(BOOL)isInvoked
{
    return invoked;
}

-(void)keepSelectionOnRefresh:(NSMutableArray*)allButtons buttonsSelected:(NSMutableSet*)selTag
{
    if ([selTag count] == 0) return; // if noselectTags skip this part
    
    for (UIButton *activeButton in allButtons){
        if ([selTag containsObject:activeButton.titleLabel.text])
        {
            activeButton.selected = YES;
        }
    }
    [self update];

}


@end
