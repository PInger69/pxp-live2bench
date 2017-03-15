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
//    NSMutableSet * _userSelected;
    NSMutableDictionary * _cachedButtons;
    UIImage * _buttonHighlightPixel;
    UIImage * _buttonNormalPixel;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _buttonSize             = CGSizeMake(120, 26);
        _buttonMargin           = CGSizeMake(4, 4);
        _buttonList             = [NSMutableArray new];
        _userSelected           = [NSMutableArray new];
        _buttonHighlightPixel   = [Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR];
        _buttonNormalPixel      = [Utility makeOnePixelUIImageWithColor:[UIColor lightGrayColor]];
        _style                  = PxpFilterButtonScrollViewStyleLandscape;
        _cachedButtons          = [NSMutableDictionary new];
        
        [self setScrollEnabled:YES];
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
        _buttonSize             = CGSizeMake(120, 26);
        _buttonMargin           = CGSizeMake(4, 4);
        _buttonList             = [NSMutableArray new];
        _userSelected           = [NSMutableArray new];
        _buttonHighlightPixel   = [Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR];
        _buttonNormalPixel      = [Utility makeOnePixelUIImageWithColor:[UIColor lightGrayColor]];
        _style                  = PxpFilterButtonScrollViewStyleLandscape;
        _cachedButtons          = [NSMutableDictionary new];
        [self setScrollEnabled:YES];
    }
    return self;
}

-(void)buildButtonsWith:(NSArray *)buttonLabels
{
    
    NSMutableDictionary * tempPool          = [NSMutableDictionary new];
    for (NSString * txt in buttonLabels) {
        if( ![_cachedButtons objectForKey:txt]){
            CustomButton* eventButton = [self buildButton:CGRectZero btnText:txt btnValue:txt];
            
            [tempPool setObject:eventButton forKey:txt];
            self.modified = YES;
        } else {
            [tempPool setObject:[_cachedButtons objectForKey:txt] forKey:txt];
        }
    }
    
    for (NSString* tagLabel in [[_cachedButtons allKeys] copy]) {
        if (![buttonLabels containsObject:tagLabel]) {
            [_cachedButtons removeObjectForKey:tagLabel];
            self.modified = YES;
        }
    }
    
    if (!self.modified) return ; // no changes ignore
    

    _cachedButtons = tempPool;
    
    // Remove all buttons if modified
    for (CustomButton * buttonObj in _buttonList) {
        [buttonObj removeFromSuperview];
    }
    [_buttonList removeAllObjects];
    
    // make a new list of buttons and sort if needed
    
    _buttonList = [NSMutableArray arrayWithArray:[_cachedButtons allValues]];
    
    
    NSUInteger colNum = 0;
    NSUInteger rowNum = 0;
    NSUInteger rowCount;

    CGFloat fw;
    CGFloat bm;
    if (self.style ==PxpFilterButtonScrollViewStyleLandscape){
        fw = self.frame.size.height;
        bm = _buttonSize.height+_buttonMargin.height;
    } else {
        fw = self.frame.size.width;
        bm = _buttonSize.width+_buttonMargin.width;
    }
    
    rowCount   = (NSUInteger)(((fw + bm-1)/bm)-1);// just rounding up to a whole one
    
    for (NSUInteger k = 0; k < _buttonList.count; k++ ) {
        
        CustomButton  *eventButton  = _buttonList[k];
        
        CGRect      rect            =  CGRectMake(colNum * (_buttonSize.width+_buttonMargin.width),
                                                  rowNum * (_buttonSize.height+_buttonMargin.height),
                                                  _buttonSize.width, _buttonSize.height);
        [eventButton setFrame:rect];
        
        
        if (self.style ==PxpFilterButtonScrollViewStyleLandscape){
            if (++rowNum >=rowCount){
                rowNum = 0;
                colNum++;
            }
        } else {
            if (++colNum >=rowCount){
                colNum = 0;
                rowNum++;

            }
        }
        
        [self addSubview:eventButton];
    }

    
    if (self.style ==PxpFilterButtonScrollViewStyleLandscape){
        [self setContentSize:CGSizeMake((colNum+1)*_buttonSize.width, self.frame.size.height)];
    } else {
        [self setContentSize:CGSizeMake(self.frame.size.width, (rowNum+1)*_buttonSize.height)];
    }
    
    
    

    // this builds the predicates for the buttons
    NSMutableArray  * toCombo  = [[NSMutableArray alloc]init];
    for (CustomButton  *b in _buttonList) {
        if(b.selected == YES){
            
            NSString * theKey = (b.accessibilityValue)?b.accessibilityValue:b.titleLabel.text;
            [toCombo addObject:[NSPredicate predicateWithFormat:@"%K == %@",_sortByPropertyKey, theKey]];
        }
    }

       if (!self.filterModuleDelegate) _predicate           = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];
    
    self.modified = NO;

}

/**
 *  This creates the button structure (maybe the button should have its own class)
 *
 *  @param frame  buttons Position and size
 *  @param btnTxt the text that will be visible on the button
 *  @param btnValue accessibilityLabel
 *
 *  @return produced button
 */
-(CustomButton *)buildButton:(CGRect)frame btnText:(NSString*)btnTxt btnValue:(NSString*)btnValue
{
    CustomButton  *eventButton  = [CustomButton  buttonWithType:UIButtonTypeCustom];
    [eventButton setFrame:frame];
    [eventButton setBackgroundImage:_buttonNormalPixel forState:UIControlStateNormal];
    [eventButton setBackgroundImage:_buttonHighlightPixel forState:UIControlStateSelected];
    [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    [eventButton setTitle:btnTxt forState:UIControlStateNormal];
    [eventButton setAccessibilityValue:btnValue];
    [eventButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [eventButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    eventButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    eventButton.selected        = [_userSelected containsObject:btnTxt];
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
            [_userSelected addObject:b];
        } else {
            [_userSelected removeObject:b];
        }
    }
    
    if (self.filterModuleDelegate) {
        [self.filterModuleDelegate onUserInput:self];
    } else {
        _predicate           = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];
    }
    
    

    [_parentFilter refresh];
    
    self.modified = YES;
}



-(void)deselect
{
    for (CustomButton  *b in _buttonList) {
        b.selected = NO;
  
    }
    selectedCount = 0;
    [_userSelected removeAllObjects];
    self.modified = NO;
}



// Protocol methods
-(void)filterTags:(NSMutableArray *)tagsToFilter
{
    if (selectedCount == 0 || (selectedCount && _displayAllTagIfAllFilterOn)) return; // all or none are selected || selectedCount == [_buttonList count]
    [tagsToFilter filterUsingPredicate:_predicate];
}

-(void)reset{
    [self deselect];
}


@end
