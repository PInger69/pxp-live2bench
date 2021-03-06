//
//  PxpFilterButtonView.m
//  Live2BenchNative
//
//  Created by andrei on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterButtonView.h"
#import "CustomButton.h"
#import "PxpFilterToggleButton.h"

@implementation PxpFilterButtonView
{
    NSInteger   _selectedCount;
    NSPredicate * _combo;
    NSMutableSet * _userSelected;
    NSMutableArray * _buttonPredicate;
    NSMutableArray *_buttonPool;
}

@synthesize modified = _modified;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _buttonSize      = CGSizeMake(120, 25);
        _buttonMargin    = CGSizeMake(3, 3);
        _buttonList      = [NSMutableArray new];
        _buttonPool      = [NSMutableArray new];
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
        _buttonPool      = [NSMutableArray new];
        _userSelected    = [NSMutableSet new];
    }
    return self;
}

-(void)addButtonToPool:(NSDictionary *)dict{    // add a button to buttonPool
    [_buttonPool addObject:dict];
}

-(void)buildButtons{    // build buttons with buttonPool
    [self buildButtonsWith:_buttonPool];
}

-(void)grabButton{
    [_buttonList removeAllObjects];
    for (NSObject *subView in self.subviews) {
        if ([subView isKindOfClass:[PxpFilterToggleButton class]]) {
            [_buttonList addObject:subView];
        }
    }
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
 *  @param Predicate a predicate
 *
 *  @return produced button
 */

-(CustomButton *)buildButton:(CGRect)frame btnText:(NSString*)btnTxt predicate:(NSPredicate*)Predicate
{
    CustomButton  *eventButton = [CustomButton  buttonWithType:UIButtonTypeCustom];
    [eventButton setFrame:frame];
    [eventButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:SECONDARY_APP_COLOR] forState:UIControlStateNormal];
    [eventButton setBackgroundImage:[Utility makeOnePixelUIImageWithColor:PRIMARY_APP_COLOR] forState:UIControlStateSelected];
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
    _selectedCount              = 0;
    button.selected            = !button.selected;
    
    for (NSDictionary *dict in _buttonList) {
        CustomButton  *b = dict[@"Object"];
        if(b.selected == YES){
            _selectedCount++;
            [toCombo addObject:dict[@"Predicate"]];
            [_userSelected addObject:b.titleLabel.text];
        } else {
            [_userSelected removeObject:b.titleLabel.text];
        }
    }
    
    _combo = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];
    [_parentFilter refresh];
}

-(void)deselect
{
    for (NSDictionary *dict in _buttonList) {
        CustomButton  *b = dict[@"Object"];
        b.selected = NO;
    }
    _selectedCount = 0;
    [_userSelected removeAllObjects];
}



// Protocol methods
-(void)filterTags:(NSMutableArray *)tagsToFilter
{
    if (_selectedCount == 0 || _selectedCount == [_buttonList count]) return; // all or none are selected
    [tagsToFilter filterUsingPredicate:_combo];
}

-(void)reset{
    [self deselect];
}


@end
