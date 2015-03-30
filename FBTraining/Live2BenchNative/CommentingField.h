//
//  CommentingField.h
//  QuickTest
//
//  Created by dev on 6/13/2014.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderButton.h"
//#import <QuartzCore/QuartzCore.h>

@interface CommentingField : UIView
{
    UILabel         * fieldTitle;
    UITextView      * textField;
    BorderButton    * saveButton;
    BorderButton    * clearButton;
    UILabel         * saveMessage;
    BOOL            enabled;
}


@property (nonatomic,strong)    UILabel *fieldTitle;
@property (nonatomic,strong)    UITextView *textField;
@property (nonatomic,strong) 	BorderButton *saveButton;
@property (nonatomic,strong) 	BorderButton *clearButton;
@property (nonatomic,strong)    UILabel *saveMessage;
@property (nonatomic,strong)    NSString * title;
@property (nonatomic,assign)    BOOL enabled;

@property (nonatomic, strong)   NSString *context;

-(id)initWithFrame:(CGRect)frame title:(NSString *)title;

-(void)onPressClearPerformSelector:(SEL)sel addTarget:(id)target;
-(void)onPressSavePerformSelector:(SEL)sel addTarget:(id)target;

-(void)setText:(NSString*)txt;
-(NSString*)text;

-(void)clear;


@end
