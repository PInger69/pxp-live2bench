//
//  PxpFilterButtonGroupController.m
//  Live2BenchNative
//
//  Created by dev on 2015-08-13.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterButtonGroupController.h"
#import "PxpFilterButton.h"

@implementation PxpFilterButtonGroupController {

    NSMutableArray  * _buttons;
    NSPredicate     * _combo;
    NSMutableSet    * _userSelected;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _buttons        = [NSMutableArray new];
        _userSelected   = [NSMutableSet new];
    }
    return self;
}

-(void)addButtonToGroup:(PxpFilterButton*)button
{
    button.ownDelegate = self;
    [_buttons addObject:button];
}


#pragma mark - PxpFilterModuleProtocol Methods

-(void)reset{          //reset the slider
    for (UIButton  *b in _buttons) {
        b.selected = NO;
    }
    [_userSelected removeAllObjects];
}

-(void)filterTags:(NSMutableArray*)tagsToFilter{
    if ([_userSelected count] == 0 || [_userSelected count] == [_buttons count]) return; // all or none are selected
    [tagsToFilter filterUsingPredicate:_combo];
}

#pragma mark - PxpFilterButtonGroupControllerDelegate Methods
-(void)onButtonSelected:(UIButton*)button
{

    NSMutableArray  * toCombo  = [[NSMutableArray alloc]init];
    button.selected            = !button.selected;
    
    for (PxpFilterButton * b in _buttons) {
        if(b.selected == YES){
              [toCombo addObject:b.ownPredicate];
            [_userSelected addObject:b];
        } else {
            [_userSelected removeObject:b];
        }
    }
    
    _combo           = [NSCompoundPredicate orPredicateWithSubpredicates:toCombo];
    [_parentFilter refresh];
}

@end
