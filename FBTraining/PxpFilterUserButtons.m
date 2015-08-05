//
//  PxpFilterUserButtons.m
//  Live2BenchNative
//
//  Created by dev on 2015-08-05.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterUserButtons.h"
#import "UserColorButton.h"


#define USER_BUTTON_HEIGHT              40
#define ROWS_IN_EVENTS                  6
#define PADDING                         3


@implementation PxpFilterUserButtons
{
    NSInteger           _selectedCount;
    NSMutableArray      * _buttonList;
    NSMutableSet        * _userSelected;
    NSPredicate         * _combo;
    NSMutableDictionary * _userToColor;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttonList      = [NSMutableArray new];
        _userSelected    = [NSMutableSet new];
        _userToColor     = [NSMutableDictionary new];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _buttonList      = [NSMutableArray new];
        _userSelected    = [NSMutableSet new];
        _userToColor     = [NSMutableDictionary new];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}




// this takes in an array of dicts  @[@{@"user":<String>,@"color":<UIColor>},@{@"user":<String>,@"color":<UIColor>}]

-(void)buildButtonsWith:(NSArray*)data
{
    //remove any previous buttons
    for (CustomButton * buttonObj in _buttonList) {
        [buttonObj removeFromSuperview];
    }
    [_buttonList removeAllObjects];
    [_userToColor removeAllObjects];
    
    
    for (NSInteger i=0; i<data.count; i++) {
        NSDictionary    * userInfo = data[i];
        NSString        * user      = userInfo[@"user"];
        UIColor         * uColor    = userInfo[@"color"];
        float           bWidth      = (self.frame.size.width - (PADDING *data.count)) /data.count;
        
        [_userToColor setObject:uColor forKey:user];// this saves the data for retreival
        
        CustomButton  *eventButton = [self buildButton:CGRectMake(i*(bWidth+PADDING), 0, bWidth, self.frame.size.height) btnColor:uColor accessibilityLabel:user];
        [self addSubview:eventButton];
    }
    
    
    
    // rebuild filter
    NSMutableArray  * toCombo  = [[NSMutableArray alloc]init];
    for (CustomButton  *b in _buttonList) {
        if(b.selected == YES){
            _selectedCount++;
            [toCombo addObject:[NSPredicate predicateWithFormat:@"%K == %@",@"user", b.accessibilityLabel]];
        }
    }
    _combo           = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];
    
    
    
}


-(CustomButton *)buildButton:(CGRect)frame btnColor:(UIColor*)btnColor accessibilityLabel:(NSString*)aLabel
{
    CustomButton  *eventButton = [[UserColorButton alloc]initWithFrame:frame btnColor:btnColor accessibilityLabel:aLabel];
    [eventButton addTarget:self action:@selector(cellSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:eventButton];
    [_buttonList addObject:eventButton];
    return eventButton;
}


// This calls a selector and tells the next object to update
-(void)cellSelected:(id)sender
{
    CustomButton  *button = (CustomButton *)sender;
    BOOL isButtonSelected = button.isSelected ? FALSE : TRUE;
    [button setSelected:isButtonSelected];
    
    if(button.isSelected){
        [_userSelected addObject:button.titleLabel.text];
    } else {
        [_userSelected removeObject:button.titleLabel.text];
    }
    
    // rebuild filter
    NSMutableArray  * toCombo  = [[NSMutableArray alloc]init];
    for (CustomButton  *b in _buttonList) {
        if(b.selected == YES){
            _selectedCount++;
            [toCombo addObject:[NSPredicate predicateWithFormat:@"user == %@", b.titleLabel.text]];
        }
    }
    _combo           = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];
    
    
    
}









-(void)reset
{}



-(void)deselect
{
    for (CustomButton  *b in _buttonList) {
        b.selected = NO;
        [b setAlpha:0.1f];
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




@end
