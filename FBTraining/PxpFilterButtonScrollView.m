//
//  PxpFilterButtonScrollView.m
//  Live2BenchNative
//
//  Created by dev on 2015-07-29.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterButtonScrollView.h"
#import "CustomButton.h"



@implementation PxpFilterButtonScrollView
{
    NSInteger   selectedCount;
    NSPredicate * combo;
    NSMutableSet * _userSelected;
    
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _buttonSize      = CGSizeMake(120, 25);
        _buttonMargin    = CGSizeMake(3, 3);
        _buttonList      = [NSMutableArray new];
        _userSelected    = [NSMutableSet new];
    }
    return self;
}

-(void)encodeWithCoder:(nonnull NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttonSize      = CGSizeMake(120, 25);
        _buttonMargin    = CGSizeMake(3, 3);
        _buttonList      = [NSMutableArray new];
        _userSelected    = [NSMutableSet new];
        
    }
    return self;
}


-(void)buildButtonsWith:(NSArray *)buttonLabels
{

    for (CustomButton * buttonObj in _buttonList) {
        [buttonObj removeFromSuperview];
    }
    [_buttonList removeAllObjects];

    NSUInteger colNum = 0;
    NSUInteger rowNum = 0;
    NSUInteger rowCount = (NSUInteger)self.frame.size.height / _buttonSize.height;
    for (NSUInteger k = 0; k < buttonLabels.count; k++ ) {
        
        
        
        NSString    *tagLabel       = [buttonLabels objectAtIndex:k];
        CGRect      rect            =  CGRectMake(colNum * (_buttonSize.width+_buttonMargin.width),
                                                  rowNum * (_buttonSize.height+_buttonMargin.height),
                                                  _buttonSize.width, _buttonSize.height);
        
        if (++rowNum ==rowCount){
            rowNum = 0;
            colNum++;
        }
        
        CustomButton  *eventButton = [self buildButton:rect btnText:tagLabel];
        [self addSubview:eventButton];
    }

    
    
    // rebuild filter
    NSMutableArray  * toCombo  = [[NSMutableArray alloc]init];
    for (CustomButton  *b in _buttonList) {
        if(b.selected == YES){
            selectedCount++;
            [toCombo addObject:[NSPredicate predicateWithFormat:@"%K == %@",_sortByPropertyKey, b.titleLabel.text]];
        }
    }
    combo           = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];

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
-(CustomButton *)buildButton:(CGRect)frame btnText:(NSString*)btnTxt
{
    CustomButton  *eventButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
    [eventButton setFrame:frame];
    [eventButton setBackgroundImage:[UIImage imageNamed:@"line-button-grey.png"] forState:UIControlStateNormal];
    [eventButton setBackgroundImage:[UIImage imageNamed:@"num-button.png"] forState:UIControlStateSelected];
    [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    [eventButton setTitle:btnTxt forState:UIControlStateNormal];
    [eventButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [eventButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    eventButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    
    eventButton.selected = [_userSelected containsObject:btnTxt];
    [self addSubview:eventButton];
    [_buttonList addObject:eventButton];
    return eventButton;
}



// This calls a selector and tells the next object to update
-(void)cellSelected:(id)sender
{
    CustomButton    * button   = (CustomButton *)sender;
    NSMutableArray  * toCombo  = [[NSMutableArray alloc]init];
    selectedCount              = 0;
    button.selected            = !button.selected;
    
    for (CustomButton  *b in _buttonList) {
        if(b.selected == YES){
            selectedCount++;
            [toCombo addObject:[NSPredicate predicateWithFormat:@"%K == %@",_sortByPropertyKey, b.titleLabel.text]];
            [_userSelected addObject:b.titleLabel.text];
        } else {
            [_userSelected removeObject:b.titleLabel.text];
        }
    }
    
    combo           = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];
    [_parentFilter refresh];
}

-(void)deselect
{
    for (CustomButton  *b in _buttonList) {
        b.selected = NO;
    }
    selectedCount = 0;
    [_userSelected removeAllObjects];
}


// Protocol methods
-(void)filterTags:(NSMutableArray *)tagsToFilter
{
    if (selectedCount == 0 || selectedCount == [_buttonList count]) return; // all or none are selected
    [tagsToFilter filterUsingPredicate:combo];
}



@end
