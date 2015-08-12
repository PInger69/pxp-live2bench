//
//  PxpFilterButtonView.m
//  Live2BenchNative
//
//  Created by andrei on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterButtonView.h"
#import "CustomButton.h"

@implementation PxpFilterButtonView
{
    NSInteger   selectedCount;
    NSPredicate * combo;
    NSMutableSet * _userSelected;
    NSMutableArray * buttonPredicate;
    NSMutableArray *buttonPool;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _buttonSize      = CGSizeMake(120, 25);
        _buttonMargin    = CGSizeMake(3, 3);
        _buttonList      = [NSMutableArray new];
        buttonPool      = [NSMutableArray new];
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
        buttonPool      = [NSMutableArray new];
        _userSelected    = [NSMutableSet new];
    }
    return self;
}

-(void)addButtonToPool:(NSDictionary *)dict{    // add a button to buttonPool
    [buttonPool addObject:dict];
}

-(void)buildButtons{    // build buttons with buttonPool
    [self buildButtonsWith:buttonPool];
}

-(void)buildButtonsWith:(NSArray *)buttons  // build buttons with the buttons array
{
    
    for (NSDictionary* dict in _buttonList) {
        CustomButton * buttonObj = dict[@"Object"];
        [buttonObj removeFromSuperview];
    }
    [_buttonList removeAllObjects];
    
    NSDictionary *defaultSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"None", @"Label",
                                    [NSNumber numberWithInteger:_buttonSize.width], @"Width",
                                    [NSNumber numberWithInteger:_buttonSize.height], @"Height",
                                    [NSNumber numberWithInteger:0], @"PositionX",
                                    [NSNumber numberWithInteger:0], @"PositionY",
                                    nil];
    
    for(NSUInteger k = 0; k < buttons.count; k++ ) {
        
        NSDictionary *dict = [buttons objectAtIndex:k];
        NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
        
        // Apply default setting if there is no such key in the dictionary
        
        for(id key in defaultSetting){
            if(dict[key])
                finalDict[key] = dict[key];
            else
                finalDict[key] = defaultSetting[key];
        }
        
        NSInteger Width = [[finalDict objectForKey:@"Width"] integerValue];
        NSInteger Height = [[finalDict objectForKey:@"Height"] integerValue];
        NSInteger PositionX = [[finalDict objectForKey:@"PositionX"] integerValue];
        NSInteger PositionY = [[finalDict objectForKey:@"PositionY"] integerValue];
        
        NSString *Label = [finalDict objectForKey:@"Label"];
        
        // Initialize predicate for the button
        
        NSPredicate *Predicate;
        if(dict[@"Predicate"])
            Predicate = dict[@"Predicate"];
        else
            Predicate = [NSPredicate predicateWithFormat:@"%K == %@",_sortByPropertyKey, Label];
        
        CGRect rect = CGRectMake(PositionX, PositionY, Width, Height);
        
        CustomButton  *eventButton = [self buildButton:rect btnText:Label predicate:Predicate];
        
        [self addSubview:eventButton];
    }
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

-(CustomButton *)buildButton:(CGRect)frame btnText:(NSString*)btnTxt predicate:(NSPredicate*)Predicate
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
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:eventButton, @"Object", Predicate, @"Predicate",  nil];
    [_buttonList addObject:dict];
    return eventButton;
}



// This calls a selector and tells the next object to update
-(void)cellSelected:(id)sender
{
    
    CustomButton    * button   = (CustomButton *)sender;
    NSMutableArray  * toCombo  = [[NSMutableArray alloc]init];
    selectedCount              = 0;
    button.selected            = !button.selected;
    
    for (NSDictionary *dict in _buttonList) {
        CustomButton  *b = dict[@"Object"];
        if(b.selected == YES){
            selectedCount++;
            [toCombo addObject:dict[@"Predicate"]];
            [_userSelected addObject:b.titleLabel.text];
        } else {
            [_userSelected removeObject:b.titleLabel.text];
        }
    }
    
    combo = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];
    [_parentFilter refresh];
}

-(void)deselect
{
    for (NSDictionary *dict in _buttonList) {
        CustomButton  *b = dict[@"Object"];
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

-(void)reset{
    [self deselect];
}


@end