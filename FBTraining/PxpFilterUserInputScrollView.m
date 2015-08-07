//
//  PxpFilterUserInputScrollView.m
//  Live2BenchNative
//
//  Created by andrei on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterUserInputScrollView.h"
#import "CustomButton.h"

@implementation PxpFilterUserInputScrollView
{
    NSInteger   selectedCount;
    NSMutableSet * userSelected;
    NSMutableArray     * filterOptionList;
}





- (void)initUIInfo{
    NSInteger width = self.frame.size.width;
    NSInteger marginX = 5;
    NSInteger marginY = 5;
    NSInteger size = 20;
    
    _buttonSize      = CGSizeMake(width, size);
    _buttonMargin    = CGSizeMake(marginX, marginY);
    _deleteButtonSize      = CGSizeMake(size, size);
    _deleteButtonMargin    = CGSizeMake(width - size, marginY);
    
    filterOptionList      = [NSMutableArray new];
    userSelected    = [NSMutableSet new];
}

- (void)initView{
    
}
         
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initUIInfo];
        [self initView];
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
        [self initUIInfo];
        [self initView];
        [self setScrollEnabled:YES];
    }
    return self;
}

-(CGRect)getDeleteButtonRect:(NSInteger)rowNum{
    return CGRectMake(_deleteButtonMargin.width, (_deleteButtonMargin.height + _deleteButtonSize.height) * rowNum, _deleteButtonSize.width, _deleteButtonSize.height);
}

-(CGRect)getMainButtonRect:(NSInteger)rowNum{
    return CGRectMake(_buttonMargin.width, (_buttonMargin.height + _buttonSize.height) * rowNum, _buttonSize.width, _buttonSize.height);
}

-(void)rearrangeButtons{
    NSInteger rowNum = filterOptionList.count;
    for(NSInteger i = 0; i < rowNum; i++){
        NSDictionary *dict = filterOptionList[i];
        CustomButton *eventButton = dict[@"MainButton"];
        UIButton *deleteButton = dict[@"DeleteButton"];
        eventButton.frame = [self getMainButtonRect:i];
        deleteButton.frame = [self getDeleteButtonRect:i];
    }
    [self setContentSize:CGSizeMake(self.frame.size.width, (rowNum)*(_buttonMargin.height+_buttonSize.height))];
}

-(BOOL)addNewOption:(NSString*)title withPredicate:(NSPredicate*)Predicate{
    
    for(int i = 0; i<filterOptionList.count;i++){
        NSDictionary *dict = filterOptionList[i];
        CustomButton *eventButton = dict[@"MainButton"];
        if([eventButton.titleLabel.text isEqualToString:title])return NO;
    }
    
    NSInteger rowNum = filterOptionList.count;
    
    CustomButton *eventButton = [self buildButton:[self getMainButtonRect:rowNum] btnText:title];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:[self getDeleteButtonRect:rowNum]];
    
    [deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [deleteButton setTitle:@"X" forState:UIControlStateNormal];
    [deleteButton setTitle:@"X" forState:UIControlStateHighlighted];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [deleteButton setBackgroundColor:[UIColor redColor]];
    
    [self addSubview:eventButton];
    [self addSubview:deleteButton];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: eventButton, @"MainButton", Predicate, @"Predicate", deleteButton, @"DeleteButton", nil];
    
    [filterOptionList addObject:dict];
    [self rearrangeButtons];
    
    return YES;
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
    [eventButton setTitle:btnTxt forState:UIControlStateHighlighted];
    [eventButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    eventButton.titleLabel.font=[UIFont systemFontOfSize:14.0f];
    eventButton.selected = [userSelected containsObject:btnTxt];
    return eventButton;
}

-(void)removeOption:(NSDictionary*)dict{
    //need to complete
    CustomButton *eventButton = dict[@"MainButton"];
    [userSelected removeObject:eventButton.titleLabel.text];
    [dict[@"MainButton"] removeFromSuperview];
    [dict[@"DeleteButton"] removeFromSuperview];
    [filterOptionList removeObject:dict];
    //NSInteger rowNum = filterOptionList.count;
    [self rearrangeButtons];
}

-(void)deleteButtonPressed:(id)sender{
    NSDictionary *target = nil;
    for(NSDictionary *dict in filterOptionList){
        if(dict[@"DeleteButton"] == (UIButton *)sender){
            target = dict;
            break;
        }
    }
    if(target)[self removeOption:target];
}


// This calls a selector and tells the next object to update
-(void)cellSelected:(id)sender
{
    
    CustomButton    * button   = (CustomButton *)sender;
    NSMutableArray  * toCombo  = [[NSMutableArray alloc]init];
    selectedCount              = 0;
    button.selected            = !button.selected;
    
    for (NSDictionary *dict in filterOptionList) {
        CustomButton *b = dict[@"MainButton"];
        if(b.selected == YES){
            selectedCount++;
            [toCombo addObject:dict[@"Predicate"]];
            [userSelected addObject:b.titleLabel.text];
        } else {
            [userSelected removeObject:b.titleLabel.text];
        }
    }
    
    _combo = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];
    if(selectedCount == 0) _combo = nil;
    [_parentView updateCombo];
}

-(void)deselect
{
    for (NSDictionary *dict in filterOptionList) {
        CustomButton *b = dict[@"MainButton"];
        b.selected = NO;
    }
    selectedCount = 0;
    [userSelected removeAllObjects];
}



-(void)reset{
    [self deselect];
}

@end
