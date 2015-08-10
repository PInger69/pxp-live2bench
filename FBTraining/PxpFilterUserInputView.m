//
//  PxpFilterUserInputView.m
//  Live2BenchNative
//
//  Created by Colin on 2015-08-07.
//  Copyright © 2015 DEV. All rights reserved.
//

#import "PxpFilterUserInputView.h"
#import "PxpFilterUserInputScrollView.h"

@implementation PxpFilterUserInputView{
    UITextField *inputField;
    UIButton *addButton;
    PxpFilterUserInputScrollView *scrollView;
    NSPredicate *combo;
    CGSize scrollViewMargin;
    CGSize scrollViewSize;
}

- (void) initUIInfo{
    
    NSInteger width = self.frame.size.width;
    NSInteger height = self.frame.size.height;
    NSInteger marginX = 10;
    NSInteger marginY = 10;
    NSInteger topSize = 20;
    
    scrollViewSize = CGSizeMake(width-marginX*2, height/4*3);
    scrollViewMargin = CGSizeMake(marginX, marginY*2 + topSize);
    _addButtonSize = CGSizeMake(topSize,topSize);
    _addButtonMargin = CGSizeMake (width - marginX*4, marginY);
    _textFieldSize = CGSizeMake(width - marginX*6 , topSize);
    _textFieldMargin = CGSizeMake(marginX,marginY);
}
- (void)initUserInputArea{
    inputField = [[UITextField alloc]initWithFrame:CGRectMake(_textFieldMargin.width, _textFieldMargin.height, _textFieldSize.width, _textFieldSize.height)];
    
    inputField.backgroundColor = [UIColor whiteColor];
    [inputField setBorderStyle:UITextBorderStyleLine];
    [inputField setTextColor:[UIColor blackColor]];
    
    [self addSubview:inputField];
    
    addButton = [[UIButton alloc]initWithFrame:CGRectMake(_addButtonMargin.width, _addButtonMargin.height, _addButtonSize.width, _addButtonSize.height)];
    
    addButton.backgroundColor = [UIColor greenColor];
    
    [addButton setTitle:@"+" forState:UIControlStateNormal];
    [addButton setTitle:@"+" forState:UIControlStateHighlighted];
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    
    [self addSubview:addButton];
    
    [addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) initView{
    [self initUserInputArea];
    scrollView = [[PxpFilterUserInputScrollView alloc]initWithFrame:CGRectMake(scrollViewMargin.width, scrollViewMargin.height, scrollViewSize.width, scrollViewSize.height)];
    scrollView.parentView = self;
    [self addSubview: scrollView];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initUIInfo];
    }
    return self;
}

-(void)loadView{
    [self initView];
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
    }
    return self;
}



-(BOOL)checkContent:(NSString*)content{ //check whether the content is legal
    if(!content||[content isEqualToString:@""])return NO;                                    //need to complete
    return YES;
}

-(NSPredicate*)getPredicate{
    return [NSPredicate predicateWithFormat:@"%K == %@", @"name", inputField.text];
}

-(void)addButtonPressed:(id)sender{
    
    if([self checkContent:inputField.text]){
        [scrollView addNewOption:inputField.text withPredicate:[self getPredicate]];
    }else{
        // need to complete
    }
}

-(void)updateCombo{
    combo = scrollView.combo;
    [_parentFilter refresh];
}


// Protocol methods
-(void)filterTags:(NSMutableArray *)tagsToFilter
{
    if(combo)
        [tagsToFilter filterUsingPredicate:combo];
}

-(void)reset{
    [scrollView reset];
}

@end
