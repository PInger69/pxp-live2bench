//
//  PxpFilterUserInputScrollView.h
//  Live2BenchNative
//
//  Created by andrei on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PxpFilter.h"
#import "PxpFilterUserInputView.h"

@interface PxpFilterUserInputScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic,strong) NSString           * sortByPropertyKey;
@property (assign,nonatomic) CGSize             buttonSize; // used only during populate method
@property (assign,nonatomic) CGSize             buttonMargin; // used only during populate method
@property (assign,nonatomic) CGSize             deleteButtonSize; // used only during populate method
@property (assign,nonatomic) CGSize             deleteButtonMargin; // used only during populate method

@property (nonatomic,strong) NSPredicate *combo;

@property (nonatomic,weak) PxpFilterUserInputView *parentView;

-(BOOL)addNewOption:(NSString*)title withPredicate:(NSPredicate*)Predicate;

-(void)reset;

@end
