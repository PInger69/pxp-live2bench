//
//  PxpFilterUserInputView.h
//  Live2BenchNative
//
//  Created by andrei on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"

@interface PxpFilterUserInputView : UIView<PxpFilterModuleProtocol>


@property (assign,nonatomic) CGSize             addButtonSize; // used only during populate method
@property (assign,nonatomic) CGSize             addButtonMargin; // used only during populate method
@property (assign,nonatomic) CGSize             textFieldSize; // used only during populate method
@property (assign,nonatomic) CGSize             textFieldMargin; // used only during populate method

-(void)updateCombo;

-(void)loadView;

// Protocol
@property (nonatomic,weak) PxpFilter * parentFilter;

// Protocol
-(void)filterTags:(NSMutableArray *)tagsToFilter;

-(void)reset;

@end
